factory_app
.factory("DeliverySubVoucher",
  ["$http", "$rootScope", "$window", function ($http, $rootScope, $window) {
  return {
    index: function (keyword) {
      return $http({
        method: "GET",
        url: "/api/v1/sub_vouchers/delivery",
        params: {
          keyword: keyword
        }
      })
    },
    show: function(id) {
      return $http.get("/api/v1/sub_vouchers/delivery/" + id);
    },
    delete: function (id) {
      return $http.delete("/api/v1/sub_vouchers/delivery/" + id);
    },
    search: function (keyword) {
      return $http.post("/api/v1/sub_vouchers/search_delivery_sub_vouchers", {sub_voucher: keyword});
    }
  }
}])
.factory("DeliverySubVoucher_SubMedicine",
  ["$http", "$rootScope", "$window", function ($http, $rootScope, $window) {
  return {
    index: function(type) {
      return $http({
        method: "GET",
        url: "/api/v1/sub_vouchers/delivery/sub_medicines"
      });
    }
  }
}])
.factory("DeliverySubVoucher_Allocation",
  ["$http", "$rootScope", "$window", function ($http, $rootScope, $window) {
  return {
    create: function (sub_voucher) {
      return $http.post("/api/v1/sub_vouchers/delivery/allocation", {sub_voucher: sub_voucher});
    },
    update: function (id, sub_voucher) {
      return $http.put("/api/v1/sub_vouchers/delivery/allocation/" + id, {sub_voucher: sub_voucher});
    },
    delete: function (id) {
      return $http.delete("/api/v1/sub_vouchers/delivery/allocation/" + id);
    }
  }
}])
.factory("Accept_DeliverySubVoucher",
  ["$http", "$rootScope", "$window", function ($http, $rootScope, $window) {
  return {
    update: function (id) {
      return $http.put("/api/v1/sub_vouchers/delivery/accept/" + id);
    }
  }
}])
.factory("DeliverySubVoucher_GiveBack",
  ["$http", "$rootScope", "$window", function ($http, $rootScope, $window) {
  return {
    create: function (sub_voucher) {
      return $http.post("/api/v1/sub_vouchers/delivery/give_back", {sub_voucher: sub_voucher});
    },
    update: function (id, sub_voucher) {
      return $http.put("/api/v1/sub_vouchers/delivery/give_back/" + id, {sub_voucher: sub_voucher});
    },
    delete: function (id) {
      return $http.delete("/api/v1/sub_vouchers/delivery/give_back/" + id);
    }
  }
}])
.factory("DeliverySubVouchers",
  ["$http", "$rootScope", "$window", function ($http, $rootScope, $window) {
  // cai nay sap bo
  return {
    index: function () {
      return $http({
        method: "GET",
        url: "/api/v1/delivery_sub_vouchers"
      })
    },
    create: function (sub_voucher) {
      return $http.post("/api/v1/delivery_sub_vouchers", {sub_voucher: sub_voucher});
    },
    accept: function(sub_voucher_id) {
      return $http.put("/api/v1/delivery_sub_vouchers/" + sub_voucher_id, {accept: 1});
    },
    show: function(sub_voucher_id) {
      return $http.get("/api/v1/delivery_sub_vouchers/" + sub_voucher_id);
    },
    delete: function(sub_voucher_id) {
      return $http.delete("/api/v1/delivery_sub_vouchers/" + sub_voucher_id);
    }
  }
}])
