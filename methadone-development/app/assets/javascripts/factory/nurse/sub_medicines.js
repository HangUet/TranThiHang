factory_app
.factory("SubMedicine", ["$http", "$rootScope", "$window", function ($http, $rootScope, $window) {
  return {
    index: function(page, keyword) {
      return $http({
        method: "GET",
        url: "/api/v1/sub_medicines",
        params: {
          page: page || 1,
          keyword: keyword
        }
      });
    }
  }
}])
.factory("DeliverySubMedicine", ["$http", "$rootScope", "$window", function ($http, $rootScope, $window) {
  return {
    index: function(page, keyword) {
      return $http({
        method: "GET",
        url: "/api/v1/delivery_sub_medicines",
        params: {
          page: page || 1,
          keyword: keyword
        }
      });
    }
  }
}])
