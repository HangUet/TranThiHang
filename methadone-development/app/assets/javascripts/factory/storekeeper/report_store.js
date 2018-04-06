factory_app
.factory("StoreReport_Inventory", ["$http", "$rootScope", "$window", function ($http, $rootScope, $window) {
  return {
    index: function(type) {
      return $http({
        method: "GET",
        url: "/api/v1/store_reports/inventories",
        params: {
          type: type
        }
      });
    }
  }
}])
