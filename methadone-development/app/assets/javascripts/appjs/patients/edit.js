angular.module("AccountApp")
  .config(['$stateProvider', '$urlRouterProvider',
    function ($stateProvider, $urlRouterProvider) {
  $stateProvider
  .state('main.patients.edit', {
    url: "/:id/edit",
    templateUrl: "/templates/patients/edit.html",
    resolve: {
      patient: ['API', '$stateParams', function(API, $stateParams) {
        return API.getPatient($stateParams.id).then(function(response) {
          return response.data.data;
        });
      }],
      ethnicities: ['API', function(API) {
        return API.getEthnicities().then(function(response) {
          return response.data.data;
        });
      }],
      provinces: ['API', function(API) {
        return API.getProvinces().then(function(response) {
          return response.data.data;
        });
      }]
    },
    controller: "Doctor_EditPatientController",
    requireLogin: true,
    requireRoles: ["doctor", "executive_staff", "admin_agency"]
  })
}]);
