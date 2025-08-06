# Kubernetes from scratch

The aim of this repo will be to document my progress learning kubernetes. I have a set of problems which each need a solution; this may reveal more problems and require more solutions. The process won't be "complete" until all problems are solved.

## Initial problems/solutions:

### Hardware problems
| Problem    | Solution |
| --------- | ------- |
| No computer (I use a laptop for work) | Buy a cheap laptop from ebay (recommend lenovo thinkcentre with a lot of memory). |
| No keyboard           | Oh dear... I had a feeling this might happen. Create an automated boot ISO...        |
| No video          | I have faith the video works, but my TV was running at 4k... Find an alternateive monitor (my neighbors helped).   |
| USB stick didn't work/boot          | The automated cloudinit stuff I'd googled didn't work with the uefi boot... Back to square one.        |
| Need a keyboard now | Buy a keyboard (a cheap one).        |
| USB stick still doesn't work          | Let's go back to the basics, use the basic ubuntu server image.        |

Finally after all this we have a bootable, fully functiona ubuntu server... Using wifi. Some small changes required to sort that:

### OS Problems/solutions
| Problem    | Solution |
| --------- | ------- |
| Wifi Only (remember I installed at my neighbors) | Switch Wifi off by removing wifi related configs (in my case `rm /etc/netplan/50-cloud-init.yaml`).<br>Create a new file in [/etc/netplan/01-netcfg.yaml](configs/01-netcfg.yaml).<br>Make sure ownership is root and permission are 600 (`chown root: /etc/netplan/01-netcfg.yaml; chmod 600 /etc/netplan/01-netcfg.yaml`. |
| IPv6 is everywhere?!| Disable in grub.<br>edit `/etc/default/grub` to have `GRUB_CMDLINE_LINUX_DEFAULT="ipv6.disable=1"` in.<br>run `update-grub` |
| DHCP is set | Change the netcfg to be static (see [/etc/netplan/01-netcfg.yaml](configs/01-netcfg.yaml#L6-L12)). |
| Update the OS | `apt update && sudo apt full-upgrade -y` |
| Install some packages | `apt install -y htop git curl wget vim tmux` |

Finally after all this we have a static, no IPv6 wired system which I can transport to my home and plug in and ssh into.

### Kubernetes prerequisites
| Prerequisite    | Solution |
| --------- | ------- |
| IP Forwarding | Create a new file in [/etc/sysctl.d/10-ip-forwarding.conf](configs/10-ip-forwarding.conf). Run `sysctl --system` |
| No swap | swapoff -a<br>sed -i '/ swap / s/^/#/' /etc/fstab |
| Install containerd | `apt install -y containerd; systemctl restart containerd; systemctl enable containerd` |
