#!/bin/bash

NS="audit-zone"

echo "=== Проверка admission в namespace $NS ==="
expect_fail() {
    if kubectl apply -f "$1" 2>&1 | grep -qE "Error|forbidden|denied|violates"; then
        echo "[OK] $1 отклонён"
    else
        echo "[FAIL] $1 не отклонён"
    fi
}

expect_success() {
    if kubectl apply -f "$1" 2>&1 | grep -qE "created|unchanged|configured"; then
        echo "[OK] $1 успешно применён"
    else
        echo "[FAIL] $1 не применён"
    fi
}

echo "--- Небезопасные манифесты (должны быть заблокированы) ---"
expect_fail ../insecure-manifests/01-priveleged-pod.yaml
expect_fail ../insecure-manifests/02-hostpath-pod.yaml
expect_fail ../insecure-manifests/03-root-user-pod.yaml

echo ""
echo "--- Исправленные манифесты (должны быть приняты) ---"
expect_success ../secure-manifests/01-secure.yaml
expect_success ../secure-manifests/02-secure.yaml
expect_success ../secure-manifests/03-secure.yaml

echo "Готово."
