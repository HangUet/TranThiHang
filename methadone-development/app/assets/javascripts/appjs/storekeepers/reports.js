angular.module("AccountApp")
  .config(['$stateProvider', '$urlRouterProvider',
    function ($stateProvider, $urlRouterProvider) {
  $stateProvider
  .state('main.medicine_allocations_report', {
    url: "/medicine_allocations_report?page",
    templateUrl: "/templates/storekeeper/medicine_allocations_report.html",
    resolve: {
      patients_allocations: ['API', '$stateParams', function(API, $stateParams) {
        return API.getAllPatientsByAllocation($stateParams.page).then(function(response) {
          return response.data;
        });
      }],
    },
    controller: "Storekeeper_MedicineAllocationReportController",
    requireLogin: true,
    requireRoles: ["storekeeper"]
  })
  .state('main.report_today', {
    url: "/report_today?page",
    templateUrl: "/templates/storekeeper/report_today.html",
    resolve: {
      patients_change_current: ['API', function(API) {
        return API.getChangeDosage().then(function(response) {
          return response.data;
        });
      }],
      // import_export_current: ['API', function(API) {
      //   return API.getImportExportDay().then(function(response) {
      //     return response.data;
      //   });
      // }],
    },
    controller: "Storekeeper_ReportTodayController",
    requireLogin: true,
    requireRoles: ["storekeeper"]
  } )
  .state('main.import_export_medicine', {
    controller: "Storekeeper_ImportExportMedicineController",
    url: "/import_export_medicine",
    templateUrl: "/templates/storekeeper/import_export_medicine.html",
    resolve: {
      importExportMedicine: ['API', '$stateParams', function(API, $stateParams) {
        return API.getImportExportMedicineDay(null).then(function(response) {
          return response.data.data;
        });
      }]
    },
    requireLogin: true,
    requireRoles: ["storekeeper"]
  })
  .state('main.other_report', {
    url: "/other_report",
    templateUrl: "/templates/storekeeper/other_report.html",
    requireLogin: true,
    requireRoles: ["storekeeper"]
  }).state('main.store_report', {
    url: "/store_report",
    templateUrl: "/templates/storekeeper/store_report.html",
    resolve: {
      store_report: ['API', function(API) {
        return API.getStoreReport(null).then(function(response) {
          return response.data;
        });
      }],
    },
    controller: "Storekeeper_StoreReportController",
    requireLogin: true,
    requireRoles: ["storekeeper"]
  })
  .state('main.situation_report', {
    url: "/situation_report",
    templateUrl: "/templates/storekeeper/situation_report.html",
    resolve: {
      patients_report: ['API', function(API) {
        return API.getPatientReport(null).then(function(response) {
          return response.data;
        });
      }],
    },
    controller: "StoreKeeper_SituationReportController",
    requireLogin: true,
    requireRoles: ["storekeeper"]
  })
  .state('main.situation_use', {
    url: "/situation_use",
    templateUrl: "/templates/storekeeper/situation_use.html",
    // resolve: {
    //   medicines: ['Allocations_Medicine', function(Allocations_Medicine) {
    //     return Allocations_Medicine.index().then(function(response) {
    //       return response.data.data;
    //     });
    //   }],
    // },
    controller: "StoreKeeper_SituationUseController",
    requireLogin: true,
    requireRoles: ["storekeeper"]
  })
  .state('main.stock_received_docket', {
    url: "/stock_received_docket",
    templateUrl: "/templates/storekeeper/stock_received_docket.html",
    resolve: {
      importMedicine: ['API', '$stateParams', function(API, $stateParams) {
        return API.getDailyImport().then(function(response) {
          return response.data.data;
        });
      }]
    },
    controller: "Storekeeper_StockReceivedDocketController",
    requireLogin: true,
    requireRoles: ["storekeeper"]
  })
}]);
