app.controller("Doctor_ShowPatientController", ['$scope', '$rootScope', '$state', 'patient',
  'toastr', '$filter', '$uibModal', '$ngBootbox', 'API',
  function ($scope, $rootScope, $state, patient, toastr, $filter, $uibModal, $ngBootbox, API) {
  if($state.current.name == "main.patient") {
    $state.go("main.patient.action.detail.executive_info");
  }
  $scope.patient = patient;
  $scope.showCancelChangeModal = function(patient) {
    $ngBootbox.confirm($filter("translator")("cancel_agency_confirm", "main")).then(function() {
      NProgress.start();
      API.deletePatientAgencyHistory(patient.id).success(function(response) {
        NProgress.done();
        if(response.code == 1) {
          $state.reload();
          toastr.success(response.message);
        } else {
          toastr.error(response.message);
        }
      });
    });
  }
  $scope.showChangeAgencyModal = function(patient) {
    NProgress.start();
    var modalInstance = $uibModal.open({
      templateUrl: "/templates/patient_agency_histories/create.html",
      size: 'lg',
      backdrop: 'static',
      keyboard: false,
      resolve: {
        provinces: ['API', function(API) {
          return API.getProvinces().then(function(response) {
            return response.data.data;
          });
        }]
      },
      controller: ['$scope', '$filter', 'provinces', '$uibModalInstance', 'toastr', '$state', 'API',
        function($scope, $filter, provinces, $uibModalInstance, toastr, $state, API) {
        NProgress.done();
        $scope.patientAgencyHistory = {
          patient_id: patient.id
        }
        $scope.temporary = false;
        $scope.change_temporary = function(temporary) {
          if(temporary){
            $scope.temporary = true;
          }
        }
        $scope.today = moment(TODAY).format("DD/MM/YYYY");
        $scope.provinces = provinces;
        $scope.reloadAgencies = function(province_id) {
          API.getIssuingAgenciesByProvince(province_id).success(function(response) {
            $scope.agencies = response.data;
          });
        }
        $scope.createPatientAgencyHistory = function() {
          API.createPatientAgencyHistory($scope.patientAgencyHistory).success(function (response) {
            NProgress.done();
            if(response.code == 1) {
              toastr.success(response.message);
              $state.reload();
              $uibModalInstance.dismiss();
            } else {
              toastr.error(response.message);
            }
          });
        }
        $scope.close = function () {
          $uibModalInstance.dismiss();
        }
      }]
    });
  }

  $scope.showStopTreatmentModal = function() {
    NProgress.start();
    var modalInstance = $uibModal.open({
      templateUrl: "/templates/patients/stop_treatment.html",
      size: 'md',
      backdrop: 'static',
      keyboard: false,
      resolve: {
        reasons: ['API', function(API) {
          return API.getAllReasons().then(function(response) {
            return response.data;
          });
        }]
      },
      controller: ['$scope', '$filter', '$uibModalInstance', 'toastr', '$state', 'API', 'reasons',
        function($scope, $filter, $uibModalInstance, toastr, $state, API, reasons) {
        NProgress.done();
        $scope.reasons = reasons.data;
        $scope.stop_treatment = {
          patient_id: $state.params.id,
        };
        $scope.sendStopTreatment = function() {
          NProgress.start();
          API.sendStopTreatment($scope.stop_treatment).success(function (response) {
            NProgress.done();
            if(response.code == 1) {
              $state.reload();
              $uibModalInstance.dismiss();
              toastr.success(response.message);
            } else {
              toastr.error(response.message);
            }
          });
        }
        $scope.close = function () {
          $uibModalInstance.dismiss();
        }
      }]
    });
  }

  $scope.continueTreatment = function () {
    NProgress.start();
    patient_id = $state.params.id;
    API.ContinueTreatment(patient_id).success(function (response) {
      NProgress.done();
      if(response.code == 1) {
        $state.reload();
        toastr.success(response.message);
      } else {
        toastr.error(response.message);
      }
    });
  }

  $scope.showCreatePrescriptionModal = function() {
    NProgress.start();
    API.checkVommited($state.params.id).success(function (response) {
      NProgress.done();
      if(response.code == 1) {
        var modalInstance = $uibModal.open({
          templateUrl: "/templates/prescriptions/create.html",
          size: 'lg',
          backdrop: 'static',
          keyboard: false,
          resolve: {
            lastPrescription: ['API', '$stateParams', function(API, $stateParams) {
              return API.getLastPrescriptionOfPatient($stateParams.id).then(function(response) {
                return response.data.data;
              });
            }],
            medicines: ['Allocations_Medicine', function(Allocations_Medicine) {
              return Allocations_Medicine.index().then(function(response) {
                return response.data;
              });
            }],
          },
          controller: ['$scope', '$filter', '$uibModalInstance', 'toastr', '$state', 'lastPrescription', 'API', 'medicines',
            function($scope, $filter, $uibModalInstance, toastr, $state, lastPrescription, API, medicines) {
            NProgress.done();
            $scope.medicines = medicines.data;
            $scope.medicines.unshift({name: 'Tên thuốc', composition: 'Thành phần',
              concentration: 'Nồng độ', remaining: 'SL tồn', manufacturer: 'Nhà sản xuất'});
            var admission_date_temp = patient.admission_date.toString().split('/');
            $scope.mindate = new Date(admission_date_temp[2],admission_date_temp[1]-1,admission_date_temp[0]);
            $scope.lastPrescription = lastPrescription;
            $scope.today = moment(TODAY).subtract('days', 1).format("DD/MM/YYYY");
            $scope.new_prescription = {
              prescription_type: 'N',
              type: false,
              begin_date: moment(TODAY).format("DD/MM/YYYY"),
              patient_id: $state.params.id,
            };

            $scope.changed = function (type) {
              if(type) {
                $scope.new_prescription.dosage_morning = 0;
                $scope.new_prescription.type = true;
                $scope.dosage_afternoon = 0;
              }
            }

            $scope.change_total_or_morning = function() {
              if($scope.new_prescription.dosage && $scope.new_prescription.dosage_morning) {
                var tmp = $scope.new_prescription.dosage - $scope.new_prescription.dosage_morning;
                $scope.dosage_afternoon = tmp > 0 ? tmp : 0;
              }
            }

            $scope.change_begin_date_or_duration = function() {
              if($scope.new_prescription.begin_date && $scope.new_prescription.duration) {
                var tmp_begin_date = moment($scope.new_prescription.begin_date, "DD/MM/YYYY");
                tmp_begin_date.add($scope.new_prescription.duration - 1, 'days');
                $scope.new_prescription.end_date_expected = tmp_begin_date.format('DD/MM/YYYY');
              }
            }

            $scope.prescriptions_type = ["New Methadone Presciption", "Methadone Dose Adjustment", "Methadone Renewal"];
            $scope.createPrescription = function() {
              if($scope.new_prescription.type_treatment) {
                $scope.new_prescription.type_treatment = 'reduce_the_dose';
              }
              NProgress.start();
              // $("#submit").prop('disabled', true);
              API.createPrescription($scope.new_prescription).success(function (response) {
                NProgress.done();
                if(response.code == 1) {
                  $state.reload($state.current);
                  $uibModalInstance.dismiss();
                  toastr.success(response.message);
                }
                else if(response.code == 3) {
                  $ngBootbox.confirm(response.message).then(function() {
                    $scope.new_prescription.check_today_allocation = 1
                    API.createPrescription($scope.new_prescription).success(function (response) {
                      if(response.code == 1) {
                        $state.reload($state.current);
                        $uibModalInstance.dismiss();
                        toastr.success(response.message);
                      } else {
                        toastr.error(response.message);
                      }
                    })
                  })
                }
                else {
                  toastr.error(response.message);
                }
              });
            }
            $scope.close = function () {
              $uibModalInstance.dismiss();
            }
          }]
        });
      } else {
        toastr.error(response.message);
      }
    });

  }
}]);
