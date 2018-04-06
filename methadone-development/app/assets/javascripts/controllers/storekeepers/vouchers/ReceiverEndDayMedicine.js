app.controller("Storekeeper_Voucher_ReceivedEndDayMedicine",
  ['$scope', '$state', '$stateParams', 'API', 'Voucher', 'Accept_ReceivedVoucher', 'ReceivedVoucher',
   'medicineReceived', '$uibModal', '$ngBootbox', '$filter', 'toastr', 'RejectVoucher_GiveBack', 'voucher',
  function ($scope, $state, $stateParams, API, Voucher, Accept_ReceivedVoucher, ReceivedVoucher,
    medicineReceived, $uibModal, $ngBootbox, $filter, toastr, RejectVoucher_GiveBack, voucher) {

  if(medicineReceived.code == 2) {
    $state.go("main.received_vouchers", {}, {reload: true});
    toastr.error(medicineReceived.message);
  }
  $scope.medicine_received = medicineReceived.data;
  $scope.voucher_typee = medicineReceived.voucher_typee;
  $scope.voucher_status = medicineReceived.voucher_status;
  $scope.voucher_user_id = medicineReceived.voucher_user_id;
  $scope.user_id = medicineReceived.user_id;
  $scope.voucher = voucher.data;

  $scope.showEditVoucherModal = function () {
    NProgress.start();
    var modalInstance = $uibModal.open({
      templateUrl: "/templates/vouchers/received_end_day/edit.html",
      backdrop: 'static',
      keyboard: false,
      resolve: {
        voucher: ["Voucher", function (Voucher) {
          return Voucher.show($stateParams.id, "with_medicines").then(function(response) {
            return response.data;
          });
        }],
        list_medicines: ['Selections_Medicine', function(Selections_Medicine) {
          return Selections_Medicine.index("allocation", $scope.voucher.datee.split("/").reverse().join("-")).then(function(response) {
            return response.data.data;
          });
        }],
        manufacturers: ['Manufacturer', '$stateParams',
          function(Manufacturer, $stateParams) {
          return Manufacturer.index().then(function(response) {
            return response.data.data;
          });
        }],
        providers: ['Provider', '$stateParams',
          function(Provider, $stateParams) {
          return Provider.index().then(function(response) {
            return response.data.data;
          });
        }],
      },
      size: 'full',
      controller: ['$scope', '$rootScope', 'voucher', 'list_medicines', 'manufacturers', 'providers',
        '$uibModalInstance', 'toastr', '$state', '$stateParams', 'API', 'ReceivedVoucher', 'ReceivedEndDayVoucher_EndDay',
        function ($scope, $rootScope, voucher, list_medicines, manufacturers, providers,
        $uibModalInstance, toastr, $state, $stateParams, API, ReceivedVoucher, ReceivedEndDayVoucher_EndDay) {
        NProgress.done();
        $scope.manufacturers = manufacturers;
        $scope.providers = providers;

        $scope.new_voucher = voucher.data;
        if ($scope.new_voucher.medicines == 'undefined') {
          $scope.new_voucher.medicines = [{}];
        }

        $scope.available_medicines = list_medicines;
        $scope.available_medicines.unshift({name: 'Tên thuốc', composition: 'Thành phần',
          concentration: 'Nồng độ', packing: 'Đóng gói', production_batch: 'Số lô',
          provider: 'Nhà phân phối', source: "Nguồn thuốc", expiration_date: 'Ngày hết hạn',
          remaining: 'SL tồn', manufacturer: 'Nhà sản xuất', unit: 'Đơn vị tính'});
        $scope.available_medicines_origin = list_medicines;

        find_by_id = function(array, id) {
          if(typeof(array) == 'undefined'){
            return '';
          } else {
            var match =  $.grep(array, function(e){ return e.id == id })[0]
            if(typeof(match) == 'undefined')
              return '';
            return match.name;
          }
        }

        $scope.reloadInfoMedicine = function(avaiable_medicine, idx) {
          $scope.new_voucher.medicines[idx] = JSON.parse(JSON.stringify(avaiable_medicine));
        }

        $scope.removeMedicine = function(index) {
          $scope.new_voucher.medicines.splice(index, 1);
        }

        $scope.addMoreMedicine = function () {
          $scope.new_voucher.medicines.push({});
        }

        $scope.editVoucher = function () {
          NProgress.start();
          ReceivedEndDayVoucher_EndDay.update($stateParams.id, $scope.new_voucher).success(function (response) {
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

        $scope.checkExpiration = function (voucher_date, exp_date) {
          function toDate(dateStr) {
            const [day, month, year] = dateStr.split("/")
            return new Date(year, month - 1, day)
          }
          if (voucher_date == null || voucher_date == "" || exp_date == null || exp_date == "") return;
          timeDiff = toDate(exp_date).getTime() - toDate(voucher_date).getTime();
          dayDiff = Math.ceil(timeDiff / (1000 * 3600 * 24));
          return dayDiff;
        }

        $scope.close = function () {
          $uibModalInstance.dismiss();
        }
      }]
    });
  }

  $scope.showDeleteVoucherModal = function () {
    $ngBootbox.confirm($filter("translator")("confirm_delete", "main") + '?').then(function() {
      NProgress.start();
      ReceivedVoucher.delete($stateParams.id).success(function(response) {
        NProgress.done();
        if(response.code == 1) {
          $state.go("main.received_end_day_vouchers", {}, {reload: true});
          toastr.success(response.message);
        } else {
          toastr.error(response.message);
        }
      });
    });
  }
  $scope.showAcceptVoucherModal = function() {
    $ngBootbox.confirm($filter("translator")("confirm_accept", "main") + '?').then(function() {
      NProgress.start();
      Accept_ReceivedVoucher.update($stateParams.id).success(function(response) {
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

  $scope.showRejectVoucherModal = function() {
    $ngBootbox.confirm($filter("translator")("confirm_reject", "main") + '?').then(function() {
      NProgress.start();
      RejectVoucher_GiveBack.update($stateParams.id).success(function(response) {
        NProgress.done();
        if(response.code == 1) {
          $state.go("main.received_vouchers", {}, {reload: true});
          toastr.success(response.message);
        } else {
          toastr.error(response.message);
        }
      });
    });
  }

  $scope.showPrintReceivedEndDayModal = function() {
    NProgress.start();
    var modalInstance = $uibModal.open({
      templateUrl: "/templates/vouchers/received_end_day/medicines/print.html",
      size: 'lg',
      backdrop: 'static',
      keyboard: false,
      resolve: {
        voucher: ["Voucher", function (Voucher) {
          return Voucher.show($stateParams.id, "with_medicines").then(function(response) {
            return response.data;
          });
        }],
      },
      controller: ['$scope', '$uibModalInstance', 'toastr', '$state', 'voucher', '$rootScope',
        function ($scope, $uibModalInstance, toastr, $state, voucher, $rootScope) {
        NProgress.done();
        $scope.close = function() {
          $uibModalInstance.dismiss();
        }

        $scope.currentDate = currentDate;
        $scope.currentMonth = currentMonth;
        $scope.currentYear = currentYear;

        $scope.voucher = voucher.data;

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
      }]
    });

  }
}]);
