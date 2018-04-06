angular.module("AccountApp")
  .config(['$stateProvider', '$urlRouterProvider',
    function ($stateProvider, $urlRouterProvider) {
  $stateProvider
  .state('main.notify_prescription', {
    url: "/notify_prescription/:id?patient_id&notify_status",
    templateUrl: "/templates/notify_prescription/show.html",
    resolve: {
      patient:['API', '$stateParams', function(API, $stateParams) {
        return API.getPatient($stateParams.patient_id).then(function(response) {
          return response.data.data;
        });
      }],
    },
    controller: "NotifyPrescriptionController",
    requireLogin: true,
    requireRoles: ["doctor"]
  })
  .state('main.medicines', {
    url: "/medicine?page&&keyword&&type",
    templateUrl: "/templates/medicines/index.html",
    resolve: {
      medicines: ['API', '$stateParams', function(API, $stateParams) {
        return API.getMedicines($stateParams.type, $stateParams.page, $stateParams.keyword).then(function(response) {
          return response.data;
        });
      }]
    },
    controller: "Storekeeper_MedicineController",
    requireLogin: true,
    requireRoles: ["storekeeper"]
  })
  .state('main.users', {
    url: "/admin_agency/users?page&&keyword",
    templateUrl: "/templates/admin_agency/users/index.html",
    resolve: {
      users: ['API', '$stateParams', function(API, $stateParams) {
        return API.getUsers($stateParams.page, $stateParams.keyword).then(function(response) {
          return response.data;
        });
      }]
    },
    controller: "AdminAgencies_UsersController",
    requireLogin: true,
    requireRoles: ["admin_agency"]
  })
  .state('main.same_patient', {
    url: "/same_patient/:id",
    templateUrl: "/templates/same_patient/show.html",
    resolve: {
      patient_agency_history: ['API', '$stateParams', function(API, $stateParams) {
        return API.getPatientAgencyHistory($stateParams.id).then(function(response) {
          return response.data.data;
        });
      }]
    },
    controller: "SamePatientController",
    requireLogin: true,
    requireRoles: ["admin_agency", "doctor", "executive_staff"]
  })
 .state('main.renunciated', {
    url: "/renunciated/:id?patient_id&dosage&prescription",
    resolve: {
      patient:['API', '$stateParams', function(API, $stateParams) {
        return API.getPatient($stateParams.patient_id).then(function(response) {
          return response.data.data;
        });
      }],
      prescription: ['API', '$stateParams', function(API, $stateParams) {
        return API.getOnePrescription($stateParams.prescription).then(function(response) {
          return response.data;
        });
      }],
      reasons: ['API', function(API) {
        return API.getAllReasons().then(function(response) {
          return response.data;
        });
      }],
    },
    templateUrl: "/templates/renunciated/show.html",
    controller: "NotifyRenunciatedController",
    requireSignIn: true,
    requireRoles: ["doctor", "executive_staff", "admin_agency"]
  })
 .state('main.redundancy_report', {
    url: "/redundancy_report?page",
    templateUrl: "/templates/nurses/patients/redundancy_report.html",
    controller: "RedundancyReportController",
    requireSignIn: true,
    requireRoles: ["nurse"]
  })
  .state('main.lost_report', {
    url: "/lost_report?page",
    templateUrl: "/templates/nurses/patients/lost_report.html",
    controller: "LostReportController",
    requireSignIn: true,
    requireRoles: ["nurse"]
  })
  .state('main.redundancy_lost_report', {
    url: "/redundancy_lost_report?page",
    templateUrl: "/templates/nurses/patients/redundancy_lost_report.html",
    controller: "RedundancyLostReportController",
    requireSignIn: true,
    requireRoles: ["nurse"]
  })
  .state('main.give_up_report', {
    url: "/give_up_report?page",
    templateUrl: "/templates/nurses/patients/give_up_report.html",
    controller: "GiveUpReportController",
    resolve: {
      all_users: ['API', function(API) {
        return API.getAllUsers().then(function(response) {
          return response.data.data;
        });
      }],
      history_vommited: ['API', function(API) {
        return API.getListPatientRevoke(null, null, null, null, 1).then(function(response) {
          return response.data;
        });
      }],
    },
    requireSignIn: true,
    requireRoles: ["nurse"]
  })
  .state('common_test', {
    url: "/common_test",
    templateUrl: "/templates/common_test/index.html",
    resolve: {
      issuing_agencies: ['API', '$stateParams', function(API, $stateParams) {
        return API.getIssuingAgencies($stateParams.page, $stateParams.keyword).then(function(response) {
          return response.data;
        });
      }]
    },
    controller: "CommonTest",
    requireLogin: false
  });
}]);
