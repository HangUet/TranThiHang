angular.module("AccountApp")
  .config(['$stateProvider', '$urlRouterProvider',
    function ($stateProvider, $urlRouterProvider) {
  $stateProvider
  .state('main.received_vouchers', {
    controller: "Storekeeper_Voucher_Received",
    url: "/received_vouchers?keyword",
    templateUrl: "/templates/vouchers/received/index.html",
    resolve: {
      vouchers: ['ReceivedVoucher', '$stateParams', function(ReceivedVoucher, $stateParams) {
        return ReceivedVoucher.index($stateParams.keyword).then(function(response) {
          return response.data.data;
        });
      }],
    },
    requireLogin: true,
    requireRoles: ["storekeeper"]
  })
  .state('main.received_vouchers.medicines', {
    controller: "Storekeeper_Voucher_ReceivedMedicine",
    url: "/:id/medicines",
    templateUrl: "/templates/vouchers/received/medicines/index.html",
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
