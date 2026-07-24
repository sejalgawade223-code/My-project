<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
include("dbconnection.php");
$con = dbconnection();

if (
    empty($_POST["name"]) ||
    empty($_POST["Brand"]) ||
    empty($_POST["type"]) ||
    empty($_POST["description"]) ||
    empty($_POST["price"]) ||
    empty($_POST["stock_quantity"])
) {
    echo json_encode(["success" => false, "error" => "Missing required fields"]);
    exit;
}

$name = $_POST["name"];
$brand = $_POST["Brand"];
$type = $_POST["type"];
$description = $_POST["description"];
$price = $_POST["price"];
$stock_quantity = $_POST["stock_quantity"];

$target_dir = "uploads/";
if (!file_exists($target_dir)) {
    mkdir($target_dir, 0777, true);
}

$image_url = "";

if (isset($_FILES["image_url"]) && $_FILES["image_url"]["error"] == UPLOAD_ERR_OK) {
    $file_name = basename($_FILES["image_url"]["name"]);
    $unique_name = uniqid() . "_" . $file_name;
    $target_file = $target_dir . $unique_name;

    $allowed_types = ['jpg', 'jpeg', 'png', 'gif'];
    $imageFileType = strtolower(pathinfo($target_file, PATHINFO_EXTENSION));

    if (in_array($imageFileType, $allowed_types)) {
        if (move_uploaded_file($_FILES["image_url"]["tmp_name"], $target_file)) {
            $image_url = $target_file;
        } else {
            echo json_encode(["success" => false, "error" => "Failed to move uploaded file"]);
            exit;
        }
    } else {
        echo json_encode(["success" => false, "error" => "Invalid image type"]);
        exit;
    }
} else {
    echo json_encode(["success" => false, "error" => "No image uploaded"]);
    exit;
}

$query = "INSERT INTO `products`(`name`, `Brand`, `type`, `description`, `price`, `stock_quantity`, `image_url`)VALUES('$name', '$brand', '$type', '$description', '$price', '$stock_quantity', '$image_url')";
$exe = mysqli_query($con, $query);

if ($exe) {
    echo json_encode(["success" => true, "message" => "Product added successfully", "image_url" => $image_url]);
} else {
    echo json_encode(["success" => false, "error" => mysqli_error($con)]);
}
?>
