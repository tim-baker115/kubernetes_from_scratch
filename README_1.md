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
| Have things installed? | `for cmd in "kubeadm version" "kubelet --version" "kubectl version --client"; do $cmd \| grep -q "1.30" && echo "$cmd ran ok" \|\| echo "something went wrong with $cmd"; done`<br>`systemctl status kubelet` |

### Starting kubernetes
Assuming everything is up and running we can now initialize:
`kubeadm init`
This paused for a brief period for me and I noticed a warning: 
```
I0806 12:30:23.084037    4436 version.go:256] remote version is much newer: v1.33.3; falling back to: stable-1.30
[init] Using Kubernetes version: v1.30.14
[preflight] Running pre-flight checks
[preflight] Pulling images required for setting up a Kubernetes cluster
[preflight] This might take a minute or two, depending on the speed of your internet connection
[preflight] You can also perform this action in beforehand using 'kubeadm config images pull'
W0806 12:30:23.612342    4436 checks.go:844] detected that the sandbox image "registry.k8s.io/pause:3.8" of the container runtime is inconsistent with that used by kubeadm.It is recommended to use "registry.k8s.io/pause:3.9" as the CRI sandbox image.
```
Fixing this warning (safe to ignore).
There's a snippet on how to set the sandbox image in this url [override-pause-image-containerd](https://kubernetes.io/docs/setup/production-environment/container-runtimes/#override-pause-image-containerd).
It's pretty much the following:
```
ctr image pull registry.k8s.io/pause:3.9 #User containerd to pull the image
mkdir -p /etc/containerd #Make a folder for the default config
containerd config default \| tee /etc/containerd/config.toml #Output the current defaults to the toml file.
sed -i 's/pause:3.8/pause:3.9/1' /etc/containerd/config.toml #Search for pause:3.8 and replace it.
systemctl restart containerd #Restart containerd
systemctl restart kubelet #Restart kubelet
kubeadm reset -f #Reset the init process
kubeadm init #Init again!
```

### Running kubernetes

Run the following: `kubectl get nodes` to get the nodes. This resulted in the following error:
```
root@labbox:~$ kubectl get nodes
E0806 12:53:54.002070   15281 memcache.go:265] couldn't get current server API group list: Get "http://localhost:8080/api?timeout=32s": dial tcp 127.0.0.1:8080: connect: connection refused
E0806 12:53:54.002449   15281 memcache.go:265] couldn't get current server API group list: Get "http://localhost:8080/api?timeout=32s": dial tcp 127.0.0.1:8080: connect: connection refused
E0806 12:53:54.003805   15281 memcache.go:265] couldn't get current server API group list: Get "http://localhost:8080/api?timeout=32s": dial tcp 127.0.0.1:8080: connect: connection refused
E0806 12:53:54.004055   15281 memcache.go:265] couldn't get current server API group list: Get "http://localhost:8080/api?timeout=32s": dial tcp 127.0.0.1:8080: connect: connection refused
E0806 12:53:54.005390   15281 memcache.go:265] couldn't get current server API group list: Get "http://localhost:8080/api?timeout=32s": dial tcp 127.0.0.1:8080: connect: connection refused
The connection to the server localhost:8080 was refused - did you specify the right host or port?
```
This looks to be a problem with how kubectl is falled. This is quite a common problem and can be solved following the instructions in [this post](https://discuss.kubernetes.io/t/couldnt-get-current-server-api-group-list-get-http-localhost-8080-api-timeout-32s-dial-tcp-127-0-0-1-connect-connection-refused/25471/5).

```
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
export KUBECONFIG=$HOME/.kube/config
```
Now the same command reveals something slightly more interesting!!
```
root@labbox:~$ kubectl get nodes
NAME     STATUS     ROLES           AGE   VERSION
labbox   NotReady   control-plane   14m   v1.30.14
```
