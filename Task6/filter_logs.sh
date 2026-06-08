#!/bin/bash

INPUT="${1:-audit.log}"
OUTPUT="${2:-audit-exctract.json}"

echo "====== get/list/watch secrets" >> "$OUTPUT"
jq -r 'select(.objectRef.resource == "secrets")
  | "\(.requestReceivedTimestamp) user=\(.user.username) verb=\(.verb) secret=\(.objectRef.namespace)/\(.objectRef.name) sourceIP=\(.sourceIPs[0])"' \
  "$INPUT" >> "$OUTPUT"
echo  >> "$OUTPUT"
echo  >> "$OUTPUT"

echo "====== create/update/delete rolebindings, clusterrolebindings, clusterroles" >> "$OUTPUT"
jq -r 'select(.objectRef.resource == "rolebindings" or .objectRef.resource == "clusterrolebindings" or .objectRef.resource == "clusterroles")
  | select(.verb == "create" or .verb == "update" or .verb == "delete")
  | "\(.requestReceivedTimestamp) user=\(.user.username) verb=\(.verb) resource=\(.objectRef.resource) name=\(.objectRef.namespace)/\(.objectRef.name)"' \
  "$INPUT" >> "$OUTPUT"
echo  >> "$OUTPUT"
echo  >> "$OUTPUT"

echo "====== delete/patch/update kube-system, nodes, clusterroles, clusterrolebindings" >> "$OUTPUT"
jq -r 'select(.verb == "delete" or .verb == "patch" or .verb == "update")
  | select(.objectRef.namespace == "kube-system" or .objectRef.resource == "nodes" or .objectRef.resource == "clusterroles" or .objectRef.resource == "clusterrolebindings")
  | "\(.requestReceivedTimestamp) user=\(.user.username) verb=\(.verb) resource=\(.objectRef.resource) namespace=\(.objectRef.namespace) name=\(.objectRef.name)"' \
  "$INPUT" >> "$OUTPUT"
echo  >> "$OUTPUT"
echo  >> "$OUTPUT"

echo "====== exec/create/delete/update" >> "$OUTPUT"
jq -r 'select(.objectRef.resource == "pods")
  | select(.verb != "list" and .verb != "watch" and .verb != "get")
  | "\(.requestReceivedTimestamp) user=\(.user.username) verb=\(.verb) pod=\(.objectRef.namespace)/\(.objectRef.name) sourceIP=\(.sourceIPs[0])"' \
  "$INPUT" >> "$OUTPUT"
echo  >> "$OUTPUT"
echo  >> "$OUTPUT"

echo "====== privileged pods" >> "$OUTPUT"
jq -r 'select(.objectRef.resource == "pods" and .verb == "create")
  | "\(.requestReceivedTimestamp) user=\(.user.username) CREATE pod=\(.objectRef.namespace)/\(.objectRef.name)"' \
  "$INPUT" >> "$OUTPUT"
echo  >> "$OUTPUT"
echo  >> "$OUTPUT"

echo "Готово" >> "$OUTPUT"