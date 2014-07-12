FROM debian:wheezy
 
ENV DEBIAN_FRONTEND noninteractive
 
RUN apt-get update -y
RUN apt-get install -y \
 curl 

RUN echo "deb http://packages.dotdeb.org wheezy-php55 all" >> /etc/apt/sources.list
RUN echo "deb-src http://packages.dotdeb.org wheezy-php55 all" >> /etc/apt/sources.list 
RUN curl http://www.dotdeb.org/dotdeb.gpg > /root/dotdeb.gpg
RUN apt-key add /root/dotdeb.gpg

RUN apt-get update
RUN apt-get install -y php5-cli

RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer

RUN composer global require 'phpunit/phpunit=4.1.*'


#Les tests sur le finder (et notamment testIgnoredAccessDeniedException et testAccessDeniedException)
#ne peuvent être lancés en root
RUN useradd tests

#permet de lancer ProfilerTest
RUN apt-get install -y php5-sqlite


#permet de faire fonctionner src/Symfony/Component/Process/Tests/SimpleProcessTest.php ::testSignal
RUN sed --in-place '/disable_functions/d' /etc/php5/cli/php.ini

RUN apt-get install -y wget build-essential
	
RUN wget http://download.icu-project.org/files/icu4c/51.2/icu4c-51_2-src.tgz -O	 /root/icu4c-51_2-src.tgz
RUN cd /root && tar -zxf icu4c-51_2-src.tgz
RUN cd /root/icu/source/ && ./configure && make && make install

RUN apt-get install -y php-pear php5-dev
RUN pecl update-channels
RUN pecl install intl-3.0.0

RUN echo 'date.timezone = Europe/Paris' >> /etc/php5/cli/php.ini
RUN echo 'extension=intl.so' >> /etc/php5/cli/php.ini
RUN echo 'intl.error_level=0' >> /etc/php5/cli/php.ini
RUN echo 'intl.default_locale=en' >> /etc/php5/cli/php.ini
RUN echo 'intl.use_exceptions=0' >>  /etc/php5/cli/php.ini


#permet de faire fonctionner testDumpNumericValueWithLocale
#Symfony\Component\Yaml\Tests\InlineTest
RUN apt-get install -y locales
RUN cat /etc/locale.gen
RUN sed -i "s/^# fr_FR/fr_FR/" /etc/locale.gen
RUN locale-gen
RUN update-locale LANG=fr_FR.UTF-8

#permet de lancer Symfony\Component\HttpFoundation\Tests\Session\Storage\Handler\MemcacheSessionHandlerTest
RUN echo 'deb http://packages.dotdeb.org wheezy all' >> /etc/apt/sources.list
RUN echo 'deb-src http://packages.dotdeb.org wheezy all' >> /etc/apt/sources.list
RUN apt-get update
RUN apt-get install -y php5-memcached

#permet de lancer src/Symfony/Component/HttpFoundation/Tests/Session/Storage/Handler/MemcacheSessionHandlerTest.php
RUN apt-get install -y php5-memcache

#permet de lancer src/Symfony/Component/HttpFoundation/Tests/Session/Storage/Handler/MongoDbSessionHandlerTest.php
RUN apt-get install -y php5-mongo
RUN mkdir -p /data/db
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10
RUN echo 'deb http://downloads-distro.mongodb.org/repo/debian-sysvinit dist 10gen' | tee /etc/apt/sources.list.d/10gen.list
RUN apt-get update
RUN apt-get install -y -q mongodb-org
RUN sed --in-place "/bind_ip/d" /etc/mongod.conf
RUN echo 'nojournal = true' >> /etc/mongod.conf
RUN apt-get install -y netcat
RUN usermod -a -G mongodb tests
RUN chmod 777 /var/log/mongodb


# permet de faire fonctionner ces tests : 
#   src/Symfony/Component/Finder/Tests/Iterator/RecursiveDirectoryIteratorTest.php
#   src/Symfony/Component/Finder/Tests/FinderTest.php
# parfois ils échouent car le ftp inacessible
# on va donc faire pointer ftp.mozilla.org vers un ftp local
# où se trouvera la même structure de fichiers
RUN echo '127.0.0.1 ftp.mozilla.org' > /tmp/hosts
RUN mkdir -p -- /lib-override && cp /lib/x86_64-linux-gnu/libnss_files.so.2 /lib-override
RUN perl -pi -e 's:/etc/hosts:/tmp/hosts:g' /lib-override/libnss_files.so.2
ENV LD_LIBRARY_PATH /lib-override
RUN apt-get install -y vsftpd
RUN apt-get install -y telnet
RUN apt-get install -y ftp
RUN mkdir /tmp/ftp
RUN mkdir /tmp/ftp_chroot
RUN echo 'secure_chroot_dir=/tmp/ftp_chroot' >> /etc/vsftpd.conf
RUN echo 'local_enable=NO' >> /etc/vsftpd.conf
RUN echo 'write_enable=NO' >> /etc/vsftpd.conf
RUN echo 'anon_root=/tmp/ftp' >> /etc/vsftpd.conf
RUN touch /tmp/ftp/README
RUN touch /tmp/ftp/index.html
RUN touch /tmp/ftp/pub


ADD add_exclude_tests.php /usr/local/bin/add_exclude_tests.php


WORKDIR /var/www
VOLUME ["/var/www"]

ADD entrypoint /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["--exclude-group", "benchmark"]

