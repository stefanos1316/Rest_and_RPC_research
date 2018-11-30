<?php

require 'vendor/autoload.php';

$url = "http://195.251.251.27:8001/hello";
$client = new GuzzleHttp\Client();

for ( $i = 0; $i < 20000; $i++) {
	$res = $client->request('GET', 'http://195.251.251.27:8001/hello', [
    		'auth' => [NULL, NULL]
	]);
}
	echo $res->getStatusCode();

?>
