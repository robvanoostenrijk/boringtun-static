## Static boringtun (Wireguard Userspace Client) ##

This repository leverages GitHub Actions and [cross-rs](https://github.com/cross-rs/cross) to build a statically compiled [boringtun](https://github.com/cloudflare/boringtun).

Compilation is done using Cargo/Cross and results in the following executables:

- aarch64-unknown-linux-gnu <sup><sub>:white_check_mark: Officially supported target</sub></sup>  
boringtun-cli: ELF 64-bit LSB executable, ARM aarch64, version 1 (SYSV), statically linked, for GNU/Linux 3.7.0, stripped

- aarch64-unknown-linux-musl  
boringtun-cli: ELF 64-bit LSB executable, ARM aarch64, version 1 (SYSV), statically linked, stripped

- arm-unknown-linux-gnueabihf  
boringtun-cli: ELF 32-bit LSB executable, ARM, EABI5 version 1 (SYSV), statically linked, for GNU/Linux 4.19.21, stripped

- armv7-unknown-linux-gnueabihf <sup><sub>:white_check_mark: Officially supported target</sub></sup>  
boringtun-cli: ELF 32-bit LSB executable, ARM, EABI5 version 1 (SYSV), statically linked, for GNU/Linux 3.2.0, stripped

- armv7-unknown-linux-musleabi  
boringtun-cli: ELF 32-bit LSB executable, ARM, EABI5 version 1 (SYSV), statically linked, stripped

- armv7-unknown-linux-musleabihf  
boringtun-cli: ELF 32-bit LSB executable, ARM, EABI5 version 1 (SYSV), statically linked, stripped

- x86_64-unknown-linux-gnu <sup><sub>:white_check_mark: Officially supported target</sub></sup>  
boringtun-cli: ELF 64-bit LSB pie executable, x86-64, version 1 (SYSV), static-pie linked, for GNU/Linux 3.2.0, stripped

- x86_64-unknown-linux-musl  
boringtun-cli: ELF 64-bit LSB pie executable, x86-64, version 1 (SYSV), static-pie linked, stripped

### Legacy Kernels

For very old devices using legacy 2.6.x+ kernels, usually router firmwares. There are a set of experimental compiles available:

- arm-unknown-linux-gnueabi  
boringtun-cli: ELF 32-bit LSB executable, ARM, EABI5 version 1 (SYSV), statically linked, for GNU/Linux 2.6.32, BuildID[sha1]=a99e8f3161e01590d7b9e2294b49db39837c9e7e, stripped

- arm-unknown-linux-musleabi   
boringtun-cli: ELF 32-bit LSB executable, ARM, EABI5 version 1 (SYSV), statically linked, stripped

- x86_64-unknown-linux-gnu  
boringtun-cli: ELF 64-bit LSB executable, x86-64, version 1 (GNU/Linux), statically linked, for GNU/Linux 2.6.24, stripped

### 32-bit armv5 builds

Very experimental 32-bit builds for very old armv5 based devices with legacy 2.6.x+ kernels

- armv5te-unknown-linux-gnueabi  
boringtun-cli: ELF 32-bit LSB shared object, ARM, EABI5 version 1 (SYSV), dynamically linked, interpreter /lib/ld-linux.so.3, for GNU/Linux 2.6.32, stripped

- armv5te-unknown-linux-musleabi  
boringtun-cli: ELF 32-bit LSB executable, ARM, EABI5 version 1 (SYSV), statically linked, stripped

The arm executables should be usable on [OpenWRT](https://openwrt.org/), [AsusWRT](https://www.asuswrt-merlin.net/) & [DD-WRT](https://dd-wrt.com/) routers.

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
