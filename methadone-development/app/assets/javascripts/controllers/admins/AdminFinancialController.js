app.controller("Admin_FinancialsController", ['$scope', '$state', 'financials', '$uibModal', '$ngBootbox', 'API', 'toastr',
  '$filter', function ($scope, $state, financials, $uibModal, $ngBootbox, API, toastr, $filter) {
  $scope.financials = financials;
  $scope.keyword = $state.params.keyword;
  $scope.financial = {};
  $scope.financial.keystatus = $state.params.keystatus;
  $scope.currentPage = $state.params.page || 1;
  $scope.showCreateFinancialModal = function() {
    NProgress.start();
    var modalInstance = $uibModal.open({
      templateUrl: "/templates/admin/financials/create.html",
      size: 'md',
      backdrop: 'static',
      keyboard: false,
      controller: ['$scope', '$uibModalInstance', 'toastr', '$state', 'API',
        function($scope, $uibModalInstance, toastr, $state, API) {
        NProgress.done();
        $scope.createFinancial = function () {
          NProgress.start();
          API.createFinancial($scope.financial).success(function (response) {
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

  $scope.showEditFinancialModal = function(financial_id) {
    NProgress.start();
    var modalInstance = $uibModal.open({
      templateUrl: "/templates/admin/financials/edit.html",
      size: 'md',
      backdrop: 'static',
      keyboard: false,
      resolve: {
        financial: ["API", function(API) {
          return API.getFinancial(financial_id).then(function(response) {
            return response.data;
          });
        }]
      },
      controller: ['$scope', 'financial', '$uibModalInstance', 'toastr', '$state', 'API',
        function ($scope, financial, $uibModalInstance, toastr, $state, API) {
        NProgress.done();
        $scope.financial = financial.data;
        $scope.editFinancial = function () {
          NProgress.start();
          API.updateFinancial(financial_id, $scope.financial).success(function (response) {
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

  $scope.showCancelFinancialModal = function(financial) {
    $ngBootbox.confirm($filter("translator")("confirm_cancel", "main") + ' "' +
      financial.fromfinancial+ ' - ' + financial.tofinancial + '"?').then(function() {
      NProgress.start();
      API.deleteFinancial(financial.id).success(function(response) {
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
    $state.go($state.current, {keyword: $scope.keyword, keystatus: $scope.financial.keystatus});
  }

}]);
