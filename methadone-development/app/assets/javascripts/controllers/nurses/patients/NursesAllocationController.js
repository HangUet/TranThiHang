app.controller("Nurses_AllocationController", ['$scope', '$rootScope', '$state', 'toastr', 'patient', 'medicineAllocations', 'API', '$filter', '$uibModal', '$ngBootbox',
  function ($scope, $rootScope, $state, toastr, patient, medicineAllocations, API, $filter, $uibModal, $ngBootbox) {

  $scope.patient = patient;
  $scope.medicineAllocations = medicineAllocations.data;
  $scope.patient_warnings = medicineAllocations.patient_warning;
  $scope.allow_allocation = medicineAllocations.allow_allocation;
  $scope.waiting_doctor = medicineAllocations.waiting_doctor;
  $scope.description = medicineAllocations.description;
  $scope.medicine = medicineAllocations.medicine;

  // thuoc cap phat danh cho benh nhan
  $scope.day_medicines = medicineAllocations.day_medicines;
  console.log($scope.day_medicines);
  if ($scope.day_medicines != null && $scope.day_medicines.length > 0) {
    $scope.drinked_day_medicine_id = $scope.day_medicines[0].id;
    $scope.day_medicines.unshift({name: "Tên thuốc", production_batch: "Lô sản xuất",
      expiration_date: "Ngày hết hạn", manufacturer: 'Nhà sản xuất' })
  }
  $scope.dosage_morning = medicineAllocations.dosage_morning;
  $scope.dosage = medicineAllocations.dosage;
  $scope.dosage_afternoon = $scope.dosage - $scope.dosage_morning;
  $scope.type_allocation = medicineAllocations.data.length;
  if ($scope.type_allocation == 2) {
    if (medicineAllocations.data[0].status == 'taked' || medicineAllocations.data[1].status == 'taked') {
      $scope.taked = true;
    } else {
      $scope.taked = false;
    }
  } else if ($scope.type_allocation == 1) {
    if (medicineAllocations.data[0].status == 'taked') {
      $scope.taked = true;
    } else {
      $scope.taked = false;
    }
  } else {
    $scope.taked = false;
    if (medicineAllocations.patient_warning) {
      if (medicineAllocations.patient_warning.level == 'empty_prescription') {
        $scope.empty_prescription = true;
      } else if (medicineAllocations.patient_warning.level == 'obligatory') {
        $scope.obligatory = true;
      } else if (medicineAllocations.patient_warning.level == 'optional') {
        $scope.optional = true;
      }
    }
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
  if(patient) {
    $scope.patient.household = getString(patient.household_address) + getString(patient.household_hamlet)
      + getString(patient.household_ward) + getString(patient.household_district)
      + endString(patient.household_province);
  }
  $scope.create_medicineAllocation = function(medicine_allocation_id, index) {
    NProgress.start();
    var allocation = $scope.medicineAllocations[index];
    switch (allocation.status) {
      case "waiting":
        allocation.status = "allocated";
        break;
      case "allocated":
        allocation.status = "taked";
        break;
      default:
    }
    // var check_allocation = $scope.day_medicines[1].remaining_number - $scope.day_medicines[1].booking - allocation.dosage/$scope.day_medicines[1].concentration;
    // if(check_allocation <= 0 && allocation.status == "allocated") {
    //   NProgress.done();
    //   $ngBootbox.confirm("Đã hết thuốc xuất ra đầu ngày, bạn có chắc chắn cấp phát thuốc ?").then(function() {
    //     allocateMedicine(allocation, medicine_allocation_id, index);
    //   }, function() {
    //     allocation.status = "waiting";
    //   });
    // } else {
    //   allocateMedicine(allocation, medicine_allocation_id, index);
    // }
    allocateMedicine(allocation, medicine_allocation_id, index);
  }
  var allocateMedicine = function(allocation, medicine_allocation_id, index) {
    API.createMedicineAllocation($state.params.id, allocation, medicine_allocation_id, $scope.drinked_day_medicine_id).success(function(response) {
      NProgress.done();
      if(response.code == 1) {
        if ($scope.medicineAllocations[index].status == 'taked') {
          $state.reload();
        } else {
          $state.reload($state.current);
        }
        toastr.success(response.message);
      } else {
        toastr.error(response.message);
      }
    });
  }
  $scope.back = function(index) {
    NProgress.start();
    var allocation = $scope.medicineAllocations[index];
    switch (allocation.status) {
      case "allocated":
        allocation.status = "waiting";
        break;
      case "taked":
        allocation.status = "allocated";
        break;
      default:
    }
    var medicine_allocation_id = $scope.medicineAllocations[index].id;
    API.backMedicineAllocation($state.params.id, allocation, medicine_allocation_id, "back", $scope.drinked_day_medicine_id).success(function(response) {
      NProgress.done();
      if(response.code == 1) {
        $state.reload();
      }
    });
  }

  $scope.showHistoryMedicineAllocationModal = function() {
    NProgress.start();
    var modalInstance = $uibModal.open({
      templateUrl: "/templates/nurses/patients/history_form.html",
      size: 'lg',
      backdrop: 'static',
      keyboard: false,
      controller: ['$scope', '$uibModalInstance', 'toastr', '$state', 'API',
        function($scope, $uibModalInstance, toastr, $state, API) {
        NProgress.done();
        $scope.from_date = "01" + "/" + currentMonth + "/" + currentYear;
        $scope.to_date = currentDate + "/" + currentMonth + "/" + currentYear;
        $scope.medicineAllocation = medicineAllocations;
        $scope.getHistoryMedicationAllocation = function () {
          NProgress.start();
          API.getHistoryMedicationAllocation($state.params.id, $scope.from_date, $scope.to_date).success(function (response) {
            NProgress.done();
            if(response.code == 1) {
              $scope.history_medicine_allocation = response.data;
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

  $scope.showMedicineNotifyModal = function() {
    NProgress.start();
    if ($scope.type_allocation == 2) {
      if (medicineAllocations.data[0].status == 'taked' || medicineAllocations.data[1].status == 'taked') {
        $scope.taked = true;
      } else {
        $scope.taked = false;
      }
    } else if ($scope.type_allocation == 1) {
      if (medicineAllocations.data[0].status == 'taked') {
        $scope.taked = true;
      } else {
        $scope.taked = false;
      }
    } else {
      $scope.taked = false;
      if (medicineAllocations.patient_warning.level == 'empty_prescription') {
        $scope.empty_prescription = true;
      } else if (medicineAllocations.patient_warning.level == 'obligatory') {
        $scope.obligatory = true;
      }
    }
    console.log($scope.taked)
    console.log(medicineAllocations.data.length > 0)
    if (($scope.empty_prescription) || ($scope.taked) || ($scope.obligatory)) {
      var modalInstance = $uibModal.open({
        templateUrl: "/templates/nurses/patients/notify_form.html",
        size: 'md',
        controller: ['$scope', '$uibModalInstance', 'toastr', '$state', 'API', '$rootScope',
          function($scope, $uibModalInstance, toastr, $state, API, $rootScope) {
          NProgress.done();
          $scope.allocate_times = [{name: 'morning', value: 0}, {name:'afternoon', value: 1}]
          $scope.type_allocation = medicineAllocations.data.length;
          $scope.notification = {};
          if ($scope.type_allocation == 2) {
            if (medicineAllocations.data[0].status == 'taked' || medicineAllocations.data[1].status == 'taked') {
              $scope.taked = true;
            } else {
              $scope.taked = false;
            }
          } else if ($scope.type_allocation == 1) {
            if (medicineAllocations.data[0].status == 'taked') {
              $scope.taked = true;
            } else {
              $scope.taked = false;
            }
          } else {
            $scope.taked = false;
            if (medicineAllocations.patient_warning.level == 'empty_prescription') {
              $scope.empty_prescription = true;
              $scope.notification.notify_status = "empty_prescription";
            } else if (medicineAllocations.patient_warning.level == 'obligatory') {
              $scope.obligatory = true;
              $scope.notification.notify_status = "expirate_prescription";
            }
          }
          $scope.sendMedicineNotify = function () {
            NProgress.start();
            if (medicineAllocations.data.length > 0) {
              $scope.medicineAllocation = medicineAllocations.data[$scope.notification.type || 0];
              $scope.medicine_allocation_id = $scope.medicineAllocation.id;
              $scope.notification.patient_id = $state.params.id;
            } else {
              $scope.notification.patient_id = $state.params.id;
              $scope.medicine_allocation_id = null;
              $scope.medicineAllocation = {};
              $scope.medicineAllocation.status = "expirate_prescription_or_empty_prescription";
            }
            if ($scope.medicineAllocation.status == "taked" || $scope.medicine_allocation_id == null) {
              if (medicineAllocations.data.length == 1) {
                type = "day";
              } else {
                if ($scope.notification.type == 0) {
                  type = "morning";
                } else {
                  type = "afternoon";
                }
              }
              API.sendMedicineNotify($scope.notification, $scope.medicine_allocation_id, type).success(function (response) {
                NProgress.done();
                if(response.code == 1) {
                  $state.reload($state.current);
                  $uibModalInstance.dismiss();
                  toastr.success(response.message);
                } else {
                  toastr.error(response.message);
                }
              });
            } else {
              toastr.error("Bệnh nhân chưa uống thuốc");
              NProgress.done();
            }
          }
          $scope.close = function () {
            $uibModalInstance.dismiss();
          }
        }]
      });
    } else {
      toastr.error("Bệnh nhân chưa uống thuốc không thể tạo thông báo nôn!")
      NProgress.done();
    }
  }

  $scope.reportFall = function() {
    NProgress.start();
    if (medicineAllocations.data.length > 1) {
      var modalInstance = $uibModal.open({
        templateUrl: "/templates/nurses/patients/falled_notify.html",
        size: 'md',
        backdrop: 'static',
        keyboard: false,
        controller: ['$scope', '$uibModalInstance', 'toastr', '$state', 'API', '$rootScope',
          function($scope, $uibModalInstance, toastr, $state, API, $rootScope) {
          NProgress.done();
          $scope.allocate_times = [{name: 'morning', value: 0}, {name:'afternoon', value: 1}]
          $scope.type_allocation = medicineAllocations.data.length;
          $scope.notification = {};
          $scope.sendMedicineNotify = function () {
            $scope.medicineAllocation = medicineAllocations.data[$scope.notification.type || 0];
            if ($scope.medicineAllocation.status == "allocated") {
              $ngBootbox.confirm($filter("translator")("confirm_fall", "main")).then(function() {
                NProgress.start();
                var type = $scope.notification.type;
                $scope.notification.patient_id = $scope.medicineAllocation.patient_id;
                $scope.medicine_allocation_id = $scope.medicineAllocation.id;
                $scope.notification.notify_status = "falled";
                API.sendMedicineNotify($scope.notification, $scope.medicineAllocation.id).success(function (response) {
                  NProgress.done();
                  if(response.code == 1) {
                    $state.reload($state.current);
                    $uibModalInstance.dismiss();
                  } else {
                    toastr.error(response.message);
                  }
                });
                var modalInstance = $uibModal.open({
                  templateUrl: "/templates/nurses/report_falled.html",
                  size: 'lg',
                  backdrop: 'static',
                  keyboard: false,
                  controller: ['$scope', '$uibModalInstance', 'toastr', '$state', 'API',
                    '$rootScope',
                    function($scope, $uibModalInstance, toastr, $state, API, $rootScope) {
                    NProgress.done();
                    $scope.patient = patient;
                    $scope.currentDate = currentDate;
                    $scope.currentMonth = currentMonth;
                    $scope.currentYear = currentYear;
                    var date = TIME_NOW;
                    $scope.hour = date.getHours();
                    $scope.minute = date.getMinutes();
                    if ($scope.minute < 10) {
                      $scope.minute = "0" + $scope.minute;
                    }
                    if ($scope.currentDate < 10) {
                      $scope.currentDate = "0" + $scope.currentDate;
                    }
                    if ($scope.currentMonth < 10) {
                      $scope.currentMonth = "0" + $scope.currentMonth;
                    }
                    $scope.seccond = date.getSeconds();
                    $scope.medicineAllocation = medicineAllocations.data[type || 0];
                    var weekday = ["Chủ nhật", "Thứ hai", "Thứ ba", "Thứ tư", "Thứ năm", "Thứ sáu", "Thứ bảy"];
                    $scope.weekdays = weekday[date.getDay()];
                    $scope.print = function() {
                      var mywindow = window.open('', 'PRINT');
                      mywindow.document.write('<html><head><title></title>');
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
              });
            } else if ($scope.medicineAllocation.status == "waiting"){
              toastr.error("Bệnh nhân chưa cấp phát thuốc, không thể lập biên bản đổ!")
              NProgress.done();
            }
            else if ($scope.medicineAllocation.status == "taked"){
              toastr.error("Bệnh nhân đã uống thuốc không thể lập biên bản đổ!")
              NProgress.done();
            }
          }
          $scope.close = function () {
            $uibModalInstance.dismiss();
          }
        }]
      });
    } else {
      if ($scope.medicineAllocations[0].status == "allocated") {
        $ngBootbox.confirm($filter("translator")("confirm_fall", "main")).then(function() {
          $scope.notification = {};
          $scope.notification.notify_status = "falled";
          API.sendMedicineNotify($scope.notification, $scope.medicineAllocations[0].id).success(function (response) {
            NProgress.done();
            if(response.code == 1) {
              $state.reload($state.current);
            } else {
              toastr.error(response.message);
            }
          });
          var modalInstance = $uibModal.open({
            templateUrl: "/templates/nurses/report_falled.html",
            size: 'lg',
            backdrop: 'static',
            keyboard: false,
            controller: ['$scope', '$uibModalInstance', 'toastr', '$state', 'API',
              '$rootScope',
              function($scope, $uibModalInstance, toastr, $state, API, $rootScope) {
              NProgress.done();
              $scope.patient = patient;
              $scope.currentDate = currentDate;
              $scope.currentMonth = currentMonth;
              $scope.currentYear = currentYear;
              var date = TIME_NOW;
              $scope.hour = date.getHours();
              $scope.minute = date.getMinutes();
              if ($scope.minute < 10) {
                $scope.minute = "0" + $scope.minute;
              }
              $scope.seccond = date.getSeconds();
              $scope.medicineAllocation = medicineAllocations.data[0];
              var weekday = ["Chủ nhật", "Thứ hai", "Thứ ba", "Thứ tư", "Thứ năm", "Thứ sáu", "Thứ bảy"];
              $scope.weekdays = weekday[date.getDay()];
              $scope.print = function() {
                var mywindow = window.open('', 'PRINT');
                mywindow.document.write('<html><head><title></title>');
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
        });
        NProgress.done();
      } else if ($scope.medicineAllocations[0].status == "waiting"){
        toastr.error("Bệnh nhân chưa cấp phát thuốc, không thể lập biên bản đổ!")
        NProgress.done();
      }
      else if ($scope.medicineAllocations[0].status == "taked"){
        toastr.error("Bệnh nhân đã uống thuốc không thể lập biên bản đổ!")
        NProgress.done();
      }
    }
  }


  $scope.showExportExcelModal = function() {
    NProgress.start();
    var modalInstance = $uibModal.open({
      templateUrl: "/templates/nurses/patients/export_form.html",
      size: 'md',
      backdrop: 'static',
      keyboard: false,
      controller: ['$scope', '$uibModalInstance', 'toastr', '$state', 'API',
        function($scope, $uibModalInstance, toastr, $state, API) {
        NProgress.done();
        $scope.patient = patient;
        $scope.time = {
          current_year: TODAY.getFullYear(),
          current_month: TODAY.getMonth() + 1
        }
        $scope.list_years = [$scope.time.current_year, $scope.time.current_year - 1, $scope.time.current_year - 2];
        $scope.export = function(patient_id, month, year) {
          NProgress.start();
          API.export_bill(patient_id, month, year).success(function(response) {
            var blob = new Blob([response], { type: "attachment/xlsx" });
            saveAs(blob, "Bao_cao.xlsx");
            NProgress.done();
            $state.reload($state.current);
            $uibModalInstance.dismiss();
            toastr.success('Xuất Excel thành công');
          });
        }
        $scope.close = function () {
          $uibModalInstance.dismiss();
        }
      }]
    });
  }

  $scope.giveUpReport = function() {
    // var report_creator = $scope.report_creator;
    // var list_user = [];
    // for (var i = 0; i < $scope.report_creator.length; i++) {
    //   list_user.push($scope.report_creator[i].id)
    // }
    // API.createReport(list_user, 3).success(function (response) {
    //   NProgress.done();
    //   if(response.code == 1) {
    //     toastr.success(response.message);
    //   } else {
    //     toastr.error(response.message);
    //   }
    // });
    var modalInstance = $uibModal.open({
      templateUrl: "/templates/nurses/edit_report.html",
      size: 'lg',
      controller: ['$scope', '$uibModalInstance', 'toastr', '$state', 'API',
        '$rootScope',
        function($scope, $uibModalInstance, toastr, $state, API, $rootScope) {
        NProgress.done();

        API.getAllUsers().success(function (response) {
          $scope.all_users = response.data;
        });

        $scope.report_creator = [{}];

        $scope.removeReportor = function(index) {
          $scope.report_creator.splice(index, 1);

        }

        $scope.reloadReportor = function(reportor, idx) {
          var check = 1;
          for (var i = 0; i < $scope.report_creator.length; i++) {
            if (reportor.id == $scope.report_creator[i].id) {
              toastr.error("Bạn đã chọn người này rồi <3!");
              check = 0;
              break;
            }
          }
          if (check == 1) {
            $scope.report_creator[idx] = reportor;
          }

        }

        $scope.addReportor = function(index) {
          $scope.report_creator.push({});
        }

        $scope.exportReport = function() {
          var report_creator = $scope.report_creator;
          var list_user = [];
          for (var i = 0; i < $scope.report_creator.length; i++) {
            list_user.push($scope.report_creator[i].id)
          }

          var modalInstance = $uibModal.open({
            templateUrl: "/templates/nurses/give_up_report.html",
            size: 'lg',
            controller: ['$scope', '$uibModalInstance', 'toastr', '$state', 'API',
              '$rootScope',
              function($scope, $uibModalInstance, toastr, $state, API, $rootScope) {
              NProgress.done();
              $scope.patient = patient;
              $scope.report_creator = report_creator;

              var date = TIME_NOW;
              $scope.date = date;
              $scope.history = history;
              $scope.currentDate = date.getDate();
              $scope.currentMonth = date.getMonth() + 1;
              $scope.currentYear = date.getFullYear();
              $scope.hour = date.getHours();
              $scope.minute = date.getMinutes();
              if ($scope.minute < 10) {
                $scope.minute = "0" + $scope.minute;
              }
              if ($scope.currentDate < 10) {
                $scope.currentDate = "0" + $scope.currentDate;
              }
              if ($scope.currentMonth < 10) {
                $scope.currentMonth = "0" + $scope.currentMonth;
              }
              $scope.seccond = date.getSeconds();
              var weekday = ["Chủ nhật", "Thứ hai", "Thứ ba", "Thứ tư", "Thứ năm", "Thứ sáu", "Thứ bảy"];
              $scope.weekdays = weekday[date.getDay()];
              $scope.print = function() {
                var mywindow = window.open('', 'PRINT');
                mywindow.document.write('<html><head><title></title>');
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

        $scope.close = function () {
          $uibModalInstance.dismiss();
        }
      }]
    });
    // var modalInstance = $uibModal.open({
    //   templateUrl: "/templates/nurses/give_up_report.html",
    //   size: 'lg',
    //   controller: ['$scope', '$uibModalInstance', 'toastr', '$state', 'API',
    //     '$rootScope',
    //     function($scope, $uibModalInstance, toastr, $state, API, $rootScope) {
    //     NProgress.done();

    //     // $scope.report_creator= report_creator;

    //     var date = TIME_NOW;
    //     $scope.date = date;
    //     $scope.history = history;
    //     $scope.currentDate = date.getDate();
    //     $scope.currentMonth = date.getMonth() + 1;
    //     $scope.currentYear = date.getFullYear();
    //     $scope.hour = date.getHours();
    //     $scope.minute = date.getMinutes();
    //     if ($scope.minute < 10) {
    //       $scope.minute = "0" + $scope.minute;
    //     }
    //     if ($scope.currentDate < 10) {
    //       $scope.currentDate = "0" + $scope.currentDate;
    //     }
    //     if ($scope.currentMonth < 10) {
    //       $scope.currentMonth = "0" + $scope.currentMonth;
    //     }
    //     $scope.seccond = date.getSeconds();
    //     var weekday = ["Chủ nhật", "Thứ hai", "Thứ ba", "Thứ tư", "Thứ năm", "Thứ sáu", "Thứ bảy"];
    //     $scope.weekdays = weekday[date.getDay()];
    //     $scope.print = function() {
    //       var mywindow = window.open('', 'PRINT');
    //       mywindow.document.write('<html><head><title></title>');
    //       mywindow.document.write('<link rel="stylesheet" href="" media="print"/>');
    //       mywindow.document.write('</head><body>');
    //       mywindow.document.write(document.getElementById("pdf").innerHTML);
    //       mywindow.document.write('</body></html>');
    //       setTimeout(function() {
    //         mywindow.document.close(); // necessary for IE >= 10
    //         mywindow.focus(); // necessary for IE >= 10*/
    //         mywindow.print();
    //         mywindow.close();
    //       }, 100)
    //       return true;
    //     }
    //     $scope.close = function () {
    //       $uibModalInstance.dismiss();
    //     }
    //   }]
    // });
  }
}]);
