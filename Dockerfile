FROM openjdk:8-jdk-stretch
RUN apt-get update && \
    apt-get -y install awscli curl
RUN apt-get update -q && apt-get install -q -y \
        curl apt-transport-https apt-utils dialog

WORKDIR /tmp/download
ARG NODEREPO="node_6.x"
ARG DISTRO="stretch"
RUN curl -sSO https://deb.nodesource.com/gpgkey/nodesource.gpg.key
RUN apt-key add nodesource.gpg.key
RUN echo "deb https://deb.nodesource.com/${NODEREPO} ${DISTRO} main" > /etc/apt/sources.list.d/nodesource.list
RUN echo "deb-src https://deb.nodesource.com/${NODEREPO} ${DISTRO} main" >> /etc/apt/sources.list.d/nodesource.list
RUN apt-get update -q && apt-get install -y nodejs && npm i -g npm@5

RUN npm install -g kinesalite -unsafe-perm=true --allow-root

RUN apt-get update && apt-get install -y supervisor
RUN mkdir -p /var/log/supervisor
COPY supervisord.conf /etc/supervisor/conf.d/
WORKDIR /opt/dynamodb
RUN curl -fsL -o dynamodb_local_latest.tar.gz https://s3.eu-central-1.amazonaws.com/dynamodb-local-frankfurt/dynamodb_local_latest.tar.gz && \
    tar xvf dynamodb_local_latest.tar.gz && \
    rm  dynamodb_local_latest.tar.gz
CMD ["/usr/bin/supervisord","-n", "-c", "/etc/supervisor/supervisord.conf"]
