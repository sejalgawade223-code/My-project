<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

include "dbconnection.php";
$con = dbconnection();

if (!$con) {
    echo json_encode(["status" => "error", "message" => "DB connection failed"]);
    exit;
}


$sql = "SELECT r.*, u.name as user_name, p.name as product_name
        FROM product_reviews r
        JOIN user u ON r.u_id = u.u_id
        JOIN products p ON r.p_id = p.p_id
        ORDER BY r.created_at DESC";

$result = mysqli_query($con, $sql);

$reviews = [];

if ($result) {
    while($row = mysqli_fetch_assoc($result)) {
        $reviews[] = $row;
    }
    echo json_encode($reviews);
} else {

    echo json_encode(["status" => "error", "message" => mysqli_error($con)]);
}

mysqli_close($con);
?>