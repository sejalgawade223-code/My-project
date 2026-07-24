<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
error_reporting(0);
include "dbconnection.php";

$con = dbconnection();

$order_id = $_POST['order_id'] ?? '';
$status   = $_POST['status'] ?? '';

if ($order_id == '' || $status == '') {
    echo json_encode(["status" => "error"]);
    exit;
}

$q = mysqli_query($con, "
    UPDATE orders
    SET status='$status'
    WHERE order_id='$order_id'
");

if ($q) {
    echo json_encode(["status" => "success"]);
} else {
    echo json_encode(["status" => "failed"]);
}
