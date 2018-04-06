app.controller("Storekeeper_Voucher_DeliveryMedicine",
  ['$scope', '$state', '$stateParams', 'API', 'Voucher', 'allMedicine', 'Accept_DeliveryVoucher', 'DeliveryVoucher',
   'medicineDelivery', '$uibModal', '$ngBootbox', '$filter', 'toastr', 'voucher',
  function ($scope, $state, $stateParams, API, Voucher, allMedicine, Accept_DeliveryVoucher, DeliveryVoucher,
    medicineDelivery, $uibModal, $ngBootbox, $filter, toastr, voucher) {
  $scope.medicine_deliveries = medicineDelivery.data;
  $scope.voucher_status = medicineDelivery.voucher_status;
  $scope.voucher_user_id = medicineDelivery.voucher_user_id;
  $scope.user_id = medicineDelivery.user_id;
  $scope.voucher = voucher.data;

  $scope.showEditVoucherModal = function() {
    NProgress.start();
    var modalInstance = $uibModal.open({
      templateUrl: "/templates/vouchers/delivery/edit.html",
      backdrop: 'static',
      keyboard: false,
      resolve: {
        voucher: ["Voucher", function (Voucher) {
          return Voucher.show($stateParams.id, "with_medicines").then(function(response) {
            return response.data;
          });
        }],
        available_medicines: ['Selections_Medicine', function(Selections_Medicine) {
          return Selections_Medicine.index("main").then(function(response) {
            return response.data.data;
          });
        }]
      },
      size: 'full',
      controller: ['$scope', '$rootScope', 'voucher', 'available_medicines', '$uibModalInstance',
        'toastr', '$state', '$stateParams', 'API', 'DeliveryVoucher',
        function ($scope, $rootScope, voucher, available_medicines, $uibModalInstance,
         toastr, $state, $stateParams, API, DeliveryVoucher) {
        NProgress.done();
        $scope.new_voucher = voucher.data;
        if ($scope.new_voucher.medicines == undefined) {
          $scope.new_voucher.medicines = [{}];
        }

        // phan thuoc de chon (dropdown) remaining phai cong them thuoc dang order trong don

        for (var i in available_medicines) {
          for (var j in voucher.data.medicines) {
            if (available_medicines[i].id == voucher.data.medicines[j].medicine_id) {
              available_medicines[i].remaining_number += voucher.data.medicines[j].number_order;
            }
          }
        }

        // phan thuoc dang order trong don, remaining phai cong voi so dang order

        for (var i in voucher.data.medicines) {
          voucher.data.medicines[i].remaining_number = voucher.data.medicines[i].remaining_number
                                                     - voucher.data.medicines[i].booking
                                                     + voucher.data.medicines[i].number_order
        }

        $scope.available_medicines_origin = available_medicines;

        $scope.available_medicines = [];

        $scope.available_medicines.unshift({name: 'Tên thuốc', composition: 'Thành phần',
          concentration: 'Nồng độ', packing: 'Đóng gói', production_batch: 'Số lô',
          provider: 'Nhà phân phối', source: "Nguồn thuốc", expiration_date: 'Ngày hết hạn',
          remaining: 'SL tồn', manufacturer: 'Nhà sản xuất', unit: 'Đơn vị tính'});
        // bo thuoc o phan select voi nhung thuoc da co trong phieu

        for (var i = 0; i < $scope.available_medicines_origin.length; i++) {
          var has_medicine = false;
          for (var j = 0; j < $scope.new_voucher.medicines.length; j++) {
            if ($scope.available_medicines_origin[i].id == $scope.new_voucher.medicines[j].id) {
              has_medicine = true;
              break;
            }
          }
          if (!has_medicine) {
            $scope.available_medicines.push($scope.available_medicines_origin[i]);
          }
        }

        //

        find_by_id = function (array, id) {
          if (typeof(array) == 'undefined') {
            return '';
          } else {
            var match =  $.grep(array, function(e){ return e.id == id })[0]
            if(typeof(match) == 'undefined')
              return '';
            return match.name;
          }
        }

        // FUNCTION new_voucher_datee_change
        // init_date change -> (1) ton tai medicine.init_date > new_voucher.datee, (2) khong ton tai
        // (1) hien loi "Ngày tạo phiếu phải lớn hơn ngày nhập thuốc."
        // (2) cho doi -> cap nhat lai thuoc trong select

        function toDate(dateStr) {
          const [day, month, year] = dateStr.split("/")
          return new Date(year, month - 1, day)
        }

        function lastest() {
          function pad(s) { return (s < 10) ? '0' + s : s; }
          var dates = $scope.available_medicines.map(function(x) { return new Date(x.init_date); })
          var lastest = new Date(Math.max.apply(null, dates));
          return [pad(lastest.getDate()), pad(lastest.getMonth() + 1), lastest.getFullYear()].join('/');
        }

        function medicine_yesterday() {
          datee = toDate($scope.new_voucher.datee);
          yesterday = new Date(datee.setDate(datee.getDate()));
          yesterday_string = yesterday.toISOString().substr(0, 10);
          $scope.yesterday_string = yesterday_string.split('-').reverse().join('/');
          NProgress.start();
          API.getMedicines("yesterday", 1, yesterday_string).success(function (response) {
            NProgress.done();
            $scope.medicine_yesterday = response.data;
            for (i = 0; i < $scope.medicine_yesterday.length; i++) {
              if ($scope.medicine_yesterday[i].export_yesterday == "0.0") {
                $scope.medicine_yesterday.splice(i, 1);
                i--;
              }
            }
          })
        }

        medicine_yesterday();

        $scope.lastest = lastest();

        var reload_select = function() {
          $scope.available_medicines = [];
          $scope.available_medicines.unshift({name: 'Tên thuốc', composition: 'Thành phần',
            concentration: 'Nồng độ', packing: 'Đóng gói', production_batch: 'Số lô',
            provider: 'Nhà phân phối', source: "Nguồn thuốc", expiration_date: 'Ngày hết hạn',
            remaining: 'SL tồn', manufacturer: 'Nhà sản xuất', unit: 'Đơn vị tính'});
          for (var i = 0; i < $scope.available_medicines_origin.length; i++) {
            var has_medicine = false;
            for (var j = 0; j < $scope.new_voucher.medicines.length; j++) {
              if ($scope.available_medicines_origin[i].id == $scope.new_voucher.medicines[j].id) {
                has_medicine = true;
                break;
              }
            }
            if (!has_medicine) {
              $scope.available_medicines.push($scope.available_medicines_origin[i]);
            }
          }
        }

        $scope.get_medicine_yesterday = function() {
          datee = toDate($scope.new_voucher.datee);
          yesterday = new Date(datee.setDate(datee.getDate()));
          yesterday_string = yesterday.toISOString().substr(0, 10);
          $scope.yesterday_string = yesterday_string.split('-').reverse().join('/');
          NProgress.start();
          API.getMedicines("yesterday", 1, yesterday_string).success(function (response) {
            NProgress.done();
            $scope.medicine_yesterday = response.data;
            for (i = 0; i < $scope.medicine_yesterday.length; i++) {
              if ($scope.medicine_yesterday[i].export_yesterday == "0.0") {
                $scope.medicine_yesterday.splice(i, 1);
                i--;
              }
            }
          })
        }

        $scope.addInitdateMoreThan =  function (voucher_id) {
          if (toDate($scope.new_voucher.medicines[voucher_id].init_date).getTime() > toDate($scope.new_voucher.datee).getTime())
            return "Ngày tạo thuốc phải nhỏ hơn ngày xuất phiếu";
        }

        $scope.addExpirationText = function (voucher_id) {
          if ($scope.new_voucher.medicines[voucher_id].expiration_date == null ||
            $scope.new_voucher.medicines[voucher_id].expiration_date == "" ||
            $scope.new_voucher.datee == null || $scope.new_voucher.datee == "") return;
          timeDiff = toDate($scope.new_voucher.medicines[voucher_id].expiration_date).getTime() - toDate($scope.new_voucher.datee).getTime();
          dayDiff = Math.ceil(timeDiff / (1000 * 3600 * 24));
          if (dayDiff < 0) return "Thuốc đã hết hạn";
          else if (dayDiff <= 180) return "Thuốc sắp hết hạn";
        }

        $scope.reloadInfoMedicine = function(avaiable_medicine, idx) {
          $scope.new_voucher.medicines[idx] = avaiable_medicine;
          reload_select();
        }

        $scope.removeMedicine = function(index) {
          $scope.new_voucher.medicines.splice(index, 1);
          reload_select();
        }

        $scope.addMoreMedicine = function () {
          $scope.new_voucher.medicines.push({});
        }

        $scope.editVoucher = function () {
          function toDate(dateStr) {
            const [day, month, year] = dateStr.split("/")
            return new Date(year, month - 1, day)
          }
          for (i = 0; i < $scope.new_voucher.medicines.length; i++) {
            if (toDate($scope.new_voucher.datee) < toDate($scope.new_voucher.medicines[i].init_date)) {
              $ngBootbox.alert("Có thuốc mà ngày tạo lớn hơn ngày xuất phiếu.");
              return;
            }
          }
          NProgress.start();
          DeliveryVoucher.update($stateParams.id, $scope.new_voucher).success(function (response) {
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

  $scope.showDeleteVoucherModal = function () {
    $ngBootbox.confirm($filter("translator")("confirm_delete", "main") + '?').then(function() {
      NProgress.start();
      DeliveryVoucher.delete($stateParams.id).success(function(response) {
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

  $scope.showAcceptVoucherModal = function () {
    $ngBootbox.confirm($filter("translator")("confirm_accept", "main") + '?').then(function() {
      NProgress.start();
      Accept_DeliveryVoucher.update($stateParams.id).success(function(response) {
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

  $scope.showPrintDeliveryVoucherModal = function () {
    NProgress.start();
    var modalInstance = $uibModal.open({
      templateUrl: "/templates/vouchers/delivery/medicines/print.html",
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
