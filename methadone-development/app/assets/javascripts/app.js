APP_VERSION = 70;
var app = angular.module("AccountApp",
  ['ngBootbox', 'app.filter', 'app.factory', 'app.directive', 'app.language', 'ui.bootstrap',
  'ui.router', 'toastr', 'ngMessages', 'autofocus', 'anguFixedHeaderTable', 'angularMoment',
  'ui.select', 'ngSanitize', 'ng-backstretch'])
.config(['$stateProvider', '$urlRouterProvider', function ($stateProvider, $urlRouterProvider) {
  $stateProvider
  .state("signin", {
    url: "/signin",
    templateUrl: "/templates/users/sessions/new.html",
    controller: "SignInController",
    requireLogin: false
  })
  .state('resetPassword', {
    url: "/passwords/new",
    templateUrl: "/templates/users/passwords/new.html",
    controller: "ResetPasswordController",
    requireLogin: false
  })
  .state('editPassword', {
    url: "/users/password",
    templateUrl: "/templates/users/passwords/edit.html",
    controller: "EditPasswordController",
    requireLogin: false
  })
  .state('confirmation', {
    url: "/user/confirmation",
    templateUrl: "/templates/users/confirmations/new.html",
    controller: "ConfirmationController",
    requireLogin: false
  })
  .state('unlock', {
    url: "/user/unlock",
    templateUrl: "/templates/users/unlocks/new.html",
    controller: "UnlockController",
    requireLogin: false
  })
  .state('main', {
    url: "/main",
    templateUrl: "/templates/main.html",
    controller: "MainController",
    requireLogin: true
  });
  $urlRouterProvider.otherwise('/main');
}]);
