angular.module("AccountApp")
  .config(['$stateProvider', '$urlRouterProvider',
    function ($stateProvider, $urlRouterProvider) {
  $stateProvider
  .state('main.delivery_sub_vouchers', {
    controller: "Nurses_SubVoucher_Delivery",
    url: "/delivery_sub_vouchers?keyword",
    templateUrl: "/templates/sub_vouchers/delivery/index.html",
    resolve: {
      delivery_sub_vouchers: ['DeliverySubVoucher', '$stateParams',
        function(DeliverySubVoucher, $stateParams) {
        return DeliverySubVoucher.index($stateParams.keyword).then(function(response) {
          return response.data.data;
        });
      }]
    },
  })
  .state('main.delivery_sub_vouchers.sub_medicines', {
    controller: "Nurses_SubVoucher_DeliverySubMedicines",
    url: "/:id/sub_medicines",
    templateUrl: "/templates/sub_vouchers/delivery/sub_medicines/index.html",
    resolve: {
      delivery_sub_medicines: ['DeliverySubVoucher', '$stateParams',
        function(DeliverySubVoucher, $stateParams) {
        return DeliverySubVoucher.show($stateParams.id).then(function(response) {
          return response.data.data;
        });
      }]
    }
  })
}]);
