app.controller("Admin_ProvidersController", ['$scope', '$state', 'providers', '$uibModal', '$ngBootbox', 'API',
  'toastr', '$filter', function ($scope, $state, providers, $uibModal, $ngBootbox, API, toastr, $filter) {
  $scope.providers = providers;
  $scope.keyword = $state.params.keyword;
  $scope.provider = {};
  $scope.provider.keystatus = $state.params.keystatus;
  $scope.currentPage = $state.params.page || 1;
  $scope.showCreateProviderModal = function() {
    NProgress.start();
    var modalInstance = $uibModal.open({
      templateUrl: "/templates/admin/providers/create.html",
      size: 'md',
      backdrop: 'static',
      keyboard: false,
      controller: ['$scope', '$uibModalInstance', 'toastr', '$state', 'API',
        function($scope, $uibModalInstance, toastr, $state, API) {
        NProgress.done();
        $scope.createProvider = function () {
          NProgress.start();
          API.createProvider($scope.provider).success(function (response) {
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

  $scope.showEditProviderModal = function(provider_id) {
    NProgress.start();
    var modalInstance = $uibModal.open({
      templateUrl: "/templates/admin/providers/edit.html",
      size: 'md',
      backdrop: 'static',
      keyboard: false,
      resolve: {
        provider: ["API", function(API) {
          return API.getProvider(provider_id).then(function(response) {
            return response.data;
          });
        }]
      },
      controller: ['$scope', 'provider', '$uibModalInstance', 'toastr', '$state', 'API',
        function ($scope, provider, $uibModalInstance, toastr, $state, API) {
        NProgress.done();
        $scope.provider = provider.data;
        $scope.editProvider = function () {
          NProgress.start();
          API.updateProvider(provider_id, $scope.provider).success(function (response) {
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

  $scope.showDeleteProviderModal = function(provider) {
    $ngBootbox.confirm($filter("translator")("confirm_delete", "main") + ' "' + provider.name + '"?')
    .then(function() {
      NProgress.start();
      API.deleteProvider(provider.id).success(function(response) {
        NProgress.done();
        if(response.code == 1) {
          $state.reload($state.current);
          toastr.success(response.message);
        } else {
          if(response.code == 2) {
            toastr.error(response.message);
          }
        }
        if (response.code == 3) {
          $ngBootbox.confirm($filter("translator")("confirm_deactived_provider", "category")).then(function() {
            NProgress.start();
            API.deleteProvider(provider.id, 1).success(function(response) {
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
      });
    });
  }

  $scope.pageChanged = function() {
    $state.go($state.current, {page: $scope.currentPage});
  }
  $scope.search = function() {
    $state.go($state.current, {keyword: $scope.keyword, page: 1 , keystatus: $scope.provider.keystatus});
  }
}]);
