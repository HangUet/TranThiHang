app.controller("StoreKeeper_SituationUseController", ['$scope', '$state', 'API', 'toastr',
  function ($scope, $state, API, toastr) {
    // $scope.medicines = medicines;
    // $scope.situation_use = [];
    $scope.from_date = "01" + "/" + currentMonth + "/" + currentYear;
    $scope.to_date = currentDate + "/" + currentMonth + "/" + currentYear;
    $scope.searchSituationUse = function(){
      NProgress.start();
      API.searchSituationUseMain($scope.from_date, $scope.to_date, $scope.medicine_name)
        .success(function (response) {
          if(response.code == 1) {
            NProgress.done();
            $scope.issuing_agency = response.issuing_agency;
            $scope.inventory_medicines = response.data;
          } else {
            toastr.error(response.message);
          }
      })
    }
  }
]);
