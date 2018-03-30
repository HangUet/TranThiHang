<?php
  include 'connect.php';
?>
<?php
  if(isset($_GET['id'])) {
    $giaovienID = $_GET['id'];
    $query = "DELETE FROM giangday where giaovienID='$giaovienID'";
    if ($conn->query($query) === TRUE) {
      echo "Xóa thành công.";
      
    } else {
        echo "Error: " . $query . "<br>" . $conn->error;
    }
  }
?>
