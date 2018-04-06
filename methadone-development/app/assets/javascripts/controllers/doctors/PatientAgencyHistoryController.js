app.controller("Doctor_PatientAgencyHistoryController", ['$scope', '$rootScope',
  '$state', 'toastr', 'patient_agency_history', 'API', '$uibModal',
  function ($scope, $rootScope, $state, toastr, patient_agency_history, API, $uibModal) {
  $scope.patient_agency_history = patient_agency_history.data;

  if($state.current.name == "main.patient_agency_history") {
    $state.go("main.patient_agency_history.change_agency");
  }

  $scope.feedback = function(status) {
    API.feedbackPatientAgencyHistory($scope.patient_agency_history.id, status).success(function (response) {
      NProgress.done();
      if(response.code == 1) {
        toastr.success(response.message);
        $state.reload();
      } else {
        toastr.error(response.message);
      }
    });
  }

  $scope.showHistoryMedicineAllocationModal = function() {
    NProgress.start();
    var modalInstance = $uibModal.open({
      templateUrl: "/templates/nurses/patients/history_form.html",
      backdrop: 'static',
      keyboard: false,
      resolve: {
        medicineAllocation: ['API', '$stateParams', function(API, $stateParams) {
          return API.getMedicineAllocation(patient_agency_history.patient_id).then(function(response) {
            return response.data.data;
          });
        }]
      },
      size: 'lg',
      controller: ['$scope', '$uibModalInstance', 'toastr', '$state', 'API', 'medicineAllocation',
        function($scope, $uibModalInstance, toastr, $state, API, medicineAllocation) {
        NProgress.done();

        $scope.medicineAllocation = medicineAllocation;
        $scope.from_date = "01" + "/" + currentMonth + "/" + currentYear;
        $scope.to_date = currentDate + "/" + currentMonth + "/" + currentYear;
        $scope.getHistoryMedicationAllocation = function () {
          NProgress.start();
          API.getHistoryMedicationAllocation(patient_agency_history.patient_id, $scope.from_date, $scope.to_date).success(function (response) {
            NProgress.done();
            if(response.code == 1) {
              $scope.history_medicine_allocation = response.data;
            } else {
              toastr.error(response.message);
            }
          });
        }
        $scope.close = function () {
          $uibModalInstance.dismiss();
        }
      }]
    });
  }
}]);
