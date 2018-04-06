angular.module("AccountApp")
  .config(['$stateProvider', '$urlRouterProvider',
    function ($stateProvider, $urlRouterProvider) {
  $stateProvider
  .state('main.card_store', {
    url: "/card_store",
    templateUrl: "/templates/storekeeper/card_store.html",
    resolve: {
      medicines: ['Allocations_Medicine', function(Allocations_Medicine) {
        return Allocations_Medicine.index().then(function(response) {
          return response.data.data;
        });
      }],
    },
    controller: "Storekeeper_CardStoreController",
    requireLogin: true,
    requireRoles: ["storekeeper"]
  })
  .state('main.check_received_stock_report', {
    url: "/check_received_stock_report",
    templateUrl: "/templates/storekeeper/check_received_stock_report/show.html",
    controller: "Storekeeper_CheckReceivedStockReportController",
    resolve: {
      providers: ['Provider', '$stateParams',
        function(Provider, $stateParams) {
        return Provider.index().then(function(response) {
          return response.data.data;
        });
      }]
    },
    requireLogin: true,
    requireRoles: ["storekeeper"]
  })
}]);
