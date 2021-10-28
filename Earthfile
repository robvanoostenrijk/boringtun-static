FROM ubuntu:14.04
ENV PATH=/root/.cargo/bin:$PATH

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

WORKDIR /build/boringtun

build:
	COPY	cargo.config /build/cargo.config
	RUN	cat /build/cargo.config >> .cargo/config && \
		for TARGET in "arm-unknown-linux-musleabi" "arm-unknown-linux-gnueabi" "x86_64-unknown-linux-gnu"; \
		do \
			echo "======= Building ${TARGET} ======="; \
			cargo build --release --bin boringtun --target ${TARGET}; \
			echo "======= Output ${TARGET} ======="; \
			file "target/${TARGET}/release/boringtun"; \
			ls -lh "target/${TARGET}/release/boringtun"; \
		done
	SAVE ARTIFACT ./target/arm-unknown-linux-musleabi/release/boringtun AS LOCAL ./dist/arm-unknown-linux-musleabi/boringtun
	SAVE ARTIFACT ./target/arm-unknown-linux-gnueabi/release/boringtun AS LOCAL ./dist/arm-unknown-linux-gnueabi/boringtun
	SAVE ARTIFACT ./target/x86_64-unknown-linux-gnu/release/boringtun AS LOCAL ./dist/x86_64-unknown-linux-gnu/boringtun

