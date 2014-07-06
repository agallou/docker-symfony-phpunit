FROM debian:wheezy
 
ENV DEBIAN_FRONTEND noninteractive
 
RUN apt-get update -y
RUN apt-get install -y \
 curl \
 php5-cli php5-json php5-curl


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
#RUN pear install pecl
RUN pecl update-channels


RUN apt-get install -y php5-intl 
RUN apt-get install -y php-apc 

RUN echo 'date.timezone = Europe/Paris' >> /etc/php5/cli/php.ini


#permet de faire fonctionner testDumpNumericValueWithLocale
#Symfony\Component\Yaml\Tests\InlineTest
RUN apt-get install -y locales
RUN cat /etc/locale.gen
RUN sed -i "s/^# fr_FR/fr_FR/" /etc/locale.gen
RUN locale-gen
RUN update-locale LANG=fr_FR.UTF-8

USER tests

WORKDIR /var/www
VOLUME ["/var/www"]


CMD ["--exclude-group", "benchmark"]

ENTRYPOINT ["/.composer/vendor/bin/phpunit"]

