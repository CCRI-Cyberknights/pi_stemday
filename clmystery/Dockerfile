FROM debian:bullseye-slim

# 1. Delete the hidden Docker config that blocks manual pages
RUN rm -f /etc/dpkg/dpkg.cfg.d/docker /etc/dpkg/dpkg.cfg.d/excludes

# 2. Install our tools AND reinstall the core utilities to force the man pages to unpack
RUN apt-get update && \
    apt-get install -y openssh-server git nano less grep sqlite3 man-db manpages && \
    apt-get install -y --reinstall coreutils grep less

# 3. Standard SSH and User Setup
RUN mkdir /var/run/sshd
RUN useradd -m -s /bin/bash detective && echo "detective:detective" | chpasswd
RUN git clone https://github.com/veltman/clmystery.git /home/detective/clmystery
RUN chown -R detective:detective /home/detective/clmystery

CMD ["/usr/sbin/sshd", "-D"]