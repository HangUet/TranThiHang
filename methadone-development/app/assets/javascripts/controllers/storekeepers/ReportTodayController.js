app.controller("Storekeeper_ReportTodayController",['$scope', '$state', 'patients_change_current', 'API',
  function ($scope, $state, patients_change_current, API) {
  $scope.patients_change = patients_change_current;
  $scope.date = currentDate + "/" + currentMonth + "/" + currentYear
  // $scope.import_exports = import_export_current;
  $scope.getHalf = function(x) {
    return parseInt(x/2);
  }
  $scope.applyDay = function() {
    NProgress.start();
    // API.getImportExportDay($scope.date).success(function (response) {
    //   if(response.code == 1) {
    //     $scope.import_exports.data = response.data;
    //     $scope.import_exports.other = response.other;
    //     $scope.import_exports.total = response.total;
    //     $scope.import_exports.total_other = response.total_other;
    //   }
    // });
    API.getChangeDosage($scope.date).success(function (response) {
      if(response.code == 1) {
        NProgress.done();
        $scope.patients_change.data = response.data;
      }
    });
  }
}]);
