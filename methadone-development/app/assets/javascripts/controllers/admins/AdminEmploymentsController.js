app.controller("Admin_EmploymentsController", ['$scope', '$state', 'employments', '$uibModal', '$ngBootbox', 'API', 'toastr',
  '$filter', function ($scope, $state, employments, $uibModal, $ngBootbox, API, toastr, $filter) {
  $scope.employments = employments;
  $scope.keyword = $state.params.keyword;
  $scope.employment = {};
  $scope.employment.keystatus = $state.params.keystatus;
  $scope.currentPage = $state.params.page || 1;
  $scope.showCreateEmploymentModal = function() {
    NProgress.start();
    var modalInstance = $uibModal.open({
      templateUrl: "/templates/admin/employments/create.html",
      size: 'md',
      backdrop: 'static',
      keyboard: false,
      controller: ['$scope', '$uibModalInstance', 'toastr', '$state', 'API',
        function($scope, $uibModalInstance, toastr, $state, API) {
        NProgress.done();
        $scope.createEmployment = function () {
          NProgress.start();
          API.createEmployment($scope.employment).success(function (response) {
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

  $scope.showEditEmploymentModal = function(employment_id) {
    NProgress.start();
    var modalInstance = $uibModal.open({
      templateUrl: "/templates/admin/employments/edit.html",
      size: 'md',
      backdrop: 'static',
      keyboard: false,
      resolve: {
        employment: ["API", function(API) {
          return API.getEmployment(employment_id).then(function(response) {
            return response.data;
          });
        }]
      },
      controller: ['$scope', 'employment', '$uibModalInstance', 'toastr', '$state', 'API',
        function ($scope, employment, $uibModalInstance, toastr, $state, API) {
        NProgress.done();
        $scope.employment = employment.data;
        $scope.editEmployment = function () {
          NProgress.start();
          API.updateEmployment(employment_id, $scope.employment).success(function (response) {
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

  $scope.showDeleteEmploymentModal = function(employment) {
    $ngBootbox.confirm($filter("translator")("confirm_delete", "main") + ' "' + employment.name + '"?').then(function() {
      NProgress.start();
      API.deleteEmployment(employment.id).success(function(response) {
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
    $state.go($state.current, {keyword: $scope.keyword, keystatus: $scope.employment.keystatus});
  }
}]);
