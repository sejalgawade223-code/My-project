<?php
header("Content-Type: application/json");
error_reporting(0);
include "dbconnection.php";

$con = dbconnection();

$action = $_POST['action'] ?? '';




if ($action === 'delete_order') {

  $order_id = $_POST['order_id'] ?? '';
  $reason = $_POST['reason'] ?? 'Not specified';

  if ($order_id == '') {
    echo json_encode(["status" => false, "message" => "Order ID missing"]);
    exit;
  }


  $query = "UPDATE orders SET status='Cancelled' WHERE order_id='$order_id'";

  if(mysqli_query($con, $query)){


      $insertCancel = "INSERT INTO cancel_order (order_id, cancel_date, cancellation_reason, refund_status)
                       VALUES ('$order_id', NOW(), '$reason', 'Pending')";

      if(mysqli_query($con, $insertCancel)) {
          echo json_encode(["status" => true]);
      } else {

          echo json_encode(["status" => false, "message" => "Failed to log cancellation"]);
      }
  } else {
      echo json_encode(["status" => false]);
  }
  exit;
}



$u_id = $_POST['u_id'] ?? '';

if (empty($u_id)) {
    echo json_encode([]);
    exit;
}

$orders = [];

$q = mysqli_query($con, "SELECT * FROM orders WHERE u_id='$u_id' ORDER BY order_id DESC");

if ($q) {
    while ($o = mysqli_fetch_assoc($q)) {
        $items = [];

        $oid = (int)trim($o['order_id']);


        $item_query = "SELECT
                        oi.quantity,
                        oi.price,
                        COALESCE(p.name, 'Unknown Product') AS name,
                        p.image_url
                       FROM order_items oi
                       LEFT JOIN products p ON oi.p_id = p.p_id
                       WHERE oi.order_id = $oid";

        $r = mysqli_query($con, $item_query);

        if ($r) {
            while ($i = mysqli_fetch_assoc($r)) {
                $items[] = $i;
            }
        }

        $o['items'] = $items;
        $orders[] = $o;
    }
}

echo json_encode($orders);
exit;