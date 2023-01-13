VERSION 0.6

clean:
	LOCALLY
	RUN rm -f -R ./dist

build:
	FROM DOCKERFILE .

package:
	FROM +build

	RUN set -x \
&&		mkdir -p /usr/src/boringtun/dist \
&&		XZ_OPT=-9 tar -C /usr/src/boringtun/target -Jcvf /usr/src/boringtun/dist/boringtun.tar.xz \
		arm-unknown-linux-gnueabi/release/boringtun-cli \
		arm-unknown-linux-musleabi/release/boringtun-cli \
		x86_64-unknown-linux-gnu/release/boringtun-cli \
		armv5te-unknown-linux-gnueabi/release/boringtun-cli \
		armv5te-unknown-linux-musleabi/release/boringtun-cli

	SAVE ARTIFACT /usr/src/boringtun/dist/boringtun.tar.xz AS LOCAL ./dist/boringtun-legacy-kernel.tar.xz

all:
	BUILD +clean
	BUILD --platform=linux/amd64 +package
