angular.module("AccountApp")
  .config(['$stateProvider', '$urlRouterProvider',
    function ($stateProvider, $urlRouterProvider) {
  $stateProvider
  .state('main.sub_medicines', {
    controller: "Nurses_SubMedicines",
    url: "/sub_medicines",
    templateUrl: "/templates/sub_medicines/index.html",
    resolve: {
      sub_medicines: ['SubMedicine', '$stateParams',
        function(SubMedicine, $stateParams) {
        return SubMedicine.index().then(function(response) {
          return response.data.data;
        });
      }]
    },
  })
  // .state('main.nurse_voucher_medicine', {
  //   controller: "Nurses_VoucherMedicineDeliveryController",
  //   url: "/nurses/voucher_medicine_delivery",
  //   templateUrl: "/templates/nurses/voucher_medicine/index.html",
  //   resolve: {
  //     vouchers: ['ReceivedVoucher', '$stateParams', function(API, $stateParams) {
  //       return ReceivedVoucher.index().then(function(response) {
  //         return response.data;
  //       });
  //     }],
  //     voucher_medicines: ['API', '$stateParams', function(API, $stateParams) {
  //       return API.getNurseMedicineVouchers().then(function(response) {
  //         return response.data;
  //       });
  //     }]
  //   },
  //   requireLogin: true,
  //   requireRoles: ["nurse"]
  // })
  .state('main.nurse_medicine_received', {
    controller: "Nurses_VoucherMedicineReceivedController",
    url: "/nurses/medicine_received",
    templateUrl: "/templates/nurses/medicine_received/index.html",
    resolve: {
      vouchers: ['API', '$stateParams', function(API, $stateParams) {
        return API.getNurseVouchersImport().then(function(response) {
          return response.data;
        });
      }],
      voucher_medicines: ['API', '$stateParams', function(API, $stateParams) {
        return API.getNurseMedicineVouchers().then(function(response) {
          return response.data;
        });
      }],
      voucher_medicines_import: ['API', '$stateParams', function(API, $stateParams) {
        return API.getNurseMedicineVouchersImport().then(function(response) {
          return response.data;
        });
      }]
    },
    requireLogin: true,
    requireRoles: ["nurse"]
  })
  .state('main.nurse_card_store', {
    controller: "Nurses_CardStoreController",
    url: "/nurses/card_store",
    templateUrl: "/templates/nurses/report/card_store.html",
    resolve: {
      medicines: ['Allocations_Medicine', function(Allocations_Medicine) {
        return Allocations_Medicine.index().then(function(response) {
          return response.data.data;
        });
      }],
    },
    requireLogin: true,
    requireRoles: ["nurse"]
  })
}]);
