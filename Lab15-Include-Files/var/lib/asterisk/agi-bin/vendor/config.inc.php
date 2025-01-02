<?php

//Database Connection
$db_host = "localhost";
$db_user = "otikadmin";
$db_pass = "P@ssw0rd";
$db_name = "pbxsystem";

$conn = new mysqli($db_host,$db_user,$db_pass,$db_name);

if($conn->connect_error){
        die($conn->connect_error);
}

?>
