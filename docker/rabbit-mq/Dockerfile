#
# RabbitMQ Dockerfile
#
# https://github.com/dockerfile/rabbitmq
#

# Pull base image.
FROM debian:bullseye


RUN apt-get update && apt-get install curl gnupg wget -y 

# Define environment variables.
ENV RABBITMQ_LOG_BASE /data/log
ENV RABBITMQ_MNESIA_BASE /data/mnesia

# Install RabbitMQ.
COPY ./install.sh /tmp/install.sh

# Define working directory.
WORKDIR /data



RUN bash -x /tmp/install.sh

# Define default command.
CMD ["/usr/lib/rabbitmq/bin/rabbitmq-server"]

# Expose ports.
EXPOSE 5672
EXPOSE 15672