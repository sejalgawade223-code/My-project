<?php
header("Content-Type: application/json");
error_reporting(0);

$conn = new mysqli("localhost","root","","fertismart",3307);

if ($conn->connect_error) {
    echo json_encode([]);
    exit();
}

$p_id = intval($_GET['p_id'] ?? 0);

$result = $conn->query("
SELECT r_id, p_id, u_id, rating, review, created_at
FROM product_reviews
WHERE p_id=$p_id
ORDER BY created_at DESC
");

$reviews = [];

while ($row = $result->fetch_assoc()) {
    $reviews[] = [
        "r_id" => (int)$row['r_id'],
        "p_id" => (int)$row['p_id'],
        "u_id" => (int)$row['u_id'],
        "rating" => (int)$row['rating'],
        "review" => $row['review'],
        "created_at" => $row['created_at']
    ];
}

echo json_encode($reviews);
$conn->close();
?>
