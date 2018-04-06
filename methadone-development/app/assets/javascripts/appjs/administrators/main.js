angular.module("AccountApp")
  .config(['$stateProvider', '$urlRouterProvider',
    function ($stateProvider, $urlRouterProvider) {
  $stateProvider
  .state('main.administrators', {
    url: "/admin/administrators?page&&keyword",
    templateUrl: "/templates/admin/users/index.html",
    resolve: {
      administrators: ['API', '$stateParams', function(API, $stateParams) {
        return API.getAdministrators($stateParams.page, $stateParams.keyword).then(function(response) {
          return response.data;
        });
      }]
    },
    controller: "Admin_AdminAgenciesController",
    requireLogin: true,
    requireRoles: ["admin"]
  })
  .state('main.summary_report', {
    url: "/admin/summary_report?page&&keyword",
    templateUrl: "/templates/admin/reports/summary_report.html",
    controller: "AdminReportSummaryController",
    resolve: {
      provinces: ['API', function(API) {
        return API.getProvinces().then(function(response) {
          return response.data.data;
        });
      }]
    },
    requireLogin: true,
    requireRoles: ["admin"]
  })
  .state('main.issuing_agency', {
    url: "/admin/administrators/issuing_agency?page&&keyword",
    templateUrl: "/templates/admin/issuing_agencies/index.html",
    resolve: {
      issuing_agencies: ['API', '$stateParams', function(API, $stateParams) {
        return API.getIssuingAgencies($stateParams.page, $stateParams.keyword).then(function(response) {
          return response.data;
        });
      }]
    },
    controller: "Admin_IssuingAgenciesController",
    requireLogin: true,
    requireRoles: ["admin"]
  })
  .state('main.employments', {
    url: "/admin/administrators/employments?page&&keyword&&keystatus",
    templateUrl: "/templates/admin/employments/index.html",
    resolve: {
      employments: ['API', '$stateParams', function(API, $stateParams) {
        return API.getAllEmployments($stateParams.page, $stateParams.keyword, $stateParams.keystatus).then(function(response) {
          return response.data;
        });
      }]
    },
    controller: "Admin_EmploymentsController",
    requireLogin: true,
    requireRoles: ["admin"]
  })
  .state('main.sources', {
    url: "/admin/administrators/sources?page&&keyword&&keystatus",
    templateUrl: "/templates/admin/sources/index.html",
    resolve: {
      sources: ['API', '$stateParams', function(API, $stateParams) {
        return API.getAllSources($stateParams.page, $stateParams.keyword, $stateParams.keystatus).then(function(response) {
          return response.data;
        });
      }]
    },
    controller: "Admin_SourcesController",
    requireLogin: true,
    requireRoles: ["admin"]
  })
  .state('main.educations', {
    url: "/admin/administrators/educations?page&&keyword&&keystatus",
    templateUrl: "/templates/admin/educations/index.html",
    resolve: {
      educations: ['API', '$stateParams', function(API, $stateParams) {
        return API.getAllEducations($stateParams.page, $stateParams.keyword, $stateParams.keystatus).then(function(response) {
          return response.data;
        });
      }]
    },
    controller: "Admin_EducationsController",
    requireLogin: true,
    requireRoles: ["admin"]
  })
  .state('main.maritals', {
    url: "/admin/administrators/maritals?page&&keyword&&keystatus",
    templateUrl: "/templates/admin/maritals/index.html",
    resolve: {
      maritals: ['API', '$stateParams', function(API, $stateParams) {
        return API.getAllMaritals($stateParams.page, $stateParams.keyword, $stateParams.keystatus).then(function(response) {
          return response.data;
        });
      }]
    },
    controller: "Admin_MaritalsController",
    requireLogin: true,
    requireRoles: ["admin"]
  })
  .state('main.financials', {
    url: "/admin/administrators/financials?page&&keyword&&keystatus",
    templateUrl: "/templates/admin/financials/index.html",
    resolve: {
      financials: ['API', '$stateParams', function(API, $stateParams) {
        return API.getAllFinancials($stateParams.page, $stateParams.keyword, $stateParams.keystatus).then(function(response) {
          return response.data;
        });
      }]
    },
    controller: "Admin_FinancialsController",
    requireLogin: true,
    requireRoles: ["admin"]
  })
  .state('main.medicine_list', {
    url: "/admin/administrators/medicine_list?page&&keyword&&keystatus",
    templateUrl: "/templates/admin/medicine_list/index.html",
    resolve: {
      medicine_list: ['API', '$stateParams', function(API, $stateParams) {
        return API.getListMedicines($stateParams.page || 1, $stateParams.keyword, $stateParams.keystatus).then(function(response) {
          return response.data;
        });
      }],
      manufacturer_list: ['API', '$stateParams', function(API, $stateParams) {
        return API.getAllManufacturers($stateParams.page || 1, $stateParams.keyword).then(function(response) {
          return response.data;
        });
      }],
      provider_list: ['API', '$stateParams', function(API, $stateParams) {
        return API.getAllProviders($stateParams.page || 1, $stateParams.keyword).then(function(response) {
          return response.data;
        });
      }],
    },
    controller: "Admin_MedicineListController",
    requireLogin: true,
    requireRoles: ["admin"]
  })
  .state('main.providers', {
    url: "/admin/administrators/providers?page&&keyword&&keystatus",
    templateUrl: "/templates/admin/providers/index.html",
    resolve: {
      providers: ['API', '$stateParams', function(API, $stateParams) {
        return API.getProviders($stateParams.page, $stateParams.keyword, $stateParams.keystatus).then(function(response) {
          return response.data;
        });
      }]
    },
    controller: "Admin_ProvidersController",
    requireLogin: true,
    requireRoles: ["admin"]
  })
  .state('main.manufacturers', {
    url: "/admin/administrators/manufacturers?page&&keyword&&keystatus",
    templateUrl: "/templates/admin/manufacturers/index.html",
    resolve: {
      manufacturers: ['API', '$stateParams', function(API, $stateParams) {
        return API.getManufacturers($stateParams.page, $stateParams.keyword, $stateParams.keystatus).then(function(response) {
          return response.data;
        });
      }]
    },
    controller: "Admin_ManufacturersController",
    requireLogin: true,
    requireRoles: ["admin"]
  })
  .state('main.stop_reasons', {
    url: "/admin/administrators/stop_reasons?page&&keyword&&keystatus",
    templateUrl: "/templates/admin/stop_reasons/index.html",
    resolve: {
      reasons: ['API', '$stateParams', function(API, $stateParams) {
        return API.getReasons($stateParams.page, $stateParams.keyword, $stateParams.keystatus).then(function(response) {
          return response.data;
        });
      }]
    },
    controller: "Admin_StopReasonsController",
    requireLogin: true,
    requireRoles: ["admin"]
  })
}]);
