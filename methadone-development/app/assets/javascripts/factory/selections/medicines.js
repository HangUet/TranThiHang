factory_app
.factory("Selections_Medicine", ["$http", "$rootScope", "$window", function ($http, $rootScope, $window) {
  return {
    index: function(division, init_date) {
      return $http({
        method: "GET",
        url: "/api/v1/selections/medicines",
        params: {
          division: division,
          init_date: init_date
        }
      });
    }
  }
}])
