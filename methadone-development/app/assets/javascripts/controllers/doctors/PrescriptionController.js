app.controller("Doctor_PrescriptionController", ['$scope', '$uibModal',
  'listPrescription','$state', '$filter', '$stateParams', 'toastr', 'patient',
  'API', 'prescription', '$ngBootbox', 'listDoctor',
  function ($scope, $uibModal, listPrescription, $state, $filter,
    $stateParams,toastr, patient, API, prescription, $ngBootbox , listDoctor) {
  $scope.patient = patient;
  if(patient){
    $scope.list_prescription = listPrescription;
  }
  $scope.current_dosage = "none";
  $scope.listDoctor = listDoctor.data;
  var today = TODAY;
  $scope.begins_date = prescription.date;
  $scope.new_dosage = 20;
  if(prescription.data) {
    var begin_date = $filter('date')(prescription.data.begin_date, "dd/MM/yyyy");
    $scope.current_dosage = prescription.data.dosage + "mg on " + begin_date.toString();
  } else {
    var begin_date = "";
    $scope.current_dosage = "none";
  }
  $scope.check_end_date = function(check, data) {
    if(check) {
      return "-";
    }
    return data;
  }
  $scope.duration = 5;
  $scope.prescriptions_type = ["New Methadone Presciption",
    "Methadone Dose Adjustment", "Methadone Renewal"];
  $scope.calculateAge = function calculateAge(birthday) {
    if(!birthday) {
      return "";
    }
    var birthday = new Date(birthday);
    var today = new Date();
    var age = ((today - birthday) / (31557600000));
    var age = Math.floor( age );
    return age;
  }

  $scope.printElement = function(elem) {
    $(elem).print({noPrintSelector: ".no-print"});
  }

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



  $scope.showPrintModal = function(prescription_id) {
    NProgress.start();
    var modalInstance = $uibModal.open({
      templateUrl: "/templates/prescriptions/print.html",
      size: 'lg',
      backdrop: 'static',
      keyboard: false,
      resolve: {
        listPDF: ['API', '$stateParams', function(API, $stateParams) {
          return API.printPrescription(prescription_id).then(function(response) {
            return response.data;
          });
        }],
      },
      controller: ['$scope', '$uibModalInstance', 'toastr', '$state', 'listPDF', 'API',
        function($scope, $uibModalInstance, toastr, $state, listPDF, API) {
        NProgress.done();
        // $scope.medicines = medicines;
        $scope.listPDF = listPDF;
        $scope.day = listPDF.date.split('/')[0];
        $scope.month = listPDF.date.split('/')[1];
        $scope.year = listPDF.date.split('/')[2];
        $scope.household = getString(listPDF.household_address) + getString(listPDF.household_hamlet)
          + getString(listPDF.household_ward) + getString(listPDF.household_district)
          + endString(listPDF.household_province);
        $scope.print = function() {
          var mywindow = window.open('', 'PRINT');
          mywindow.document.write('<html><head><title>Đơn thuốc</title>');
          mywindow.document.write('<link rel="stylesheet" href="" media="print"/>');
          mywindow.document.write('</head><body>');
          mywindow.document.write(document.getElementById("pdf").innerHTML);
          mywindow.document.write('</body></html>');
          setTimeout(function() {
            mywindow.document.close(); // necessary for IE >= 10
            mywindow.focus(); // necessary for IE >= 10*/
            mywindow.print();
            mywindow.close();
          }, 100)
          return true;
        }
        $scope.close = function () {
          $uibModalInstance.dismiss();
        }
      }]
    });
  }
  $scope.showPrescriptionDescriptionModal = function(description) {
    if(description){
      var modalInstance = $uibModal.open({
        templateUrl: "/templates/prescriptions/description.html",
        backdrop: 'static',
        keyboard: false,
        controller: ['$scope', '$uibModalInstance', function ($scope, $uibModalInstance) {
          $scope.description = description;
          $scope.close = function () {
            $uibModalInstance.dismiss();
          }
        }]
      });
    }
    else {
      toastr.error("Đơn thuốc không có y lệnh");
    }
  }
  $scope.showEditPrescriptionModal = function(prescription_id) {
    NProgress.start();
    var modalInstance = $uibModal.open({
      templateUrl: "/templates/prescriptions/edit.html",
      backdrop: 'static',
      keyboard: false,
      resolve: {
        prescription: ["API", function(API) {
          return API.getOnePrescription(prescription_id).then(function(response) {
            return response.data;
          });
        }],
        medicines: ['Allocations_Medicine', function(Allocations_Medicine) {
          return Allocations_Medicine.index().then(function(response) {
            return response.data;
          });
        }],
      },
      size: 'lg',
      controller: ['$scope', 'prescription', '$uibModalInstance', 'toastr', '$state', 'API', 'medicines',
        function ($scope, prescription, $uibModalInstance, toastr, $state, API, medicines) {
        NProgress.done();
        $scope.medicines = medicines.data;
        $scope.medicines.unshift({name: 'Tên thuốc', composition: 'Thành phần',
          concentration: 'Nồng độ', remaining: 'SL tồn', manufacturer: 'Nhà sản xuất'});
        $scope.edit_prescription = prescription.data;
        $scope.today = moment(TODAY).subtract('days', 1).format("DD/MM/YYYY");

        if($scope.edit_prescription.type_treatment == 3) {
          $scope.edit_prescription.type_treatment = true;
        }

        if($scope.edit_prescription.dosage_morning && $scope.edit_prescription.dosage_morning > 0) {
          $scope.edit_prescription.type = true;
          var tmp = $scope.edit_prescription.dosage - $scope.edit_prescription.dosage_morning;
          $scope.dosage_afternoon = tmp > 0 ? tmp : 0;
        } else {
          $scope.edit_prescription.type = false;
        }

        $scope.changed = function (type) {
          if (type) {
            $scope.edit_prescription.type = true;
            $scope.dosage_afternoon = 0;
          } else {
            $scope.edit_prescription.dosage_morning = 0;
          }
        }

        if($scope.edit_prescription.begin_date && $scope.edit_prescription.end_date_expected) {
          var tmp_begin_date = moment($scope.edit_prescription.begin_date, "DD/MM/YYYY");
          var tmp_end_date = moment($scope.edit_prescription.end_date_expected, "DD/MM/YYYY");
          $scope.edit_prescription.duration = tmp_end_date.diff(tmp_begin_date, 'days') + 1;
        }

        $scope.change_duration = function() {
          if($scope.edit_prescription.dosage && $scope.edit_prescription.dosage_morning) {
            var tmp = parseFloat(($scope.edit_prescription.dosage - $scope.edit_prescription.dosage_morning).toFixed(4));
            $scope.dosage_afternoon = tmp > 0 ? tmp : 0;
          }
        }

        $scope.change_total_or_morning = function() {
          if($scope.edit_prescription.dosage && $scope.edit_prescription.dosage_morning) {
            var tmp = parseFloat(($scope.edit_prescription.dosage - $scope.edit_prescription.dosage_morning).toFixed(4));
            $scope.dosage_afternoon = tmp > 0 ? tmp : 0;
          }
        }

        $scope.change_begin_date_or_duration = function() {
          if($scope.edit_prescription.begin_date && $scope.edit_prescription.duration) {
            var tmp_begin_date = moment($scope.edit_prescription.begin_date, "DD/MM/YYYY");
            tmp_begin_date.add($scope.edit_prescription.duration - 1, 'days');
            $scope.edit_prescription.end_date_expected = tmp_begin_date.format('DD/MM/YYYY');
          }
        }
        $scope.updatePrescription = function () {
          if($scope.edit_prescription.type_treatment == true) {
            $scope.edit_prescription.type_treatment = "reduce_the_dose";
          }

          NProgress.start();
          API.updatePrescription(prescription_id, $scope.edit_prescription).success(function (response) {
            NProgress.done();
            if(response.code == 1) {
              $state.reload($state.current);
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

  $scope.showDeletePrescriptionModal = function(prescrip) {
    $ngBootbox.confirm($filter("translator")("confirm_delete", "prescription")).then(function() {
      NProgress.start();
      API.deletePrescription(prescrip.id).success(function(response) {
        NProgress.done();
        if(response.code == 1) {
          $state.reload($state.current);
          toastr.success(response.message);
        } else {
          toastr.error(response.message);
        }
      });
    });
  }

  $scope.showClosePrescriptionModal = function(prescrip) {
    $ngBootbox.confirm($filter("translator")("confirm_close", "prescription")).then(function() {
      NProgress.start();
      API.closePrescription(prescrip.id).success(function(response) {
        NProgress.done();
        if(response.code == 1) {
          $state.reload($state.current);
          toastr.success(response.message);
        } else {
          toastr.error(response.message);
        }
      });
    });
  }
  $scope.doctor = {};

  $scope.filterPrescription = function() {
      NProgress.start();
      API.filterPrescription($state.params.id, $scope.begin_date_from, $scope.begin_date_to,
        $scope.end_date_from, $scope.end_date_to, $scope.doctor.id).success(function(response) {
        NProgress.done();
        if(response.code == 1) {
          $scope.list_prescription.data = response.data;
        } else {
          toastr.error(response.message);
        }
      });
  }

}]);
