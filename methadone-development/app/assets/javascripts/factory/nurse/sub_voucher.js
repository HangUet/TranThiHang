factory_app
.factory("SubVoucher_SubMedicines", ["$http", "$rootScope", "$window", function ($http, $rootScope, $window) {
  return {
    index: function(sub_voucher_id) {
      return $http({
        method: "GET",
        url: "/api/v1/sub_vouchers/sub_medicines",
        params: {
          sub_voucher_id: sub_voucher_id
        }
      });
    }
  }
}])
