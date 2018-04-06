app.controller("Dashboard1Controller", ['$scope', function ($scope) {
  $scope.height = $(window).height() - $('.page-header').height() - $('.col-lg-3').height() - $('#chart').height() - 75;
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
