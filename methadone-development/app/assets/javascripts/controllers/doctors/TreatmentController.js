app.controller("Doctor_TreatmentController", ['$scope', '$state', '$filter',
  '$stateParams', 'toastr', 'dosage', 'patient', 'API', 'treatmentHistory',
  function ($scope, $state, $filter, $stateParams, toastr, dosage, patient,
  API, treatmentHistory) {
  $scope.patient = patient;
  $scope.treatmentHistory = treatmentHistory;
  $scope.number_day = parseInt($scope.treatmentHistory.today.number_day);
  $scope.note = $scope.treatmentHistory.note
  $scope.dosage = dosage;
  $scope.date = currentMonth + "/" + currentYear;
  $scope.range = function() {
    var input = [];
    for (var i = 1; i <= $scope.number_day; i += 1) {
      input.push(i);
    }
    return input;
  }
  $scope.check_disble = function(day) {
    return day != $scope.treatmentHistory.today.day ? true : false;
  }
  $scope.applyDay =function() {
    NProgress.start();
    API.getDosagePatient($scope.date, $stateParams.id).success(function (response) {
      if(response.code == 1) {
        NProgress.done();
        $scope.dosage = response.data;
      }
    });
  }
  $scope.createTreatment = function() {
    NProgress.start();
    var index = $scope.treatmentHistory.today.day - 1;
    API.createTreatment($scope.treatmentHistory.data[index], $scope.note, $stateParams.id).success(function (response) {
      NProgress.done();
      if(response.code == 1) {
        toastr.success(response.message);
        $state.go("main.patients");
      } else {
        toastr.error(response.message);
      }
    });
  }
  $scope.process_data = function(data) {
    if (data) {
      return data;
    } else {
      return "-";
    }
  }
  $scope.process_checkbox_data = function(data) {
    if (data) {
      return $filter("translator")("yes", "main");
    } else {
      return "-";
    }
  }
}]);
