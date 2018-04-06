factory_app
.factory("ReceivedEndDayVoucher", ["$http", "$rootScope", "$window", function ($http, $rootScope, $window) {
  return {
    index: function () {
      return $http.get("/api/v1/vouchers/received_end_day");
    }
  }
}])
.factory("ReceivedEndDayVoucher_EndDay", ["$http", "$rootScope", "$window", function ($http, $rootScope, $window) {
  return {
    create: function (voucher) {
      return $http.post("/api/v1/vouchers/received/end_day", {voucher: voucher});
    },
    update: function (id, voucher) {
      return $http.put("/api/v1/vouchers/received_end_day/" + id, {voucher: voucher});
    }
  }
}])
