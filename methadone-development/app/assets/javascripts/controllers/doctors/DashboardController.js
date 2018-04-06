app.controller("Doctor_DashboardController", ['$scope', 'dashboard_doctor', function ($scope, dashboard_doctor) {
  $scope.dashboard = dashboard_doctor;
  var total_patients = parseInt(dashboard_doctor.total_patients);
  var total_give_up_medicine = parseInt(dashboard_doctor.total_give_up_medicine);
  var total_expirate_prescription = parseInt(dashboard_doctor.total_expirate_prescription);
  $scope.give_up_medicine_ratio = Math.round(total_give_up_medicine / total_patients * 100);
  $scope.expirate_prescription_ratio = Math.round(total_expirate_prescription / total_patients * 100);
  $scope.height = $scope.height = $(window).height() - $('.page-header').height() - $('.col-lg-3').height() - $('#chart').height() - $('.page-footer').height();
  $scope.dataProvider = [
    {
      "tháng": "1",
      "Bệnh nhân": 99,
    },
    {
      "tháng": "2",
      "Bệnh nhân": 99,
    },
    {
      "tháng": "3",
      "Bệnh nhân": 99,
    },
    {
      "tháng": "4",
      "Bệnh nhân": 99
    },
    {
      "tháng": "5",
      "Bệnh nhân": 99,
    },
    {
      "tháng": "6",
      "Bệnh nhân": 99,
    },
    {
      "tháng": "7",
      "Bệnh nhân": 90,
    }, {
      "tháng": "7",
      "Bệnh nhân": 95
    }, {
      "tháng": "8",
      "Bệnh nhân": 99
    }, {
      "tháng": "9",
      "Bệnh nhân": 80,
    }, {
      "tháng": "9",
      "Bệnh nhân": 97,
    }, {
      "tháng": "10",
      "Bệnh nhân": 99,
    },
    {
      "tháng": "11",
      "Bệnh nhân": 99,
    },
    {
      "tháng": "12",
      "Bệnh nhân": 99,
    }];
  $scope.dataProvider1 = [
   {
      "tháng": "1",
      "Bệnh nhân": 2,
    },
    {
      "tháng": "2",
      "Bệnh nhân": 3,
    },
    {
      "tháng": "3",
      "Bệnh nhân": 3,
    },
    {
      "tháng": "4",
      "Bệnh nhân": 1,
    },
    {
      "tháng": "5",
      "Bệnh nhân": 2,
    },
    {
      "tháng": "6",
      "Bệnh nhân": 3,
    },
    {
      "tháng": "7",
      "Bệnh nhân": 2,
    }, {
      "tháng": "7",
      "Bệnh nhân": 2,
    }, {
      "tháng": "8",
      "Bệnh nhân": 1,
    }, {
      "tháng": "9",
      "Bệnh nhân": 3,
    }, {
      "tháng": "9",
      "Bệnh nhân": 2,
    }, {
      "tháng": "10",
      "Bệnh nhân": 1,
    },
    {
      "tháng": "11",
      "Bệnh nhân": 2,
    },
    {
      "tháng": "12",
      "Bệnh nhân": 2,
    }
  ];
}]);
