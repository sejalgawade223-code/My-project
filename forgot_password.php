<?php

date_default_timezone_set("Asia/Kolkata");

use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

require __DIR__ . '/PHPMailer/src/Exception.php';
require __DIR__ . '/PHPMailer/src/PHPMailer.php';
require __DIR__ . '/PHPMailer/src/SMTP.php';

header("Content-Type: application/json");


$conn = new mysqli("localhost", "root", "", "fertismart", 3307);

if ($conn->connect_error) {
    echo json_encode(["status" => false, "message" => "DB connection failed"]);
    exit;
}


$conn->query("SET time_zone = '+05:30'");

$data = json_decode(file_get_contents("php://input"), true);
$email = trim($data['email'] ?? '');

if ($email === '') {
    echo json_encode(["status" => false, "message" => "Email required"]);
    exit;
}


$stmt = $conn->prepare("SELECT u_id FROM user WHERE email=?");
$stmt->bind_param("s", $email);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows === 0) {
    echo json_encode(["status" => false, "message" => "Email not registered"]);
    exit;
}


$otp = rand(100000, 999999);

$expiry = date("Y-m-d H:i:s", strtotime("+10 minutes"));


$update = $conn->prepare("UPDATE user SET otp=?, otp_expiry=? WHERE email=?");
$update->bind_param("sss", $otp, $expiry, $email);
$update->execute();


$mail = new PHPMailer(true);
try {
    $mail->isSMTP();
    $mail->Host = 'smtp.gmail.com';
    $mail->SMTPAuth = true;
    $mail->Username = 'sejalgawade223@gmail.com';
    $mail->Password = 'mvfpkopshazvjzrw';
    $mail->SMTPSecure = PHPMailer::ENCRYPTION_STARTTLS;
    $mail->Port = 587;

    $mail->setFrom('sejalgawade223@gmail.com', 'Fertismart');
    $mail->addAddress($email);

    $mail->isHTML(true);
    $mail->Subject = 'Password Reset OTP';
    $mail->Body = "
        <div style='font-family: Arial, sans-serif; border: 1px solid #ddd; padding: 20px;'>
            <h2 style='color: #2e7d32;'>Fertismart OTP Verification</h2>
            <p>Tumcha password reset karnyasathi khaliil OTP vapara:</p>
            <h1 style='background: #f4f4f4; padding: 10px; display: inline-block;'>$otp</h1>
            <p style='color: #666;'>Ha OTP pudhcha 10 minutansathi valid aahe.</p>
        </div>
    ";

    $mail->send();
    echo json_encode(["status" => true, "message" => "OTP sent successfully"]);

} catch (Exception $e) {
    echo json_encode(["status" => false, "message" => "Mailer Error: " . $mail->ErrorInfo]);
}
?>