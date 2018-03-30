<?php
  $servername = "localhost";
  $username = "root";
  $password = "123456";
  $dbname = "n1";
  // Create connection
  $conn = new mysqli($servername, $username, $password, $dbname);
  // Check connection
  if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
  } 
  mysqli_query($conn, 'SET NAMES UTF8');
  function mb_ucwords($str)
  {
    return mb_convert_case($str, MB_CASE_TITLE, "UTF-8");
  }
?>
<head>
  <title>Cuối kỳ</title>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
  <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.2.0/jquery.min.js"></script>
  <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script>
</head>
