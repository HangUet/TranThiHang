app.controller("Doctor_ChangePatientController", ['$scope', '$state', '$filter',
  'toastr', '$uibModal', 'history_change_agency', '$ngBootbox', 'API', 'medicineAllocation',
  function ($scope, $state, $filter, toastr, $uibModal, history_change_agency, $ngBootbox, API, medicineAllocation) {
  $scope.history_change_agency = history_change_agency;

  $scope.showHistoryMedicineAllocationModal = function() {
    NProgress.start();
    var modalInstance = $uibModal.open({
      templateUrl: "/templates/nurses/patients/history_form.html",
      size: 'lg',
      backdrop: 'static',
      keyboard: false,
      controller: ['$scope', '$uibModalInstance', 'toastr', '$state', 'API',
        function($scope, $uibModalInstance, toastr, $state, API) {
        NProgress.done();
        $scope.medicineAllocation = medicineAllocation;
        $scope.from_date = "01" + "/" + currentMonth + "/" + currentYear;
        $scope.to_date = currentDate + "/" + currentMonth + "/" + currentYear;
        $scope.getHistoryMedicationAllocation = function () {
          NProgress.start();
          API.getHistoryMedicationAllocation($state.params.id, $scope.from_date, $scope.to_date).success(function (response) {
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
