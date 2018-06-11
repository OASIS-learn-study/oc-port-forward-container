FROM centos:7
MAINTAINER Michael Vorburger <vorburger@redhat.com>

ENV OC_VERSION 3.10.0-0.63.0

RUN yum update -y; yum install -y socat nmap && yum clean all
# net-tools: ifconfig
# iproute: ip addr show

# Inspired by jboss/base
RUN groupadd -r oc -g 1000 && \
    useradd -u 1000 -r -g oc -m -d /opt/oc -s /sbin/nologin -c "OC user" oc && \
    chmod 755 /opt/oc

WORKDIR /opt/oc

USER oc

# https://github.com/openshift/origin/releases
# would be an alternative download location, but
# https://mirror.openshift.com/pub/openshift-v3/clients/
# has NEWER releases, at least right now.
RUN curl -s -L https://mirror.openshift.com/pub/openshift-v3/clients/$OC_VERSION/linux/oc.tar.gz -o /tmp/oc.tar.gz && \
    tar zxvf /tmp/oc.tar.gz -C /opt/oc/ && \
    rm /tmp/oc.tar.gz && \
    /opt/oc/oc version

COPY *.sh /opt/oc/

CMD ["sh", "-c", "/opt/oc/oc.sh"]

# NB: It's really 25564 and *NOT* 25565!
EXPOSE 25564
