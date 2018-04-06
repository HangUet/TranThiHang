app.controller("Nurses_SubVouchers_Received",
  ['$scope', '$state', 'ReceivedSubVouchers', 'ReceivedSubVoucher_EndDay', 'received_sub_vouchers',
  '$ngBootbox', '$uibModal', '$filter', 'toastr', '$rootScope', 'ReceivedSubVoucher',
  function ($scope, $state, ReceivedSubVouchers, ReceivedSubVoucher_EndDay, received_sub_vouchers,
    $ngBootbox, $uibModal, $filter, toastr, $rootScope, ReceivedSubVoucher) {
  $scope.sub_vouchers = received_sub_vouchers;
  console.log($scope.sub_vouchers);
  if(($state.current.name === 'main.received_sub_vouchers') && $scope.sub_vouchers.length > 0) {
    $state.go("main.received_sub_vouchers.sub_medicines", {id: $scope.sub_vouchers[0].id});
  }
  $scope.showCreateSubVoucherModal = function() {
    NProgress.start();
    var modalInstance = $uibModal.open({
      templateUrl: "/templates/sub_vouchers/received/new.html",
      size: 'full',
      backdrop: 'static',
      keyboard: false,
      resolve: {
        day_medicines: ['ReceivedSubVoucher_DayMedicine', '$stateParams',
          function(ReceivedSubVoucher_DayMedicine, $stateParams) {
          return ReceivedSubVoucher_DayMedicine.index().then(function(response) {
            return response.data.data;
          });
        }]
      },
      controller: ['$scope', '$rootScope', '$uibModalInstance', 'toastr', '$state',
                   'ReceivedSubVouchers', 'day_medicines',
        function($scope, $rootScope, $uibModalInstance, toastr, $state,
                 ReceivedSubVouchers, day_medicines) {
        NProgress.done();
        $scope.new_sub_voucher = {"sub_medicines": [{}]};
        $scope.new_sub_voucher.typee = 2;
        $scope.available_sub_medicines = day_medicines;
        $scope.available_sub_medicines_origin = day_medicines;
        console.log($scope.available_sub_medicines)
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
          console.log($scope.new_sub_voucher.sub_medicines);
          $scope.available_sub_medicines = []
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

        $scope.createReceivedSubVoucher = function () {
          NProgress.start();
          ReceivedSubVoucher_EndDay.create($scope.new_sub_voucher).success(function (response) {
            NProgress.done();
            if(response.code == 1) {
              $state.reload();
              $uibModalInstance.dismiss();
              toastr.success(response.message);
              $state.go("main.received_sub_vouchers", {}, { reload: true });
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
      templateUrl: "/templates/sub_vouchers/received/advance_search.html",
      size: 'lg',
      resolve: {
        keyword: $rootScope.sub_voucher_search
      },
      controller: ['$scope', '$uibModalInstance', 'toastr', '$state', 'API', 'keyword',
        function ($scope, $uibModalInstance, toastr, $state, API, keyword) {
          NProgress.done();
          $scope.keyword = keyword;

          $scope.search = function() {
            ReceivedSubVoucher.search($scope.keyword).success(function(response) {
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

        if(($state.current.name === 'main.received_sub_vouchers') && $scope.sub_vouchers.length) {
          $state.go("main.received_sub_vouchers.sub_medicines", {id: $scope.sub_vouchers[0].id});
        }
      }
    });
    $scope.keyword = [];
  }
}]);
