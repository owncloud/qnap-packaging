# dockerized qpkg docs:

https://qnap-dev.github.io/container-station-api/dqpkg.html#quick-start



Create Docker App on QNAP NAS in QPKG format
============================================

NOTE: Before starting to pack QPKG, install docker.

This repo provides Docker image [dorowu/qdk2-build](https://hub.docker.com/r/dorowu/qdk2-build/) and a sample QPKG source of [Redmine](http://www.redmine.org/), a blogging platform to show how easily to pack Dockerized QPKG.

Steps
=========================
```

$ docker run -it --rm -v ${PWD}/example/owncloud:/src dorowu/qdk2-build
Creating archive with data files for x86_64...
      tar:   50kB 0:00:00 [ 520kB/s] [=======================================================================================================] 185%            
Creating archive with control files...
Creating QPKG package...
-rw-r--r-- 1 root root 33188 May 20 09:41 ownCloud_10.4.1_x86_64.qpkg
```

A QPKG was created in `example/ownCloud/ownCloud_10.4.1_x86_64.qpkg`. Make sure there is Container Station installed on QNAP NAS, then manually install it in App Center.
