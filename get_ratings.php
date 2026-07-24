<?php
header("Content-Type: application/json");
error_reporting(0);

$conn = new mysqli("localhost","root","","fertismart",3307);

if ($conn->connect_error) {
    echo json_encode(["error"=>"Database connection failed"]);
    exit();
}

$p_id = intval($_GET['p_id'] ?? 0);

if ($p_id == 0) {
    echo json_encode([
        "total"=>0,
        "average"=>0,
        "five"=>0,
        "four"=>0,
        "three"=>0,
        "two"=>0,
        "one"=>0
    ]);
    exit();
}

$sql = "
SELECT
COUNT(*) as total,
IFNULL(AVG(rating),0) as average,
SUM(rating=5) as five,
SUM(rating=4) as four,
SUM(rating=3) as three,
SUM(rating=2) as two,
SUM(rating=1) as one
FROM product_reviews
WHERE p_id=$p_id
";

$result = $conn->query($sql);
$row = $result->fetch_assoc();

echo json_encode([
    "total" => (int)$row['total'],
    "average" => round((float)$row['average'],1),
    "five" => (int)$row['five'],
    "four" => (int)$row['four'],
    "three" => (int)$row['three'],
    "two" => (int)$row['two'],
    "one" => (int)$row['one']
]);

$conn->close();
?>
