FROM fedora:28
MAINTAINER Jonathan Christison

USER root
#Stolen from https://github.com/nhr/znc-cluster-app/blob/master/Dockerfile
RUN dnf install -y procps-ng expect znc --allowerasing && mkdir /opt/znc-env && mkdir /opt/znc-run
COPY znc_* /opt/znc-run/
RUN chown -R 1001:0 /opt/znc-env /opt/znc-run && chmod -R ug+rwx /opt/znc-env /opt/znc-run

# Add our own awaynick module. Has the helpful side-benefit of
# upgrading ZNC to 1.6.5
COPY awaynick2.cpp /usr/lib64/znc
RUN PKGS='redhat-rpm-config znc-devel gcc-c++' && \
    dnf install --setopt=tsflags=nodocs -y tar rsync $PKGS && \
    cd /usr/lib64/znc && \
    znc-buildmod awaynick2.cpp && \
    dnf remove -y $PKGS && \
    dnf clean all

USER 1001
EXPOSE 6698
ENTRYPOINT ["/opt/znc-run/znc_runner.sh"]
