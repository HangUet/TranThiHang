<?php
  $query = "SELECT * FROM giangday order by id ASC";
  $result = mysqli_query($conn, $query);
  if(mysqli_num_rows($result) > 0 ) {
    $i = 0;
    while($row = mysqli_fetch_assoc($result) ) {
      $i++;
      $giangvienID = $row['giangvienID'];
      $monhocID = $row['monhocID'];
      $ngaybatdau = $row['ngaybatdau'];
      echo "<tr>";
      echo "<td><input type='checkbox' class='check_item' name='giangvienID[]' value='$giangvienID'/></td>";
      echo "<td>$i</td>";
      echo "<td>$giangvienID</td>";
      echo "<td>$monhocID</td>";
      echo "<td>$ngaybatdau</td>";
      echo "<td><a href='edit.php?id=$giangvienID'>Sửa</a></td>";
      echo "<td><a href='delete.php?id=$giangvienID'>Xóa</a></td>";
      echo "</tr>";
    }
  } else {
    echo "0 kết quả!";
  }
?>
