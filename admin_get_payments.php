<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
error_reporting(E_ALL);
ini_set('display_errors', 1);

include "dbconnection.php";
$con = dbconnection();

if (!$con) {
    echo json_encode(["status" => "error", "message" => "DB connection failed"]);
    exit;
}

$filter = $_GET['filter'] ?? 'All';

$sql = "SELECT
            p.order_id,
            p.u_id,
            p.payment_id,
            p.razorpay_order_id,
            p.amount,
            p.payment_status,
            p.payment_date,
            o.customer_name,
            o.payment_method,
            o.created_at
        FROM payments p
        JOIN orders o ON p.order_id = o.order_id";

if ($filter == 'Online') {
    $sql .= " WHERE o.payment_method = 'Online'";
} elseif ($filter == 'COD') {
    $sql .= " WHERE o.payment_method = 'COD'";
}


$result = mysqli_query($con, $sql);

$payments_list = [];

if ($result) {
    while ($row = mysqli_fetch_assoc($result)) {
        $payments_list[] = $row;
    }
    echo json_encode($payments_list);
} else {
    echo json_encode(["status" => "error", "message" => mysqli_error($con)]);
}
?>