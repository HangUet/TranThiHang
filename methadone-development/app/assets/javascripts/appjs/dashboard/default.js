angular.module("AccountApp")
  .config(['$stateProvider', '$urlRouterProvider',
    function ($stateProvider, $urlRouterProvider) {
  $stateProvider
  .state('main.dashboard1', {
    url: "/dashboard1",
    templateUrl: "/templates/dashboard/1.html",
    controller: "Dashboard1Controller",
    requireLogin: true
  })
}]);
