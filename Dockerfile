FROM ubuntu:xenial

MAINTAINER Dave Lane <dave@davelane.nz>
# modified from that by MAINTAINER frenchbeard <frenchbeardsec@gmail.com>

ENV TENDENCI_VERSION=7.2 \
    TENDENCI_USER="tendenci" \
    TENDENCI_HOME="/home/tendenci" \
    TENDENCI_LOG_DIR="/var/log/tendenci" \
    TENDENCI_VIRTUALENV="${TENDENCI_HOME}/virtualenv"

ENV TENDENCI_INSTALL_DIR="${TENDENCI_HOME}/install" \
    TENDENCI_DATA_DIR="${TENDENCI_HOME}/data" \
    TENDENCI_BUILD_DIR="${TENDENCI_HOME}/build" \
    APP_NAME="default"

ENV APT_SERVER http://ucmirror.canterbury.ac.nz/ubuntu
ENV APT_FILE sources.list
ENV UBUNTU_NAME xenial
#
# add local mirror to reduce build time :)
RUN echo "deb $APT_SERVER ${UBUNTU_NAME} main universe" > /etc/apt/${APT_FILE}
RUN echo "deb $APT_SERVER ${UBUNTU_NAME}-updates main universe" >> /etc/apt/${APT_FILE}
RUN echo "deb $APT_SERVER ${UBUNTU_NAME}-security main universe" >> /etc/apt/${APT_FILE}
RUN echo "deb-src $APT_SERVER ${UBUNTU_NAME} main universe" >> /etc/apt/${APT_FILE}
RUN echo "deb-src $APT_SERVER ${UBUNTU_NAME}-updates main universe" >> /etc/apt/${APT_FILE}
RUN echo "deb-src $APT_SERVER ${UBUNTU_NAME}-security main universe" >> /etc/apt/${APT_FILE}

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get upgrade -y \
    && apt-get install -y build-essential python-dev libevent-dev libpq-dev \
        libjpeg8 libjpeg-dev libfreetype6 libfreetype6-dev git python-pip \
        python-virtualenv git \
    && update-locale LANG=C.UTF-8 LC_MESSAGES=POSIX

COPY assets/build/ ${TENDENCI_BUILD_DIR}
RUN bash -x ${TENDENCI_BUILD_DIR}/install.sh

COPY assets/runtime/ /runtime

EXPOSE 8000/tcp

VOLUME [ "${TENDENCI_DATA_DIR}", "${TENDENCI_LOG_DIR}" ]
WORKDIR ${TENDENCI_INSTALL_DIR}

ENTRYPOINT [ "/runtime/run.sh" ]
CMD [ "python", "manage.py", "runserver" ]
