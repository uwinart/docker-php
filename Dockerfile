# Version 0.0.1
FROM uwinart/base:latest

MAINTAINER Yurii Khmelevskii <y@uwinart.com>

# Set noninteractive mode for apt-get
ENV DEBIAN_FRONTEND noninteractive

RUN echo "deb http://packages.dotdeb.org wheezy all" >> /etc/apt/sources.list.d/dotdeb.list && \
  echo "deb-src http://packages.dotdeb.org wheezy all" >> /etc/apt/sources.list.d/dotdeb.list && \
  echo "deb http://packages.dotdeb.org wheezy-php56 all" >> /etc/apt/sources.list.d/dotdeb.list && \
  echo "deb-src http://packages.dotdeb.org wheezy-php56 all" >> /etc/apt/sources.list.d/dotdeb.list && \
  wget http://www.dotdeb.org/dotdeb.gpg -O- |apt-key add - && \
  apt-get update -q && \
  apt-get install -yq php5-dev php5-cli php5-fpm php5-pgsql php5-memcached php5-imagick php5-mongo php5-curl && \
  apt-get clean && \
  cd /usr/local/src && \
  wget http://alexeyrybak.com/blitz/all-releases/blitz-0.8.14.tar.gz && \
  tar xzf blitz-0.8.14.tar.gz && \
  rm -f blitz-0.8.14.tar.gz && \
  cd blitz-0.8.14 && \
  phpize && \
  ./configure --enable-blitz && \
  make install clean && \
  cd /etc/php5/mods-available && \
  touch blitz.ini && \
  echo "extension=blitz.so" | tee -a blitz.ini && \
  php5enmod blitz && \
  usermod -u 1000 www-data && \
  mkdir /var/log/php-fpm && \
  sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php5/fpm/php-fpm.conf && \
  sed -i -e "s/error_log\s*=.*/error_log = \/var\/log\/php-fpm\/php5-fpm.log/g" /etc/php5/fpm/php-fpm.conf && \
  sed -i -e "s/listen\s*=.*/listen = 0.0.0.0:9000/g" /etc/php5/fpm/pool.d/www.conf && \
  sed -i -e "s/upload_max_filesize\s*=.*/upload_max_filesize = 2000M/g" /etc/php5/fpm/php.ini && \
  sed -i -e "s/max_input_time\s*=.*/max_input_time = 900/g" /etc/php5/fpm/php.ini && \
  sed -i -e "s/max_execution_time\s*=.*/max_execution_time = 900/g" /etc/php5/fpm/php.ini && \
  sed -i -e "s/memory_limit\s*=.*/memory_limit = 1024M/g" /etc/php5/fpm/php.ini && \
  sed -i -e "s/pm\.max_children\s*=.*/pm\.max_children = 12/g" /etc/php5/fpm/pool.d/www.conf

RUN cd /usr/src/ && \
  wget http://sphinxsearch.com/files/sphinx-2.2.6-release.tar.gz && \
  tar -xvf sphinx-2.2.6-release.tar.gz && \
  rm sphinx-2.2.6-release.tar.gz && \
  cd sphinx-2.2.6-release/api/libsphinxclient && \
  ./configure && \
  make && \
  make install && \
  yes "" | pecl install sphinx && \
  cd /etc/php5/mods-available && \
  touch sphinx.ini && \
  echo "extension=sphinx.so" | tee -a sphinx.ini && \
  php5enmod sphinx

EXPOSE 9000

VOLUME ["/var/log/php-fpm"]

CMD ["/usr/sbin/php5-fpm"]
