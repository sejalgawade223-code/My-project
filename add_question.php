<?php
$conn = new mysqli("localhost","root","","fertilizer",3307);


$question = $_POST['question'];
$options = [
  $_POST['option1'],
  $_POST['option2'],
  $_POST['option3'],
  $_POST['option4']
];
$answer = $_POST['answer'];

$conn->query("INSERT INTO question (que_txt) VALUES ('$question')");
$question_id = $conn->insert_id;

foreach ($options as $opt) {
  $isCorrect = ($opt == $answer) ? 1 : 0;
  $conn->query(
    "INSERT INTO question_options (question_id, option_txt, answer)
     VALUES ($question_id, '$opt', $isCorrect)"
  );
}

echo json_encode(["status"=>"success"]);
?>
