<?php

if (ob_get_length()) {
    ob_clean();
}

header("Content-Type: application/json; charset=UTF-8");
error_reporting(E_ALL);
ini_set('display_errors', 1);

require_once "dbconnection.php";
$con = dbconnection();

if (!$con) {
    echo json_encode([
        "success" => false,
        "message" => "Database connection failed"
    ]);
    exit;
}


$required = ['name','email','password','confirm_password'];
foreach ($required as $field) {
    if (!isset($_POST[$field]) || trim($_POST[$field]) === '') {
        echo json_encode([
            "success" => false,
            "message" => "All fields are required"
        ]);
        exit;
    }
}


$name     = trim($_POST['name']);
$email    = trim($_POST['email']);
$password = $_POST['password'];
$confirm  = $_POST['confirm_password'];


if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    echo json_encode([
        "success" => false,
        "message" => "Invalid email format"
    ]);
    exit;
}


if ($password !== $confirm) {
    echo json_encode([
        "success" => false,
        "message" => "Passwords do not match"
    ]);
    exit;
}


$stmt = mysqli_prepare($con, "SELECT u_id FROM user WHERE email = ?");
mysqli_stmt_bind_param($stmt, "s", $email);
mysqli_stmt_execute($stmt);
mysqli_stmt_store_result($stmt);

if (mysqli_stmt_num_rows($stmt) > 0) {
    echo json_encode([
        "success" => false,
        "message" => "Email already exists"
    ]);
    mysqli_stmt_close($stmt);
    exit;
}
mysqli_stmt_close($stmt);


$hashedPassword = password_hash($password, PASSWORD_DEFAULT);


$stmt = mysqli_prepare(
    $con,
    "INSERT INTO user (name, email, password) VALUES (?, ?, ?)"
);

mysqli_stmt_bind_param(
    $stmt,
    "sss",
    $name,
    $email,
    $hashedPassword
);

if (mysqli_stmt_execute($stmt)) {
    echo json_encode([
        "success" => true,
        "message" => "Signup successful"
    ]);
} else {
    echo json_encode([
        "success" => false,
        "message" => "Signup failed"
    ]);
}

mysqli_stmt_close($stmt);
mysqli_close($con);
exit;
?>
