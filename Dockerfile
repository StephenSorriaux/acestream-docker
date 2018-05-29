FROM ubuntu:12.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get -y update && apt-get install -y wget python-minimal python-setuptools net-tools && \
    wget -O - http://repo.acestream.org/keys/acestream.public.key | apt-key add - && \
    echo "deb http://repo.acestream.org/ubuntu/ precise main" > /etc/apt/sources.list.d/acestream.list && \
    apt-get -y update && apt-get install -y acestream-full unzip && \
    apt-get clean autoclean && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt /var/lib/dpkg /var/lib/cache /var/lib/log

COPY start.sh /
RUN chmod +x /start.sh

ENTRYPOINT ["/start.sh"]
