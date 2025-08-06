# Kubernetes from scratch

The aim of this repo will be to document my progress learning kubernetes. I have a set of problems which each need a solution; this may reveal more problems and require more solutions. The process won't be "complete" until all problems are solved.

# Initial problems/solutions:

These problems relate to hardware only... 

| Problem    | Solution |
| --------- | ------- |
| No computer (I use a laptop for work) | Buy a cheap from ebay (recommended lenovo thinkcentre with a lot of memory) |
| No keyboard           | Oh dear... I had a feeling this might happen. Create an automated boot ISO...        |
| No video          | This was a major pain. In the end I took the computer to my neighbors house and got a terrible 480p output.        |
| USB stick didn't work          | The automated cloudinit stuff I'd googled didn't work with the uefi boot... Back to square one.        |
| Need a keyboard now | Buy a keyboard (a cheap one)        |
| USB stick still doesn't work          | Let's go back to the basics, use the basic ubuntu server image.        |

Finally after all this we have a bootable, fully functiona ubuntu server... Using wifi. Some small changes required to sort that:

# OS Problems/solutions

| Problem    | Solution |
| --------- | ------- |
| Wifi Only |  |
| IPv6 is everywhere?!| |
| DHCP is set |  |
