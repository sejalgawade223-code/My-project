<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
error_reporting(0);
include "dbconnection.php";

$con = dbconnection();

$orders = [];

$q = mysqli_query($con, "
    SELECT
        order_id,
        u_id,
        customer_name,
        customer_address,
        customer_contact,
        total_amount,
        payment_method,
        status,
        created_at
    FROM orders
    ORDER BY order_id DESC
");



while ($row = mysqli_fetch_assoc($q)) {
    $orders[] = $row;
}

echo json_encode($orders);

