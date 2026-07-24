<?php
header("Content-Type: application/json");
$conn = new mysqli("localhost", "root", "", "fertismart",3307);

$p_id = intval($_GET['p_id']);

$result = $conn->query("
SELECT u_id, rating, review, created_at
FROM product_reviews
WHERE p_id=$p_id
ORDER BY created_at DESC
");

$reviews = [];

while ($row = $result->fetch_assoc()) {
    $reviews[] = $row;
}

echo json_encode($reviews);
$conn->close();
?>
