<?php
header("Content-Type: application/json");
include("dbconnection.php");
$con = dbconnection();

$cart_id = $_POST['cart_id'];
$type = $_POST['type'];

if ($type == 'inc') {
    $sql = "UPDATE cart SET quantity = quantity + 1 WHERE cart_id=?";
} else {
    $sql = "UPDATE cart SET quantity = IF(quantity>1, quantity-1, 1) WHERE cart_id=?";
}

$stmt = mysqli_prepare($con, $sql);
mysqli_stmt_bind_param($stmt, "i", $cart_id);
mysqli_stmt_execute($stmt);

echo json_encode(["success" => true]);

