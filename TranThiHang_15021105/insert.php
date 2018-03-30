<?php
  include 'connect.php';
?>
<div class="container">
  <form method="post">
    <div class="form-group col-xs-12"> 
      <div class="col-xs-8">
        <h3 style="text-align: center">Thêm hội viên mới</h3>
        <label for="select_giangvien">Mã giảng viên:</label>
        <select class="form-control" id="select_giangvien">
          <option></option>
        </select>
      </div>
      <div class="col-xs-8">
        <label for="select_monhoc">Mã môn học:</label>
        <select class="form-control" id="select_monhoc">
          <option></option>
        </select>
      </div>
      <div class="col-xs-8">
        <lable>Ngày bắt đầu:</label>
        <div class='input-group date' id='datetimepicker1'>
          <input type='text' class="form-control" />
          <span class="input-group-addon">
              <span class="glyphicon glyphicon-calendar"></span>
          </span>
        </div>
        <script type="text/javascript">
            $(function () {
                $('#datetimepicker1').datetimepicker();
            });
        </script>
      </div>
      <div class="col-xs-8" style="padding-top: 15px">
        <button type="submit" name="insert" class="btn btn-info"><i class="glyphicon glyphicon-plus"></i>&nbsp;Thêm</button>
      </div>
    </div>
  </form>
</div>
<?php
  if(isset($_POST['insert'])) {
    $magiangvien = $_POST[''];
    $mamonhoc = $_POST[''];
    $ngaybatdau = $_POST[''];
    $query = "INSERT INTO giangday VALUES('$magiangvien', '$mamonhoc', '$ngaybatdau')";
    if ($conn->query($query) === TRUE) {

      echo "Thêm mới giảng dạy thành công.";
      header('Location: view.php');
      
    } else {
        echo "Error: " . $query . "<br>" . $conn->error;
    }
  }
?>
