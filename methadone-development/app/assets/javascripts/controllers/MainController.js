app.controller("MainController", ['$scope', '$rootScope', '$state', '$window', '$uibModal', 'Auth', 'API',
  function ($scope, $rootScope, $state, $window, $uibModal, Auth, API) {
  if ($state.current.name == 'main') {
    if ($rootScope.currentUser.role == "admin") {
      // $state.go('main.administrators');
      $state.go('main.dashboard1');
    } else if ($rootScope.currentUser.role == "admin_agency") {
      // $state.go('main.users');
      $state.go('main.dashboard1');
    } else if ($rootScope.currentUser.role == "doctor") {
      // $state.go('main.patients');
      $state.go('main.dashboard_doctor');
    } else if ($rootScope.currentUser.role == "nurse") {
      $state.go('main.nurse_patients');
    } else if ($rootScope.currentUser.role == "storekeeper") {
      $state.go('main.dashboard1');
    } else if ($rootScope.currentUser.role == "executive_staff") {
      $state.go('main.dashboard1');
    }
  }
  $scope.pageSidebarClosed = true;
  $scope.goToTreatment = function(barcode) {
    if(!barcode) return;
    API.getPatientByBarcode(barcode).success(function(response) {
      if(response.code == 1) {
        $state.go("main.treatment", {id: response.data.id});
        $scope.barcode_message = "";
      } else {
        $scope.barcode_message = response.message;
      }
    });
  }
  $scope.showEditPasswordModal = function() {
    NProgress.start();
    var modalInstance = $uibModal.open({
      templateUrl: "/templates/users/passwords/editpassword.html",
      size: 'sm',
      backdrop: 'static',
      keyboard: false,
      controller: ['$scope', '$uibModalInstance', '$state', 'toastr', 'Auth',
      function($scope, $uibModalInstance, $state, toastr, Auth) {
        NProgress.done();
        $scope.close = function () {
          $uibModalInstance.dismiss();
        }
        $scope.updatePassword = function() {
          NProgress.start();
          Auth.updatePassword($scope.new_password, $scope.current_password).then(function(response) {
            NProgress.done();
            if(response.data.code == 1) {
              $uibModalInstance.dismiss();
              toastr.success(response.data.message);
            } else {
              toastr.error(response.data.message);
            }
          });
        }
      }]
    })
  }

  $scope.showEditNameModal = function() {
    NProgress.start();
    var modalInstance = $uibModal.open({
      templateUrl: "/templates/users/name/editname.html",
      size: 'sm',
      backdrop: 'static',
      keyboard: false,
      controller: ['$scope', '$window','$rootScope', '$uibModalInstance', '$state', 'toastr', 'API',
      function($scope, $window ,$rootScope, $uibModalInstance, $state, toastr, API) {
        $scope.user = {
          first_name: $rootScope.currentUser.first_name,
          last_name: $rootScope.currentUser.last_name,
        };
        NProgress.done();
        $scope.close = function () {
          $uibModalInstance.dismiss();
        }
        $scope.updateName = function() {
          NProgress.start();
          API.updateName($scope.user).then(function(response) {
            NProgress.done();
            if(response.data.code == 1) {
              $uibModalInstance.dismiss();
              $rootScope.currentUser.first_name = $scope.user.first_name;
              $rootScope.currentUser.last_name = $scope.user.last_name;
              $window.localStorage.user = JSON.stringify(response.data.data);
              toastr.success(response.data.message);
            } else {
              toastr.error(response.data.message);
            }
          });
        }
      }]
    })
  }

  $scope.signOut = function () {
    Auth.signOut();
    $state.go("signin");
  };

  $scope.state = $state;
}]);
