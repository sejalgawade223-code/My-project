<?php

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

include("dbconnection.php");
$con = dbconnection();


$base_url = "http://10.227.71.187/file_api/";

$query = "SELECT * FROM products";
$result = mysqli_query($con, $query);

$products = array();

if ($result) {
    while ($row = mysqli_fetch_assoc($result)) {

        if (!empty($row['image_url'])) {

            $row['image_url'] = $base_url . $row['image_url'];
        } else {
            $row['image_url'] = $base_url . "uploads/images.png";
        }
        $products[] = $row;
    }
    echo json_encode($products);
} else {
    echo json_encode(["error" => mysqli_error($con)]);
}
?>