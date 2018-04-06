angular.module("AccountApp")
  .config(['$stateProvider', '$urlRouterProvider',
    function ($stateProvider, $urlRouterProvider) {
  $stateProvider
  .state('main.received_end_day_vouchers', {
    controller: "Storekeeper_Voucher_ReceivedEndDay",
    url: "/received_end_day_vouchers?keyword",
    templateUrl: "/templates/vouchers/received_end_day/index.html",
    resolve: {
      vouchers: ['ReceivedEndDayVoucher', '$stateParams', function(ReceivedEndDayVoucher, $stateParams) {
        return ReceivedEndDayVoucher.index($stateParams.keyword).then(function(response) {
          return response.data.data;
        });
      }],
    },
    requireLogin: true,
    requireRoles: ["storekeeper"]
  })
  .state('main.received_end_day_vouchers.medicines', {
    controller: "Storekeeper_Voucher_ReceivedEndDayMedicine",
    url: "/:id/medicines",
    templateUrl: "/templates/vouchers/received_end_day/medicines/index.html",
    resolve: {
      medicineReceived: ['API', '$stateParams', function(API, $stateParams) {
        return API.medicineReceived($stateParams.id).then(function(response) {
          return response.data;
        });
      }],
      voucher: ["Voucher", '$stateParams', function (Voucher, $stateParams) {
        return Voucher.show($stateParams.id).then(function(response) {
          return response.data;
        });
      }],
    },
    requireLogin: true,
    requireRoles: ["storekeeper"]
  })
}]);
