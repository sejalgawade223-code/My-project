<?php
$conn = new mysqli("localhost","root","","fertismart",3307);

$user_id = $_POST['user_id'];
$conn->query("DELETE FROM cart WHERE user_id=$user_id");

echo json_encode(["success"=>true]);
