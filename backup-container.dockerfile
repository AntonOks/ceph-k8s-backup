FROM ubuntu:22.04

ENV TINI_VERSION v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini

RUN apt-get update -yy && \
    apt-get install -yy curl ca-certificates bzip2 ceph-common && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ARG RESTIC_VERSION=0.16.5
ARG TARGETPLATFORM

RUN if [ ${TARGETPLATFORM} = "linux/amd64" ]; then SUFFIX=linux_amd64; HASH=f1a9c39d396d1217c05584284352f4a3bef008be5d06ce1b81a6cf88f6f3a7b1; \
    elif [ ${TARGETPLATFORM} = "linux/arm64" ]; then SUFFIX=linux_arm64; HASH=41cc6ad3ac5e99ee088011f628fafcb4fa1e4d3846be2333e5c2a3f6143cd0c1; \
    else echo "no URL for $(TARGETPLATFORM)"; exit 1; fi && \
    curl -Lo /tmp/restic.bz2 https://github.com/restic/restic/releases/download/v${RESTIC_VERSION}/restic_${RESTIC_VERSION}_${SUFFIX}.bz2 && \
    printf "${HASH}  /tmp/restic.bz2\\n" | sha256sum -c && \
    bunzip2 < /tmp/restic.bz2 > /usr/local/bin/restic && \
    chmod +x /usr/local/bin/restic

ARG QCOW2_WRITER_VERSION=0.1.0
ARG QCOW2_WRITER_DL_HASH=7c6ec8277e31498e5e73ca811c2b5feca7dce4d460b0fee695c4ba74ec63ecde
RUN curl -Lo /tmp/streaming-qcow2-writer_linux_amd64.bz2 https://github.com/remram44/streaming-qcow2-writer/releases/download/v${QCOW2_WRITER_VERSION}/streaming-qcow2-writer_${QCOW2_WRITER_VERSION}_linux_amd64.bz2 && \
    printf "${QCOW2_WRITER_DL_HASH}  /tmp/streaming-qcow2-writer_linux_amd64.bz2\\n" | sha256sum -c && \
    bunzip2 < /tmp/streaming-qcow2-writer_linux_amd64.bz2 > /usr/local/bin/streaming-qcow2-writer && \
    chmod +x /usr/local/bin/streaming-qcow2-writer

ENTRYPOINT ["/tini", "--"]
