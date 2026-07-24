<?php
header("Content-Type: application/json");
error_reporting(E_ALL);
ini_set('display_errors', 1);

include "dbconnection.php";
$con = dbconnection();

if (!$con) {
  echo json_encode(["status"=>"error","message"=>"DB failed"]);
  exit;
}

$u_id = $_POST['u_id'] ?? '';
$payment_method = $_POST['payment_method'] ?? '';
$cart_items = json_decode($_POST['cart_items'] ?? '[]', true);

if ($u_id == '' || empty($cart_items)) {
  echo json_encode(["status"=>"error","message"=>"Invalid data"]);
  exit;
}


$user_q = mysqli_query($con,"
  SELECT name, address, contact_no
  FROM `user`
  WHERE u_id='$u_id'
");

$u = mysqli_fetch_assoc($user_q);


$total = 0;
foreach ($cart_items as $i) {
  $price = floatval($i['price']);
  $qty   = intval($i['quantity']);
  $total += ($price * $qty);
}


mysqli_query($con,"
INSERT INTO orders (
  u_id,
  customer_name,
  customer_address,
  customer_contact,
  total_amount,
  payment_method,
  status
) VALUES (
  '$u_id',
  '{$u['name']}',
  '{$u['address']}',
  '{$u['contact_no']}',
  '$total',
  '$payment_method',
  'Confirmed'
)
");

$order_id = mysqli_insert_id($con);


foreach ($cart_items as $i) {
  $p_id  = intval($i['p_id']);
  $qty   = intval($i['quantity']);
  $price = floatval($i['price']);

  mysqli_query($con,"
    INSERT INTO order_items (
      order_id,
      p_id,
      quantity,
      price
    ) VALUES (
      '$order_id',
      '$p_id',
      '$qty',
      '$price'
    )
  ");
}


mysqli_query($con,"DELETE FROM cart WHERE u_id='$u_id'");


echo json_encode([
  "status" => "success",
  "order_id" => $order_id
]);
exit;
