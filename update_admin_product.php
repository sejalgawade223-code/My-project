<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
include("dbconnection.php");
$con = dbconnection();

$id = $_POST["p_id"];
$name = $_POST["name"];
$type = $_POST["type"];
$description = $_POST["description"];
$price = $_POST["price"];
$stock = $_POST["stock_quantity"];

$imgSQL = "";

if (!empty($_FILES["image_url"]["name"])) {
    $dir = "uploads/";
    if (!file_exists($dir)) mkdir($dir, 0777, true);

    $file = uniqid() . "_" . $_FILES["image_url"]["name"];
    $path = $dir . $file;
    move_uploaded_file($_FILES["image_url"]["tmp_name"], $path);
    $imgSQL = ", image_url='$path'";
}

$q = "UPDATE products SET
name='$name',
type='$type',
description='$description',
price='$price',
stock_quantity='$stock'
$imgSQL
WHERE p_id='$id'";

mysqli_query($con, $q);

echo json_encode(["success" => true]);
?>
