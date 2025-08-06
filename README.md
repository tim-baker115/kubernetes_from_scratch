# Kubernetes from scratch

The aim of this repo will be to document my progress learning kubernetes. I have a set of problems which each need a solution; this may reveal more problems and require more solutions. The process won't be "complete" until all problems are solved.

## Initial problems/solutions:

### Hardware problems
| Problem    | Solution |
| --------- | ------- |
| No computer (I use a laptop for work) | Buy a cheap laptop from ebay (recommend lenovo thinkcentre with a lot of memory). |
| No keyboard           | Oh dear... I had a feeling this might happen. Create an automated boot ISO...        |
| No video          | This was a major pain. In the end I took the computer to my neighbors house and got a terrible (and unreliable) 480p output. The computer didn't work at all well with my TV.   |
| USB stick didn't work/boot          | The automated cloudinit stuff I'd googled didn't work with the uefi boot... Back to square one.        |
| Need a keyboard now | Buy a keyboard (a cheap one).        |
| USB stick still doesn't work          | Let's go back to the basics, use the basic ubuntu server image.        |

Finally after all this we have a bootable, fully functiona ubuntu server... Using wifi. Some small changes required to sort that:

### OS Problems/solutions
| Problem    | Solution |
| --------- | ------- |
| Wifi Only (remember I installed at my neighbors) | Switch Wifi off and create a new file in `/etc/netplan/01-netcfg.yaml`. |
| IPv6 is everywhere?!| Disable in grub (edit /etc/default/grub to have `GRUB_CMDLINE_LINUX_DEFAULT="ipv6.disable=1"` in, then run `update-grub` |
| DHCP is set | Change the netcfg to be static. |
| Update the OS | `apt update && sudo apt full-upgrade -y` |

Finally after all this we have a static, no IPv6 wired system which I can transport to my home and plug in and ssh into.
