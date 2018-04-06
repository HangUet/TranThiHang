app.controller("Nurses_SubVoucherReceivedSubMedicine_SubMedicines",
  ['$scope', '$state', 'ReceivedSubVouchers', 'ReceivedSubVoucher_DayMedicine', 'ReceivedSubVoucher',
   'ReceivedSubVoucher_EndDay', 'ReceivedSubVoucher',
   'received_sub_medicines', '$ngBootbox', '$uibModal', '$filter', 'toastr', 'Accept_ReceivedSubVoucher',
  function ($scope, $state, ReceivedSubVouchers, ReceivedSubVoucher_DayMedicine, ReceivedSubVoucher,
    ReceivedSubVoucher_EndDay, ReceivedSubVoucher,
    received_sub_medicines, $ngBootbox, $uibModal, $filter, toastr, Accept_ReceivedSubVoucher) {
  $scope.sub_medicines = received_sub_medicines;

  $scope.showEditSubVoucherModal = function() {
    NProgress.start();
    var modalInstance = $uibModal.open({
      templateUrl: "/templates/sub_vouchers/received/edit.html",
      size: 'full',
      backdrop: 'static',
      keyboard: false,
      resolve: {
        available_sub_medicines: ['ReceivedSubVoucher_DayMedicine', '$stateParams', function(SubMedicine, $stateParams) {
          return ReceivedSubVoucher_DayMedicine.index().then(function(response) {
            return response.data.data;
          });
        }],
        sub_voucher: ['ReceivedSubVoucher', '$stateParams', function(ReceivedSubVoucher, $stateParams) {
          return ReceivedSubVoucher.show($state.params.id).then(function(response) {
            return response.data.data;
          });
        }],
      },
      controller: ['$scope', '$rootScope', '$uibModalInstance', 'toastr', '$state',
                   'available_sub_medicines', 'sub_voucher',
        function($scope, $rootScope, $uibModalInstance, toastr, $state,
                available_sub_medicines, sub_voucher) {
        NProgress.done();

        $scope.new_sub_voucher = sub_voucher;
        console.log(available_sub_medicines)
        console.log(sub_voucher)
        // $scope.new_sub_voucher.sub_medicines = [{"sub_medicine_id": ""}];

        if ($scope.new_sub_voucher.sub_medicines == undefined) {
          $scope.new_sub_voucher.sub_medicines = [{}];
        }

        // phan thuoc de chon (dropdown) remaining phai cong them thuoc dang order trong don

        for (var i in available_sub_medicines) {
          for (var j in sub_voucher.sub_medicines) {
            if (available_sub_medicines[i].day_medicine_id == sub_voucher.sub_medicines[j].day_medicine_id) {
              available_sub_medicines[i].booking -= sub_voucher.sub_medicines[j].number_order;
            }
          }
        }

        $scope.available_sub_medicines_origin = available_sub_medicines;

        $scope.available_sub_medicines = [];
        console.log($scope.available_sub_medicines);
        for (var i = 0; i < $scope.available_sub_medicines_origin.length; i++) {
          var has_sub_medicine = false;
          for (var j = 0; j < $scope.new_sub_voucher.sub_medicines.length; j++) {
            if ($scope.available_sub_medicines_origin[i].day_medicine_id == $scope.new_sub_voucher.sub_medicines[j].day_medicine_id) {
              has_sub_medicine = true;
              break;
            }
          }
          if (!has_sub_medicine) {
            $scope.available_sub_medicines.push($scope.available_sub_medicines_origin[i]);
          }
        }
        $scope.available_sub_medicines.unshift({name: 'Tên thuốc', composition: 'Thành phần',
          concentration: 'Nồng độ', packing: 'Đóng gói', production_batch: 'Số lô',
          provider: 'Nhà phân phối', source: "Nguồn thuốc", expiration_date: 'Ngày hết hạn',
          remaining: 'SL tồn', manufacturer: 'Nhà sản xuất', unit: 'Đơn vị tính'});

        find_by_id = function(array, id) {
          if(typeof(array) == 'undefined'){
            return '';
          }
          else {
            var match =  $.grep(array, function(e){ return e.id == id })[0]
            if(typeof(match) == 'undefined')
              return '';
            return match.name;
          }
        }

        var reload_select = function() {
          $scope.available_sub_medicines = [];
          $scope.available_sub_medicines.unshift({name: 'Tên thuốc', composition: 'Thành phần',
            concentration: 'Nồng độ', packing: 'Đóng gói', production_batch: 'Số lô',
            provider: 'Nhà phân phối', source: "Nguồn thuốc", expiration_date: 'Ngày hết hạn',
            remaining: 'SL tồn', manufacturer: 'Nhà sản xuất', unit: 'Đơn vị tính'});
          for (var i = 0; i < $scope.available_sub_medicines_origin.length; i++) {
            var has_sub_medicine = false;
            for (var j = 0; j < $scope.new_sub_voucher.sub_medicines.length; j++) {
              if ($scope.available_sub_medicines_origin[i].day_medicine_id == $scope.new_sub_voucher.sub_medicines[j].day_medicine_id) {
                has_sub_medicine = true;
                break;
              }
            }
            if (!has_sub_medicine) {
              $scope.available_sub_medicines.push($scope.available_sub_medicines_origin[i]);
            }
          }
        }

        $scope.reloadInfoMedicine = function(avaiable_sub_medicine, idx) {
          $scope.new_sub_voucher.sub_medicines[idx] = avaiable_sub_medicine;
          reload_select();
        }

        $scope.removeSubMedicine = function(index) {
          $scope.new_sub_voucher.sub_medicines.splice(index, 1);
          reload_select();
        }

        $scope.addMoreSubMedicine = function () {
          $scope.new_sub_voucher.sub_medicines.push({});
        }

        $scope.editDeliverySubVoucher = function () {
          NProgress.start();
          ReceivedSubVoucher_EndDay.update($state.params.id, $scope.new_sub_voucher).success(function (response) {
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
  $scope.showDeleteSubVoucherModal = function () {
    $ngBootbox.confirm($filter("translator")("confirm_delete", "main") + '?').then(function() {
      NProgress.start();
      ReceivedSubVoucher.delete($state.params.id).success(function(response) {
        NProgress.done();
        if(response.code == 1) {
          $state.go("main.received_sub_vouchers", {}, { reload: true });
          toastr.success(response.message);
        } else {
          toastr.error(response.message);
        }
      });
    });
  }
  $scope.showAcceptSubVoucherModal = function () {
    $ngBootbox.confirm($filter("translator")("confirm_accept", "main") + '?').then(function() {
      NProgress.start();
      Accept_ReceivedSubVoucher.update($state.params.id).success(function(response) {
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
}]);
