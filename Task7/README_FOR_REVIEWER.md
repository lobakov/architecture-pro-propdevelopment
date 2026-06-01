# Инструкция по проверке.


## I. Подготовка кластера

NB: Я запускаю все под Windows 10 с докер десктоп и minikube.

- Запустить кластер с нужными драйверами, у меня `$ minikube start --driver=docker --cni=calico` 
- Убедиться, что находитесь в директории `architecture-pro-propdevelopment/Task7`
- Скопировать audit-policy в кластер: 
    `$ minikube cp audit-policy.yaml minikube:/etc/kubernetes/audit-policy.yaml`
- Подготовить директорию для логов, последовательно выполнив:
    - `$ minikube ssh -- sudo mkdir -p /var/log/kubernetes`
    - `$ minikube ssh -- sudo chmod 755 /var/log/kubernetes`
- Скопировать настройки аписервера (добавляем вольюм с audit-policy):
    `$ minikube cp 02-kube-apiserver.yaml minikube:/etc/kubernetes/manifests/kube-apiserver.yaml`
- Перезапустить кублет для применения настроек (возможно не обязательно, но лучше ребутнуть)
    `$ minikube ssh -- sudo systemctl restart kubelet`
- Подождать немного, затем убедиться что kube-apiserver в состоянии Running:
    `$ minikube ssh -- sudo crictl ps -a | grep kube-apiserver`
- Установить gatekeeper:
    `kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/v3.13.0/deploy/gatekeeper.yaml`
- Подождать немного, убедиться, что все поды gatekeeper в состоянии Running:
    `$ kubectl get pods -n gatekeeper-system`

## II. Подготовка окружения

- Применить темплейты для гейткипера: `$ kubectl apply -f gatekeeper/constraint-templates/`
- Применить констрейнты для гейткипера: `$ kubectl apply -f gatekeeper/constraints/`

## III. Проверка admission и security

- Перейти в директорию verify: `$ cd verify/`
- Запустить проверку admission: `$ ./verify-admission.sh`
- Запустить проверку security: `$ ./validate-security.sh`
