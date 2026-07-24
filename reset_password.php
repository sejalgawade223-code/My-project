<?php
header("Content-Type: application/json");

$conn = new mysqli("localhost","root","","fertismart",3307);
if ($conn->connect_error) {
    echo json_encode(["status"=>false,"message"=>"DB connection failed"]);
    exit;
}

$data = json_decode(file_get_contents("php://input"), true);
$email = trim($data['email'] ?? '');
$password = trim($data['password'] ?? '');
$confirm = trim($data['confirm_password'] ?? '');

if ($email==='' || $password==='' || $confirm===''){
    echo json_encode(["status"=>false,"message"=>"All fields required"]);
    exit;
}

if ($password !== $confirm){
    echo json_encode(["status"=>false,"message"=>"Passwords do not match"]);
    exit;
}


$hashed = password_hash($password, PASSWORD_BCRYPT);

$stmt = $conn->prepare("UPDATE user SET password=? WHERE email=?");
$stmt->bind_param("ss",$hashed,$email);

if ($stmt->execute() && $stmt->affected_rows>0){
    echo json_encode(["status"=>true,"message"=>"Password updated successfully"]);
} else {
    echo json_encode(["status"=>false,"message"=>"Invalid email or update failed"]);
}
?>

