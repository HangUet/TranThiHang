app.controller("ResetPasswordController", ['$scope', '$state', 'toastr', 'Auth', function ($scope, $state, toastr, Auth) {
  $scope.resetPassword = function() {
    NProgress.start();
    Auth.resetPassword($scope.email).then(function(response) {
      NProgress.done();
      if(response.data.code == 1) {
        toastr.success(response.data.message);
        $state.go("main");
      } else {
        toastr.error(response.data.message);
      }
    });
  }
}]);
