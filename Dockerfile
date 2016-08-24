FROM ubuntu:14.04
MAINTAINER ross.b.brattain@intel.com


# This will prevent questions from being asked during the install
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        dkms \
    && apt-get clean


RUN apt-get update && apt-get install -y --no-install-recommends \
        linux-image-extra-3.13.0-93-generic \
        linux-headers-3.13.0-93-generic \
    && apt-get clean


RUN wget -nv 'http://downloads.sourceforge.net/project/e1000/ixgbe%20stable/4.4.6/ixgbe-4.4.6.tar.gz?r=https%3A%2F%2Fsourceforge.net%2Fprojects%2Fe1000%2Ffiles%2Fixgbe%2520stable%2F4.4.6%2F&ts=1472073534&use_mirror=heanet'  && tar -xvf ixgbe-4.4.6.tar.gz && rm ixgbe-4.4.6.tar.gz
RUN wget -nv 'http://downloads.sourceforge.net/project/e1000/i40e%20stable/1.5.19/i40e-1.5.19.tar.gz?r=https%3A%2F%2Fsourceforge.net%2Fprojects%2Fe1000%2Ffiles%2Fi40e%2520stable%2F1.5.19%2F&ts=1472073621&use_mirror=heanet'  && tar -xvf i40e-1.5.19.tar.gz && rm i40e-1.5.19.tar.gz


RUN make -C /root/ixgbe-4.4.6/src install BUILD_KERNEL=3.13.0-93-generic
RUN make -C /root/i40e-1.5.19/src install BUILD_KERNEL=3.13.0-93-generic


RUN mkdir /root/bootstrap
# use --transform to convert updates/ to kernel/ because bootstrap creator isn't grabbing moduels from updates/
RUN tar --transform=s,^updates,kernel, --owner=root --group=root --numeric-owner -C /lib/modules/3.13.0-93-generic/ -cvzf /root/bootstrap/bootstrap-ubuntu-14.04-3.13.0-93-generic-i40e-1.5.19-ixgbe-4.4.6.tar.gz updates
ENTRYPOINT ["cp", "-rv", "/root/bootstrap", "/data"]
