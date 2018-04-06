app.controller("Storekeeper_MedicineAllocationReportController", ['$scope', '$state', 'patients_allocations', 'API',
  function ($scope, $state, patients_allocations, API) {
  $scope.patients_allocations = patients_allocations;
  $scope.currentPage = $state.params.page || 1;
  $scope.pageChanged = function () {
    $state.go($state.current, { page: $scope.currentPage });
  }
  $scope.page = patients_allocations.page;
}]);
