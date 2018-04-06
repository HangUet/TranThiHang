app.controller("Admin_AdminAgenciesController", ['$scope', '$state', '$filter', 'administrators', '$uibModal', '$ngBootbox', 'API', 'toastr',
  function ($scope, $state, $filter, administrators, $uibModal, $ngBootbox, API, toastr) {
  $scope.administrators = administrators;
  $scope.currentPage = $state.params.page || 1;
  $scope.keyword = $state.params.keyword;
  $scope.search = function() {
    $state.go($state.current, {keyword: $scope.keyword});
  }
  $scope.pageChanged = function() {
    $state.go($state.current, {page: $scope.currentPage});
  }
  $scope.showCreateAdminModal = function() {
    NProgress.start();
    var modalInstance = $uibModal.open({
      templateUrl: "/templates/admin/users/create.html",
      size: 'lg',
      backdrop: 'static',
      keyboard: false,
      resolve: {
        issuing_agencies: ['API', function(API) {
          return API.getAllIssuingAgencies().then(function(response) {
            if(response.data.code == 1)  {
              return response.data.data;
            } else {
              toastr.error(response.message);
            }
          });
        }]
      },
      controller: ['$scope', '$uibModalInstance', 'toastr', '$state', 'issuing_agencies', 'API',
        function ($scope, $uibModalInstance, toastr, $state, issuing_agencies, API) {
        NProgress.done();
        $scope.agencies = issuing_agencies;
        $scope.user = {}
        $scope.createAdmin = function () {
          NProgress.start();
          API.createAdmin($scope.user).success(function (response) {
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
  $scope.showUpdateAdminModal = function(user_id) {
    NProgress.start();
    var modalInstance = $uibModal.open({
      templateUrl: "/templates/admin/users/edit.html",
      size: 'lg',
      backdrop: 'static',
      keyboard: false,
      resolve: {
        issuing_agencies: ['API', function(API) {
          return API.getAllIssuingAgencies().then(function(response) {
            if(response.data.code == 1)  {
              return response.data.data;
            } else {
              toastr.error(response.message);
            }
          });
        }],
        user: ["API", function(API) {
          return API.getUser(user_id).then(function(response) {
            return response.data;
          });
        }]
      },
      controller: ['$scope','user', '$uibModalInstance', 'toastr', '$state', 'issuing_agencies', 'API',
        function ($scope, user, $uibModalInstance, toastr, $state, issuing_agencies, API) {
        NProgress.done();
        $scope.agencies = issuing_agencies;
        $scope.user = user.data;
        $scope.updateAdmin = function () {
          NProgress.start();
          API.updateAdmin(user_id, $scope.user).success(function (response) {
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
  $scope.showDeleteAdminModal = function(user) {
    $ngBootbox.confirm($filter("translator")("confirm_delete", "main") + ' "' + user.full_name + '"?').then(function() {
      NProgress.start();
      API.deleteUser(user.id).success(function(response) {
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
