app.controller("Nurses_SubVoucher_Delivery",
  ['$scope', '$state', 'DeliverySubVouchers', 'delivery_sub_vouchers', '$ngBootbox',
   '$uibModal', '$filter', 'toastr', '$rootScope', 'DeliverySubVoucher',
  function ($scope, $state, DeliverySubVouchers, delivery_sub_vouchers, $ngBootbox,
    $uibModal, $filter, toastr, $rootScope, DeliverySubVoucher) {
  $scope.sub_vouchers = delivery_sub_vouchers;

  if(($state.current.name === 'main.delivery_sub_vouchers') && $scope.sub_vouchers.length > 0) {
    $state.go("main.delivery_sub_vouchers.sub_medicines", {id: $scope.sub_vouchers[0].id});
  }
  $scope.showCreateSubVoucherModal = function() {
    NProgress.start();
    var modalInstance = $uibModal.open({
      templateUrl: "/templates/sub_vouchers/delivery/new.html",
      size: 'full',
      backdrop: 'static',
      keyboard: false,
      resolve: {
        available_sub_medicines: ['DeliverySubVoucher_SubMedicine', '$stateParams',
          function(DeliverySubVoucher_SubMedicine, $stateParams) {
          return DeliverySubVoucher_SubMedicine.index().then(function(response) {
            return response.data.data;
          });
        }]
      },
      controller: ['$scope', '$rootScope', '$uibModalInstance', 'toastr', '$state', 'DeliverySubVouchers',
        'available_sub_medicines', 'DeliverySubVoucher_GiveBack', 'DeliverySubVoucher_Allocation',
        function($scope, $rootScope, $uibModalInstance, toastr, $state, DeliverySubVouchers,
          available_sub_medicines, DeliverySubVoucher_GiveBack, DeliverySubVoucher_Allocation) {
        NProgress.done();

        $scope.new_sub_voucher = {"typee": "export_to_allocation", "sub_medicines": [{}]};

        $scope.available_sub_medicines_origin = available_sub_medicines;

        $scope.available_sub_medicines = [];

        function toDate(dateStr) {
          const [day, month, year] = dateStr.split("/")
          return new Date(year, month - 1, day)
        }

        $scope.change_date = function() {
          $scope.new_sub_voucher.sub_medicines = [{}];
          reload_select();
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

        var reload_select = function() {
          $scope.available_sub_medicines = [];
          $scope.available_sub_medicines.unshift({name: 'Tên thuốc', composition: 'Thành phần',
            concentration: 'Nồng độ', packing: 'Đóng gói', init_date: 'Ngày tạo thuốc',
            production_batch: 'Số lô', provider: 'Nhà phân phối', source: 'Nguồn thuốc',
            expiration_date: 'Ngày hết hạn', remaining: 'SL tồn', manufacturer: 'Nhà sản xuất',
            unit: 'Đơn vị tính'});
          for (var i = 0; i < $scope.available_sub_medicines_origin.length; i++) {
            var has_sub_medicine = false;
            for (var j = 0; j < $scope.new_sub_voucher.sub_medicines.length; j++) {
              if ($scope.available_sub_medicines_origin[i].id == $scope.new_sub_voucher.sub_medicines[j].id) {
                has_sub_medicine = true;
                break;
              }
            }
            if (!has_sub_medicine) {
              if ((toDate($scope.available_sub_medicines_origin[i].init_date.toString()) <= toDate($scope.new_sub_voucher.datee.toString())) ) {
                $scope.available_sub_medicines.push($scope.available_sub_medicines_origin[i]);
              }
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

        $scope.createDeliverySubVoucher = function () {
          NProgress.start();
          if ($scope.new_sub_voucher.typee == "export_to_allocation") {
            DeliverySubVoucher_Allocation.create($scope.new_sub_voucher).success(function (response) {
              NProgress.done();
              if(response.code == 1) {
                $state.reload();
                $uibModalInstance.dismiss();
                toastr.success(response.message);
                $state.go("main.delivery_sub_vouchers", {}, { reload: true });
              } else {
                toastr.error(response.message);
              }
            });
          } else {
            DeliverySubVoucher_GiveBack.create($scope.new_sub_voucher).success(function (response) {
              NProgress.done();
              if(response.code == 1) {
                $state.reload();
                $uibModalInstance.dismiss();
                toastr.success(response.message);
                $state.go("main.delivery_sub_vouchers", {}, { reload: true });
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

  $scope.keyword = $state.params.keyword;

  $scope.advanceSearch = false;

  $scope.search = function() {
    if ($scope.advanceSearch == true) {
      $state.go($state.current, {keyword: $scope.keyword}, {reload: true});
      $scope.advance_search = false;
    } else {
      $state.go($state.current, {keyword: $scope.keyword});
      $rootScope.sub_voucher_search = [];
    }
  }

  $rootScope.sub_voucher_search = {
    "typee": "",
    "status": "",
    "sender": "",
    "receiver": "",
    "code": "",
    "date_end": "",
    "date_start": "",
  }

  $scope.advance_search = false;

  $scope.showSearchModal = function() {
    NProgress.start();
    var modalInstance = $uibModal.open({
      templateUrl: "/templates/sub_vouchers/delivery/advance_search.html",
      size: 'lg',
      resolve: {
        keyword: $rootScope.sub_voucher_search
      },
      controller: ['$scope', '$uibModalInstance', 'toastr', '$state', 'API', 'keyword',
        function ($scope, $uibModalInstance, toastr, $state, API, keyword) {
        NProgress.done();
        $scope.keyword = keyword;

        $scope.search = function() {
          DeliverySubVoucher.search($scope.keyword).success(function(response) {
            data = response;
            $uibModalInstance.close(data);
          });
        }
        $scope.reset = function() {
          $scope.keyword = {
            "typee": "",
            "status": "",
            "sender": "",
            "receiver": "",
            "code": "",
            "date_end": "",
            "date_start": "",
          };
          $rootScope.sub_voucher_search = $scope.keyword;
        }

        $scope.close = function() {
          $uibModalInstance.close();
        }
      }]
    });
    modalInstance.result.then(function(response){
      if (response) {
        $scope.advance_search = true;
        // $scope.currentPage = response.page;
        $scope.sub_vouchers = response.data;

        if(($state.current.name === 'main.delivery_sub_vouchers') && $scope.sub_vouchers.length) {
          $state.go("main.delivery_sub_vouchers.sub_medicines", {id: $scope.sub_vouchers[0].id});
        }
      }
    });
    $scope.keyword = [];
  }
}]);
