angular.module("AccountApp")
  .config(['$stateProvider', '$urlRouterProvider',
    function ($stateProvider, $urlRouterProvider) {
  $stateProvider
  .state('main.patients.action', {
    url: "/:id",
    resolve: {
      patient: ['API', '$stateParams', function(API, $stateParams) {
        return API.getPatient($stateParams.id).then(function(response) {
          return response.data.data;
        });
      }],
    },
    templateUrl: "/templates/patients/action.html",
    controller: "Doctor_ShowPatientController",
    requireSignIn: true,
    requireRoles: ["doctor", "executive_staff", "admin_agency"]
  })
  .state('main.patients.action.detail', {
    url: "/detail",
    templateUrl: "/templates/patients/detail.html",
    controller: "Doctor_ShowPatientController",
    requireSignIn: true,
    requireRoles: ["doctor", "executive_staff", "admin_agency"]
  })
  .state('main.patients.action.detail.executive_info', {
    url: "/executive_info",
    templateUrl: "/templates/patients/executive_info.html",
    resolve: {
      patient: ['API', '$stateParams', function(API, $stateParams) {
        return API.getPatient($stateParams.id).then(function(response) {
          return response.data.data;
        });
      }],
    },
    controller: "Doctor_InforPatientController",
    requireLogin: true,
    requireRoles: ["doctor", "executive_staff", "admin_agency", "admin"]
  })
  .state('main.patients.action.detail.info', {
    url: "/info",
    templateUrl: "/templates/patients/info.html",
    resolve: {
      patient: ['API', '$stateParams', function(API, $stateParams) {
        return API.getPatient($stateParams.id).then(function(response) {
          return response.data.data;
        });
      }],
    },
    controller: "Doctor_InforPatientController",
    requireLogin: true,
    requireRoles: ["doctor", "executive_staff", "admin_agency", "admin"]
  })
  .state('main.patients.action.detail.change_agency_info', {
    url: "/change_agency_info",
    templateUrl: "/templates/patients/change_agency_info.html",
    resolve: {
      history_change_agency: ['API', '$stateParams', function(API, $stateParams) {
        return API.getAllPatientAgencyHistory($stateParams.id).then(function(response) {
          return response.data.data;
        });
      }],
      medicineAllocation: ['API', '$stateParams', function(API, $stateParams) {
        return API.getMedicineAllocation($stateParams.id).then(function(response) {
          return response.data.data;
        });
      }]
    },
    controller: "Doctor_ChangePatientController",
    requireLogin: true,
    requireRoles: ["doctor", "executive_staff", "admin_agency", "admin"]
  })
  .state('main.patients.action.detail.prescription', {
    url: "/prescription",
    templateUrl: "/templates/prescriptions/index.html",
    resolve: {
      patient: ['API', '$stateParams', function(API, $stateParams) {
        return API.getPatient($stateParams.id).then(function(response) {
          return response.data.data;
        });
      }],

      prescription: ['API', '$stateParams', function(API, $stateParams) {
        return API.getPrescription($stateParams.id).then(function(response) {
          return response.data;
        });
      }],

      listPrescription: ['API', '$stateParams', function(API, $stateParams) {
        return API.getListPrescription($stateParams.id).then(function(response) {
          return response.data;
        });
      }],
      listDoctor: ['API', '$rootScope', function(API) {
        return API.listPrescriptionCreator().then(function(response) {
          return response.data;
        });
      }],
    },
    controller: "Doctor_PrescriptionController",
    requireLogin: true,
    requireRoles: ["doctor", "executive_staff", "admin_agency", "admin"]
  })
}]);
