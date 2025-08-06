#!/bin/bash
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

info() {
  echo -e "${YELLOW}[INFO]${NC} $1"
}
pass() {
  echo -e "${GREEN}[PASS]${NC} $1"
}
fail() {
  echo -e "${RED}[FAIL]${NC} $1"
}

echo "=== Kubernetes Post-Install Validation ==="

echo
# --- Netplan DHCP/static detection using netplan get ---

NETPLAN_DIR="/etc/netplan"

# Gather interfaces from all netplan files
interfaces=()
for f in "$NETPLAN_DIR"/*.yaml "$NETPLAN_DIR"/*.yml; do
  [ -f "$f" ] || continue
  # Parse ethernets keys with netplan get - fallback to manual parsing if needed
  # Here we do a rough manual parse for keys under ethernets
  ifaces_in_file=$(grep -P '^\s{4}\S+:' "$f" | sed 's/^\s*//;s/:$//' || true)
  for iface in $ifaces_in_file; do
    interfaces+=("$iface")
  done
done

# Deduplicate interfaces
interfaces=($(printf "%s\n" "${interfaces[@]}" | sort -u))

if [ ${#interfaces[@]} -eq 0 ]; then
  fail "No interfaces found in netplan config"
else
  pass "Found interfaces in netplan config: ${interfaces[*]}"
fi

# Check DHCP/static and IP assignment
for iface in "${interfaces[@]}"; do
  dhcp4=$(sudo netplan get ethernets."$iface".dhcp4 2>/dev/null || echo "unknown")

  if [ "$dhcp4" = "false" ]; then
    pass "Interface $iface has dhcp4 disabled (static IP)"

    addresses=$(sudo netplan get ethernets."$iface".addresses 2>/dev/null || echo "")
    clean_ips=$(echo "$addresses" |  sed 's#^-##; s#/.*##g' | tr -d '[]," ')

    current_ips=$(ip -4 addr show dev "$iface" 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}' || echo "")

    matched=0
    for expected_ip in $clean_ips; do
      for current_ip in $current_ips; do
        if [ "$expected_ip" = "$current_ip" ]; then
          matched=1
          break 2
        fi
      done
    done

    if [ $matched -eq 1 ]; then
      pass "Assigned IP matches configured static IP: $current_ips"
    else
      fail "Assigned IP ($current_ips) does NOT match configured static IP(s) ($clean_ips)"
    fi

  elif [ "$dhcp4" = "true" ]; then
    pass "Interface $iface is configured for DHCP"
  else
    fail "Could not determine DHCP setting for interface $iface"
  fi
done

echo

# Check Wi-Fi interfaces status
WIFI_UP=0
for iface in $(ls /sys/class/net); do
  if iw dev "$iface" info &>/dev/null; then
    state=$(cat /sys/class/net/$iface/operstate)
    if [ "$state" = "up" ]; then
      fail "Wi-Fi interface $iface is UP (should be disabled)"
      WIFI_UP=1
    else
      pass "Wi-Fi interface $iface is DOWN"
    fi
  fi
done
if [ "$WIFI_UP" -eq 0 ]; then
  pass "No active Wi-Fi interfaces detected"
fi

echo

# IPv6 disabled in grub config?
GRUB_CONF="/etc/default/grub"
if grep -q 'ipv6.disable=1' "$GRUB_CONF"; then
  pass "IPv6 disabled in grub config"
else
  fail "IPv6 not disabled in grub config"
fi

# IPv6 runtime disabled (handle missing file if kernel disabled IPv6)
if [ -f /proc/sys/net/ipv6/conf/all/disable_ipv6 ]; then
  val=$(cat /proc/sys/net/ipv6/conf/all/disable_ipv6)
  if [ "$val" = "1" ]; then
    pass "IPv6 disabled at runtime"
  else
    fail "IPv6 enabled at runtime"
  fi
else
  pass "IPv6 runtime disabled (no proc sys entry, likely kernel disabled)"
fi

echo

# Swap checks
if [ $(swapon --noheadings | wc -l) -eq 0 ]; then
  pass "Swap is off"
else
  fail "Swap is active"
fi

if grep -q '^[^#].* swap ' /etc/fstab; then
  fail "Swap entry exists and is enabled in /etc/fstab"
else
  pass "No active swap entries in /etc/fstab (swap disabled)"
fi

echo

# containerd checks
if command -v containerd >/dev/null; then
  pass "containerd is installed"
else
  fail "containerd is not installed"
fi

if systemctl is-active --quiet containerd; then
  pass "containerd service is running"
else
  fail "containerd service is not running"
fi

echo

# Kernel modules loaded
for mod in br_netfilter overlay; do
  if lsmod | grep -q "$mod"; then
    pass "Kernel module '$mod' is loaded"
  else
    fail "Kernel module '$mod' is not loaded"
  fi
done

echo

# Sysctl settings
for setting in net.ipv4.ip_forward net.bridge.bridge-nf-call-iptables net.bridge.bridge-nf-call-ip6tables; do
  val=$(sysctl -n "$setting" 2>/dev/null || echo "unset")
  if [ "$val" = "1" ]; then
    pass "$setting is enabled"
  else
    fail "$setting is disabled or unset"
  fi
done

echo

# Essential packages installed
for pkg in curl vim git wget htop tmux; do
  if dpkg -l "$pkg" >/dev/null 2>&1; then
    pass "Package $pkg installed"
  else
    fail "Package $pkg NOT installed"
  fi
done

echo

# Firewall (ufw) status
if systemctl is-active --quiet ufw; then
  fail "UFW firewall is active"
else
  pass "UFW firewall is inactive or not installed"
fi

echo
echo "=== Post-install validation complete ==="
