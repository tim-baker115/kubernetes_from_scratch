#!/bin/bash

echo "Checking cgroup setup on this system..."
echo "----------------------------------------"

# 1. Check cgroup version
CGROUP_VERSION=$(stat -fc %T /sys/fs/cgroup)
echo "Cgroup filesystem type: $CGROUP_VERSION"

if [[ "$CGROUP_VERSION" == "cgroup2fs" ]]; then
    echo "Detected cgroups v2"
    CGROUP_EXPECTED="systemd"
else
    echo "Detected cgroups v1"
    CGROUP_EXPECTED="cgroupfs"
fi

# 2. Check containerd config
CONTAINERD_CONFIG="/etc/containerd/config.toml"
if [[ -f "$CONTAINERD_CONFIG" ]]; then
    SYSTEMD_CGROUP=$(grep -E '^\s*SystemdCgroup' "$CONTAINERD_CONFIG" | awk -F '=' '{print $2}' | tr -d ' ')
    if [[ "$SYSTEMD_CGROUP" == "true" ]]; then
        CONTAINERD_DRIVER="systemd"
        echo "containerd is using SystemdCgroup = true"
    elif [[ "$SYSTEMD_CGROUP" == "false" ]]; then
        CONTAINERD_DRIVER="cgroupfs"
        echo "containerd is using SystemdCgroup = false"
    else
        echo "Could not clearly detect containerd SystemdCgroup setting."
        CONTAINERD_DRIVER="unknown"
    fi
else
    echo "containerd config not found at $CONTAINERD_CONFIG"
    CONTAINERD_DRIVER="missing"
fi

# 3. Check kubelet flags
KUBELET_FLAGS=$(ps aux | grep '[k]ubelet')
KUBELET_DRIVER=$(echo "$KUBELET_FLAGS" | grep -oP '(?<=--cgroup-driver=)[^\s]*')

if [[ -n "$KUBELET_DRIVER" ]]; then
    echo "kubelet is using --cgroup-driver=$KUBELET_DRIVER"
else
    echo "kubelet cgroup-driver flag not set explicitly (may default to systemd or cgroupfs)"
    KUBELET_DRIVER="unset"
fi

# 4. Summary
echo ""
echo "Summary:"
echo "  Expected driver (based on cgroup version): $CGROUP_EXPECTED"
echo "  containerd driver: $CONTAINERD_DRIVER"
echo "  kubelet driver: $KUBELET_DRIVER"

# 5. Warnings if mismatch
WARN=false

if [[ "$CONTAINERD_DRIVER" != "$CGROUP_EXPECTED" && "$CONTAINERD_DRIVER" != "missing" ]]; then
    echo "WARNING: containerd driver doesn't match expected: $CONTAINERD_DRIVER vs $CGROUP_EXPECTED"
    WARN=true
fi

if [[ "$KUBELET_DRIVER" != "$CGROUP_EXPECTED" && "$KUBELET_DRIVER" != "unset" ]]; then
    echo "WARNING: kubelet driver doesn't match expected: $KUBELET_DRIVER vs $CGROUP_EXPECTED"
    WARN=true
fi

if [[ "$WARN" = false ]]; then
    echo "All cgroup-related drivers appear consistent with system expectations."
fi
