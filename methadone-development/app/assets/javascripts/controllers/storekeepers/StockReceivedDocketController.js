app.controller("Storekeeper_StockReceivedDocketController", ['$scope', '$state', 'API', 'importMedicine', '$uibModal', '$ngBootbox', '$filter', 'toastr',
  function ($scope, $state, API, importMedicine, $uibModal, $ngBootbox, $filter, toastr) {
  $scope.importMedicine = importMedicine;
  $scope.showCreateMedicineModal = function () {
    NProgress.start();
    var modalInstance = $uibModal.open({
      templateUrl: "/templates/medicines/create.html",
      size: 'lg',
      backdrop: 'static',
      keyboard: false,
      controller: ['$scope', '$uibModalInstance', 'toastr', '$state', 'API',
        function ($scope, $uibModalInstance, toastr, $state, API) {
          NProgress.done();
          $scope.new_medicine = {}

          $scope.createMedicine = function () {
            NProgress.start();
            API.createImportMedicine($scope.new_medicine).success(function (response) {
              NProgress.done();
              if (response.code == 1) {
                $state.reload($state.current);
                $uibModalInstance.dismiss();
                toastr.success(response.message);
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

  $scope.showEditMedicineModal = function (medicine_id) {
    NProgress.start();
    var modalInstance = $uibModal.open({
      templateUrl: "/templates/medicines/edit.html",
      backdrop: 'static',
      keyboard: false,
      resolve: {
        edit_medicine: ["API", function (API) {
          return API.getImportMedicine(medicine_id).then(function (response) {
            return response.data;
          });
        }],
      },
      size: 'lg',
      controller: ['$scope', 'edit_medicine', '$uibModalInstance', 'toastr', '$state', 'API',
        function ($scope, edit_medicine, $uibModalInstance, toastr, $state, API) {
          NProgress.done();
          $scope.edit_medicine = edit_medicine.data;
          $scope.edit_medicine.type_export = $scope.edit_medicine.type_export.toString();
          $scope.editMedicine = function () {
            NProgress.start();
            API.updateImportMedicine(medicine_id, $scope.edit_medicine).success(function (response) {
              NProgress.done();
              if (response.code == 1) {
                $state.reload($state.current);
                $uibModalInstance.dismiss();
                toastr.success(response.message);
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

  $scope.showDeleteMedicineModal = function (medicine) {
    $ngBootbox.confirm($filter("translator")("confirm_delete", "main") + ' "' + medicine.name + '"?').then(function () {
      NProgress.start();
      API.deleteImportMedicine(medicine.id).success(function (response) {
        NProgress.done();
        if (response.code == 1) {
          $state.reload($state.current);
          toastr.success(response.message);
        } else {
          toastr.error(response.message);
        }
      });
    });
  }
}]);
