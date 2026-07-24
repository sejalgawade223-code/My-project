<?php
include "dbconnection.php";
$con = dbconnection();

$data = json_decode(file_get_contents("php://input"), true);

$category = $data['cropCategory'];
$type     = $data['cropType'];
$stage    = $data['growthStage'];
$problem  = $data['problem'];

$sql = "
SELECT p.*,
GROUP_CONCAT(pi.image_path) AS images
FROM quiz_products p
LEFT JOIN product_images pi ON p.id = pi.product_id
WHERE p.crop_category = ?
AND p.crop_type = ?
AND p.growth_stage = ?
AND p.problem = ?
GROUP BY p.id
";

$stmt = $con->prepare($sql);
$stmt->bind_param("ssss", $category, $type, $stage, $problem);
$stmt->execute();
$result = $stmt->get_result();

$products = [];
while ($row = $result->fetch_assoc()) {
  $row['images'] = $row['images']
    ? explode(',', $row['images'])
    : [];
  $products[] = $row;
}

echo json_encode([
  "status" => "success",
  "data" => $products
]);
