FROM debian:bullseye-slim
RUN apt-get update && apt-get install -y openssh-server git nano less grep sqlite3 man-db
RUN mkdir /var/run/sshd
RUN useradd -m -s /bin/bash detective && echo "detective:detective" | chpasswd
RUN git clone https://github.com/veltman/clmystery.git /home/detective/clmystery
RUN chown -R detective:detective /home/detective/clmystery
CMD ["/usr/sbin/sshd", "-D"]
