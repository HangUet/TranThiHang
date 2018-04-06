app.controller("EditPasswordController", ['$scope', '$rootScope', '$http', '$window', '$state', 'toastr', 'Auth', '$location',
  function ($scope, $rootScope, $http, $window, $state, toastr, Auth, $location) {
  $scope.token = $location.search().reset_password_token;
  $scope.user = $location.search().user;
  $scope.editPassword = function() {
    NProgress.start();
    Auth.editPassword($scope.user, $scope.token, $scope.password).then(function(response) {
      NProgress.done();
      if(response.data.code == 1) {
        $rootScope.currentUser = response.data.user;
        $http.defaults.headers.common["Authorization"] = 'Bearer ' + response.data.token;
        $window.localStorage.user = JSON.stringify(response.data.user);
        $window.localStorage.token = response.data.token;
        toastr.success(response.data.message);
        $state.go("main");
      } else {
        toastr.error(response.data.message);
      }
    });
  }
}]);
