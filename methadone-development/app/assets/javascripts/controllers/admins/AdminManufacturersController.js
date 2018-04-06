app.controller("Admin_ManufacturersController", ['$scope', '$state', 'manufacturers', '$uibModal', '$ngBootbox', 'API',
  'toastr', '$filter', function ($scope, $state, manufacturers, $uibModal, $ngBootbox, API, toastr, $filter) {
  $scope.manufacturers = manufacturers;
  $scope.keyword = $state.params.keyword;
  $scope.manufacturer = {};
  $scope.manufacturer.keystatus = $state.params.keystatus;
  $scope.currentPage = $state.params.page || 1;
  $scope.showCreateManufacturerModal = function() {
    NProgress.start();
    var modalInstance = $uibModal.open({
      templateUrl: "/templates/admin/manufacturers/create.html",
      size: 'md',
      backdrop: 'static',
      keyboard: false,
      controller: ['$scope', '$uibModalInstance', 'toastr', '$state', 'API',
        function($scope, $uibModalInstance, toastr, $state, API) {
        NProgress.done();
        $scope.createManufacturer = function () {
          NProgress.start();
          API.createManufacturer($scope.manufacturer).success(function (response) {
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

  $scope.showEditManufacturerModal = function(manufacturer_id) {
    NProgress.start();
    var modalInstance = $uibModal.open({
      templateUrl: "/templates/admin/manufacturers/edit.html",
      size: 'md',
      backdrop: 'static',
      keyboard: false,
      resolve: {
        manufacturer: ["API", function(API) {
          return API.getAManufacturer(manufacturer_id).then(function(response) {
            return response.data;
          });
        }]
      },
      controller: ['$scope', 'manufacturer', '$uibModalInstance', 'toastr', '$state', 'API',
        function ($scope, manufacturer, $uibModalInstance, toastr, $state, API) {
        NProgress.done();
        $scope.manufacturer = manufacturer.data;
        console.log($scope.manufacturer.status)
        $scope.statues = [{value:0 , name:'deactived'}, {value:1 , name:'actived'}];
        $scope.editManufacturer = function () {
          NProgress.start();
          API.updateManufacturer(manufacturer_id, $scope.manufacturer).success(function (response) {
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

  $scope.showDeleteManufacturerModal = function(manufacturer) {
    $ngBootbox.confirm($filter("translator")("confirm_delete", "main") + ' "' + manufacturer.name + '"?').then(function() {
      NProgress.start();
      API.deleteManufacturer(manufacturer.id).success(function(response) {
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
          $ngBootbox.confirm($filter("translator")("confirm_deactived_manufacturer", "category")).then(function() {
            NProgress.start();
            API.deleteManufacturer(manufacturer.id, 1).success(function(response) {
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
    $state.go($state.current, {keyword: $scope.keyword, page: 1, keystatus: $scope.manufacturer.keystatus});
  }
}]);
