## Static boringtun (Wireguard Userspace Client) ##

This repository leverages GitHub Actions and [cross-rs](https://github.com/cross-rs/cross) to build a statically compiled [boringtun](https://github.com/cloudflare/boringtun).

Compilation is done using Cargo/Cross and results in the following executables:

- aarch64-unknown-linux-gnu  
boringtun-cli: ELF 64-bit LSB executable, ARM aarch64, version 1 (SYSV), statically linked, BuildID[sha1]=0f13c4a1a8a819208ea0b93c837dfc47211bbf7a, for GNU/Linux 3.7.0, stripped

- aarch64-unknown-linux-musl  
boringtun-cli: ELF 64-bit LSB executable, ARM aarch64, version 1 (SYSV), statically linked, stripped

- arm-unknown-linux-gnueabihf  
boringtun-cli: ELF 32-bit LSB executable, ARM, EABI5 version 1 (SYSV), statically linked, for GNU/Linux 4.19.21, stripped

- armv7-unknown-linux-gnueabihf  
boringtun-cli: ELF 32-bit LSB executable, ARM, EABI5 version 1 (SYSV), statically linked, BuildID[sha1]=3290baffa4a932ab7cf000d5093b704723cf5d62, for GNU/Linux 3.2.0, stripped

- armv7-unknown-linux-musleabi  
boringtun-cli: ELF 32-bit LSB executable, ARM, EABI5 version 1 (SYSV), statically linked, stripped

- armv7-unknown-linux-musleabihf  
boringtun-cli: ELF 32-bit LSB executable, ARM, EABI5 version 1 (SYSV), statically linked, stripped

- x86_64-unknown-linux-gnu  
boringtun-cli: ELF 64-bit LSB pie executable, x86-64, version 1 (SYSV), static-pie linked, BuildID[sha1]=da39374a83d5a581ed75d072a620352d3946c785, for GNU/Linux 3.2.0, stripped

- x86_64-unknown-linux-musl  
boringtun-cli: ELF 64-bit LSB pie executable, x86-64, version 1 (SYSV), static-pie linked, stripped

The arm executables are usable on [OpenWRT](https://openwrt.org/), [AsusWRT](https://www.asuswrt-merlin.net/) & [DD-WRT](https://dd-wrt.com/) routers.

The included script `generate-artifacts.sh` executes the docker build and places the generated artifacts into `./dist`.

The `wg-go` utility to allow WireGuard configuration on ARM devices can be installed from https://github.com/seud0nym/openwrt-wireguard-go/.

### Usage ###

In order to use this on a ARM based kernel 2.6 router, the following steps are needed:

   1. Load the tun kernel module with `modprobe tun`
   2. Add the WireGuard client ip address to the tun interface  

    ip addr add 172.16.0.2/32 dev tun0
    ip link set dev tun0 mtu 1280
    ip link set dev tun0 up

   3. Setup IP routing

    # Check /etc/iproute2/rt_tables for available table names
    ip route add default via 172.16.0.2 dev tun0 table 200
    ip route flush cache

    ip rule add from all to 172.16.0.0/24 table 200
    # Route only device 192.168.1.99 through the WireGuard connection
    ip rule add from 192.168.1.99/32 table 200

   4. Enable NAT on iptables for tun device

    iptables -t nat -A POSTROUTING ! -s 172.16.0.2/32 -o tun+ -j MASQUERADE

   5. Start boringtun userspace wireguard client

    # Single-user router systems cannot drop privileges, multi-queue is not supported on 2.x kernels
    boringtun --disable-multi-queue --disable-drop-privileges root tun0
