app.controller("Storekeeper_Voucher_ReceivedEndDay",
  ['$scope', '$state', 'ReceivedEndDayVoucher_EndDay', 'vouchers',
  '$uibModal', '$rootScope', '$ngBootbox', '$filter', 'toastr',
  'ReceivedVoucher', function ($scope, $state,
  ReceivedEndDayVoucher_EndDay, vouchers, $uibModal, $rootScope, $ngBootbox,
  $filter, toastr, ReceivedVoucher) {

  $scope.vouchers = vouchers;

  if($state.current.name.match('main.received_end_day_vouchers') && $scope.vouchers.length) {
    $state.go("main.received_end_day_vouchers.medicines", {id: $scope.vouchers[0].id});
  }

  $scope.showCreateVoucherModal = function() {
    NProgress.start();
    var modalInstance = $uibModal.open({
      templateUrl: "/templates/vouchers/received_end_day/create.html",
      size: 'full',
      backdrop: 'static',
      keyboard: false,
      resolve: {
        list_medicines: ['Selections_Medicine', function(Selections_Medicine) {
          return Selections_Medicine.index("allocation").then(function(response) {
            return response.data.data;
          });
        }],
      },
      controller: ['$scope', '$rootScope', 'Selections_Medicine', 'list_medicines', '$uibModalInstance', 'toastr', '$state',
        function($scope, $rootScope, Selections_Medicine, list_medicines, $uibModalInstance, toastr, $state) {
        NProgress.done();

        $scope.new_voucher = {typee: "import_end_day",
                              agency_sender_receiver: $rootScope.currentUser.agency.name,
                              medicines: [{}]};

        $scope.available_medicines = [{}];
        $scope.available_medicines.unshift({name: 'Tên thuốc', composition: 'Thành phần',
          concentration: 'Nồng độ', packing: 'Đóng gói', production_batch: 'Số lô',
          provider: 'Nhà phân phối', source: "Nguồn thuốc", expiration_date: 'Ngày hết hạn',
          remaining: 'SL tồn', manufacturer: 'Nhà sản xuất', unit: 'Đơn vị tính'});
        $scope.available_medicines_origin = list_medicines;

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

        var reload_select = function() {
          $scope.available_medicines = [];
          $scope.available_medicines.unshift({name: 'Tên thuốc', composition: 'Thành phần',
            concentration: 'Nồng độ', unit: 'Đơn vị tính', packing: 'Đóng gói', production_batch: 'Số lô',
            provider: 'Nhà phân phối', source: "Nguồn thuốc", expiration_date: 'Ngày hết hạn',
            remaining: 'SL tồn', manufacturer: 'Nhà sản xuất'});
          for (var i = 0; i < $scope.available_medicines_origin.length; i++) {
            var has_medicine = false;
            for (var j = 0; j < $scope.new_voucher.medicines.length; j++) {
              if ($scope.available_medicines_origin[i].id == $scope.new_voucher.medicines[j].id) {
                has_medicine = true;
                break;
              }
            }
            if (!has_medicine) {
              if ((toDate($scope.available_medicines_origin[i].init_date.toString()) <= toDate($scope.new_voucher.datee.toString())) ) {
                $scope.available_medicines.push($scope.available_medicines_origin[i]);
              }
            }
          }
        }

        $scope.reloadInfoMedicine = function(avaiable_medicine, idx) {
          $scope.new_voucher.medicines[idx] = JSON.parse(JSON.stringify(avaiable_medicine));
          reload_select();
        }

        $scope.removeMedicine = function(index) {
          $scope.new_voucher.medicines.splice(index, 1);
          reload_select();
        }

        $scope.addMoreMedicine = function () {
          $scope.new_voucher.medicines.push({});
          reload_select();
        }

        $scope.new_voucher.total_money = 0;
        $scope.sum_money_cacl = function () {
          if ($scope.new_voucher.medicines == undefined || $scope.new_voucher.medicines.length == 0) {
            $scope.new_voucher.total_money = 0;
          }
          $scope.new_voucher.total_money = 0;
          for (var i in $scope.new_voucher.medicines) {
            $scope.new_voucher.total_money += ($scope.new_voucher.medicines[i].price || 0) * ($scope.new_voucher.medicines[i].number || 0);
          }
        }

        $scope.createVoucherReceived = function () {
          NProgress.start();
          ReceivedEndDayVoucher_EndDay.create($scope.new_voucher).success(function (response) {
            NProgress.done();
            if(response.code == 1) {
              $state.reload();
              $uibModalInstance.dismiss();
              toastr.success(response.message);
              $state.go("main.received_end_day_vouchers", {}, {reload: true});
            } else {
              toastr.error(response.message);
            }
          });
        }

        $scope.getSelectionMedicine = function () {
          $scope.new_voucher.medicines = [{}];

          Selections_Medicine.index("allocation", $scope.new_voucher.datee.split("/").reverse().join("-")).then(function(response) {
            $scope.available_medicines = response.data.data;
            $scope.available_medicines_origin = response.data.data;
            $scope.available_medicines.unshift({name: 'Tên thuốc', composition: 'Thành phần',
              concentration: 'Nồng độ', packing: 'Đóng gói', production_batch: 'Số lô',
              provider: 'Nhà phân phối', source: "Nguồn thuốc", expiration_date: 'Ngày hết hạn',
              remaining: 'SL tồn', manufacturer: 'Nhà sản xuất', unit: 'Đơn vị tính'});
          })
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

  $scope.keyword = $state.params.keyword;

  $scope.advanceSearch = false;

  $scope.search = function() {
    if ($scope.advanceSearch == true) {
      $state.go($state.current, {keyword: $scope.keyword});
      $scope.advance_search = false;
      $rootScope.voucher_search = {
        "typee": "",
        "status": "",
        "code": "",
        "type": "",
        "date_end": "",
        "date_start": "",
        "provider": ""
      }
    } else {
      $state.go($state.current, {keyword: $scope.keyword});
    }
  }

  $rootScope.voucher_search = {
    "typee": "",
    "status": "",
    "code": "",
    "type": "",
    "date_end": "",
    "date_start": "",
    "provider": ""
  }

  $scope.advance_search = false;

  $scope.showSearchModal = function() {
    NProgress.start();
    var modalInstance = $uibModal.open({
      templateUrl: "/templates/vouchers/received/advance_search.html",
      size: 'lg',
      resolve: {
        providers: ['Provider', '$stateParams',
          function(Provider, $stateParams) {
          return Provider.index().then(function(response) {
            return response.data.data;
          });
        }],
        keyword: $rootScope.voucher_search
      },
      controller: ['$scope', '$uibModalInstance', 'toastr', '$state', 'API', 'providers', 'keyword',
        function ($scope, $uibModalInstance, toastr, $state, API, providers, keyword) {
        NProgress.done();
        $scope.keyword = keyword;

        $scope.providers = providers;

        $scope.search = function() {
          ReceivedVoucher.search($scope.keyword).success(function(response) {
            data = response;
            $uibModalInstance.close(data);
          });
        }
        $scope.reset = function() {
          $scope.keyword = {
            "typee": "",
            "status": "",
            "code": "",
            "type": "",
            "date_end": "",
            "date_start": "",
            "provider": ""
          };
          $rootScope.voucher_search = $scope.keyword;
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
        $scope.vouchers = response.data;

        if($scope.vouchers.length > 0) {
          $scope.keyword = "";
          $state.go("main.received_vouchers.medicines", {id: $scope.vouchers[0].id});
        }
      }
    });
  }
}]);
