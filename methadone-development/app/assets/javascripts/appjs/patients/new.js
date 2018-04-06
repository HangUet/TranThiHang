angular.module("AccountApp")
  .config(['$stateProvider', '$urlRouterProvider',
    function ($stateProvider, $urlRouterProvider) {
  $stateProvider
  .state('main.patients.new', {
    url: "/new",
    templateUrl: "/templates/patients/new.html",
    resolve: {
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
    controller: "Doctor_NewPatientController",
    requireLogin: true,
    requireRoles: ["doctor", "executive_staff", "admin_agency"]
  })
}]);
