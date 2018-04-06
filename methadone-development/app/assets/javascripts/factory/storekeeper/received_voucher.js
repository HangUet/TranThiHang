factory_app
.factory("MedicineList", ["$http", "$rootScope", "$window", function ($http, $rootScope, $window) {
  return {
    index: function () {
      return $http.get("/api/v1/list_medicines");
    }
  }
}])
.factory("ReceivedVoucher", ["$http", "$rootScope", "$window", function ($http, $rootScope, $window) {
  return {
    index: function (keyword) {
      return $http({
        method: "GET",
        url: "/api/v1/vouchers/received",
        params: {
          keyword: keyword
        }
      })
    },
    update: function (id, voucher) {
      return $http.put("/api/v1/vouchers/received/" + id, {voucher: voucher});
    },
    delete: function (id) {
      return $http.delete("/api/v1/vouchers/received/" + id);
    },
    search: function(keyword) {
      return $http.post("/api/v1/vouchers/search_received_vouchers", {voucher: keyword});
    }
  }
}])
.factory("ReceivedVoucher_GiveBack", ["$http", "$rootScope", "$window", function ($http, $rootScope, $window) {
  return {
    create: function (voucher) {
      return $http.post("/api/v1/vouchers/received/give_backs", {voucher: voucher});
    },
    update: function (id, voucher) {
      return $http.put("/api/v1/medicine_received/give_backs" + id, {voucher: voucher});
    },
  }
}])
.factory("ReceivedVoucher_ImportNew", ["$http", "$rootScope", "$window", function ($http, $rootScope, $window) {
  return {
    create: function (voucher) {
      return $http.post("/api/v1/vouchers/received/import_news", {voucher: voucher});
    },
    update: function (id, voucher) {
      return $http.put("/api/v1/medicine_received/import_news" + id, {voucher: voucher});
    },
  }
}])
.factory("Accept_ReceivedVoucher",
  ["$http", "$rootScope", "$window", function ($http, $rootScope, $window) {
  return {
    update: function (id) {
      return $http.put("/api/v1/vouchers/received/accept/" + id);
    }
  }
}])
