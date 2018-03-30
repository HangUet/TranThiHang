<?php
  include 'connect.php';
?>
<div class="container">
  <form method="post">
    <div class="form-group col-xs-12"> 
      <div class="col-xs-8">
        <h3 style="text-align: center">Chỉnh sửa hội viên </h3>
        <label>Tên hội viên:</label>
        <input type="text" class="form-control" name="tenhoivien" >
        
      </div>
      <div class="col-xs-8" style="padding-top: 15px">
        <button type="submit" name="edit" class="btn btn-info"><i class="glyphicon glyphicon-pencil"></i>&nbsp;Sửa</button>
      </div>
    </div>
  </form>
</div>

<?php
  if(isset($_POST['edit'])) {
    $ma = $_GET['id'];
    $hoten = mb_ucwords(trim($_POST['tenhoivien']),' ');
    $query = "UPDATE hoivien SET hoten = '$hoten' WHERE ma = '$ma'";
    if ($conn->query($query) === TRUE) {
      echo "Cập nhật thành công.";
      header('Location: view.php');
      
    } else {
        echo "Error: " . $query . "<br>" . $conn->error;
    }
  }
?>
