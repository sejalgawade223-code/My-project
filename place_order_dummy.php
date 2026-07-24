<?php
header('Content-Type: application/json');
$conn = new mysqli("localhost", "root", "", "fertismart", 3307);

if ($conn->connect_error) {
    die(json_encode(["status" => "error", "message" => "Connection Failed"]));
}

$u_id = $_POST['u_id'];
$name = $_POST['customer_name'];
$address = $_POST['customer_address'];
$contact = $_POST['customer_contact'];
$amount = $_POST['total_amount'];
$method = $_POST['payment_method'];
$pay_id = $_POST['payment_id'] ?? '';
$razor_id = $_POST['razorpay_order_id'] ?? '';


$cart_items = json_decode($_POST['cart_items'], true);

$conn->begin_transaction();

try {

    $sql = "INSERT INTO orders (u_id, customer_name, customer_address, customer_contact, total_amount, payment_method, payment_id, razorpay_order_id, status, payment_status) VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'Confirmed', ?)";
    $stmt = $conn->prepare($sql);
    $p_status = ($method == "COD") ? "Pending" : "Completed";
    $stmt->bind_param("issssssss", $u_id, $name, $address, $contact, $amount, $method, $pay_id, $razor_id, $p_status);

    if (!$stmt->execute()) {
        throw new Exception("Order Insert Failed");
    }

    $order_id = $conn->insert_id;
    $receipt_no = "FS-" . date("Y") . "-" . (1000 + $order_id);


    $sql_r = "INSERT INTO receipts (order_id, receipt_no) VALUES (?, ?)";
    $stmt_r = $conn->prepare($sql_r);
    $stmt_r->bind_param("is", $order_id, $receipt_no);
    $stmt_r->execute();


    if (!empty($cart_items)) {
        foreach ($cart_items as $item) {
            $p_id = $item['p_id'];
            $qty = $item['quantity'];
            $price = $item['price'];


                $sql_items = "INSERT INTO order_items (order_id, p_id, quantity, price) VALUES (?, ?, ?, ?)";
                $stmt_items = $conn->prepare($sql_items);
                $stmt_items->bind_param("iiid", $order_id, $p_id, $qty, $price);
                $stmt_items->execute();

            $res = $conn->query("SELECT stock_quantity FROM products WHERE p_id='$p_id'");
            $product_data = $res->fetch_assoc();
            $old_stock = $product_data['stock_quantity'];
            $new_stock = $old_stock - $qty;


            $update_sql = "UPDATE products SET stock_quantity = ? WHERE p_id = ?";
            $upd_stmt = $conn->prepare($update_sql);
            $upd_stmt->bind_param("ii", $new_stock, $p_id);
            $upd_stmt->execute();


            $log_sql = "INSERT INTO stock_logs (p_id, old_stock, added_stock, new_stock) VALUES (?, ?, ?, ?)";
            $log_stmt = $conn->prepare($log_sql);
            $minus_qty = -$qty;
            $log_stmt->bind_param("iiii", $p_id, $old_stock, $minus_qty, $new_stock);
            $log_stmt->execute();
        }
    }
    $conn->query("DELETE FROM cart WHERE u_id='$u_id'");
    $conn->commit();
    echo json_encode(["status" => "success", "receipt_no" => $receipt_no]);

} catch (Exception $e) {
    $conn->rollback();
    echo json_encode(["status" => "error", "message" => $e->getMessage()]);
}

$conn->close();
?>