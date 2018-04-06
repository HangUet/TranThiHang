app.controller("Storekeeper_StoreReportController", ['$scope', '$state', 'store_report', 'API',
  function ($scope, $state, store_report, API) {
    $scope.store_report = store_report.data;
    $scope.month = currentMonth + "/" + currentYear;
    $scope.total_stock_early_month = 0;
    $scope.total_stock_end_month = 0;
    $scope.total_import = 0;
    $scope.total_expirate_next_month = 0;
    for (var i = 0; i < $scope.store_report.reports[1].length; i++) {
      $scope.total_stock_early_month += $scope.store_report.reports[1][i].stock_early_month;
      $scope.total_stock_end_month += $scope.store_report.reports[1][i].stock_end_month;
      $scope.total_import += $scope.store_report.reports[1][i].import;
      $scope.total_expirate_next_month += $scope.store_report.reports[1][i].expirate_next_month;
    }
    $scope.submit = function () {
      NProgress.start();
      API.getStoreReport($scope.month).then(function (response) {
        $scope.store_report = response.data.data;
        $scope.total_stock_early_month = 0;
        $scope.total_stock_end_month = 0;
        $scope.total_import = 0;
        $scope.total_expirate_next_month = 0;
        for (var i = 0; i < $scope.store_report.reports[1].length; i++) {
          $scope.total_stock_early_month += $scope.store_report.reports[1][i].stock_early_month;
          $scope.total_stock_end_month += $scope.store_report.reports[1][i].stock_end_month;
          $scope.total_import += $scope.store_report.reports[1][i].import;
          $scope.total_expirate_next_month += $scope.store_report.reports[1][i].expirate_next_month;
        }
      NProgress.done();
     });
   }
}]);
