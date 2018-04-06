app.controller("NotifyRenunciatedController", ['$scope', '$rootScope',
 '$state', 'toastr', 'API', 'patient', 'prescription', 'reasons',
  function ($scope, $rootScope, $state, toastr, API, patient, prescription, reasons) {
  $scope.patient = patient;
  $scope.dosage = $state.params.dosage; 
  $scope.prescription_description = prescription.data.description;
  $scope.prescription_id = $state.params.prescription;
  $scope.reasons = reasons.data;
  $scope.stop_treatment = {
    patient_id: $state.params.patient_id,
  };
  $scope.sendStopTreatment = function() {
    NProgress.start();
    API.sendStopTreatment($scope.stop_treatment).success(function (response) {
      NProgress.done();
      if(response.code == 1) {
        $state.reload($state.current);
        toastr.success(response.message);
      } else {
        toastr.error(response.message);
      }
    });
  }
}]);
