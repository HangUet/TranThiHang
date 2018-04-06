angular.module('app.language', [])
.filter("translator", ['$rootScope', '$window', function ($rootScope, $window) {
  function filter(string, child) {
    return $window.LANGUAGE[$rootScope.language][child][string] || string;
  }
  filter.$stateful = true;
  return filter;
}]);
