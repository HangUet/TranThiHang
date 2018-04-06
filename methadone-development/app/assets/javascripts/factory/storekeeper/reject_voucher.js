factory_app
.factory("RejectVoucher_GiveBack", ["$http", "$rootScope", "$window", function ($http, $rootScope, $window) {
  return {
    update: function (id) {
      return $http.put("/api/v1/vouchers/received/reject/" + id);
    },
  }
}])
