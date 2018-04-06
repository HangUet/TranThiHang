app.controller("LostReportController", ['$scope', '$rootScope',
 '$state', 'toastr', 'API', '$uibModal', '$filter', '$ngBootbox',
  function ($scope, $rootScope, $state, toastr, API, $uibModal, $filter,
  $ngBootbox) {
  $scope.councils = {"data": [{}]};

  $scope.addCouncil = function() {
    $scope.councils.data.push({});
  }

  $scope.deleteCouncil = function(index) {
    $scope.councils.data.splice(index, 1);
  }

  $scope.showPrintModal = function(councils) {
    var time = $scope.date;
    var modalInstance = $uibModal.open({
      templateUrl: "/templates/nurses/lost_report.html",
      size: 'lg',
      controller: ['$scope', '$uibModalInstance', 'toastr', '$state', 'API',
        '$rootScope',
        function($scope, $uibModalInstance, toastr, $state, API, $rootScope) {
        NProgress.done();

        API.getLossReduncy("day", time, "loss").success(function (response) {
          NProgress.done();
          if(response.code == 1) {
            $scope.loss = response.data;
          } else {
            toastr.error(response.message);
          }
        });

        $scope.councils = councils;
        var choose_time = time.split("/")
        var date = TIME_NOW;
        $scope.currentDate = choose_time[0];
        $scope.currentMonth = choose_time[1];
        $scope.currentYear = choose_time[2];
        $scope.hour = date.getHours();
        $scope.minute = date.getMinutes();
        if ($scope.minute < 10) {
          $scope.minute = "0" + $scope.minute;
        }
        // if ($scope.currentDate < 10) {
        //   $scope.currentDate = "0" + $scope.currentDate;
        // }
        // if ($scope.currentMonth < 10) {
        //   $scope.currentMonth = "0" + $scope.currentMonth;
        // }
        $scope.seccond = date.getSeconds();
        var weekday = ["Chủ nhật", "Thứ hai", "Thứ ba", "Thứ tư", "Thứ năm", "Thứ sáu", "Thứ bảy"];
        $scope.weekdays = weekday[date.getDay()];
        $scope.print = function() {
          var mywindow = window.open('', 'PRINT');
          mywindow.document.write('<html><head><title></title>');
          mywindow.document.write('<link rel="stylesheet" href="" media="print"/>');
          mywindow.document.write('</head><body>');
          mywindow.document.write(document.getElementById("pdf").innerHTML);
          mywindow.document.write('</body></html>');
          setTimeout(function() {
            mywindow.document.close(); // necessary for IE >= 10
            mywindow.focus(); // necessary for IE >= 10*/
            mywindow.print();
            mywindow.close();
          }, 100)
          return true;
        }
        $scope.close = function () {
          $uibModalInstance.dismiss();
        }
      }]
    });
  }
}]);
