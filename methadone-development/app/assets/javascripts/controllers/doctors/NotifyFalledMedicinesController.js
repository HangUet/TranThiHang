app.controller("Doctor_NotifyFalledMedicinesController", ['$scope', '$rootScope',
 '$state', 'toastr', 'API', 'patient', 'prescription', 'medicine_allocation',
  function ($scope, $rootScope, $state, toastr, API, patient, prescription, medicine_allocation) {
  $scope.patient = patient;
  $scope.medicine_allocation = medicine_allocation.data;
  $scope.notify_status = $state.params.notify_status;
  $scope.dosage = $state.params.dosage;
  $scope.current_dosage = $state.params.dosage; 
  $scope.prescription_description = prescription.data.description;
  $scope.prescription_id = $state.params.prescription;
  var getString = function(string) {
    if(string) {
      return string + " - ";
    }
    return "";
  }
  var endString = function(string) {
    if(string) {
      return string;
    }
    return "";
  }
  if(patient) {
  $scope.patient.household = getString(patient.household_address) + getString(patient.household_hamlet)
    + getString(patient.household_ward) + getString(patient.household_district)
    + endString(patient.household_province);

  $scope.patient.resident = getString(patient.resident_address) + getString(patient.resident_hamlet)
    + getString(patient.resident_ward) + getString(patient.resident_district)
    + endString(patient.resident_province);
  }
  $scope.agree_allocation = function(status) {
    API.agreeAllocation($scope.medicine_allocation.id, status, $scope.notify_status).success(function (response) {
      NProgress.done();
      if(response.code == 1) {
        toastr.success(response.message);
        $state.reload($state.current);
      } else {
        toastr.error(response.message);
      }
    });
  }
  
  $scope.agree_prescription = function () {
    $scope.new_prescription = {
      dosage: $scope.dosage,
      begin_date: moment(TODAY).format("DD/MM/YYYY"),
      end_date_expected: moment(TODAY).format("DD/MM/YYYY"),
      prescription_type: null,
      patient_id: $state.params.patient
    };
    $scope.status = "agree_prescription";
    API.agreePrescription($scope.new_prescription, $scope.status, $scope.notify_status,
      $scope.medicine_allocation.id, $scope.prescription_id, $state.params.vomited_time).success(function (response) {
      NProgress.done();
      if(response.code == 1) {
        toastr.success(response.message);
        $state.reload($state.current);
      } else {
        toastr.error(response.message);
      }
    });
  }  
}]);
