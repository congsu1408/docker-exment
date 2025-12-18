ARG PHP_VERSION

FROM php:${PHP_VERSION}-fpm

# install php-ext
RUN apt-get update && apt-get install -y git wget gnupg vim unzip libxml2-dev libpng-dev libzip-dev libonig-dev default-mysql-client libldap2-dev\
  && docker-php-ext-install mbstring dom gd zip pdo_mysql ftp ldap\
  && apt-get clean

# Some environments enforce SSL for MySQL client tools via global defaults,
# while the target DB server (especially MariaDB in CI) may not support SSL.
# Provide wrappers that disable ssl-mode only when the client supports it.
RUN set -eu; \
  cat > /usr/local/bin/mysql <<'EOF'\
#!/bin/sh\
set -eu\
REAL=/usr/bin/mysql\
if "$REAL" --help 2>/dev/null | grep -q -- '--ssl-mode'; then\
  exec "$REAL" --ssl-mode=DISABLED "$@"\
fi\
exec "$REAL" "$@"\
EOF\
  ; chmod +x /usr/local/bin/mysql; \
  cat > /usr/local/bin/mysqldump <<'EOF'\
#!/bin/sh\
set -eu\
REAL=/usr/bin/mysqldump\
if "$REAL" --help 2>/dev/null | grep -q -- '--ssl-mode'; then\
  exec "$REAL" --ssl-mode=DISABLED "$@"\
fi\
exec "$REAL" "$@"\
EOF\
  ; chmod +x /usr/local/bin/mysqldump

# install pre sql server driver
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
  && curl https://packages.microsoft.com/config/ubuntu/20.04/prod.list | tee /etc/apt/sources.list.d/msprod.list \
  && apt-get update \
  && apt-get install -y unixodbc-dev=2.3.7 unixodbc=2.3.7 odbcinst1debian2=2.3.7 odbcinst=2.3.7 libgssapi-krb5-2 \
  && ACCEPT_EULA=Y apt-get install -y msodbcsql17 mssql-tools

# install sql server driver
RUN pecl install sqlsrv && pecl install pdo_sqlsrv && docker-php-ext-enable sqlsrv && docker-php-ext-enable pdo_sqlsrv

# install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

COPY .env /var/www/exment/.env
WORKDIR /var/www/exment
