#!/bin/bash
export distribution="bullseye"

tee /etc/apt/sources.list.d/rabbitmq.list <<EOF
## Provides modern Erlang/OTP releases from a Cloudsmith mirror
##
deb [signed-by=/usr/share/keyrings/rabbitmq.E495BB49CC4BBE5B.gpg] https://ppa1.novemberain.com/rabbitmq/rabbitmq-erlang/deb/ubuntu $distribution main
deb-src [signed-by=/usr/share/keyrings/rabbitmq.E495BB49CC4BBE5B.gpg] https://ppa1.novemberain.com/rabbitmq/rabbitmq-erlang/deb/ubuntu $distribution main

# another mirror for redundancy
deb [signed-by=/usr/share/keyrings/rabbitmq.E495BB49CC4BBE5B.gpg] https://ppa2.novemberain.com/rabbitmq/rabbitmq-erlang/deb/ubuntu $distribution main
deb-src [signed-by=/usr/share/keyrings/rabbitmq.E495BB49CC4BBE5B.gpg] https://ppa2.novemberain.com/rabbitmq/rabbitmq-erlang/deb/ubuntu $distribution main

## Provides RabbitMQ from a Cloudsmith mirror
##
deb [signed-by=/usr/share/keyrings/rabbitmq.9F4587F226208342.gpg] https://ppa1.novemberain.com/rabbitmq/rabbitmq-server/deb/ubuntu $distribution main
deb-src [signed-by=/usr/share/keyrings/rabbitmq.9F4587F226208342.gpg] https://ppa1.novemberain.com/rabbitmq/rabbitmq-server/deb/ubuntu $distribution main

# another mirror for redundancy
deb [signed-by=/usr/share/keyrings/rabbitmq.9F4587F226208342.gpg] https://ppa2.novemberain.com/rabbitmq/rabbitmq-server/deb/ubuntu $distribution main
deb-src [signed-by=/usr/share/keyrings/rabbitmq.9F4587F226208342.gpg] https://ppa2.novemberain.com/rabbitmq/rabbitmq-server/deb/ubuntu $distribution main
EOF

apt-get update -y

## Install Erlang packages
apt-get install -y erlang-base \
                        erlang-asn1 erlang-crypto erlang-eldap erlang-ftp erlang-inets \
                        erlang-mnesia erlang-os-mon erlang-parsetools erlang-public-key \
                        erlang-runtime-tools erlang-snmp erlang-ssl \
                        erlang-syntax-tools erlang-tftp erlang-tools erlang-xmerl

## Install rabbitmq-server and its dependencies
apt-get install rabbitmq-server -y --fix-missing

## Enable RabbitMQ Management plugins
rabbitmq-plugins enable rabbitmq_management

## Create RabbitMQ users for remote access
export RABBITMQ_LOG_BASE=/data/log
export RABBITMQ_MNESIA_BASE=/data/mnesia
RABBIT_MQ_UNIQUE_PASSWORD_AND_COOKIE=2a55f70a841f18b97c3a7db939b7adc9e34a0f1b
echo $RABBIT_MQ_UNIQUE_PASSWORD_AND_COOKIE > /var/lib/rabbitmq/.erlang.cookie
echo $RABBIT_MQ_UNIQUE_PASSWORD_AND_COOKIE > /root/.erlang.cookie
chmod 600 /var/lib/rabbitmq/.erlang.cookie
chown rabbitmq /var/lib/rabbitmq/.erlang.cookie
chmod 600 /root/.erlang.cookie
service rabbitmq-server start
sleep 10
rabbitmqctl add_user 'symfony-mq' $RABBIT_MQ_UNIQUE_PASSWORD_AND_COOKIE
rabbitmqctl add_user 'admin-mq' $RABBIT_MQ_UNIQUE_PASSWORD_AND_COOKIE
rabbitmqctl set_permissions -p "/" "symfony-mq" ".*" ".*" ".*"
rabbitmqctl set_permissions -p "/" "admin-mq" ".*" ".*" ".*"
rabbitmqctl set_user_tags admin-mq administrator
service rabbitmq-server stop