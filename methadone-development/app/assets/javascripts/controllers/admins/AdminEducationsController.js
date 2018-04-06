app.controller("Admin_EducationsController", ['$scope', '$state', 'educations', '$uibModal', '$ngBootbox', 'API',
  'toastr', '$filter', function ($scope, $state, educations, $uibModal, $ngBootbox, API, toastr, $filter) {
  $scope.educations = educations;
  $scope.keyword = $state.params.keyword;
  $scope.education = {};
  $scope.education.keystatus = $state.params.keystatus;
  $scope.currentPage = $state.params.page || 1;
  $scope.showCreateEducationModal = function() {
    NProgress.start();
    var modalInstance = $uibModal.open({
      templateUrl: "/templates/admin/educations/create.html",
      size: 'md',
      backdrop: 'static',
      keyboard: false,
      controller: ['$scope', '$uibModalInstance', 'toastr', '$state', 'API',
        function($scope, $uibModalInstance, toastr, $state, API) {
        NProgress.done();
        $scope.createEducation = function () {
          NProgress.start();
          API.createEducation($scope.education).success(function (response) {
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

  $scope.showEditEducationModal = function(education_id) {
    NProgress.start();
    var modalInstance = $uibModal.open({

      templateUrl: "/templates/admin/educations/edit.html",
      size: 'md',
      backdrop: 'static',
      keyboard: false,
      resolve: {
        education: ["API", function(API) {
          return API.getEducation(education_id).then(function(response) {
            return response.data;
          });
        }]
      },
      controller: ['$scope', 'education', '$uibModalInstance', 'toastr', '$state', 'API',
        function ($scope, education, $uibModalInstance, toastr, $state, API) {
        NProgress.done();
        $scope.education = education.data;
        $scope.editEducation = function () {
          NProgress.start();
          API.updateEducation(education_id, $scope.education).success(function (response) {
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

  $scope.showDeleteEducationModal = function(education) {
    $ngBootbox.confirm($filter("translator")("confirm_delete", "main") + ' "' + education.name + '"?').then(function() {
      NProgress.start();
      API.deleteEducation(education.id).success(function(response) {
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
    $state.go($state.current, {keyword: $scope.keyword, keystatus: $scope.education.keystatus});
  }

}]);
