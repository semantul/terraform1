[k8s]
k8s-master	ansible_host=${master}
k8s-worker1	ansible_host=${worker}

[k8s:vars]
ansible_ssh_user=ubuntu
