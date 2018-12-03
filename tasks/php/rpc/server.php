<?php

require 'vendor/autoload.php';
use JsonRPC\Server;

$server = new Server();
$server->allowHosts(['195.251.251.22:8080']);
$server->getProcedureHandler()
    ->withCallback('addition', function ($a, $b) {
        return $a + $b;
    })
    ->withCallback('random', function ($start, $end) {
        return mt_rand($start, $end);
    })
    ->withCallback('helloWord', function ($a) {
	return "Hello word" . $a;		
    })
;

echo $server->execute();
?>
