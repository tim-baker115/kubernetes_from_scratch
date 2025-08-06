# Kubernetes installation

These next steps delve into the kubernetes install, again it will cover problems and solutions and gotchas along the way. I'll be relying on the following guide [install-kubectl-linux](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/).
It's worth noting at this point; this is not a complete kubernetes install, we have a single server and it's not expected to be clustered at this point. 

## Initial problems/solutions:

### Install problems
| Problem    | Solution |
| --------- | ------- |
| Packages not available by default | Add the correct repo. |
| No GPG key| `curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key \| sudo gpg --dearmor -o /usr/share/keyrings/kubernetes-apt-keyring.gpg`|
| No repo| Add this file in [/etc/apt/sources.list.d/kubernetes.list](configs/kubernetes.list) |
| Install missing packages| `apt-get update; apt-get install -y kubelet kubeadm kubectl`|
