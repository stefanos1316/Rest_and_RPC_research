<?php

require 'vendor/autoload.php';
use JsonRPC\Server;

$server = new Server();
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
