<?php

date_default_timezone_set("Asia/Kolkata");
header("Content-Type: application/json");


$conn = new mysqli("localhost", "root", "", "fertismart", 3307);

if ($conn->connect_error) {
    echo json_encode([
        "status" => false,
        "message" => "DB connection failed: " . $conn->connect_error
    ]);
    exit;
}


$conn->query("SET time_zone = '+05:30'");


$data = json_decode(file_get_contents("php://input"), true);
if (!is_array($data)) {
    echo json_encode([
        "status" => false,
        "message" => "Invalid request format"
    ]);
    exit;
}

$email = trim($data['email'] ?? '');
$otp   = trim($data['otp'] ?? '');

if ($email === '' || $otp === '') {
    echo json_encode([
        "status" => false,
        "message" => "Email & OTP are required"
    ]);
    exit;
}


$stmt = $conn->prepare("SELECT otp, otp_expiry FROM user WHERE email=?");
$stmt->bind_param("s", $email);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows !== 1) {
    echo json_encode([
        "status" => false,
        "message" => "User not found"
    ]);
    exit;
}

$row = $result->fetch_assoc();


if ((string)$row['otp'] !== (string)$otp) {
    echo json_encode([
        "status" => false,
        "message" => "Invalid OTP code"
    ]);
    exit;
}


$current_time = time();
$expiry_time  = strtotime($row['otp_expiry']);

if ($expiry_time === false || $expiry_time === 0) {
    echo json_encode([
        "status" => false,
        "message" => "OTP expiry data is missing or invalid"
    ]);
    exit;
}


if ($current_time > $expiry_time) {
    echo json_encode([
        "status" => false,
        "message" => "OTP expired",
        "debug_info" => [
            "current_server_time" => date("Y-m-d H:i:s", $current_time),
            "database_expiry"     => $row['otp_expiry']
        ]
    ]);
    exit;
}



echo json_encode([
    "status" => true,
    "message" => "OTP verified successfully!"
]);

$stmt->close();
$conn->close();
?>