#!/usr/bin/env /bin/php
<?php

require __DIR__ . '/vendor/autoload.php';
date_default_timezone_set("Asia/Bangkok");
$agi = new AGI();

$to = $argv[1];
$from = $argv[2];

$permission = true;

$agi->set_variable("response",$permission);
$agi->set_variable("time",date("h:i:sa"));
$agi->set_variable("to",$to);
$agi->set_variable("from",$from);

//Database Connection
$db_host = "localhost";
$db_user = "root";
$db_pass = "";
$db_name = "crm";

$conn = new mysqli($db_host,$db_user,$db_pass,$db_name);

if($conn->connect_error){
	die($conn->connect_error);
}

$tsql = "SELECT * FROM users LIMIT 1";
$result = $conn->query($tsql);

if($result->num_rows > 0){
	$row = $result->fetch_assoc();
}



