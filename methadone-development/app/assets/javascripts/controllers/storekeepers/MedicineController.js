app.controller("Storekeeper_MedicineController", ['$scope', '$state', 'medicines',
  '$uibModal', '$ngBootbox', 'API', 'toastr',
  '$filter', function ($scope, $state, medicines, $uibModal, $ngBootbox, API, toastr, $filter) {
  $scope.medicines = medicines.data;
  $scope.pages = medicines;
  $scope.changed = function(type) {
    NProgress.start();
    $state.go($state.current, {type: type});
    NProgress.done();
  }
  $scope.page = {
    page: $scope.pages.page,
    per_page: $scope.pages.per_page,
    total: $scope.pages.total
  }
  $scope.type = $state.params.type || "can_use";
  $scope.keyword = $state.params.keyword;
  $scope.currentPage = $state.params.page || 1;
  $scope.pageChanged = function() {
    $state.go($state.current, {page: $scope.currentPage, type: $scope.type});
  }

  $scope.showCreateMedicineModal = function() {
    NProgress.start();
    var modalInstance = $uibModal.open({
      templateUrl: "/templates/medicines/create.html",
      size: 'lg',
      backdrop: 'static',
      keyboard: false,
      controller: ['$scope', '$uibModalInstance', 'toastr', '$state', 'API',
        function($scope, $uibModalInstance, toastr, $state, API) {
        NProgress.done();
        $scope.new_medicine = {}

        $scope.createMedicine = function () {
          NProgress.start();
          API.createMedicine($scope.new_medicine).success(function (response) {
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
      templateUrl: "/templates/medicines/edit.html",
      backdrop: 'static',
      keyboard: false,
      resolve: {
        edit_medicine: ["API", function(API) {
          return API.getOneMedicine(medicine_id).then(function(response) {
            return response.data;
          });
        }],
      },
      size: 'lg',
      controller: ['$scope', 'edit_medicine', '$uibModalInstance', 'toastr', '$state', 'API',
        function ($scope, edit_medicine, $uibModalInstance, toastr, $state, API) {
        NProgress.done();
        $scope.edit_medicine = edit_medicine.data;
        $scope.editMedicine = function () {
          NProgress.start();
          API.updateMedicine(medicine_id, $scope.edit_medicine).success(function (response) {
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
      API.deleteMedicine(medicine.id).success(function(response) {
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
