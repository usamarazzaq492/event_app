<?php
$env = parse_ini_file('.env');
$mysqli = new mysqli($env['DB_HOST'], $env['DB_USERNAME'], $env['DB_PASSWORD'], $env['DB_DATABASE']);
$res = $mysqli->query("SELECT * FROM events ORDER BY eventId DESC LIMIT 1");
print_r($res->fetch_assoc());
