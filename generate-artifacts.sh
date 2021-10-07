#!/bin/sh

docker build -t boringtun-static .
docker run --detach --rm --name boringtun-static boringtun-static sleep 5

for TARGET in "arm-unknown-linux-musleabi" "arm-unknown-linux-gnueabi" "x86_64-unknown-linux-gnu"
do
	mkdir -p ./dist/${TARGET}
	docker cp "boringtun-static:/build/boringtun/target/${TARGET}/release/boringtun" ./dist/${TARGET}/boringtun
done

docker stop boringtun-static
docker rmi boringtun-static

rm -f ./dist/boringtun-static.tar.gz
tar -C ./dist --exclude '*.tar.gz' -zcvf ./dist/boringtun-static.tar.gz .
rm -f -R ./dist/*/
