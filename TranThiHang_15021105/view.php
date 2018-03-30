<?php
  include 'connect.php';
?>
<body>
  <div class="container">
    <header>
      <h1 style="text-align: center">Quản lý hội viên</h1>
    </header>
    <section>
      <div style="text-align: right">
        <a href="insert.php" class="btn btn-info"><i class="glyphicon glyphicon-plus"></i>&nbsp;Thêm mới giảng dạy</a>
      </div>
      <form method="POST" action="deleteAll.php">
        <h3 style="text-align: center">Danh sách giảng dạy</h3>
        <table class="table" style="padding-top: 20px">
          <thead>
            <tr>
              <th><input type="checkbox" id="check_all"></th>
              <th>STT</th>
              <th>ID Giáo viên</th>
              <th>ID Môn học</th>
              <th>Ngày bắt đầu</th>
              <th>Sửa</th>
              <th>Xóa</th>
            </tr>
          </thead>
          <tbody>
          <?php
            include 'show.php';
          ?>    
          </tbody>    
        </table>
      </form>
    </section>
  </div>
</body>
