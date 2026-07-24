<?php
header("Content-Type: application/json");
include "dbconnection.php";

$conn = dbconnection();   // 🔥 REQUIRED

$action = $_POST['action'] ?? "";


if ($action == "add") {

    $u_id = $_POST['u_id'];
    $p_id = $_POST['p_id'];

    $check = mysqli_query(
        $conn,
        "SELECT * FROM cart WHERE u_id='$u_id' AND p_id='$p_id'"
    );

    if (mysqli_num_rows($check) > 0) {
        mysqli_query(
            $conn,
            "UPDATE cart SET quantity = quantity + 1
             WHERE u_id='$u_id' AND p_id='$p_id'"
        );
    } else {
        mysqli_query(
            $conn,
            "INSERT INTO cart (u_id, p_id, quantity)
             VALUES ('$u_id', '$p_id', 1)"
        );
    }

    echo json_encode(["status" => true, "message" => "Product added to cart"]);
    exit;
}


if ($action == "fetch") {

    $u_id = $_POST['u_id'];

    $sql = "
        SELECT
            cart.cart_id,
            cart.p_id,
            cart.quantity,
            products.name,
            products.price,
            products.image_url
        FROM cart
        JOIN products ON cart.p_id = products.p_id
        WHERE cart.u_id = '$u_id'
    ";

    $res = mysqli_query($conn, $sql);
    $data = [];

    while ($row = mysqli_fetch_assoc($res)) {
        $data[] = $row;
    }

    echo json_encode($data);
    exit;
}


if ($action == "update_qty") {

    $cart_id = $_POST['cart_id'];
    $type = $_POST['type'];

    if ($type == "increment") {
        mysqli_query(
            $conn,
            "UPDATE cart SET quantity = quantity + 1 WHERE cart_id='$cart_id'"
        );
    } else {
        mysqli_query(
            $conn,
            "UPDATE cart SET quantity = quantity - 1
             WHERE cart_id='$cart_id' AND quantity > 1"
        );
    }

    echo json_encode(["status" => true]);
    exit;
}


if ($action == "remove") {

    $cart_id = $_POST['cart_id'];
    mysqli_query($conn, "DELETE FROM cart WHERE cart_id='$cart_id'");

    echo json_encode(["status" => true]);
    exit;
}
?>


