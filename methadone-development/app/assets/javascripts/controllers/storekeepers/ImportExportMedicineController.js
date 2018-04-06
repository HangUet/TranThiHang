app.controller("Storekeeper_ImportExportMedicineController", ['$scope', '$state', 'API', 'importExportMedicine',
  function ($scope, $state, API, importExportMedicine) {
  $scope.data = importExportMedicine;
  if ($scope.data.length) {
    $scope.day = $scope.data[0].month;
  }
  $scope.applyDay = function () {
    NProgress.start();
    API.getImportExportMedicineDay($scope.day).success(function (response) {
      NProgress.done();
      if (response.code == 1) {
        $scope.data = response.data;
      }
    });
  }
}]);
