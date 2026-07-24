<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

include("dbconnection.php");
$con = dbconnection();

if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_FILES['csv_file'])) {
    $file = $_FILES['csv_file']['tmp_name'];


    if (($handle = fopen($file, "r")) !== FALSE) {


        fgetcsv($handle);

        $successCount = 0;
        $errorCount = 0;


        while (($data = fgetcsv($handle, 1000, ",")) !== FALSE) {


            if (count($data) < 6) continue;


            $name = mysqli_real_escape_string($con, $data[0]);
            $brand = mysqli_real_escape_string($con, $data[1]);
            $type = mysqli_real_escape_string($con, $data[2]);
            $desc = mysqli_real_escape_string($con, $data[3]);
            $price = (float)$data[4];
            $stock = (int)$data[5];
            $image = mysqli_real_escape_string($con, $data[6]);


            $sql = "INSERT INTO products (name, Brand, type, description, price, stock_quantity, image_url)
                    VALUES ('$name', '$brand', '$type', '$desc', $price, $stock, '$image')";

            if (mysqli_query($con, $sql)) {
                $successCount++;
            } else {
                $errorCount++;
            }
        }

        fclose($handle);

        echo json_encode([
            "success" => true,
            "message" => "$successCount products uploaded successfully. Errors: $errorCount"
        ]);
    } else {
        echo json_encode(["success" => false, "message" => "Unable to open CSV file."]);
    }
} else {
    echo json_encode(["success" => false, "message" => "Invalid request or file missing."]);
}
?>