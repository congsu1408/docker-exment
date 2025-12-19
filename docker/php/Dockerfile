ARG PHP_VERSION

FROM php:${PHP_VERSION}-fpm

# install php-ext
RUN apt-get update && apt-get install -y git wget gnupg vim unzip libxml2-dev libpng-dev libzip-dev libonig-dev default-mysql-client libldap2-dev\
  && docker-php-ext-install mbstring dom gd zip pdo_mysql ftp ldap\
  && apt-get clean

# Git 2.35+ blocks repos with mismatched ownership (common in CI volume mounts).
# Mark the mounted project directories as safe for all users.
RUN git config --system --add safe.directory /var/www/exment \
  && git config --system --add safe.directory /var/www/exment/exment

# mysql/mysqldump: default to non-SSL in CI where server doesn't support TLS.
# If the caller already specifies any SSL option, do not override it.
RUN set -eu; \
  for tool in mysql mysqldump; do \
    printf '%s\n' \
      '#!/usr/bin/env sh' \
      'set -eu' \
      '' \
      'tool_name="$(basename "$0")"' \
      '' \
      '# Bypass /usr/local/bin (this wrapper) when resolving the real binary.' \
      'real="$(PATH=/usr/bin:/bin command -v "$tool_name" || true)"' \
      'if [ -z "$real" ]; then real="/usr/bin/$tool_name"; fi' \
      '' \
      'has_ssl=0' \
      'for arg in "$@"; do' \
      '  case "$arg" in' \
      '    --ssl-mode|--ssl-mode=*|--ssl|--ssl-*) has_ssl=1 ;;' \
      '  esac' \
      'done' \
      '' \
      'if [ "$has_ssl" -eq 0 ]; then' \
      '  exec "$real" --ssl-mode=DISABLED "$@"' \
      'else' \
      '  exec "$real" "$@"' \
      'fi' \
      > "/usr/local/bin/$tool"; \
    chmod +x "/usr/local/bin/$tool"; \
  done

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
