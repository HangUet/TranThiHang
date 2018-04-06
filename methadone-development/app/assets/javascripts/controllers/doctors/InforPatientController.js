app.controller("Doctor_InforPatientController", ['$scope', '$state', '$filter',
  'toastr', '$uibModal', 'patient', '$ngBootbox', 'API',
  function ($scope, $state, $filter, toastr, $uibModal, patient, $ngBootbox, API) {
  $scope.patient = patient;

  var getString = function(string) {
    if(string) {
      return string + " - ";
    }
    return "";
  }
  var endString = function(string) {
    if(string) {
      return string;
    }
    return "";
  }
  if(patient) {
  $scope.patient.household = getString(patient.household_address) + getString(patient.household_hamlet)
    + getString(patient.household_ward) + getString(patient.household_district)
    + endString(patient.household_province);

  $scope.patient.resident = getString(patient.resident_address) + getString(patient.resident_hamlet)
    + getString(patient.resident_ward) + getString(patient.resident_district)
    + endString(patient.resident_province);
  }
}]);
