<?php
error_reporting(E_ALL & ~E_NOTICE);
ini_set('display_errors', 0);
header("Content-Type: application/json");

$conn = new mysqli("localhost","root","","fertismart",3307);

if ($conn->connect_error) {
    echo json_encode(["success" => false, "error" => $conn->connect_error]);
    exit;
}

$data = json_decode(file_get_contents("php://input"), true);

$uid     = $data['u_id'] ?? null;
$name    = $data['name'] ?? '';
$address = $data['address'] ?? '';
$contact = $data['contact_no'] ?? '';

if ($uid === null) {
    echo json_encode(["success" => false, "error" => "User ID missing"]);
    exit;
}


$stmt = $conn->prepare("UPDATE `user` SET name=?, address=?, contact_no=? WHERE u_id=?");
$stmt->bind_param("sssi", $name, $address, $contact, $uid);

if ($stmt->execute()) {
    echo json_encode(["success" => true]);
} else {
    echo json_encode(["success" => false, "error" => $stmt->error]);
}

$stmt->close();
$conn->close();
