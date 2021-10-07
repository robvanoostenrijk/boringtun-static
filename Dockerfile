FROM ubuntu:14.04

ENV PATH=/root/.cargo/bin:$PATH

COPY ["cargo.config", "/build/"]

RUN	set -x && \
	apt-get update && \
	apt-get install \
		curl \
		file \
		git \
		nano \
		build-essential \
		gcc-4.7-multilib-arm-linux-gnueabi \
		-y && \
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | \
	sh -s -- --default-toolchain stable -y && \
	rustup target add arm-unknown-linux-musleabi arm-unknown-linux-gnueabi && \
	git clone https://github.com/cloudflare/boringtun /build/boringtun

RUN 	cd /build/boringtun && \
	cat /build/cargo.config >> .cargo/config && \
	for TARGET in "arm-unknown-linux-musleabi" "arm-unknown-linux-gnueabi" "x86_64-unknown-linux-gnu"; \
	do \
		echo "======= Building ${TARGET} ======="; \
		cargo build --release --bin boringtun --target ${TARGET}; \
		echo "======= Output ${TARGET} ======="; \
		file "target/${TARGET}/release/boringtun"; \
		ls -lh "target/${TARGET}/release/boringtun"; \
	done
