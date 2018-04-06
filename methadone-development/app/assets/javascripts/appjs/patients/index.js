angular.module("AccountApp")
  .config(['$stateProvider', '$urlRouterProvider',
    function ($stateProvider, $urlRouterProvider) {
  $stateProvider
  .state('main.patients', {
    url: "/patients?page&keyword&type",
    templateUrl: "/templates/patients/index.html",
    resolve: {
      patients: ['API', '$stateParams', function(API, $stateParams) {
        return API.getPatientsDoctor($stateParams.page, $stateParams.keyword, $stateParams.type).then(function(response) {
          return response.data;
        });
      }],
      provinces: ['API', function(API) {
        return API.getProvinces().then(function(response) {
          return response.data.data;
        });
      }],
      ethnicities: ['API', function(API) {
        return API.getEthnicities().then(function(response) {
          return response.data.data;
        });
      }],
      issuingAgencies: ['API', function(API) {
        return API.getAllIssuingAgencies().then(function(response) {
          return response.data.data;
        });
      }],
    },
    controller: "Doctor_PatientsController",
    requireLogin: true,
    requireRoles: ["doctor", "executive_staff", "admin_agency", "admin"]
  })
}]);
