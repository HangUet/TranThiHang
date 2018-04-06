app.controller("CommonTest", ['$scope', '$state', 'issuing_agencies', '$uibModal', '$ngBootbox', 'API', 'toastr',
  '$filter', function ($scope, $state, issuing_agencies, $uibModal, $ngBootbox, API, toastr, $filter) {
  $scope.issuing_agencies = [
    {
      "name": "Cơ sở 1",
      "code": "1001",
      "active": "Hoạt động",
      "province": "Hà Nội",
      "district": "Cầu gíây",
      "description": "Mô tả",
    "date": "11/05/2006"
    },
    {
      "name": "Cơ sở 2",
      "code": "1002",
      "active": "Hoạt động",
      "province": "Hà Nội",
      "district": "Cầu gíây",
      "description": "Mô tả",
    "date": "11/05/2006"
    },
    {
      "name": "Cơ sở 3",
      "code": "1003",
      "active": "Hoạt động",
      "province": "Hà Nội",
      "district": "Cầu gíây",
      "description": "Mô tả",
    "date": "11/05/2006"
    },
    {
      "name": "Cơ sở 4",
      "code": "1004",
      "active": "Hoạt động",
      "province": "Hà Nội",
      "district": "Cầu gíây",
      "description": "Mô tả",
    "date": "11/05/2006"
    },
    {
      "name": "Cơ sở 5",
      "code": "1005",
      "active": "Hoạt động",
      "province": "Hà Nội",
      "district": "Cầu gíây",
      "description": "Mô tả",
    "date": "11/05/2006"
    },
    {
      "name": "Cơ sở 6",
      "code": "1006",
      "active": "Hoạt động",
      "province": "Hà Nội",
      "district": "Cầu gíây",
      "description": "Mô tả",
    "date": "11/05/2006"
    },
    {
      "name": "Cơ sở 7",
      "code": "1007",
      "active": "Hoạt động",
      "province": "Hà Nội",
      "district": "Cầu gíây",
      "description": "Mô tả",
    "date": "11/05/2006"
    },
    {
      "name": "Cơ sở 8",
      "code": "1008",
      "active": "Hoạt động",
      "province": "Hà Nội",
      "district": "Cầu gíây",
      "description": "Mô tả",
    "date": "11/05/2006"
    },
    {
      "name": "Cơ sở 9",
      "code": "1009",
      "active": "Hoạt động",
      "province": "Hà Nội",
      "district": "Cầu gíây",
      "description": "Mô tả",
    "date": "11/05/2006"
    },
    {
      "name": "Cơ sở 10",
      "code": "1010",
      "active": "Hoạt động",
      "province": "Hà Nội",
      "district": "Cầu gíây",
      "description": "Mô tả",
    "date": "11/05/2006"
    }
  ];

  $scope.object = {
    "name": "",
    "code": "",
    "active": "",
    "province": "",
    "district": "",
    "description": "",
    "date": "11/05/2006"
  }

  $scope.create = function() {
    $scope.issuing_agencies.push($scope.object);
    $scope.object = {};
  }

  $scope.delete = function(index) {
    $scope.issuing_agencies.splice(index, 1);
  }

  $scope.districts = ["Ba Đình", "Tây Hồ", "Hoàn Kiếm", "Hai Bà Trưng", "Hoàng Mai",
   "Đống Đa", "Thanh Xuân"]

  $scope.provinces = ["Hà Nội", "Thành phố Hải Phòng", "Vĩnh Phúc", "Bắc Ninh",
   "Hải Dương", "Hưng Yên", "Hà Nam"]
  $scope.page = issuing_agencies.page;
  $scope.keyword = $state.params.keyword;
  $scope.currentPage = $state.params.page || 1;
}]);
