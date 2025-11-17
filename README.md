# inception-of-things
Yes, kubernetes are a thing.
### Fuck 42BCN Computers

# Pre-requisits
Setup an alpine 3.22 (current latest stable alpine version) machine for Inception of Things.  
Download the iso from [the alpine website](https://alpinelinux.or/downloads) the x86_64 version. ([Direct Link](https://dl-cdn.alpinelinux.org/alpine/v3.22/releases/x86_64/alpine-standard-3.22.2-x86_64.iso))  
When creating the machine, configure the following:
- Minimum 4 cpu cores
- Minimum 4GB of ram
- Enable nested virtualization (Nested VT on virtualbox)
- On network settings, put the network as NAT, and on advanced settings add the following port fowarding rule: TCP, , 2222, , 22.
- After installing and setting up the machine you may need to switch the boot order to make a priority the boot up from the disk.

# Install alpine
Install alpine with `setup-alpine`.  
No need to create a new user when prompted, with root we are already set; make sure to enable root loging then. Most of the questions prompted are default options, just keep pressing enter and read carefully, as an example read when setting up the network interface and when looking for repositories. When prompted about the disk, select the default disk "sda", set it up as "sys" and say yes when prompted to format it.

# Finally, we beging.
Start by setting up the repositories file by editing the '/etc/apk/repositories' and add the comunity ones. And don't forget to update the system with 'apk update && apl upgrade'.  
Install basic dependencies that you like: vim, tree, htop, git, curl, wget… with `apk add --no-cache <package>`.  
You can do it now or later, by its easier now, lets set up your ssh. It should work out of the box. On you host machine connect to the vm with `ssh root@localhost -p 2222`. If prompted with errors, try to resolve it with `ssh -keygen -f "/home/$USER/.ssh/known_hosts" -R "[localhost]:2222"`.  
Lets add our ssh for the vm to github. Create the ssh key with `ssh-keygen -t ed25519 -C "<your_email>"`. Add the key with the following `eval "$(ssh-agent -s)"` and `ssh-add ~/.ssh/id_ed25519.pub`. Config your info with `git config --global user.name and user.email`. Once you copied your ssh public key (without the email) try running `ssh -T git@github.com` to see if you github ssh was configured succesfully.  
Add this point you may also want to look how to optimize the memory ussage and swapfile  of your machine. ex:
- Dissable unnecessary sevices:
    - `rc-status` and `rc-update` to check the services
    - Dissable what you don't need. ex: `rc-update del acpid`, `rc-update del chronyd`…
- Use zram instead of swapfile:
```bash
apk add zram-init
rc-update add zram-init
rc-service zram-init start
```

# A grphical interface because the subjects says so…
This good man may be the only one with a simple enough [guide](https://breder.org/alpine-setup) and actually funcional one at that on how to install a lightweight GUI on alpine.  
Basically at this point you want to install these packaged: `apk add --no-cache setup-xorg-base xfce4 lightdm-gtk-greeter xfce4-terminal firefox-esr mousepad`.  
After this, add the service and start the GUI with `rc-update add lightdm` `rc-update add dbus` and start it `rc-sercice lightdm start`. (It should be now always start with a GUI on noot up).

# Can we start the project?
No



We need to install a virtualizer and hypervisor (which is kinda the same). But this is more for the part one config so yes, we technically start it.

Lets follow this to install the packages necessary for virtualization using qemu and libvir: 'https://krython.com/post/installing-virtualization-software'

'apk add --no-cache qemu qemu-system-x86_64 qemu-img qemu-guest-agent qemu-tools'
Check if it was installed correctly with 'qemu-system-x86_64 --version'
'apk add --no-cache libvirt libvirt-daemon libvirt-qemu virt-install virt-manager virt-viewer bridge-utils dnsmasq iptables'
Add the services:
'rc-update libvirtd default' and 'rc-update add libvirtd default'. Start it 'service libvirtd start'
Add vagrant for p1 and p2.
'apk add --no-cache ruby ruby-dev make gcc g++ libvirt-dev libxml2-dev libxslt-dev libarchive-tools'
And run 'gem install vagrant' and 'vagrant plugin install vagrant-libvirt'.
We must at this point add the necessary kernel modules for everything to work ' modprobe tun'
If it does not work, run the follwwing: 'lsmod | grep tun
mkdir -p /dev/net
mknod /dev/net/tun c 10 200
chmod 0666 /dev/net/tun
echo "tun" >> /etc/modules
rc-service libvirtd restart'

# Should I ask??
At this point we should have everything necessary to work at least on p1 and p2.
