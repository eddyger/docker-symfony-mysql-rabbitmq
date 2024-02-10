#!/bin/sh

chown www-data:www-data -R /app/Symfony/public
chmod 775 -R  /app/Symfony/public

# Start php-fpm and apache services and keep the container running
service php8.2-fpm start && apachectl -D FOREGROUND