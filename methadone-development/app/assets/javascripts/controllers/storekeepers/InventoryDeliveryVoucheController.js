app.controller("Storekeeper_InventoryDeliveryVoucheController", ['$scope', '$state', 'API', 'exportMedicine', 'importMedicine', '$uibModal', '$ngBootbox', '$filter', 'toastr',
  function ($scope, $state, API, exportMedicine, importMedicine, $uibModal, $ngBootbox, $filter, toastr) {
  $scope.exportMedicine = exportMedicine;
  $scope.showCreateMedicineModal = function() {
    NProgress.start();
    var modalInstance = $uibModal.open({
      templateUrl: "/templates/export_medicines/create.html",
      size: 'lg',
      backdrop: 'static',
      keyboard: false,
      controller: ['$scope', '$uibModalInstance', 'toastr', '$state', 'API',
        function($scope, $uibModalInstance, toastr, $state, API) {
        NProgress.done();
        $scope.importMedicine = importMedicine;
        $scope.new_medicine = {};
        if($scope.importMedicine.length) {
          $scope.typeMedicine = 0;
          $scope.new_medicine = $scope.importMedicine[0];
          $scope.new_medicine.sender = "";
          $scope.new_medicine.receiver = "";
        }

        $scope.reloadMedicine = function(index) {
          $scope.new_medicine = $scope.importMedicine[index];
          $scope.new_medicine.sender = "";
          $scope.new_medicine.receiver = "";
        }

        $scope.createMedicine = function () {
          NProgress.start();
          API.createExportMedicine($scope.new_medicine).success(function (response) {
            NProgress.done();
            if(response.code == 1) {
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

  $scope.showEditMedicineModal = function(medicine_id) {
    NProgress.start();
    var modalInstance = $uibModal.open({
      templateUrl: "/templates/export_medicines/edit.html",
      backdrop: 'static',
      keyboard: false,
      resolve: {
        importMedicine: ['API', '$stateParams', function(API, $stateParams) {
          return API.getDailyImport().then(function(response) {
            return response.data.data;
          });
        }],
        edit_medicine: ["API", function(API) {
          return API.getExportMedicine(medicine_id).then(function(response) {
            return response.data;
          });
        }],
      },
      size: 'lg',
      controller: ['$scope', 'edit_medicine', '$uibModalInstance', 'toastr', '$state', 'API',
        function ($scope, edit_medicine, $uibModalInstance, toastr, $state, API) {
        NProgress.done();
        $scope.importMedicine = importMedicine;
        $scope.edit_medicine = edit_medicine.data;
        $scope.edit_medicine.type_export = $scope.edit_medicine.type_export.toString();
        $scope.reloadMedicine = function(index) {
          var tmp1 = $scope.edit_medicine.sender;
          var tmp2 = $scope.edit_medicine.receiver;
          $scope.edit_medicine = $scope.importMedicine[index];
          $scope.edit_medicine.sender = tmp1;
          $scope.edit_medicine.receiver = tmp2;
        }
        $scope.editMedicine = function () {
          NProgress.start();
          API.updateExportMedicine(medicine_id, $scope.edit_medicine).success(function (response) {
            NProgress.done();
            if(response.code == 1) {
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

  $scope.showDeleteMedicineModal = function(medicine) {
    $ngBootbox.confirm($filter("translator")("confirm_delete", "main") + ' "' + medicine.name + '"?').then(function() {
      NProgress.start();
      API.deleteExportportMedicine(medicine.id).success(function(response) {
        NProgress.done();
        if(response.code == 1) {
          $state.reload($state.current);
          toastr.success(response.message);
        } else {
          toastr.error(response.message);
        }
      });
    });
  }
}]);
