angular.module("AccountApp")
  .config(['$stateProvider', '$urlRouterProvider',
    function ($stateProvider, $urlRouterProvider) {
  $stateProvider
  .state('main.nurse_patients', {
    url: "/nurses/patients?page&keyword&gofirst",
    templateUrl: "/templates/nurses/patients/index.html",
    resolve: {
      patients: ['API', '$stateParams', function(API, $stateParams) {
        return API.getPatients($stateParams.page, $stateParams.keyword).then(function(response) {
          return response.data;
        });
      }],
      provinces: ['API', function(API) {
        return API.getProvinces().then(function(response) {
          return response.data.data;
        });
      }],
    },
    controller: "Nurses_PatientController",
    requireLogin: true,
    requireRoles: ["nurse"]
  })
  .state('main.nurse_patients.medicine_allocation', {
    url: "/:id/medicine_allocation",
    templateUrl: "/templates/nurses/patients/medicine_allocation.html",
    resolve: {
      patient: ['API', '$stateParams', function(API, $stateParams) {
        return API.getPatient($stateParams.id).then(function(response) {
          return response.data.data;
        });
      }],
      medicineAllocations: ['API', '$stateParams', function(API, $stateParams) {
        return API.getMedicineAllocation($stateParams.id).then(function(response) {
          return response.data;
        });
      }],
    },
    controller: "Nurses_AllocationController",
    requireSignIn: true,
    requireRoles: ["nurse"]
  })
  .state('main.notify_falled_medicines', {
    url: "/notify_falled_medicine/:id?allocation&patient&notify_status&dosage&prescription&vomited_time",
    resolve: {
      patient:['API', '$stateParams', function(API, $stateParams) {
        return API.getPatient($stateParams.patient).then(function(response) {
          return response.data.data;
        });
      }],
      prescription: ['API', '$stateParams', function(API, $stateParams) {
        return API.getOnePrescription($stateParams.prescription).then(function(response) {
          return response.data;
        });
      }],
      medicine_allocation: ['API', '$stateParams', function(API, $stateParams) {
        return API.getMedicineAllocationById($stateParams.allocation).then(function(response) {
          return response.data;
        });
      }],
    },
    templateUrl: "/templates/notify_falled_medicines/show.html",
    controller: "Doctor_NotifyFalledMedicinesController",
    requireSignIn: true,
    requireRoles: ["doctor", "executive_staff", "admin_agency"]
  })
  .state('main.history_falled', {
    url: "/history_falled?page",
    templateUrl: "/templates/nurses/patients/history_fall.html",
    controller: "FalledReportController",
    resolve: {
      history_falled: ['API', '$stateParams', function(API, $stateParams) {
        return API.getHistoryFalled(null, null, null, null, null, null, $stateParams.page).then(function(response) {
          return response.data;
        });
      }],
      listNurse: ['API', function(API, $rootScope) {
        return API.listNurse().then(function(response) {
          return response.data.data;
        });
      }],
    },
    requireSignIn: true,
    requireRoles: ["nurse"]
  })
}]);
