<?php

$filePath = $argv[1];

$excludeSkippedAndIncomplete = true;

if (!is_file($filePath)) {
    throw new \InvalidArgumentException(sprintf('File %s does not exists', $filePath));
}

$dom = new DOMDocument();
$dom->load($filePath);

$xPath = new DOMXPath($dom);
$testSuiteSearch = $xPath->query('//testsuites/testsuite');

if (1 !== $testSuiteSearch->length) {
    throw new \InvalidArgumentException('Invalid PHPUnit config file');
}

$testSuiteNode = $testSuiteSearch->item(0);

$failingTests = array(
    //Test non à jour ?
    './src/Symfony/Component/Intl/Tests/ResourceBundle/Reader/BinaryBundleReaderTest.php',
    './src/Symfony/Component/Intl/Tests/DateFormatter/AbstractIntlDateFormatterTest.php',
    './src/Symfony/Component/Intl/Tests/DateFormatter/IntlDateFormatterTest.php',
    './src/Symfony/Component/Intl/Tests/DateFormatter/Verification/IntlDateFormatterTest.php',

    //Sigchild environnment ?
    './src/Symfony/Component/Process/Tests/SigchildDisabledProcessTest.php',
    './src/Symfony/Component/Process/Tests/SigchildEnabledProcessTest.php',

    //proc_open(/dev/tty): failed to open stream: No such device or address
    './src/Symfony/Component/Process/Tests/SimpleProcessTest.php',
);

$excludedTests = array(
// skipped test

    // pourquoi le test remonte qu'on est en user root ?
    './src/Symfony/Component/HttpFoundation/Tests/File/MimeType/MimeTypeTest.php',

    //Pas de constante PHP_BINARY alors qu'on est en 5.5 et qu'elle se trouve à partir de 5.4 ?
    './src/Symfony/Component/Process/Tests/PhpExecutableFinderTest.php',

    //Le test semble inutile (test toujours skipped)
    './src/Symfony/Bridge/Doctrine/Tests/Form/ChoiceList/UnloadedEntityChoiceListCompositeIdTest.php',
    './src/Symfony/Bridge/Doctrine/Tests/Form/ChoiceList/UnloadedEntityChoiceListCompositeIdWithQueryBuilderTest.php',
    './src/Symfony/Bridge/Doctrine/Tests/Form/ChoiceList/UnloadedEntityChoiceListSingleIntIdTest.php',
    './src/Symfony/Bridge/Doctrine/Tests/Form/ChoiceList/UnloadedEntityChoiceListSingleIntIdWithQueryBuilderTest.php',
    './src/Symfony/Bridge/Doctrine/Tests/Form/ChoiceList/UnloadedEntityChoiceListSingleStringIdTest.php',
    './src/Symfony/Bridge/Doctrine/Tests/Form/ChoiceList/UnloadedEntityChoiceListSingleStringIdWithQueryBuilderTest.php',


//Incomplete tests

    //Needs to be reimplemented using validators
    './src/Symfony/Component/Form/Tests/Extension/Core/Type/TimeTypeTest.php',

    //The Yaml Dumper currently does not support prototyped arrays
    './src/Symfony/Component/Config/Tests/Definition/Dumper/YamlReferenceDumperTest.php',

);


$groups = array(
  // APC alors que l'on se trouve en version 5.5
  'apc' => array(
    './src/Symfony/Component/ClassLoader/Tests/ApcUniversalClassLoaderTest.php',
    './src/Symfony/Component/Validator/Tests/Mapping/Cache/ApcCacheTest.php',
    './src/Symfony/Bundle/FrameworkBundle/Tests/DependencyInjection/FrameworkExtensionTest.php',
    './src/Symfony/Bundle/FrameworkBundle/Tests/DependencyInjection/PhpFrameworkExtensionTest.php',
    './src/Symfony/Bundle/FrameworkBundle/Tests/DependencyInjection/YamlFrameworkExtensionTest.php',
    './src/Symfony/Bundle/FrameworkBundle/Tests/DependencyInjection/XmlFrameworkExtensionTest.php',
  ),
  'ci_fs' => array(
    //Contient un test pour windows (système de fichier case insensitive, créer un groupe ?)
    './src/Symfony/Component/Debug/Tests/DebugClassLoaderTest.php',
    './src/Symfony/Component/Debug/Tests/FatalErrorHandler/ClassNotFoundFatalErrorHandlerTest.php',
  ),
  'windows' => array(
    './src/Symfony/Component/Process/Tests/SimpleProcessTest.php',
  ),
  '32bits' => array(
    './src/Symfony/Component/Form/Tests/Extension/Core/Type/DateTypeTest.php',
    './src/Symfony/Component/Intl/Tests/NumberFormatter/NumberFormatterTest.php',
    './src/Symfony/Component/Intl/Tests/NumberFormatter/Verification/NumberFormatterTest.php',
  ),
  'ipv6' => array(
    //contient deux  cas distints : PHP compilé avec option disable-ipv6 et sans
    './src/Symfony/Component/HttpFoundation/Tests/IpUtilsTest.php',
  ),
  'php53' => array(
    //Contient un test spécifique à php 5.3
    './src/Symfony/Component/HttpFoundation/Tests/Session/Storage/NativeSessionStorageTest.php',
    './src/Symfony/Component/HttpFoundation/Tests/Session/Storage/PhpBridgeSessionStorageTest.php',
    './src/Symfony/Component/HttpFoundation/Tests/Session/Storage/Proxy/AbstractProxyTest.php',
  ),
);


foreach ($failingTests as $excludedFile) {
    $testSuiteNode->appendChild($dom->createElement('exclude', $excludedFile));
}

if ($excludeSkippedAndIncomplete) {
  foreach ($excludedTests as $excludedFile) {
      $testSuiteNode->appendChild($dom->createElement('exclude', $excludedFile));
  }

  foreach ($groups as $name => $files) {
    foreach ($files as $file) {
      $testSuiteNode->appendChild($dom->createElement('exclude', $file));
    }
  }
}


$dom->save($filePath);
