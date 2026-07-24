<?php
header("Content-Type: application/json");
$conn = new mysqli("localhost", "root", "", "fertismart", 3307);

if ($conn->connect_error) {
    echo json_encode(["status" => false, "message" => "DB connection failed"]);
    exit;
}

$u_id = $_POST['u_id'] ?? '';
$p_id = $_POST['p_id'] ?? '';

if (empty($u_id) || empty($p_id)) {
    echo json_encode(["status" => false, "message" => "Missing data"]);
    exit;
}


$check = $conn->prepare(
    "SELECT cart_id FROM cart WHERE u_id=? AND p_id=?"
);
$check->bind_param("ii", $u_id, $p_id);
$check->execute();
$res = $check->get_result();

if ($res->num_rows > 0) {
    echo json_encode([
        "status" => false,
        "message" => "Product already in cart"
    ]);
    exit;
}


$stmt = $conn->prepare(
    "INSERT INTO cart (u_id, p_id, quantity) VALUES (?, ?, 1)"
);
$stmt->bind_param("ii", $u_id, $p_id);

if ($stmt->execute()) {
    echo json_encode([
        "status" => true,
        "message" => "Product added to cart"
    ]);
} else {
   echo json_encode([
           "status" => false,
           "message" => "SQL Error: " . $stmt->error
       ]);
}
?>
