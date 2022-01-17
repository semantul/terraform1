#Создать и устаноить необходимые пакеты
======================
terraform apply

#Инициализировать кластер, установить сеть и Dashboard
=======================
ansible-playbook -l all -i hosts.ini k8s-init.yaml

#Создать токен и присоединить рабочий узел
=======================
ansible-playbook -l all -i hosts.ini k8s-join.yaml
