app.controller("UnlockController", ['$scope', '$rootScope', '$state', '$http', '$window', 'toastr', 'Auth', '$location',
  function ($scope, $rootScope, $state, $http, $window, toastr, Auth, $location) {
  $scope.unlock_token = $location.search().unlock_token;
  $scope.user = $location.search().user;
  if($scope.unlock_token != undefined) {
    Auth.unlock($scope.unlock_token, $scope.user).then(function(response) {
      if(response.data.code == 1) {
        toastr.success(response.data.message);
        $state.go("main");
      } else {
        toastr.error(response.data.message);
        $state.go("confirmation");
      }
    })
  }
  $scope.resendUnlock = function () {
    NProgress.start();

    Auth.resendUnlock($scope.email).then(function(response) {
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
