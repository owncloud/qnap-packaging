### 1. Build QPKG

```
⋊> ~/qnap-packaging on master ◦ make
### Prepare QPKG builder: qnap/qpkg-builder
docker build -t qnap/qpkg-builder .
Sending build context to Docker daemon  3.584kB
Step 1/8 : FROM owncloud/ubuntu:18.04
 ---> aa372854d3cb
Step 2/8 : LABEL maintainer="consulting@owncloud.com"
 ---> Using cache
 ---> 55ee1f8ef99f
Step 3/8 : ARG QDK2_VER=0.29
 ---> Using cache
 ---> a11d8b8fbe3f
Step 4/8 : ARG DOCKER_VER=19.03.11
 ---> Using cache
 ---> f127821f47b0
Step 5/8 : RUN   apt-get update   && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends     curl wget fakeroot rsync pv bsdmainutils ca-certificates openssl xz-utils make   && rm -rf /var/cache/debconf/* /var/lib/apt/lists/* /var/log/*
 ---> Using cache
 ---> dea22da2b312
Step 6/8 : RUN   wget https://github.com/qnap-dev/qdk2/releases/download/v${QDK2_VER}/qdk2_${QDK2_VER}.bionic_amd64.deb   && dpkg -i --force-depends qdk2_${QDK2_VER}.bionic_amd64.deb   && rm -f qdk2_${QDK2_VER}.bionic_amd64.deb
 ---> Using cache
 ---> 66f0143093ba
Step 7/8 : RUN   curl -sq https://download.docker.com/linux/static/stable/x86_64/docker-$DOCKER_VER.tgz    | tar zxf - -C /usr/bin docker/docker --strip-components=1   && chown root:root /usr/bin/docker
 ---> Using cache
 ---> 85587a48e1ca
Step 8/8 : WORKDIR /work
 ---> Using cache
 ---> 0db3b63e340f
Successfully built 0db3b63e340f
Successfully tagged qnap/qpkg-builder:latest
make[1]: Entering directory '/work'
### Download container image: owncloud/server:latest
latest: Pulling from owncloud/server
Digest: sha256:ba51d5d51f40af34ee062450b1a11ffd4edf54b1c55ee56ee220c11af71b44ef
Status: Image is up to date for owncloud/server:latest
docker.io/owncloud/server:latest
### Save container image to a tar archive: owncloud-server_latest.tar
### Download container image: webhippie/mariadb:latest
latest: Pulling from webhippie/mariadb
Digest: sha256:8a2c927529e5fd6238f08f79e3855d90a353e4475481574aa4bf0b90550b5db9
Status: Image is up to date for webhippie/mariadb:latest
docker.io/webhippie/mariadb:latest
### Save container image to a tar archive: webhippie-mariadb_latest.tar
### Download container image: webhippie/redis:latest
latest: Pulling from webhippie/redis
Digest: sha256:42f6d51be6a7a5ef6fb672e98507824816566f0b1f89c19b2d585f54e26b2529
Status: Image is up to date for webhippie/redis:latest
docker.io/webhippie/redis:latest
### Save container image to a tar archive: webhippie-redis_latest.tar
### Build QPKG ...
fakeroot /usr/share/qdk2/QDK/bin/qbuild --build-dir build --xz amd64
Creating archive with data files for x86_64...
      tar: 1.41GiB 0:08:49 [2.72MiB/s] [===========================================================>] 100%
Creating archive with control files...
Creating QPKG package...
make[1]: Leaving directory '/work'
```

### 2. Artifacts

```
⋊> ~/qnap-packaging on master ⨯ ls -la build
total 502792
drwxr-xr-x   4 walkerlee  staff        128 Jun 26 07:12 ./
drwxr-xr-x  15 walkerlee  staff        480 Jun 26 07:15 ../
-rw-r--r--   1 walkerlee  staff  247005609 Jun 26 07:12 owncloud_10.4.1_x86_64.qpkg
-rw-r--r--   1 walkerlee  staff         68 Jun 26 07:12 owncloud_10.4.1_x86_64.qpkg.md5
```

### 3. Clean up

```
⋊> ~/qnap-packaging on master ⨯ make clean
### Remove build files ...
rm -rf */{data,docker-images}
rm -rf build{,.*}/ tmp.*/
```

## Reference

##### How to build a containerized QPKG

https://github.com/qnap-dev/containerized-qpkg

##### package\_routines doc:

https://edhongcy.gitbooks.io/qdk-qpkg-development-kit/content/package-specific-installation-functions.html

##### qpkg.cfg doc:

https://edhongcy.gitbooks.io/qdk-qpkg-development-kit/content/qpkg-configuration-file.html

##### QDK GitHub:

https://github.com/qnap-dev/QDK

##### Dockerfile:

https://docs.docker.com/engine/reference/builder/

##### docker-compose.yml:

https://docs.docker.com/compose/