ARG DEBIAN_RELEASE=12.11

FROM debian:${DEBIAN_RELEASE} AS builder

ARG PHP_VERSION=8.3

# Set environment variables early to cache them
ENV TZ=Europe/Paris
ENV LANG=C.UTF-8
ENV DEBIAN_FRONTEND=noninteractive

# Install all APT packages in a single RUN to reduce layers and cache updates
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        make \
        git \
        locales \
        acl \
        curl \
        wget \
        gnupg \
        ca-certificates \
        apt-transport-https \
        lsb-release \
        apache2 \
        php${PHP_VERSION} \
        php${PHP_VERSION}-pdo-mysql \
        php${PHP_VERSION}-fpm \
        php${PHP_VERSION}-dev \
        php-pear \
        php${PHP_VERSION}-xml \
        php${PHP_VERSION}-ldap \
        php${PHP_VERSION}-zip \
        php${PHP_VERSION}-curl \
        php${PHP_VERSION}-gd \
        php${PHP_VERSION}-mbstring \
        php${PHP_VERSION}-intl \
        php${PHP_VERSION}-amqp \
        unzip \
        nodejs \
        yarn \
        rsync \
        dos2unix && \
    # Clean up APT cache to reduce image size
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set timezone and locale
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone && \
    update-locale LANG=C.UTF-8

# Install PHP repository (Sury)
RUN wget -qO - https://packages.sury.org/php/apt.gpg | apt-key add - && \
    echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list && \
    apt-get update && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --quiet && \
    mv composer.phar /usr/local/bin/composer && \
    composer self-update --2 --quiet

# Install Symfony CLI
RUN curl -1sLf 'https://dl.cloudsmith.io/public/symfony/stable/setup.deb.sh' | bash && \
    apt-get update && \
    apt-get install -y --no-install-recommends symfony-cli && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Node.js and Yarn
RUN apt-get update && \
    apt-get install -y ca-certificates curl gnupg && \
    mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" > /etc/apt/sources.list.d/nodesource.list && \
    apt-get update && \
    apt-get install -y nodejs && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Yarn
RUN curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor > /usr/share/keyrings/yarnkey.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/yarnkey.gpg] https://dl.yarnpkg.com/debian stable main" > /etc/apt/sources.list.d/yarn.list && \
    apt-get update && \
    apt-get install -y yarn && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Xdebug via PECL
RUN pecl install xdebug-3.3.1 && \
    echo "xdebug.mode=debug" >> /etc/php/${PHP_VERSION}/mods-available/xdebug.ini && \
    echo "xdebug.client_host=host.docker.internal" >> /etc/php/${PHP_VERSION}/mods-available/xdebug.ini && \
    echo "xdebug.start_with_request=yes" >> /etc/php/${PHP_VERSION}/mods-available/xdebug.ini && \
    echo "xdebug.idekey=VSCODE" >> /etc/php/${PHP_VERSION}/mods-available/xdebug.ini

# Final image
FROM debian:${DEBIAN_RELEASE}

# Copy only necessary files from builder
COPY --from=builder /usr/local/bin/composer /usr/local/bin/composer
COPY --from=builder /usr/bin/symfony /usr/bin/symfony
COPY --from=builder /etc/php /etc/php
COPY --from=builder /usr/lib/php /usr/lib/php
COPY --from=builder /usr/share/php /usr/share/php
COPY --from=builder /usr/bin/node /usr/bin/node
COPY --from=builder /usr/bin/npm /usr/bin/npm
COPY --from=builder /usr/bin/yarn /usr/bin/yarn
COPY --from=builder /etc/apt /etc/apt
COPY --from=builder /usr/share/keyrings/yarnkey.gpg /usr/share/keyrings/yarnkey.gpg
COPY --from=builder /usr/share/zoneinfo /usr/share/zoneinfo
COPY --from=builder /etc/timezone /etc/timezone
COPY --from=builder /etc/localtime /etc/localtime
COPY --from=builder /etc/locale.gen /etc/locale.gen
COPY --from=builder /usr/lib/locale /usr/lib/locale

# Install runtime dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        apache2 \
        php${PHP_VERSION} \
        php${PHP_VERSION}-pdo-mysql \
        php${PHP_VERSION}-fpm \
        php${PHP_VERSION}-xml \
        php${PHP_VERSION}-ldap \
        php${PHP_VERSION}-zip \
        php${PHP_VERSION}-curl \
        php${PHP_VERSION}-gd \
        php${PHP_VERSION}-mbstring \
        php${PHP_VERSION}-intl \
        php${PHP_VERSION}-amqp \
        unzip \
        rsync \
        dos2unix && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy configuration files
COPY apache/apache2.conf /etc/apache2/apache2.conf
COPY apache/ports.conf /etc/apache2/ports.conf
COPY apache/security.conf /etc/apache2/conf-available/security.conf
COPY php/8.x/cli/php.ini /etc/php/${PHP_VERSION}/cli/php.ini
COPY php/8.x/fpm/php.ini /etc/php/${PHP_VERSION}/fpm/php.ini
COPY php/8.x/fpm/www.conf /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf
COPY apache/http-vhosts.conf /etc/apache2/sites-available/http-vhosts.conf

# Configure Apache
RUN a2enmod proxy_fcgi && \
    a2ensite http-vhosts.conf

# Set up directories and permissions
RUN mkdir -p /.cache /var/www/.cache /var/www/.config && \
    chmod 777 -R /var/www/.cache && \
    chown www-data:www-data -R /var/www && \
    chmod 775 -R /var/www

# Create user
RUN groupadd -g 1000 host-user && \
    useradd -m -u 1000 -g host-user host-user && \
    usermod -aG www-data host-user

# Expose port
EXPOSE 80

# Copy and configure entrypoint
COPY entrypoint/entrypoint.sh /script/entrypoint.sh
RUN chmod 755 /script/entrypoint.sh && \
    dos2unix /script/entrypoint.sh

# Set entrypoint and default command
ENTRYPOINT ["/script/entrypoint.sh"]
CMD ["sh"]