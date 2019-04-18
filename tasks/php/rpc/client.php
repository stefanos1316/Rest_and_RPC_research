<?php

require 'vendor/autoload.php';
use JsonRPC\Client;

$client = new Client('https://195.251.251.27/rpc/server.php');
for ( $i = 0; $i < 20000; $i++) {
	//$result = $client->execute('addition', [3,5]);
	$result = $client->execute('helloWord', ['Stefanos']);
}
?>
