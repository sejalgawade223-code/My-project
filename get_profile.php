<?php
header("Content-Type: application/json");

$conn = new mysqli("localhost","root","","fertismart",3307);

$userId = $_GET['u_id'] ?? '';

if ($userId == '') {
  echo json_encode(["success"=>false]);
  exit;
}

$q = $conn->query("
  SELECT name, email, address, contact_no
  FROM `user`
  WHERE u_id='$userId'
");

$data = $q->fetch_assoc();

echo json_encode([
  "success" => true,
  "user" => $data
]);
