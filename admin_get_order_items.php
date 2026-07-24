<?php
header("Content-Type: application/json");
error_reporting(0);
include "dbconnection.php";

$con = dbconnection();
$order_id = $_GET['order_id'] ?? '';

if ($order_id == '') {
    echo json_encode([]);
    exit;
}

$data = [];

$q = mysqli_query($con, "
    SELECT
        o_i_id.quantity,
        o_i_id.price,
        p.name AS product_name
    FROM order_items o_i_id
    JOIN products p ON o_i_id.p_id = p.p_id
    WHERE o_i_id.order_id = '$order_id'
");

while ($row = mysqli_fetch_assoc($q)) {
    $data[] = $row;
}

echo json_encode($data);
