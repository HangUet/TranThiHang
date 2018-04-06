app.controller("AdminAgencies_UsersController", ['$scope', '$state', '$filter', 'users', '$uibModal','$ngBootbox', 'API', 'toastr',
  function ($scope, $state, $filter, users, $uibModal, $ngBootbox, API, toastr) {
  $scope.users = users;
  $scope.currentPage = $state.params.page || 1;
  $scope.keyword = $state.params.keyword;
  $scope.search = function() {
    $state.go($state.current, {keyword: $scope.keyword});
  }
  $scope.pageChanged = function() {
    $state.go($state.current, {page: $scope.currentPage});
  }
  $scope.showCreateUserModal = function() {
    NProgress.start();
    var modalInstance = $uibModal.open({
      templateUrl: "/templates/admin_agency/users/create.html",
      size: 'lg',
      controller: ['$scope', '$uibModalInstance', 'toastr', '$state', 'API', '$filter',
        function ($scope, $uibModalInstance, toastr, $state, API, $filter) {
        NProgress.done();
        $scope.user = {};
        $scope.role_list = ["doctor", "nurse", "executive_staff", "counselor", "analyzer", "storekeeper"];
        $scope.createUser = function () {
          NProgress.start();
          API.createUser($scope.user).success(function (response) {
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
  $scope.showEditUserModal = function(user_id) {
    NProgress.start();
    var modalInstance  = $uibModal.open({
      templateUrl: "/templates/admin_agency/users/edit.html",
      resolve: {
        user: ["API", function(API) {
          return API.getUser(user_id).then(function(response) {
            return response.data;
          });
        }]
      },
      size: 'lg',
      controller: ['$scope', 'user', '$uibModalInstance', 'toastr', '$state', 'API',
        function($scope, user, $uibModalInstance, toastr, $state, API) {
        NProgress.done();
        $scope.user = user.data;
        $scope.role_list = ["doctor", "nurse", "executive_staff", "counselor", "analyzer", "storekeeper"];
        $scope.editUser = function() {
          NProgress.start();
          API.updateUser(user_id, $scope.user).success(function(response) {
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
    })
  }
  $scope.showDeleteUserModal = function(user) {
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
