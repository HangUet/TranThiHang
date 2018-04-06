app.controller("Admin_MaritalsController", ['$scope', '$state', 'maritals', '$uibModal', '$ngBootbox', 'API', 'toastr',
  '$filter', function ($scope, $state, maritals, $uibModal, $ngBootbox, API, toastr, $filter) {
  $scope.maritals = maritals;
  $scope.keyword = $state.params.keyword;
  $scope.marital = {};
  $scope.marital.keystatus = $state.params.keystatus;
  $scope.currentPage = $state.params.page || 1;
  $scope.showCreateMaritalModal = function() {
    NProgress.start();
    var modalInstance = $uibModal.open({
      templateUrl: "/templates/admin/maritals/create.html",
      size: 'md',
      backdrop: 'static',
      keyboard: false,
      controller: ['$scope', '$uibModalInstance', 'toastr', '$state', 'API',
        function($scope, $uibModalInstance, toastr, $state, API) {
        NProgress.done();
        $scope.createMarital = function () {
          NProgress.start();
          API.createMarital($scope.marital).success(function (response) {
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

  $scope.showEditMaritalModal = function(marital_id) {
    NProgress.start();
    var modalInstance = $uibModal.open({
      templateUrl: "/templates/admin/maritals/edit.html",
      size: 'md',
      backdrop: 'static',
      keyboard: false,
      resolve: {
        marital: ["API", function(API) {
          return API.getMarital(marital_id).then(function(response) {
            return response.data;
          });
        }]
      },
      controller: ['$scope', 'marital', '$uibModalInstance', 'toastr', '$state', 'API',
        function ($scope, marital, $uibModalInstance, toastr, $state, API) {
        NProgress.done();
        $scope.marital = marital.data;
        $scope.editMarital = function () {
          NProgress.start();
          API.updateMarital(marital_id, $scope.marital).success(function (response) {
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

  $scope.showDeleteMaritalModal = function(marital) {
    $ngBootbox.confirm($filter("translator")("confirm_delete", "main") + ' "' + marital.name + '"?').then(function() {
      NProgress.start();
      API.deleteMarital(marital.id).success(function(response) {
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

  $scope.pageChanged = function() {
    $state.go($state.current, {page: $scope.currentPage});
  }
  $scope.search = function() {
    $state.go($state.current, {keyword: $scope.keyword, keystatus: $scope.marital.keystatus});
  }
}]);
