<?php
header('Content-Type: application/json');
error_reporting(0);


$conn = new mysqli("localhost", "root", "", "fertismart",3307);

if ($conn->connect_error) {
    die(json_encode(["error" => "Connection failed"]));
}

$base_url = "http://10.227.71.187/file_api/";


$crop_type = $_GET['crop_type'] ?? '';
$problem   = $_GET['problem'] ?? '';
$pref      = $_GET['pref'] ?? '';
$stage     = $_GET['stage'] ?? '';
$soil      = $_GET['soil'] ?? '';

$search_term = "fertilizer";
if (stripos($problem, 'Yellowing') !== false) $search_term = "nitrogen";
else if (stripos($problem, 'growth') !== false) $search_term = "growth";
else if (stripos($problem, 'Pest') !== false) $search_term = "insect";
else if (stripos($problem, 'disease') !== false) $search_term = "fungi";


$type_filter = "";
if ($pref == "Bio-fertilizer") $type_filter = " AND type LIKE '%Bio%'";
else if ($pref == "Organic") $type_filter = " AND type LIKE '%Organic%'";
else if ($pref == "Chemical") $type_filter = " AND type NOT LIKE '%Bio%' AND type NOT LIKE '%Organic%'";
else if ($pref == "Both/Mixed") $type_filter = " AND type LIKE '%Both/Mixed%'";


$extra_filters = "";


if (!empty($crop_type)) {
    $extra_filters .= " AND (description LIKE '%$crop_type%' OR name LIKE '%$crop_type%')";
}

if (!empty($stage)) {
    $extra_filters .= " AND (description LIKE '%$stage%' OR name LIKE '%$stage%')";
}


if (!empty($soil)) {
    $extra_filters .= " AND (description LIKE '%$soil%' OR name LIKE '%$soil%')";
}


$sql = "SELECT p_id, name, Brand, type, description, price, image_url,stock_quantity
        FROM products
        WHERE (description LIKE ? OR name LIKE ?)
        $type_filter
        $extra_filters
        LIMIT 5";


$stmt = $conn->prepare($sql);
$query_param = "%$search_term%";
$stmt->bind_param("ss", $query_param, $query_param);
$stmt->execute();
$result = $stmt->get_result();

$data = [];
while($row = $result->fetch_assoc()) {
    $imagePath = trim($row['image_url']);
    if (!empty($imagePath)) {
        $fullImage = $base_url . $imagePath;
    } else {
        $fullImage = $base_url . "uploads/default.jpg";
    }

    $data[] = [
        "p_id"  => $row['p_id'],
        "name"  => $row['name'],
        "brand" => $row['Brand'],
        "type"  => $row['type'],
        "desc"  => $row['description'],
        "price" => (string)$row['price'],
        "image" => $fullImage,
        "stock_quantity" => (string)$row['stock_quantity']
    ];
}

echo json_encode($data);
?>