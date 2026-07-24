<?php
$conn = new mysqli("localhost","root","","fertilizer",3307);

$category = $_GET['category'];

$q = $conn->query(
  "SELECT * FROM quiz_questions WHERE category='$category'"
);

$result = [];

while ($row = $q->fetch_assoc()) {
  $qid = $row['id'];

  $optRes = $conn->query(
    "SELECT option_text FROM quiz_options WHERE question_id=$qid"
  );

  $options = [];
  while ($opt = $optRes->fetch_assoc()) {
    $options[] = $opt['option_text'];
  }

  $result[] = [
    "question" => $row['question_text'],
    "options" => $options
  ];
}

echo json_encode($result);
?>
