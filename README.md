## Static boringtun (Wireguard Userspace Client) ##

This repository contains a Dockerfile to build a statically compiled [boringtun](https://github.com/cloudflare/boringtun).

Compilation is done using Ubuntu Trusty (14.04) and results in the following executables:

    /arm-unknown-linux-musleabi (1.4Mb)
    boringtun: ELF 32-bit LSB executable, ARM, EABI5 version 1 (SYSV), statically linked, stripped

    /arm-unknown-linux-gnueabi (1.8Mb)
    boringtun: ELF 32-bit LSB executable, ARM, EABI5 version 1 (SYSV), statically linked, for GNU/Linux 2.6.32, stripped

    /x86_64-unknown-linux-gnu (2.2Mb)
    boringtun: ELF 64-bit LSB executable, x86-64, version 1 (GNU/Linux), statically linked, for GNU/Linux 2.6.24, stripped

The arm executables are usable on [OpenWRT](https://openwrt.org/), [AsusWRT](https://www.asuswrt-merlin.net/) & [DD-WRT](https://dd-wrt.com/) routers with older Linux 2.6.x kernels.

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
