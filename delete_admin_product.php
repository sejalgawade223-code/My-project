<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
include("dbconnection.php");
$con = dbconnection();


if (isset($_POST["p_id"]) && !empty($_POST["p_id"])) {

    $ids = $_POST["p_id"];

 
    $sql_images = "SELECT image_url FROM products WHERE p_id IN ($ids)";
    $res = mysqli_query($con, $sql_images);

    if ($res) {
        while ($row = mysqli_fetch_assoc($res)) {
            $image_path = $row["image_url"];
      
            if (!empty($image_path) && file_exists($image_path)) {
                unlink($image_path);
            }
        }
    }


    $sql_delete = "DELETE FROM products WHERE p_id IN ($ids)";

    if (mysqli_query($con, $sql_delete)) {
        echo json_encode(["success" => true, "message" => "Deleted successfully"]);
    } else {
        echo json_encode(["success" => false, "error" => mysqli_error($con)]);
    }
} else {
    echo json_encode(["success" => false, "message" => "No IDs provided"]);
}
?>