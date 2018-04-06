app.controller("GiveUpReportController", ['$scope', '$rootScope',
 '$state', 'toastr', 'API', '$uibModal', '$filter', '$ngBootbox', 'history_vommited',
  function ($scope, $rootScope, $state, toastr, API, $uibModal, $filter,
  $ngBootbox, history_vommited) {
  $scope.history_vommited = history_vommited;
  $scope.exportReport = function() {
    var report_creator = $scope.report_creator;
    var list_user = [];
    for (var i = 0; i < $scope.report_creator.length; i++) {
      list_user.push($scope.report_creator[i].id)
    }
    var modalInstance = $uibModal.open({
      templateUrl: "/templates/nurses/give_up_report.html",
      size: 'lg',
      controller: ['$scope', '$uibModalInstance', 'toastr', '$state', 'API',
        '$rootScope',
        function($scope, $uibModalInstance, toastr, $state, API, $rootScope) {
        NProgress.done();

        $scope.report_creator= report_creator;

        var date = TIME_NOW;
        $scope.date = date;
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

  $scope.showReport = function(patient) {

    var modalInstance = $uibModal.open({
      templateUrl: "/templates/nurses/edit_report.html",
      size: 'lg',
      controller: ['$scope', '$uibModalInstance', 'toastr', '$state', 'API',
        '$rootScope',
        function($scope, $uibModalInstance, toastr, $state, API, $rootScope) {
        NProgress.done();
        $scope.councils = {"data": [{}]};
        $scope.name_report = "give_up_report";


        $scope.addCouncil = function() {
          $scope.councils.data.push({});
        }

        $scope.deleteCouncil = function(index) {
          $scope.councils.data.splice(index, 1);
        }

        API.getTimeDropMedicine(patient.patient_id).success(function (response) {
          NProgress.done();
          if(response.code == 1) {
            $scope.timedrop = response.data;
          }
        });

        $scope.exportReport = function() {
          var councils = $scope.councils;
          var from_date = $scope.from_date
          var to_date = $scope.to_date
          var modalInstance = $uibModal.open({
            templateUrl: "/templates/nurses/give_up_report.html",
            size: 'lg',
            controller: ['$scope', '$uibModalInstance', 'toastr', '$state', 'API',
              '$rootScope',
              function($scope, $uibModalInstance, toastr, $state, API, $rootScope) {
              NProgress.done();


        var date = TIME_NOW;
        var from = from_date.split("/")
        var to = to_date.split("/")
        if (from_date == to_date) {

          $scope.give_up_date = from[0];
          $scope.give_up_month = from[1];
          $scope.give_up_year = from[2];
          $scope.drop_consecutive = false;
        } else {
          $scope.give_up_from_date = from[0];
          $scope.give_up_from_month = from[1];
          $scope.give_up_from_year = from[2];

          $scope.give_up_to_date = to[0];
          $scope.give_up_to_month = to[1];
          $scope.give_up_to_year = to[2];  

          $scope.drop_consecutive = true;
        }



        var date = TIME_NOW;
        $scope.currentDate = date.getDate();
        $scope.currentMonth = date.getMonth() + 1;
        $scope.currentYear = date.getFullYear();
        $scope.hour = date.getHours();
        $scope.minute = date.getMinutes();
        if ($scope.minute < 10) {
          $scope.minute = "0" + $scope.minute;
        }
              $scope.councils = councils;
              $scope.patient = patient;
              $scope.date = date;
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

        $scope.close = function () {
          $uibModalInstance.dismiss();
        }
      }]
    });
  }

  $scope.getListPatientRevoke = function() {
    NProgress.start();
    API.getListPatientRevoke($scope.card_number, $scope.name, 
      $scope.from_date, $scope.to_date, $scope.currentPage).success(function (response) {
      NProgress.done();
      if(response.code == 1) {
        $scope.history = true;
        $scope.history_vommited = response;
      } else {
        toastr.error(response.message);
      }
    });
  }

  $scope.pageChanged = function() {
    NProgress.start();
    API.getListPatientRevoke($scope.card_number, $scope.name, 
      $scope.from_date, $scope.to_date, $scope.currentPage).success(function (response) {
      NProgress.done();
      if(response.code == 1) {
        $scope.history = true;
        $scope.history_vommited = response;
      } else {
        toastr.error(response.message);
      }
    });
  }
}]);
