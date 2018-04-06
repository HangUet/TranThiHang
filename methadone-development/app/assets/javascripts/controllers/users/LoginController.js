app.controller("SignInController", ['$scope', '$rootScope', '$state', '$http', '$window', 'toastr', '$uibModal', 'Auth',
  function ($scope, $rootScope, $state, $http, $window, toastr, $uibModal, Auth) {
  $scope.signIn = function () {
    NProgress.start();
    Auth.signIn($scope.email, $scope.password).then(function(response) {
      NProgress.done();
      if(response.data.code == 1) {
        $rootScope.currentUser = response.data.user;
        $http.defaults.headers.common["Authorization"] = 'Bearer ' + response.data.token;
        $window.localStorage.user = JSON.stringify(response.data.user);
        $window.localStorage.token = response.data.token;
        $state.go("main");
      } else if (response.data.code == 3) {
        $state.go("unlock");
      } else {
        toastr.error(response.data.message);
      }
    });
  }
  // $scope.showSampleUser = function() {
  //     var modalInstance = $uibModal.open({
  //     template: "<div class='modal-header'>Tài khoản thử nghiệm</div><div class='modal-body'><table class='table table-bordered'><tr ng-repeat='user in users'><td>{{user.email}}</td><td>{{user.role}}</td><td><input value='Chọn' type='button' class='btn btn-sm btn-default' ng-click='select(user)'/></td></tr></table></div>",
  //     controller: ['$scope', '$uibModalInstance', 'toastr', function ($scope, $uibModalInstance, toastr) {
  //       $http.get("/api/v1/sample_users").success(function(response) {
  //         $scope.users = response.data;
  //       });
  //       $scope.select = function(user) {
  //         $scope.$parent.email = user.email;
  //         $scope.$parent.password = "12345678";
  //         $uibModalInstance.dismiss();
  //       }
  //       $scope.close = function () {
  //         $uibModalInstance.dismiss();
  //       }
  //     }]
  //   });
  // }
}]);
