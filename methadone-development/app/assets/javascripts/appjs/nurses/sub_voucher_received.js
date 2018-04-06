angular.module("AccountApp")
  .config(['$stateProvider', '$urlRouterProvider',
    function ($stateProvider, $urlRouterProvider) {
  $stateProvider
  .state('main.received_sub_vouchers', {
    url: "/received_sub_vouchers?keyword",
    templateUrl: "/templates/sub_vouchers/received/index.html",
    resolve: {
      received_sub_vouchers: ['ReceivedSubVoucher', '$stateParams',
        function(ReceivedSubVoucher, $stateParams) {
        return ReceivedSubVoucher.index($stateParams.keyword).then(function(response) {
          return response.data.data;
        });
      }]
    },
    controller: "Nurses_SubVouchers_Received"
  })
  .state('main.received_sub_vouchers.sub_medicines', {
    controller: "Nurses_SubVoucherReceivedSubMedicine_SubMedicines",
    url: "/:id/sub_medicines",
    templateUrl: "/templates/sub_vouchers/received/sub_medicines/index.html",
    resolve: {
      received_sub_medicines: ['ReceivedSubVoucher', '$stateParams',
                              function(ReceivedSubVoucher, $stateParams) {
        return ReceivedSubVoucher.show($stateParams.id).then(function(response) {
          return response.data.data;
        });
      }]
    }
  })
}]);
