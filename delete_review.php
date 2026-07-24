<?php
header("Content-Type: application/json");
error_reporting(0);

$conn = new mysqli("localhost","root","","fertismart",3307);

if ($conn->connect_error) {
    echo json_encode(["error"=>"Connection failed"]);
    exit();
}

$p_id = intval($_POST['p_id'] ?? 0);
$u_id = intval($_POST['u_id'] ?? 0);

if ($p_id == 0 || $u_id == 0) {
    echo json_encode(["error"=>"Invalid request"]);
    exit();
}

$conn->query("DELETE FROM product_reviews WHERE p_id=$p_id AND u_id=$u_id");

echo json_encode(["message"=>"Review deleted"]);

$conn->close();
?>
