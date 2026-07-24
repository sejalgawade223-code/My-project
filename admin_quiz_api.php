<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

$conn = new mysqli("localhost", "root", "", "fertismart", 3307);

if ($conn->connect_error) {
    echo json_encode(["status" => "error", "message" => "Database connection failed"]);
    exit;
}


$action = $_GET['action'] ?? $_POST['action'] ?? '';


if ($action == 'view') {
    $result = $conn->query("SELECT * FROM quiz_questions");
    $questions = [];
    while ($row = $result->fetch_assoc()) {
        $questions[] = $row;
    }
    echo json_encode($questions);
    exit;
}


if ($action == 'delete') {
    $id = $_POST['id'] ?? $_GET['id'] ?? '';
    if (empty($id)) {
        echo json_encode(["status" => "error", "message" => "ID is required for delete"]);
        exit;
    }

    $stmt = $conn->prepare("DELETE FROM quiz_questions WHERE question_id = ?");
    $stmt->bind_param("i", $id);

    if ($stmt->execute()) {
        echo json_encode(["status" => "success", "message" => "Deleted successfully"]);
    } else {
        echo json_encode(["status" => "error", "message" => "Delete failed"]);
    }
    $stmt->close();
    exit;
}


$id       = $_POST['id'] ?? '';
$category = $_POST['category'] ?? '';
$question = $_POST['question'] ?? '';
$option1  = $_POST['option1'] ?? '';
$option2  = $_POST['option2'] ?? '';
$option3  = $_POST['option3'] ?? '';
$option4  = $_POST['option4'] ?? '';

if (empty($category) || empty($question)) {
    echo json_encode(["status" => "error", "message" => "Category and Question are required"]);
    exit;
}

if (!empty($id)) {

    $stmt = $conn->prepare("UPDATE quiz_questions SET category=?, question=?, option1=?, option2=?, option3=?, option4=? WHERE question_id=?");
    $stmt->bind_param("ssssssi", $category, $question, $option1, $option2, $option3, $option4, $id);
    $msg = "Question updated successfully";
} else {

    $stmt = $conn->prepare("INSERT INTO quiz_questions (category, question, option1, option2, option3, option4) VALUES (?, ?, ?, ?, ?, ?)");
    $stmt->bind_param("ssssss", $category, $question, $option1, $option2, $option3, $option4);
    $msg = "Question added successfully";
}

if ($stmt->execute()) {
    echo json_encode(["status" => "success", "message" => $msg]);
} else {
    echo json_encode(["status" => "error", "message" => "Operation failed: " . $conn->error]);
}

$stmt->close();
$conn->close();
?>