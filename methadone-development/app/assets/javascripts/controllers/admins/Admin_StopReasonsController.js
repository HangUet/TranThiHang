app.controller("Admin_StopReasonsController", ['$scope', '$state', 'reasons', '$uibModal', '$ngBootbox', 'API',
  'toastr', '$filter', function ($scope, $state, reasons, $uibModal, $ngBootbox, API, toastr, $filter) {
  $scope.reasons = reasons;
  $scope.keyword = $state.params.keyword;
  $scope.reason = {};
  $scope.reason.keystatus = $state.params.keystatus;
  $scope.currentPage = $state.params.page || 1;
  $scope.showCreateReasonModal = function() {
    NProgress.start();
    var modalInstance = $uibModal.open({
      templateUrl: "/templates/admin/stop_reasons/create.html",
      size: 'md',
      backdrop: 'static',
      keyboard: false,
      controller: ['$scope', '$uibModalInstance', 'toastr', '$state', 'API',
        function($scope, $uibModalInstance, toastr, $state, API) {
        NProgress.done();
        $scope.createReason = function () {
          NProgress.start();
          API.createReason($scope.reason).success(function (response) {
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

  $scope.showEditReasonModal = function(reason_id) {
    NProgress.start();
    var modalInstance = $uibModal.open({

      templateUrl: "/templates/admin/stop_reasons/edit.html",
      size: 'md',
      backdrop: 'static',
      keyboard: false,
      resolve: {
        reason: ["API", function(API) {
          return API.getReason(reason_id).then(function(response) {
            return response.data;
          });
        }]
      },
      controller: ['$scope', 'reason', '$uibModalInstance', 'toastr', '$state', 'API',
        function ($scope, reason, $uibModalInstance, toastr, $state, API) {
        NProgress.done();
        $scope.reason = reason.data;
        $scope.editReason = function () {
          NProgress.start();
          API.updateReason(reason_id, $scope.reason).success(function (response) {
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

  $scope.showDeleteReasonModal = function(reason) {
    $ngBootbox.confirm($filter("translator")("confirm_delete", "main") + ' "' + reason.name + '"?').then(function() {
      NProgress.start();
      API.deleteReason(reason.id).success(function(response) {
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
    $state.go($state.current, {keyword: $scope.keyword, keystatus: $scope.reason.keystatus});
  }
}]);
