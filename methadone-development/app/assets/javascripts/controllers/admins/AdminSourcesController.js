app.controller("Admin_SourcesController", ['$scope', '$state', 'sources', '$uibModal', '$ngBootbox', 'API', 'toastr',
  '$filter', function ($scope, $state, sources, $uibModal, $ngBootbox, API, toastr, $filter) {
  $scope.sources = sources;
  $scope.keyword = $state.params.keyword;
  $scope.source = {};
  $scope.source.keystatus = $state.params.keystatus;
  $scope.currentPage = $state.params.page || 1;
  $scope.showCreateSourceModal = function() {
    NProgress.start();
    var modalInstance = $uibModal.open({
      templateUrl: "/templates/admin/sources/create.html",
      size: 'md',
      controller: ['$scope', '$uibModalInstance', 'toastr', '$state', 'API',
        function($scope, $uibModalInstance, toastr, $state, API) {
        NProgress.done();
        $scope.createSource = function () {
          NProgress.start();
          API.createSource($scope.source).success(function (response) {
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

  $scope.showEditSourceModal = function(source_id) {
    NProgress.start();
    var modalInstance = $uibModal.open({
      templateUrl: "/templates/admin/sources/edit.html",
      size: 'md',
      resolve: {
        source: ["API", function(API) {
          return API.getSource(source_id).then(function(response) {
            return response.data;
          });
        }]
      },
      controller: ['$scope', 'source', '$uibModalInstance', 'toastr', '$state', 'API',
        function ($scope, source, $uibModalInstance, toastr, $state, API) {
        NProgress.done();
        $scope.source = source.data;
        $scope.editSource = function () {
          NProgress.start();
          API.updateSource(source_id, $scope.source).success(function (response) {
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

  $scope.showDeleteSourceModal = function(source) {
    $ngBootbox.confirm($filter("translator")("confirm_delete", "main") + ' "' + source.name + '"?').then(function() {
      NProgress.start();
      API.deleteSource(source.id).success(function(response) {
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
    $state.go($state.current, {keyword: $scope.keyword, keystatus: $scope.source.keystatus});
  }
}]);
