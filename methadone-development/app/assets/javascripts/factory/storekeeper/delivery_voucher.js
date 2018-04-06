factory_app
.factory("Medicines", ["$http", "$rootScope", "$window", function ($http, $rootScope, $window) {
  return {
    index: function(type) {
      return $http({
        method: "GET",
        url: "/api/v1/medicines",
        params: {
          type: type
        }
      });
    }
  }
}])
.factory("Provider", ["$http", "$rootScope", "$window", function ($http, $rootScope, $window) {
  return {
    index: function() {
      return $http({
        method: "GET",
        url: "/api/v1/providers"
      });
    }
  }
}])
.factory("Manufacturer", ["$http", "$rootScope", "$window", function ($http, $rootScope, $window) {
  return {
    index: function() {
      return $http({
        method: "GET",
        url: "/api/v1/manufacturers"
      });
    }
  }
}])
.factory("Medicine", ["$http", "$rootScope", "$window", function ($http, $rootScope, $window) {
  return {
    index: function(type) {
      return $http({
        method: "GET",
        url: "/api/v1/medicines",
        params: {
          type: type
        }
      });
    }
  }
}])
.factory("Voucher", ["$http", "$rootScope", "$window", function ($http, $rootScope, $window) {
  return {
    show: function (id, type) {
      return $http({
        method: "GET",
        url: "/api/v1/vouchers/" + id,
        params: {
          type: type
        }
      })
    }
  }
}])
.factory("DeliveryVoucher", ["$http", "$rootScope", "$window", function ($http, $rootScope, $window) {
  return {
    index: function (keyword) {
      return $http({
        method: "GET",
        url: "/api/v1/vouchers/delivery",
        params: {
          keyword: keyword
        }
      })
    },
    update: function (id, voucher) {
      return $http.put("/api/v1/vouchers/delivery/" + id, {voucher: voucher});
    },
    delete: function (id) {
      return $http.delete("/api/v1/vouchers/delivery/" + id);
    },
    search: function (keyword) {
      return $http.post("/api/v1/vouchers/search_delivery_vouchers", {voucher: keyword});
    }
  }
}])
.factory("DeliveryVouchers_Allocation", ["$http", "$rootScope", "$window", function ($http, $rootScope, $window) {
  return {
    create: function (voucher) {
      return $http.post("/api/v1/vouchers/delivery/allocations", {voucher: voucher});
    },
    update: function (id, voucher) {
      return $http.put("/api/v1/medicine_received/allocations" + id, {voucher: voucher});
    },
  }
}])
.factory("DeliveryVouchers_Cancellations",
  ["$http", "$rootScope", "$window", function ($http, $rootScope, $window) {
  return {
    create: function (voucher) {
      return $http.post("/api/v1/vouchers/delivery/cancellations", {voucher: voucher});
    },
    update: function (id, voucher) {
      return $http.put("/api/v1/medicine_received/cancellations" + id, {voucher: voucher});
    },
  }
}])
.factory("Accept_DeliveryVoucher",
  ["$http", "$rootScope", "$window", function ($http, $rootScope, $window) {
  return {
    update: function (id) {
      return $http.put("/api/v1/vouchers/delivery/accept/" + id);
    }
  }
}])
