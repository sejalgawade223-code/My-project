<?php
header('Content-Type: application/json');
$conn = new mysqli("localhost", "root", "", "fertismart",3307);

if ($conn->connect_error) {
    die(json_encode(["error" => "Connection failed"]));
}


$crop_name = $_GET['crop_name'] ?? '';
$stage     = $_GET['stage'] ?? '';
$problem   = $_GET['problem'] ?? '';
$pref      = $_GET['pref'] ?? '';


$search_term = "";
if (strpos($problem, 'Yellowing') !== false) $search_term = "nitrogen";
else if (strpos($problem, 'growth') !== false) $search_term = "growth";
else if (strpos($problem, 'Pest') !== false) $search_term = "insect";
else if (strpos($problem, 'disease') !== false) $search_term = "disease";
else if (strpos($stage, 'Flowering') !== false) $search_term = "phosphorus";
else $search_term = "fertilizer";

$type_filter = "";
if ($pref == "Bio-fertilizer" || $pref == "Organic") {
    $type_filter = "AND (Category LIKE '%Bio%' OR Category LIKE '%Organic%')";
} else if ($pref == "Chemical") {
    $type_filter = "AND Category = 'Fertilizer'";
}

$sql = "SELECT * FROM products WHERE
        (Product_Description LIKE '%$search_term%' OR Product_Name LIKE '%$search_term%')
        $type_filter LIMIT 5";

$result = $conn->query($sql);
$data = [];

while($row = $result->fetch_assoc()) {
    $data[] = [
        "name" => $row['Product_Name'],
        "brand" => $row['Brand'],
        "desc" => $row['Product_Description'],
        "image" => $row['Product_Image_URL']
    ];
}

echo json_encode($data);
?>