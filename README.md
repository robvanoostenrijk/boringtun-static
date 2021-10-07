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