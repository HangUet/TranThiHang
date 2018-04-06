app.controller("Nurses_CardStoreController",
  ['$scope', '$state', 'API', 'toastr', 'medicines',
  function ($scope, $state, API, toastr, medicines) {
    $scope.medicines = medicines;
    $scope.card_store = {}
    $scope.from_date = "01" + "/" + currentMonth + "/" + currentYear;
    $scope.to_date = currentDate + "/" + currentMonth + "/" + currentYear;
    $scope.searchCardStore = function(){
      NProgress.start();
      API.searchCardStore($scope.from_date, $scope.to_date, $scope.card_store.medicine_list_id.id)
        .success(function (response) {
          if(response.code == 1) {
            NProgress.done();
            $scope.sub_inventory_medicines = response.data;
          } else {
            toastr.error(response.message);
          }
      })
    }
}]);
