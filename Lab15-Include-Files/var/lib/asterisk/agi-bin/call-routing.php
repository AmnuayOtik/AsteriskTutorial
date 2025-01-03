#!/usr/bin/env /bin/php
<?php

require __DIR__ . '/vendor/autoload.php';
require __DIR__ . '/vendor/config.inc.php';

$agi = new AGI();

$to = $argv[1];
$from = $argv[2];

$permission = true;

$agi->set_variable("response",$permission);
$agi->set_variable("time",date("h:i:sa"));
$agi->set_variable("to",$to);
$agi->set_variable("from",$from);

$tsql = "SELECT route_to_internal_ext FROM call_routing WHERE customer_phone = '$to' LIMIT 1";
$result = $conn->query($tsql);

if($result->num_rows > 0){
	
	$row = $result->fetch_assoc();
	$route_to = $row['route_to'];

}else{
	$route_to = 'N/A';	
}

$agi->set_variable("route_to",$route_to);
$agi->set_variable("phone_no",$argv[2]);


$conn->close();

