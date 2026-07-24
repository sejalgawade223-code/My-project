<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
error_reporting(0);
include "dbconnection.php";

$con = dbconnection();

if (!$con) {
    echo json_encode([]);
    exit;
}

$q = mysqli_query(
    $con,
    "SELECT u_id, name, email, address, contact_no,role FROM user ORDER BY u_id DESC"
);

if (!$q) {
    echo json_encode([]);
    exit;
}

$users = [];
while ($row = mysqli_fetch_assoc($q)) {
    $users[] = $row;
}

echo json_encode($users);
?>
