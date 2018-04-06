angular.module("AccountApp")
  .config(['$stateProvider', '$urlRouterProvider',
    function ($stateProvider, $urlRouterProvider) {
  $stateProvider
  .state('main.executive_staff', {
    url: "/executive_staff/patients?page&keyword",
    templateUrl: "/templates/executive_staff/patients/index.html",
    resolve: {
      patients: ['API', '$stateParams', function(API, $stateParams) {
        return API.getListPatientWarnings($stateParams.page, $stateParams.keyword).then(function(response) {
          return response.data;
        });
      }]
    },
    controller: ['$scope', '$state', 'patients', function ($scope, $state, patients) {
      $scope.patients = patients;
      if($scope.patients.total) {
        $state.go("main.executive_staff.patient_warnings", {id: $scope.patients.data[0].id});
      }
      $scope.currentPage = $state.params.page || 1;
      $scope.keyword = $state.params.keyword;
      $scope.search = function() {
        $state.go($state.current, {keyword: $scope.keyword});
      }
      $scope.pageChanged = function() {
        $state.go($state.current, {page: $scope.currentPage});
      }
    }],
    requireLogin: true,
    requireRoles: ["executive_staff"]
  })
  .state('main.executive_staff.patient_warnings', {
    url: "/:id/patient_warnings",
    templateUrl: "/templates/executive_staff/patients/patient_warnings.html",
    resolve: {
      patient: ['API', '$stateParams', function(API, $stateParams) {
        return API.getPatient($stateParams.id).then(function(response) {
          return response.data.data;
        });
      }],
      patient_warnings: ['API', '$stateParams', function(API, $stateParams) {
        return API.getPatientWarnings($stateParams.id).then(function(response) {
          return response.data.data;
        });
      }]
    },
    controller: ['$scope', '$rootScope', '$state', 'toastr', 'patient', 'patient_warnings', 'API',
      function ($scope, $rootScope, $state, toastr, patient, patient_warnings, API) {
      $scope.patient = patient;
      $scope.patient_warnings = patient_warnings;
      $scope.updatePatientWarnings = function() {
        NProgress.start();
        API.updatePatientWarnings($scope.patient_warnings.id).success(function(response) {
          NProgress.done();
          if(response.code == 1) {
            $state.reload($state.current);
            toastr.success(response.message);
          } else {
            toastr.error(response.message);
          }
        });
      }
    }],
    requireSignIn: true,
    requireRoles: ["executive_staff"]
  })
}]);
