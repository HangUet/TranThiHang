app.controller("StoreKeeper_SituationReportController", ['$scope', '$state', 'patients_report', 'API',
  function ($scope, $state, patients_report, API) {
  $scope.patients_report = patients_report.data;
  $scope.month = currentMonth + "/" + currentYear;
  $scope.submit = function() {
    NProgress.start();
    API.getPatientReport($scope.month).then(function(response) {
      $scope.patients_report = response.data.data;
      NProgress.done();
    });
  }
}]);
