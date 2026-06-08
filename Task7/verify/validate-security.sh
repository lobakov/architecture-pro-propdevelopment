#!/bin/bash

NS="audit-zone"

echo "1. Проверка security в namespace $NS"

LABEL=$(kubectl get ns $NS -o jsonpath='{.metadata.labels.pod-security\.kubernetes\.io/enforce}')
if [ "$LABEL" == "restricted" ]; then
    echo "[OK] $LABEL"
else
    echo "[FAIL] $LABEL"
fi

echo ""
echo "2. Проверка Gatekeeper"
for constraint in K8sPrivilegedContainer K8sContainerLimits K8sNoHostPath; do
    COUNT=$(kubectl get $constraint --no-headers 2>/dev/null | wc -l)
    if [ "$COUNT" -gt 0 ]; then
        echo "[OK] $constraint"
    else
        echo "[FAIL] $constraint"
    fi
done

echo ""
echo "3. Проверка, что небезопасные манифесты отклоняются"
for f in ../insecure-manifests/01-priveleged-pod.yaml ../insecure-manifests/02-hostpath-pod.yaml ../insecure-manifests/03-root-user-pod.yaml; do
    if kubectl apply -f "$f" --dry-run=server -o yaml 2>&1 | grep -q "violates\|forbidden"; then
        echo "[OK] $f"
    else
        echo "[FAIL] $f"
    fi
done

echo ""
echo "4. Проверка, что исправленные манифесты проходят"
for f in ../secure-manifests/01-secure.yaml ../secure-manifests/02-secure.yaml ../secure-manifests/03-secure.yaml; do
    if kubectl apply -f "$f" --dry-run=server -o yaml 2>&1 | grep -q "kind: Pod"; then
        echo "[OK] $f проходит dry-run"
    else
        echo "[FAIL] $f не проходит dry-run"
    fi
done

echo ""
echo "Готово."
