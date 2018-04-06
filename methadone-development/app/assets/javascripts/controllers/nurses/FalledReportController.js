app.controller("FalledReportController", ['$scope', '$rootScope',
 '$state', 'toastr', 'API', 'history_falled', '$uibModal', '$filter', 'listNurse', '$ngBootbox',
  function ($scope, $rootScope, $state, toastr, API, history_falled, $uibModal, $filter, listNurse,
  $ngBootbox) {
  $scope.history = false;
  $scope.creator = {}
  $scope.creator.status = 1;
  $scope.history_falled = history_falled;
  $scope.currentPage = $state.params.page || 1;
  $scope.listNurse = listNurse;
  $scope.from_date = ($filter('date')(TIME_NOW, 'dd/MM/yyyy'));
  $scope.to_date = ($filter('date')(TIME_NOW, 'dd/MM/yyyy'));
  $scope.getHistoryFalled = function () {
    NProgress.start();
    API.getHistoryFalled($scope.card_number, $scope.name, $scope.creator.id,
      $scope.from_date, $scope.to_date, $scope.creator.status , $scope.currentPage).success(function (response) {
      NProgress.done();
      if(response.code == 1) {
        $scope.history = true;
        $scope.history_falled = response;
      } else {
        toastr.error(response.message);
      }
    });
  }

  $scope.pageChanged = function() {
    if ($scope.history == true) {
      NProgress.start();
      API.getHistoryFalled($scope.card_number, $scope.name, $scope.creator.id,
        $scope.from_date, $scope.to_date, $scope.creator.status, $scope.currentPage).success(function (response) {
        NProgress.done();
        if(response.code == 1) {
          $scope.history_falled = response;
        }
      });
    } else {
      $state.go($state.current, {page: $scope.currentPage});
    }
  }

  $scope.showReport = function(history) {
    var modalInstance = $uibModal.open({
      templateUrl: "/templates/nurses/history_report.html",
      size: 'lg',
      controller: ['$scope', '$uibModalInstance', 'toastr', '$state', 'API',
        '$rootScope',
        function($scope, $uibModalInstance, toastr, $state, API, $rootScope) {
        NProgress.done();
        var date = new Date($filter('date')(history.updated_at, 'MM/dd/yyyy HH:mm:ss'));
        $scope.history = history;
        $scope.currentDate = date.getDate();
        $scope.currentMonth = date.getMonth() + 1;
        $scope.currentYear = date.getFullYear();
        $scope.hour = date.getHours();
        $scope.minute = date.getMinutes();
        if ($scope.minute < 10) {
          $scope.minute = "0" + $scope.minute;
        }
        if ($scope.currentDate < 10) {
          $scope.currentDate = "0" + $scope.currentDate;
        }
        if ($scope.currentMonth < 10) {
          $scope.currentMonth = "0" + $scope.currentMonth;
        }
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

  $scope.deleteReport = function(id) {
    $ngBootbox.confirm($filter("translator")("confirm_delete", "main") + ' biên bản này?').then(function() {
      API.deleteReport(id).success(function (response) {
        NProgress.done();
        if(response.code == 1) {
          $state.reload($state.current);
          toastr.success(response.message);
        } else {
          toastr.error(response.message);
        }
      });
    });
  }

}]);
