<?php
header("Access-Control-Allow-Origin: *");
header('Content-Type: application/json');
include("dbconnection.php");
$con = dbconnection();

$p_id = $_POST['p_id'];
$added_qty = $_POST['added_quantity'];

mysqli_begin_transaction($con);

try {

    $res = mysqli_query($con, "SELECT stock_quantity FROM products WHERE p_id='$p_id'");
    $row = mysqli_fetch_assoc($res);
    $old_stock = $row['stock_quantity'];
    $new_stock = $old_stock + $added_qty;


    $update_sql = "UPDATE products SET stock_quantity = stock_quantity + ? WHERE p_id = ?";
    $stmt = $con->prepare($update_sql);
    $stmt->bind_param("ii", $added_qty, $p_id);
    $stmt->execute();


    $log_sql = "INSERT INTO stock_logs (p_id, old_stock, added_stock, new_stock) VALUES (?, ?, ?, ?)";
    $log_stmt = $con->prepare($log_sql);
    $log_stmt->bind_param("iiii", $p_id, $old_stock, $added_qty, $new_stock);
    $log_stmt->execute();

    mysqli_commit($con);
    echo json_encode(["success" => true]);
} catch (Exception $e) {
    mysqli_rollback($con);
    echo json_encode(["success" => false, "error" => $e->getMessage()]);
}
?>