# Networking
## Installing cilium
Cilium is a *"framework for synamically managing networking"* (CNI - container network interface) which simplifies and controls communication between pods in a dynamic way. It manages layers 3, 4 (and 7) of the networking stack and includes a set of three sidecars per node, it uses eBPF to do this (eBPF is a kernel feature which allows seperation of environments), more on that here:[what is ebpf?](https://ebpf.io/what-is-ebpf/). They have an [install script](https://docs.cilium.io/en/stable/gettingstarted/k8s-install-default/#install-the-cilium-cli) which I've also pasted below:

```
CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)
CLI_ARCH=amd64
if [ "$(uname -m)" = "aarch64" ]; then CLI_ARCH=arm64; fi
curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
sha256sum --check cilium-linux-${CLI_ARCH}.tar.gz.sha256sum
sudo tar xzvfC cilium-linux-${CLI_ARCH}.tar.gz /usr/local/bin
rm cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
```

At this point cilium cli is installed in `/usr/local/bin` you can update it as follows.
`/usr/local/bin/cilium install --version v1.18.0`

As cilium uses it's own proxy (envoy) you may need to redo the init to *not* have the kube-system proxy:
`kubeadm init --skip-phases=addon/kube-proxy`

Once complete the pods should (eventually) start running:
```
kubectl get pods -A | grep cilium
kube-system   cilium-cl7g6                       1/1     Running   1 (66m ago)    3h37m
kube-system   cilium-envoy-bqzdk                 1/1     Running   1 (66m ago)    3h37m
kube-system   cilium-operator-6d4546b99d-nz86g   1/1     Running   1 (66m ago)    3h37m
```
Or use the cli:
```
root@labbox:~$ cilium status --wait
    /¯¯\
 /¯¯\__/¯¯\    Cilium:             OK
 \__/¯¯\__/    Operator:           OK
 /¯¯\__/¯¯\    Envoy DaemonSet:    OK
 \__/¯¯\__/    Hubble Relay:       disabled
    \__/       ClusterMesh:        disabled

DaemonSet              cilium                   Desired: 1, Ready: 1/1, Available: 1/1
DaemonSet              cilium-envoy             Desired: 1, Ready: 1/1, Available: 1/1
Deployment             cilium-operator          Desired: 1, Ready: 1/1, Available: 1/1
Containers:            cilium                   Running: 1
                       cilium-envoy             Running: 1
                       cilium-operator          Running: 1
                       clustermesh-apiserver    
                       hubble-relay             
Cluster Pods:          2/2 managed by Cilium
Helm chart version:    1.18.0
Image versions         cilium             quay.io/cilium/cilium:v1.18.0@sha256:dfea023972d06ec183cfa3c9e7809716f85daaff042e573ef366e9ec6a0c0ab2: 1
                       cilium-envoy       quay.io/cilium/cilium-envoy:v1.34.4-1753677767-266d5a01d1d55bd1d60148f991b98dac0390d363@sha256:231b5bd9682dfc648ae97f33dcdc5225c5a526194dda08124f5eded833bf02bf: 1
                       cilium-operator    quay.io/cilium/operator-generic:v1.18.0@sha256:398378b4507b6e9db22be2f4455d8f8e509b189470061b0f813f0fabaf944f51: 1
```

### Monitoring
To monitor live traffic run the following:
`cilium monitor -v`

### Cilium sidecars
Sidecars run on a per node basis, their name role and purpose is defined below. 

| Name      | Role    | Purposes |
| --------- | ------- | --------|
| cilium | The Brain | eBPF setup for pod networking<br>Identity & label tracking<br>L3/L4 policy enforcement<br>Routing and NAT |
| operator | The networking control plane | Manages IP addressing<br>Garbage-collects identities<br>Coordinates cilium-agent behaviour|
| envoy | Layer 7 management and information | Layer 7 policies<br>HTTP/gRPC inspection<br>Hubble with L7 visibility |

### L7 monitoring
Cilium includes envoy by default, however each pod will need to have a different definition to utilise traffic scanning. 
It's worth noting that you can see if it's running and see live traffic flows as follows:

`cilium monitor --type l7 #Is l7 monitoring enabled?` 
`cilium monitor -v #Live traffic flows!` 

# Istio
Istio is a service mesh. This takes care of layer 7 connectivity (applications, things like mtls, weighted traffic) and compliments cilium to some degree; however there are different methods of running the CNI and service mesh (some of the technologies overlap). Running istio by default will add a sidecar. As I'm short of resources and want a high tech POC, I'm going to do **CNI CHAINING** (I have a vague idea what this is...).


