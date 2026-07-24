<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");

include "dbconnection.php";
$con = dbconnection();

$order_id = $_POST['order_id'];
$refund_status = $_POST['refund_status'];


$sql = "UPDATE cancel_order SET refund_status = '$refund_status' WHERE order_id = '$order_id'";

if (mysqli_query($con, $sql)) {
    echo json_encode(["status" => "success", "message" => "Refund status updated"]);
} else {
    echo json_encode(["status" => "error", "message" => mysqli_error($con)]);
}
?>