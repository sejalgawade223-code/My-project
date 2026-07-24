<?php
header("Content-Type: application/json");

$conn = new mysqli("localhost", "root", "", "fertismart",3307);

if ($conn->connect_error) {
    echo json_encode(["status"=>"error","message"=>"DB Connection Failed"]);
    exit;
}

$category = $_GET['category'] ?? '';

if ($category == '') {
    echo json_encode(["status"=>"error","message"=>"Category required"]);
    exit;
}

$sql = "SELECT * FROM quiz_questions WHERE category=?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("s", $category);
$stmt->execute();

$result = $stmt->get_result();
$questions = [];

while ($row = $result->fetch_assoc()) {
    $questions[] = [
        "question" => $row['question'],
        "options" => [
            $row['option1'],
            $row['option2'],
            $row['option3'],
            $row['option4'],
        ]
    ];
}

echo json_encode([
    "status"=>"success",
    "data"=>$questions
]);

$conn->close();
?>
