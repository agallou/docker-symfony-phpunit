Docker Symfony PHPUnit
======================

Run your Symfony test suite inside a Docker container.

How to run the test suite
-------------------------

```
git clone https://github.com/symfony/symfony.git && cd symfony
docker run -t -i  --volume=$PWD:/var/www agallou/symfony-phpunit
```

Run it with an alias
--------------------

Add this to your .bashrc or zshrc:

```
alias symfony-phpunit="sudo docker run -t -i  --volume=\$PWD:/var/www agallou/symfony-phpunit \$@"
```

Then simply run `symfony-phpunit` inside your symfony directory.


Pass PHPunit options to the container
-------------------------------------

You can pass any PHPUnit option to the container like this: 

```
docker run -t -i  --volume=$PWD:/var/www agallou/symfony-phpunit src/Symfony/Component/Yaml
```

This will only run the tests inside the `src/Symfony/Component/Yaml` directory:

```
PHPUnit 4.1.3 by Sebastian Bergmann.

Configuration read from /var/www/phpunit.xml.dist

...............................................................  63 / 307 ( 20%)
............................................................... 126 / 307 ( 41%)
............................................................... 189 / 307 ( 61%)
............................................................... 252 / 307 ( 82%)
.......................................................

Time: 150 ms, Memory: 7.50Mb

OK (307 tests, 473 assertions)
```

You can also pass options when you are using the alias: 

```
symfony-phpunit src/Symfony/Component/Yaml
```
