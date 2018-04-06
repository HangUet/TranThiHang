app.controller("ConfirmationController", ['$scope', '$rootScope', '$state', '$http', '$window', 'toastr', 'Auth', '$location',
  function ($scope, $rootScope, $state, $http, $window, toastr, Auth, $location) {
  $scope.confirmation_token = $location.search().confirmation_token;
  $scope.user = $location.search().user;
  if($scope.confirmation_token != undefined) {
    Auth.confirmation($scope.confirmation_token, $scope.user).then(function(response) {
      if(response.data.code == 1) {
        toastr.success(response.data.message);
        $state.go("main");
      } else {
        toastr.error(response.data.message);
        $state.go("confirmation");
      }
    })
  }
  $scope.resendConfirmation = function () {
    NProgress.start();

    Auth.resendConfirmation($scope.email).then(function(response) {
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
