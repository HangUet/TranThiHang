app.controller("SamePatientController", ['$scope', '$state', '$filter',
  '$uibModal','$ngBootbox', 'API', 'toastr', 'patient_agency_history',
  function ($scope, $state, $filter, $uibModal, $ngBootbox, API, toastr, patient_agency_history) {
   $scope.patient_agency_history = patient_agency_history;

   $scope.feedback = function(status) {
    API.feedbackSamePatient($scope.patient_agency_history.sender_agency_id ,$scope.patient_agency_history.id, status).success(function (response) {
      NProgress.done();
      if(response.code == 1) {
        toastr.success(response.message);
        $state.reload($state.current);
      } else {
        toastr.error(response.message);
      }
    });
  }
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
  $scope.patient_agency_history.patient.household = getString(patient_agency_history.patient.household_address) + getString(patient_agency_history.patient.household_hamlet)
    + getString(patient_agency_history.patient.household_ward) + getString(patient_agency_history.patient.household_district)
    + endString(patient_agency_history.patient.household_province);
}]);
