# syntax=docker/dockerfile:1.4
FROM ubuntu:14.04

ARG BORINGTUN_TAG

ENV PATH=/root/.cargo/bin:$PATH

COPY ["config-legacy-append.toml", "/usr/src/"]
COPY ["atomic-u32.patch", "/usr/src"]

RUN <<EOF
set -x
echo Compiling for boringtun-cli-${BORINGTUN_TAG}

# GitHub Runners are on Azure, use Azure Ubuntu mirrors
rm /etc/apt/sources.list.d/ubuntu-esm-infra-trusty.list
sed --in-place --regexp-extended "s/(\/\/)(archive\.ubuntu)/\1azure.\2/" /etc/apt/sources.list
sed --in-place --regexp-extended "s/(deb http:\/\/security.ubuntu.com)/#\1/" /etc/apt/sources.list

apt-get update
apt-get install \
	build-essential \
	curl \
	file \
	gcc-4.7-multilib-arm-linux-gnueabi \
	git \
	nano \
	-y
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --default-toolchain stable -y
rustup target add \
	arm-unknown-linux-gnueabi \
	arm-unknown-linux-musleabi \
	armv5te-unknown-linux-gnueabi \
	armv5te-unknown-linux-musleabi
mkdir -p /usr/src/boringtun
curl --location https://github.com/cloudflare/boringtun/archive/refs/tags/boringtun-cli-${BORINGTUN_TAG}.tar.gz | tar xz -C /usr/src/boringtun --strip-components=1

EOF

RUN	<<EOF
cd /usr/src/boringtun
cat /usr/src/config-legacy-append.toml >> .cargo/config.toml
for TARGET in \
	"arm-unknown-linux-gnueabi" \
	"arm-unknown-linux-musleabi" \
	"x86_64-unknown-linux-gnu" \
	"armv5te-unknown-linux-gnueabi" \
	"armv5te-unknown-linux-musleabi"
do
	# Crate ring requires CC and AR to be set
	if case $TARGET in arm*) ;; *) false;; esac; then
		export TARGET_CC=/usr/bin/arm-linux-gnueabi-gcc-4.7
		export TARGET_AR=/usr/bin/arm-linux-gnueabi-ar
	else
		unset TARGET_CC
		unset TARGET_AR
	fi

	# Last two platforms are 32-bit, apply the 32 bit patch before compiling
	if case $TARGET in armv5*) ;; *) false;; esac; then
		patch -p1 < /usr/src/atomic-u32.patch
	fi

	echo "======= Building ${TARGET} ======="
	cargo build --bin boringtun-cli --release --target ${TARGET}
	echo "======= Output ${TARGET} ======="
	file "target/${TARGET}/release/boringtun-cli"
	ls -lh "target/${TARGET}/release/boringtun-cli"
done

EOF


