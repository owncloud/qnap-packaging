FROM owncloud/ubuntu:18.04
LABEL maintainer="consulting@owncloud.com"

ARG QDK2_VER=0.27

# Install.
RUN apt-get update \
  && apt-get install -y software-properties-common \
  build-essential \
  unzip \
  curl \
  wget \
  git \
 # realpath \
  coreutils \
  moreutils \
  fakeroot \
  pv \
  #python-support \
  bsdmainutils \
  curl \
  python \
  openssl 
# Install qdk2
RUN wget https://github.com/qnap-dev/qdk2/releases/download/v${QDK2_VER}/qdk2_${QDK2_VER}.bionic_amd64.deb \
  && dpkg -i qdk2_${QDK2_VER}.bionic_amd64.deb \
  && rm -f qdk2_${QDK2_VER}.bionic_amd64.deb

ADD app.sh /
ENTRYPOINT ["/app.sh"]
