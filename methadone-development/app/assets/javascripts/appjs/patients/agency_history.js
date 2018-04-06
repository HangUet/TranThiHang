angular.module("AccountApp")
  .config(['$stateProvider', '$urlRouterProvider',
    function ($stateProvider, $urlRouterProvider) {
  $stateProvider
  .state('main.patient_agency_history', {
    url: "/patient_agency_histories/:id",
    resolve: {
      patient_agency_history: ['API', '$stateParams', function(API, $stateParams) {
        return API.getPatientAgencyHistory($stateParams.id).then(function(response) {
          return response.data;
        });
      }]
    },
    templateUrl: "/templates/patient_agency_histories/show.html",
    controller: "Doctor_PatientAgencyHistoryController",
    requireSignIn: true,
    requireRoles: ["doctor", "executive_staff", "admin_agency"]
  })
  .state('main.patient_agency_history.executive_info', {
    url: "/executive_info/:patient_id",
    templateUrl: "/templates/patients/executive_info.html",
    resolve: {
      patient: ['API', '$stateParams', function(API, $stateParams) {
        return API.getPatient($stateParams.patient_id).then(function(response) {
          return response.data.data;
        });
      }],
    },
    controller: "Doctor_InforPatientController",
    requireLogin: true,
    requireRoles: ["doctor", "executive_staff", "admin_agency"]
  })
  .state('main.patient_agency_history.info', {
    url: "/info/:patient_id",
    templateUrl: "/templates/patients/info.html",
    resolve: {
      patient: ['API', '$stateParams', function(API, $stateParams) {
        return API.getPatient($stateParams.patient_id).then(function(response) {
          return response.data.data;
        });
      }],
    },
    controller: "Doctor_InforPatientController",
    requireLogin: true,
    requireRoles: ["doctor", "executive_staff", "admin_agency"]
  })
  .state('main.patient_agency_history.change_agency', {
    url: "/change_agency",
    templateUrl: "/templates/patient_agency_histories/change_agency.html",
    resolve: {
      patient_agency_history: ['API', '$stateParams', function(API, $stateParams) {
        return API.getPatientAgencyHistory($stateParams.id).then(function(response) {
          return response.data;
        });
      }]
    },
    controller: "Doctor_PatientAgencyHistoryController",
    requireLogin: true,
    requireRoles: ["doctor", "executive_staff", "admin_agency"]
  })
}]);
