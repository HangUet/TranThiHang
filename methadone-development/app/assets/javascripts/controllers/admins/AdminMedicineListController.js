app.controller("Admin_MedicineListController", ['$scope', '$state', 'medicine_list', '$uibModal',
  '$ngBootbox', 'API', 'toastr', '$filter', 'manufacturer_list', 'provider_list',
  function ($scope, $state, medicine_list, $uibModal, $ngBootbox, API, toastr,
    $filter, manufacturer_list, provider_list) {
  $scope.medicine_list = medicine_list;
  $scope.keyword = $state.params.keyword;
  $scope.medicine = {};
  $scope.medicine.keystatus = $state.params.keystatus;
  $scope.currentPage = $state.params.page || 1;
  $scope.showCreateMedicineModal = function() {
    NProgress.start();
    var modalInstance = $uibModal.open({
      templateUrl: "/templates/admin/medicine_list/create.html",
      size: 'md',
      backdrop: 'static',
      keyboard: false,
      resolve: {
        medicine_types: ['API', '$stateParams', function(API, $stateParams) {
          return API.getMedicineTypes().then(function(response) {
            return response.data.data;
          });
        }],
        manufacturer_list: ['Manufacturer', '$stateParams', function(Manufacturer, $stateParams) {
          return Manufacturer.index().then(function(response) {
            return response.data;
          });
        }]
      },
      controller: ['$scope', '$uibModalInstance', 'toastr', '$state', 'API',
        'medicine_types', 'manufacturer_list', function($scope, $uibModalInstance,
        toastr, $state, API, medicine_types, manufacturer_list) {
        NProgress.done();
        $scope.medicine_list = {};
        $scope.provider_list = provider_list.data;
        $scope.medicine_types = medicine_types;
        $scope.manufacturer_list = manufacturer_list.data;
        $scope.createMedicineList = function () {
          NProgress.start();
          API.createMedicineList($scope.medicine_list).success(function (response) {
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

  $scope.showEditMedicineListModal = function(medicine_list_id) {
    NProgress.start();
    var modalInstance = $uibModal.open({
      templateUrl: "/templates/admin/medicine_list/edit.html",
      size: 'md',
      backdrop: 'static',
      keyboard: false,
      resolve: {
        medicine_types: ['API', '$stateParams', function(API, $stateParams) {
          return API.getMedicineTypes().then(function(response) {
            return response.data.data;
          });
        }],
        medicine_list: ["API", function(API) {
          return API.getAMedicineList(medicine_list_id).then(function(response) {
            return response.data;
          });
        }],
        manufacturer_list: ['Manufacturer', '$stateParams', function(Manufacturer, $stateParams) {
          return Manufacturer.index().then(function(response) {
            return response.data;
          });
        }]
      },
      controller: ['$scope', 'medicine_list', '$uibModalInstance', 'toastr', '$state',
       'API', 'medicine_types', 'manufacturer_list',
        function ($scope, medicine_list, $uibModalInstance, toastr, $state, API,
        medicine_types, manufacturer_list) {
        NProgress.done();
        $scope.medicine_list = medicine_list.data;
        $scope.medicine_types = medicine_types;
        $scope.provider_list = [];
        for (var i = 0; i < provider_list.data.length; i++) {
          $scope.provider_list.push(provider_list.data[i].name)
        }
        $scope.manufacturer_list = [];
        for (var i = 0; i < manufacturer_list.data.length; i++) {
          $scope.manufacturer_list.push(manufacturer_list.data[i].name)
        }
        $scope.statues = [{value:0 , name:'deactived'}, {value:1 , name:'actived'}];
        $scope.editMedicineList = function () {
          NProgress.start();
          API.updateMedicineList(medicine_list_id, $scope.medicine_list).success(function (response) {
            NProgress.done();
            if(response.code == 1) {
              $state.reload($state.current);
              $uibModalInstance.dismiss();
              toastr.success(response.message);
            } else {
              if(response.code == 2) {
                toastr.error(response.message);
              }
            }
            if (response.code == 3) {
              $ngBootbox.confirm($filter("translator")("confirm_deactived", "category")).then(function() {
                NProgress.start();
                API.updateMedicineList(medicine_list_id, $scope.medicine_list, 1).success(function(response) {
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
          });
        }
        $scope.close = function () {
          $uibModalInstance.dismiss();
        }
      }]
    });
  }

  $scope.showDeleteMedicineListModal = function(medicine_list) {
    $ngBootbox.confirm($filter("translator")("confirm_delete", "main") + ' "' + medicine_list.name + '"?')
    .then(function() {
      NProgress.start();
      API.deleteMedicineList(medicine_list.id).success(function(response) {
        NProgress.done();
        if(response.code == 1) {
          $state.reload($state.current);
          toastr.success(response.message);
        } else {
          if(response.code == 2) {
            toastr.error(response.message);
          }
        }
        if (response.code == 3) {
          $ngBootbox.confirm($filter("translator")("confirm_deactived", "category")).then(function() {
            NProgress.start();
            API.deleteMedicineList(medicine_list.id, 1).success(function(response) {
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
      });
    });
  }

  $scope.pageChanged = function() {
    $state.go($state.current, {page: $scope.currentPage});
  }
  $scope.search = function() {
    $state.go($state.current, {keyword: $scope.keyword, page: 1,keystatus: $scope.medicine.keystatus});
  }
}]);
