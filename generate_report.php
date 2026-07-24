<?php

$conn = new mysqli("localhost", "root", "", "fertismart",3307);

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}


$type = isset($_GET['type']) ? $_GET['type'] : 'weekly';


if ($type == 'monthly') {
    $filename = "Monthly_Report_" . date('Y-m') . ".csv";
    $query = "SELECT order_id, customer_name, total_amount, payment_status, created_at FROM orders WHERE created_at >= DATE_SUB(NOW(), INTERVAL 1 MONTH)";
} else {
    $filename = "Weekly_Report_" . date('Y-m-d') . ".csv";
    $query = "SELECT order_id, customer_name, total_amount, payment_status, created_at FROM orders WHERE created_at >= DATE_SUB(NOW(), INTERVAL 1 WEEK)";
}

$result = $conn->query($query);


header('Content-Type: text/csv');
header('Content-Disposition: attachment; filename="' . $filename . '"');

$output = fopen('php://output', 'w');


fputcsv($output, array('Order ID', 'Customer Name', 'Total Amount', 'Payment Status', 'Order Date'));

while ($row = $result->fetch_assoc()) {
    fputcsv($output, $row);
}

fclose($output);
$conn->close();
?>