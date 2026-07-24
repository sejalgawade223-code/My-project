<?php
header("Content-Type: application/json");
include("dbconnection.php");

$con = dbconnection();

$crop_category = $_POST['crop_category'] ?? '';
$crop_type     = $_POST['crop_type'] ?? '';
$growth_stage  = $_POST['growth_stage'] ?? '';
$problem       = $_POST['problem'] ?? '';

// 🔹 Use LIKE for flexible matching
$crop_category = "%$crop_category%";
$crop_type     = "%$crop_type%";
$growth_stage  = "%$growth_stage%";
$problem       = "%$problem%";
//
$sql = "SELECT * FROM quiz_products
        WHERE crop_category LIKE ?
        AND crop_type LIKE ?
        AND growth_stage LIKE ?
        AND problem LIKE ?";



$stmt = $con->prepare($sql);
$stmt->bind_param("ssss", $crop_category, $crop_type, $growth_stage, $problem);
$stmt->execute();

$result = $stmt->get_result();
$products = [];

while ($row = $result->fetch_assoc()) {

    // fetch images
    $imgSql = "SELECT image_path FROM product_images WHERE product_id=?";
    $imgStmt = $con->prepare($imgSql);
    $imgStmt->bind_param("i", $row['id']);
    $imgStmt->execute();
    $imgResult = $imgStmt->get_result();

    $images = [];
    while ($img = $imgResult->fetch_assoc()) {
      $baseUrl = "http://10.0.0.2/file_api/";

      $images[] = $baseUrl . $img['image_path'];

    }

    $row['images'] = $images;
    $products[] = $row;
}

echo json_encode([
    "success" => true,
    "products" => $products
]);

