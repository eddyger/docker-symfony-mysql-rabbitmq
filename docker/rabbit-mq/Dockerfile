#
# RabbitMQ Dockerfile
#
# https://github.com/dockerfile/rabbitmq
#

# Pull base image.
FROM debian:bullseye


RUN apt-get update && apt-get install curl gnupg wget -y 

# Install RabbitMQ.
COPY ./install.sh /tmp/install.sh

RUN bash -x /tmp/install.sh

RUN dpkg -L rabbitmq-server && sleep 20

# Define environment variables.
ENV RABBITMQ_LOG_BASE /data/log
ENV RABBITMQ_MNESIA_BASE /data/mnesia

# Define mount points.
#VOLUME ["/data/log", "/data/mnesia"]

# Define working directory.
WORKDIR /data


# Define default command.
CMD ["/usr/lib/rabbitmq/bin/rabbitmq-server"]

# Expose ports.
EXPOSE 5672
EXPOSE 15672