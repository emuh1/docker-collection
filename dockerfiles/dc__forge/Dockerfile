# Usage: FROM [image name]
FROM debian:jessie
# Usage: MAINTAINER [name]
MAINTAINER Emanuel Ziegler <emanuel.ziegler@gmail.com>

# Usage: ADD [source directory or URL] [destination directory]
#ADD /my_app_folder /my_app_folder

# Usage: RUN [command]
RUN dpkg --add-architecture i386
# Run all apt-get commands in one run contain the changes in one layer
RUN apt-get update && \
    apt-get -y install libstdc++6:i386 libgcc1:i386 zlib1g:i386 libncurses5:i386 \
                       build-essential \
                       subversion git \
                       proot qemu-user-static \
                       autoconf automake \
                       gawk file texinfo libtool wget python2.7 && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN mkdir -p /sources

# Usage: WORKDIR /path
WORKDIR /sources

# Usage: EXPOSE [port]
# Usage: VOLUME ["/dir_1", "/dir_2" ..]
VOLUME ["/sources"]

# Usage: ENV key value
ENV LC_ALL C

# Usage: USER [UID]
#USER 751

# Usage 1: CMD application "argument", "argument", ..
#CMD "echo" "Hello docker!"

# Usage example with CMD:
# Arguments set with CMD can be overridden during *run*
ENTRYPOINT [ "/sources/scripts/bin/D__forge" ]
CMD [ "--help" ]
