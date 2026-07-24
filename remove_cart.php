<?php
include "dbconnection.php";

$data = json_decode(file_get_contents("php://input"), true);

$user_id = intval($data['user_id']);
$product_id = intval($data['product_id']);

mysqli_query($conn,
  "DELETE FROM cart
   WHERE user_id=$user_id AND product_id=$product_id"
);

echo json_encode(["success"=>true]);
