<?php
$conn = new mysqli("localhost","root","","fertilizer",3307);

$q = $conn->query("SELECT * FROM question");

$result = [];

while ($row = $q->fetch_assoc()) {
  $qid = $row['id'];

  $optRes = $conn->query(
    "SELECT option_text FROM question_options WHERE question_id=$qid"
  );

  $options = [];
  while ($opt = $optRes->fetch_assoc()) {
    $options[] = $opt['option_text'];
  }

  $result[] = [
    "question" => $row['que_txt'],
    "options" => $options
  ];
}

echo json_encode($result);
?>
