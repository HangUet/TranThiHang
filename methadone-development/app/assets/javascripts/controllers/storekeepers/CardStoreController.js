app.controller("Storekeeper_CardStoreController", ['$scope', '$state', 'API', 'medicines',
  function ($scope, $state, API, medicines) {
    $scope.medicines = medicines;
    $scope.card_store = {}
    $scope.from_date = "01" + "/" + currentMonth + "/" + currentYear;
    $scope.to_date = currentDate + "/" + currentMonth + "/" + currentYear;
    $scope.searchCardStore = function(){
      NProgress.start();
      API.searchCardStoreMain($scope.from_date, $scope.to_date, $scope.card_store.medicine_list_id.id)
        .success(function (response) {
          if(response.code == 1) {
            NProgress.done();
            $scope.inventory_medicines = response.data;
          } else {
            toastr.error(response.message);
          }
      })
    }
}]);
