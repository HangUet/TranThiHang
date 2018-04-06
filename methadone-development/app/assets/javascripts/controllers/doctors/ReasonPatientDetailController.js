app.controller("Doctor_ReasonPatientDetailController",
  ['$scope', '$state', 'patient', 'issuingAgencies', 'ethnicities', 'provinces','API',
  function ($scope, $state, patient, issuingAgencies, ethnicities, provinces, API) {
  $scope.patient = patient;
  $scope.issuingAgencies = issuingAgencies;
  $scope.ethnicities = ethnicities;
  $scope.provinces = provinces;
  // $scope.districts = districts;

  $scope.loadDistrict = function(province_id) {
    API.getDistricts(province_id).success(function(response) {
      $scope.districts = response.data
    });
  }
  $scope.loadDistrict(patient.province_id);

  $scope.reloadDistrict = function(province_id) {
    $scope.patient.district_id = "";
    $scope.loadDistrict(province_id);
  }
  $scope.updatePatient = function() {
    NProgress.start();
    API.updatePatient($scope.patient).success(function (response) {
      NProgress.done();
      if(response.code == 1) {
        toastr.success(response.message);
      } else {
        toastr.error(response.message);
      }
    });
  }
}]);
