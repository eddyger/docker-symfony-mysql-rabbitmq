ARG DEBIAN_RELEASE
FROM debian:${DEBIAN_RELEASE}

ARG DEBIAN_VERSION
ARG PHP_VERSION

# Some needed packages installation
RUN apt-get update && apt-get upgrade -y
RUN apt-get update && apt-get -y install git locales acl vim curl wget gnupg ca-certificates apt-transport-https lsb-release

# Timezone Paris
ENV TZ=Europe/Paris
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Change the default locale to C.UTF-8
RUN update-locale LANG=C.UTF-8

# Php install
RUN apt-get update && apt-get upgrade -y
RUN wget -q https://packages.sury.org/php/apt.gpg && apt-key add apt.gpg
RUN echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list
RUN apt-get update --fix-missing
RUN apt-get install apache2 php$PHP_VERSION-pdo-mysql php$PHP_VERSION-fpm php$PHP_VERSION-dev php$PHP_VERSION-xml php$PHP_VERSION-ldap php$PHP_VERSION-zip unzip php$PHP_VERSION-curl php$PHP_VERSION-gd php$PHP_VERSION-mbstring php$PHP_VERSION-xdebug php$PHP_VERSION-intl -y --allow-unauthenticated

# Composer
RUN curl -Ss https://getcomposer.org/installer | php > /dev/null
RUN mv composer.phar /usr/local/bin/composer
RUN composer self-update --2

# Symfony
RUN curl -1sLf 'https://dl.cloudsmith.io/public/symfony/stable/setup.deb.sh' | bash
RUN apt install symfony-cli

# Copy Apache config (to avoid the error => "Could not determine […] fully qualified domain name"
COPY apache/apache2.conf /etc/apache2/apache2.conf
# ports.conf is usuable for commands running directly in the vm
COPY apache/ports.conf /etc/apache2/ports.conf
# Hide server infos
COPY apache/security.conf /etc/apache2/conf-available/security.conf

# Copy php.ini files for cli and fpm
COPY php/$PHP_VERSION/cli/php.ini /etc/php/$PHP_VERSION/cli/php.ini
COPY php/$PHP_VERSION/fpm/php.ini /etc/php/$PHP_VERSION/fpm/php.ini
COPY php/$PHP_VERSION/fpm/www.conf /etc/php/$PHP_VERSION/fpm/pool.d/www.conf

COPY apache/http-vhosts.conf /etc/apache2/sites-available/http-vhosts.conf
RUN a2enmod proxy_fcgi
RUN a2ensite http-vhosts.conf

RUN curl -sL https://deb.nodesource.com/setup_14.x -o nodesource_setup.sh
RUN bash nodesource_setup.sh
RUN apt install -y nodejs
RUN curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor | tee /usr/share/keyrings/yarnkey.gpg >/dev/null
RUN echo "deb [signed-by=/usr/share/keyrings/yarnkey.gpg] https://dl.yarnpkg.com/debian stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt update
RUN apt install yarn -y
RUN apt-get install rsync -y
RUN apt-get install unoconv -y

RUN mkdir -p /.cache
RUN mkdir -p /var/www/.cache
RUN mkdir -p /var/www/.config
RUN chmod 777 -R /var/www/.cache
RUN chown www-data:www-data -R /var/www
RUN chmod 775 -R /var/www

RUN apt-get install dos2unix -y
RUN apt-get install php$PHP_VERSION-xdebug -y

# Add a user and map it to the host user's ID. This creates the "/home/host-user" as home directory (instead of "/" which causes permissions errors with composer and yarn).
RUN useradd -m host-user
RUN usermod -u 1000 host-user
RUN groupmod -g 1000 host-user

EXPOSE 80

COPY entrypoint/entrypoint.sh /script/entrypoint.sh
RUN chmod 755 /script/entrypoint.sh
RUN dos2unix  /script/entrypoint.sh

#xdebug
RUN pecl install xdebug-3.3.1 \
    && echo "xdebug.mode=debug" >> /etc/php/$PHP_VERSION/mods-available/xdebug.ini \
    && echo "xdebug.client_host=host.docker.internal" >> /etc/php/$PHP_VERSION/mods-available/xdebug.ini \
    && echo "xdebug.start_with_request=yes" >> /etc/php/$PHP_VERSION/mods-available/xdebug.ini

RUN echo "xdebug.idekey = VSCODE" >> /etc/php/$PHP_VERSION/mods-available/xdebug.ini
#RUN echo "xdebug.log = /app/Symfony/xdebug.log" >> /etc/php/$PHP_VERSION/mods-available/xdebug.ini

#amqp for rabbitmq
RUN apt-get install php$PHP_VERSION-amqp -y

ENTRYPOINT ["/script/entrypoint.sh"]
CMD ["sh"]