clean:
	LOCALLY
	RUN rm -f -R ./dist

build:
	FROM DOCKERFILE .

package:
	FROM +build

	RUN set -x \
&&		mkdir -p /build/dist \
&&		XZ_OPT=-9 tar -C /build/boringtun/target -Jcvf /build/dist/boringtun-static.tar.xz arm-unknown-linux-musleabi/release/boringtun arm-unknown-linux-gnueabi/release/boringtun x86_64-unknown-linux-gnu/release/boringtun

	SAVE ARTIFACT /build/dist/boringtun-static.tar.xz AS LOCAL ./dist/boringtun-static.tar.xz

all:
	BUILD +clean
	BUILD +package
