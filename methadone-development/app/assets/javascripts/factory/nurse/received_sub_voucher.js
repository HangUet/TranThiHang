factory_app
.factory("ReceivedSubVoucher", ["$http", "$rootScope", "$window", function ($http, $rootScope, $window) {
  return {
    index: function(keyword) {
      return $http({
        method: "GET",
        url: "/api/v1/sub_vouchers/received",
        params: {
          keyword: keyword
        }
      });
    },
    show: function(id) {
      return $http.get("/api/v1/sub_vouchers/received/" + id);
    },
    delete: function (id) {
      return $http.delete("/api/v1/sub_vouchers/received/" + id);
    },
    search: function (keyword) {
      return $http.post("/api/v1/sub_vouchers/search_received_sub_vouchers", {sub_voucher: keyword});
    }
  }
}])
.factory("ReceivedSubMedicines", ["$http", "$rootScope", "$window", function ($http, $rootScope, $window) {
  return {
    index: function(sub_voucher_id) {
      return $http({
        method: "GET",
        url: "/api/v1/received_sub_medicines",
        params: {
          sub_voucher_id: sub_voucher_id
        }
      });
    }
  }
}])
.factory("ReceivedSubVouchers", ["$http", "$rootScope", "$window", function ($http, $rootScope, $window) {
  return {
    index: function () {
      return $http({
        method: "GET",
        url: "/api/v1/received_sub_vouchers"
      })
    },
    create: function (sub_voucher) {
      return $http.post("/api/v1/received_sub_vouchers", {sub_voucher: sub_voucher});
    },
    delete: function (sub_voucher_id) {
      return $http.delete("/api/v1/received_sub_vouchers/" + sub_voucher_id);
    }
  }
}])
.factory("ReceivedSubVoucher_DayMedicine", ["$http", "$rootScope", "$window", function ($http, $rootScope, $window) {
  return {
    index: function(type) {
      return $http({
        method: "GET",
        url: "/api/v1/sub_vouchers/received/day_medicines"
      });
    }
  }
}])
.factory("ReceivedSubVoucher_EndDay", ["$http", "$rootScope", "$window", function ($http, $rootScope, $window) {
  return {
    create: function (sub_voucher) {
      return $http.post("/api/v1/sub_vouchers/received/end_day", {sub_voucher: sub_voucher});
    },
    update: function (id, sub_voucher) {
      return $http.put("/api/v1/sub_vouchers/received/end_day/" + id, {sub_voucher: sub_voucher});
    },
    delete: function (id) {
      return $http.delete("/api/v1/sub_vouchers/received/end_day/" + id);
    }
  }
}])
.factory("Accept_ReceivedSubVoucher", ["$http", "$rootScope", "$window", function ($http, $rootScope, $window) {
  return {
    update: function (id) {
      return $http.put("/api/v1/sub_vouchers/received/accept/" + id);
    }
  }
}])
