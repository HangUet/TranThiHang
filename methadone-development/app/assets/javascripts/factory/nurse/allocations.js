factory_app
.factory("Allocations_Medicine",
  ["$http", "$rootScope", "$window", function ($http, $rootScope, $window) {
  return {
    index: function () {
      return $http({
        method: "GET",
        url: "/api/v1/allocations/medicines"
      })
    },
  }
}])
