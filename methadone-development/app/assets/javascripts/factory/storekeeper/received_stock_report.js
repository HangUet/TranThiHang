factory_app
.factory("allInvoiceNumber", ["$http", "$rootScope", "$window", function ($http, $rootScope, $window) {
  return {
    index: function(voucher) {
      return $http({
        method: "GET",
        url: "/api/v1/vouchers/received/received_stock_report",
        params: {
          date_start: voucher.from_date,
          date_end: voucher.to_date,
          provider: voucher.provider
        }
      });
    },
    show: function(voucher) {
      return $http({
        method: "GET",
        url: "/api/v1/vouchers/received/received_stock_report/show",
        params: {
          date_start: voucher.from_date,
          date_end: voucher.to_date,
          provider: voucher.provider,
          invoice_number: voucher.invoice_number
        }
      });
    }
  }
}])
