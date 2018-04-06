app.controller("Nurses_SubVoucher_DeliverySubMedicines",
  ['$scope', '$state', 'DeliverySubVoucher', 'delivery_sub_medicines', 'Accept_DeliverySubVoucher',
    '$ngBootbox', '$uibModal', '$filter', 'toastr', 'DeliverySubVoucher_Allocation', 'DeliverySubVoucher_GiveBack',
  function ($scope, $state, DeliverySubVoucher, delivery_sub_medicines, Accept_DeliverySubVoucher,
    $ngBootbox, $uibModal, $filter, toastr, DeliverySubVoucher_Allocation, DeliverySubVoucher_GiveBack) {
  $scope.sub_medicines = delivery_sub_medicines;

  console.log($scope.sub_medicines)
  $scope.showEditSubVoucherModal = function() {
    NProgress.start();
    var modalInstance = $uibModal.open({
      templateUrl: "/templates/sub_vouchers/delivery/edit.html",
      size: 'full',
      backdrop: 'static',
      keyboard: false,
      resolve: {
        available_sub_medicines: ['DeliverySubVoucher_SubMedicine', '$stateParams',
          function(DeliverySubVoucher_SubMedicine, $stateParams) {
          return DeliverySubVoucher_SubMedicine.index().then(function(response) {
            return response.data.data;
          });
        }],
        sub_voucher: ['DeliverySubVoucher', '$stateParams', function(DeliverySubVoucher, $stateParams) {
          return DeliverySubVoucher.show($state.params.id).then(function(response) {
            return response.data.data;
          });
        }],
      },
      controller: ['$scope', '$rootScope', '$uibModalInstance', 'toastr', '$state',
                   'available_sub_medicines', 'sub_voucher', 'Accept_DeliverySubVoucher',
        function($scope, $rootScope, $uibModalInstance, toastr, $state,
                 available_sub_medicines, sub_voucher, Accept_DeliverySubVoucher) {
        NProgress.done();
        $scope.new_sub_voucher = sub_voucher;
        // console.log(sub_voucher);
        console.log(available_sub_medicines)

        if ($scope.new_sub_voucher.sub_medicines == undefined) {
          $scope.new_sub_voucher.sub_medicines = [{}];
        }

        // phan thuoc de chon (dropdown) remaining phai cong them thuoc dang order trong don

        for (var i in available_sub_medicines) {
          for (var j in sub_voucher.sub_medicines) {
            if (available_sub_medicines[i].id == sub_voucher.sub_medicines[j].sub_medicine_id) {
              available_sub_medicines[i].booking -= sub_voucher.sub_medicines[j].number_order
            }
          }
        }

        // phan thuoc dang order trong don, remaining phai cong voi so dang order

        for (var i in sub_voucher.sub_medicines) {
          sub_voucher.sub_medicines[i].booking -= sub_voucher.sub_medicines[i].number_order;
        }

        $scope.available_sub_medicines_origin = available_sub_medicines;

        $scope.available_sub_medicines = [];

        for (var i = 0; i < $scope.available_sub_medicines_origin.length; i++) {
          var has_sub_medicine = false;
          for (var j = 0; j < $scope.new_sub_voucher.sub_medicines.length; j++) {
            if ($scope.available_sub_medicines_origin[i].id == $scope.new_sub_voucher.sub_medicines[j].id) {
              has_sub_medicine = true;
              break;
            }
          }
          if (!has_sub_medicine) {
            $scope.available_sub_medicines.push($scope.available_sub_medicines_origin[i]);
          }
        }
        $scope.available_sub_medicines.unshift({name: 'Tên thuốc', composition: 'Thành phần',
          concentration: 'Nồng độ', packing: 'Đóng gói', init_date: 'Ngày tạo thuốc',
          production_batch: 'Số lô', provider: 'Nhà phân phối', source: 'Nguồn thuốc',
          expiration_date: 'Ngày hết hạn', remaining: 'SL tồn', manufacturer: 'Nhà sản xuất',
          unit: 'Đơn vị tính'});
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

        function toDate(dateStr) {
          const [day, month, year] = dateStr.split("/")
          return new Date(year, month - 1, day)
        }

        function latest() {
          function pad(s) { return (s < 10) ? '0' + s : s; }
          var dates = $scope.available_sub_medicines.map(function(x) { return new Date(x.init_date); })
          var latest = new Date(Math.max.apply(null, dates));
          return [pad(latest.getDate()), pad(latest.getMonth()+1), latest.getFullYear()].join('/');
        }

        $scope.latest = latest();

        var reload_select = function() {
          $scope.available_sub_medicines = [];
          $scope.available_sub_medicines.unshift({name: 'Tên thuốc', composition: 'Thành phần',
            concentration: 'Nồng độ', packing: 'Đóng gói', init_date: 'Ngày tạo thuốc', production_batch: 'Số lô',
            provider: 'Nhà phân phối', source: "Nguồn thuốc", expiration_date: 'Ngày hết hạn',
            remaining: 'SL tồn', manufacturer: 'Nhà sản xuất', unit: 'Đơn vị tính'});
          for (var i = 0; i < $scope.available_sub_medicines_origin.length; i++) {
            var has_sub_medicine = false;
            for (var j = 0; j < $scope.new_sub_voucher.sub_medicines.length; j++) {
              if ($scope.available_sub_medicines_origin[i].id == $scope.new_sub_voucher.sub_medicines[j].id) {
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
          function toDate(dateStr) {
            const [day, month, year] = dateStr.split("/")
            return new Date(year, month - 1, day)
          }
          for (i = 0; i < $scope.new_sub_voucher.sub_medicines.length; i++) {
            if (toDate($scope.new_sub_voucher.datee) < toDate($scope.new_sub_voucher.sub_medicines[i].init_date)) {
              $ngBootbox.alert("Có thuốc mà ngày tạo lớn hơn ngày xuất phiếu.");
              return;
            }
          }
          NProgress.start();
          if ($scope.new_sub_voucher.typee == "export_to_allocation") {
            DeliverySubVoucher_Allocation.update($state.params.id, $scope.new_sub_voucher).success(function (response) {
              NProgress.done();
              if(response.code == 1) {
                $state.reload();
                $uibModalInstance.dismiss();
                toastr.success(response.message);
              } else {
                toastr.error(response.message);
              }
            });
          } else {
            DeliverySubVoucher_GiveBack.update($state.params.id, $scope.new_sub_voucher).success(function (response) {
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
        }

        $scope.addExpirationText = function (voucher_id) {
          function toDate(dateStr) {
            const [day, month, year] = dateStr.split("/")
            return new Date(year, month - 1, day)
          }
          if ($scope.new_sub_voucher.sub_medicines[voucher_id].expiration_date == null ||
            $scope.new_sub_voucher.sub_medicines[voucher_id].expiration_date == "" ||
            $scope.new_sub_voucher.datee == null || $scope.new_sub_voucher.datee == "") return;
          timeDiff = toDate($scope.new_sub_voucher.sub_medicines[voucher_id].expiration_date).getTime() -
            toDate($scope.new_sub_voucher.datee).getTime();
          dayDiff = Math.ceil(timeDiff / (1000 * 3600 * 24));
          if (dayDiff < 0) return "Thuốc đã hết hạn";
          else if (dayDiff <= 180) return "Thuốc sắp hết hạn";
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
      DeliverySubVoucher.delete($state.params.id).success(function(response) {
        NProgress.done();
        if(response.code == 1) {
          $state.go("main.delivery_sub_vouchers", {}, { reload: true });
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
      Accept_DeliverySubVoucher.update($state.params.id).success(function(response) {
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
