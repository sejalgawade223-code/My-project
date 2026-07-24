<?php
ob_clean();
session_start();
header('Content-Type: application/json');
error_reporting(E_ALL);
ini_set('display_errors', 1);

include("dbconnection.php");
$con = dbconnection();

if (!$con) {
    echo json_encode(["success" => false, "message" => "Database connection failed"]);
    exit;
}

$email = trim($_POST['email'] ?? '');
$password = $_POST['password'] ?? '';

if ($email === '' || $password === '') {
    echo json_encode(["success" => false, "message" => "Email and password required"]);
    exit;
}

$stmt = mysqli_prepare($con, "SELECT u_id,name,email,password ,role FROM user WHERE email=?");
mysqli_stmt_bind_param($stmt, "s", $email);
mysqli_stmt_execute($stmt);
$result = mysqli_stmt_get_result($stmt);

if (!$result || mysqli_num_rows($result) == 0) {
    echo json_encode(["success" => false, "message" => "Invalid email"]);
    exit;
}

$row = mysqli_fetch_assoc($result);

if (password_verify($password, $row['password'])) {

    $_SESSION['user_id'] = $row['u_id'];
    $_SESSION['user_name'] = $row['name'];
    $_SESSION['user_email'] = $row['email'];

    echo json_encode([
        "success" => true,
        "user" => [
            "id" => $row['u_id'],
            "name" => $row['name'],
            "email" => $row['email'],
            "role" => $row['role']
        ]
    ]);
} else {
    echo json_encode(["success" => false, "message" => "Incorrect password"]);
}

mysqli_close($con);
?>
