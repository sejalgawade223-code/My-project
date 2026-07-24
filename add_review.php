<?php
header("Content-Type: application/json");
error_reporting(0);

$conn = new mysqli("localhost","root","","fertismart",3307);

if ($conn->connect_error) {
    echo json_encode(["error"=>"Database connection failed"]);
    exit();
}

$p_id   = intval($_POST['p_id'] ?? 0);
$u_id   = intval($_POST['u_id'] ?? 0);
$rating = intval($_POST['rating'] ?? 0);
$review = $conn->real_escape_string($_POST['review'] ?? "");

if ($p_id == 0 || $u_id == 0 || $rating < 1 || $rating > 5) {
    echo json_encode(["error"=>"Invalid input"]);
    exit();
}


$check = $conn->query("SELECT r_id FROM product_reviews WHERE p_id=$p_id AND u_id=$u_id");

if ($check->num_rows > 0) {

    $conn->query("
        UPDATE product_reviews
        SET rating=$rating, review='$review'
        WHERE p_id=$p_id AND u_id=$u_id
    ");

    echo json_encode(["message"=>"Review updated"]);

} else {

    $conn->query("
        INSERT INTO product_reviews (p_id,u_id,rating,review)
        VALUES ($p_id,$u_id,$rating,'$review')
    ");

    echo json_encode(["message"=>"Review added"]);
}

$conn->close();
?>
