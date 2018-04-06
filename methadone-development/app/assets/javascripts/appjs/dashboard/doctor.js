angular.module("AccountApp")
  .config(['$stateProvider', '$urlRouterProvider',
    function ($stateProvider, $urlRouterProvider) {
  $stateProvider
  .state('main.dashboard_doctor', {
    url: "/doctor/dashboard",
    templateUrl: "/templates/dashboard/doctor.html",
    resolve: {
      dashboard_doctor: ['API', function (API, $stateParams) {
        return API.getDashboardDoctor().then(function (response) {
          return response.data.data;
        });
      }],
    },
    controller: "Doctor_DashboardController",
    requireRoles: ["doctor"],
    requireLogin: true
  })
}]);
