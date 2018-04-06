angular.module("AccountApp")
  .config(['$stateProvider', '$urlRouterProvider',
    function ($stateProvider, $urlRouterProvider) {
  $stateProvider
  .state('main.delivery_vouchers', {
    controller: "Storekeeper_Voucher_Delivery",
    url: "/delivery_vouchers?keyword",
    templateUrl: "/templates/vouchers/delivery/index.html",
    resolve: {
      vouchers: ['DeliveryVoucher', '$stateParams', function(DeliveryVoucher, $stateParams) {
        return DeliveryVoucher.index($stateParams.keyword).then(function(response) {
          return response.data.data;
        });
      }],
    },
    requireLogin: true,
    requireRoles: ["storekeeper"]
  })
  .state('main.delivery_vouchers.medicines', {
    controller: "Storekeeper_Voucher_DeliveryMedicine",
    url: "/:id/medicines",
    templateUrl: "/templates/vouchers/delivery/medicines/index.html",
    resolve: {
      medicineDelivery: ['API', '$stateParams', function(API, $stateParams) {
        return API.medicineDelivery($stateParams.id).then(function(response) {
          return response.data;
        });
      }],
      allMedicine: ['Medicine', '$stateParams', function(Medicine, $stateParams) {
        return Medicine.index("availability").then(function(response) {
          return response.data.data;
        });
      }],
      voucher: ['Voucher', '$stateParams', function (Voucher, $stateParams) {
        return Voucher.show($stateParams.id).then(function(response) {
          return response.data;
        });
      }],
    },
    requireLogin: true,
    requireRoles: ["storekeeper"]
  })
}]);
