app.controller("Storekeeper_Voucher_Received",
  ['$scope', '$state', 'MedicineList', 'ReceivedVoucher_ImportNew', 'vouchers',
  '$uibModal', '$rootScope', '$ngBootbox', '$filter', 'toastr', 'Manufacturer',
  'Provider', 'ReceivedVoucher', function ($scope, $state, MedicineList,
  ReceivedVoucher_ImportNew, vouchers, $uibModal, $rootScope, $ngBootbox,
  $filter, toastr, Manufacturer, Provider, ReceivedVoucher) {

  $scope.vouchers = vouchers;

  if($state.current.name.match('main.received_vouchers') && $scope.vouchers.length) {
    $state.go("main.received_vouchers.medicines", {id: $scope.vouchers[0].id});
  }

  $scope.showCreateVoucherModal = function() {
    NProgress.start();
    var modalInstance = $uibModal.open({
      templateUrl: "/templates/vouchers/received/create.html",
      size: 'full',
      backdrop: 'static',
      keyboard: false,
      resolve: {
        list_medicines: ['MedicineList', function(MedicineList) {
          return MedicineList.index().then(function(response) {
            return response.data.data;
          });
        }],
        providers: ['Provider', '$stateParams',
          function(Provider, $stateParams) {
          return Provider.index().then(function(response) {
            return response.data.data;
          });
        }],
        manufacturers: ['Manufacturer', '$stateParams',
          function(Manufacturer, $stateParams) {
          return Manufacturer.index().then(function(response) {
            return response.data.data;
          });
        }],
      },
      controller: ['$scope', '$rootScope', 'list_medicines', '$uibModalInstance', 'toastr',
        '$state', 'providers', 'manufacturers',
        function($scope, $rootScope, list_medicines, $uibModalInstance, toastr,
        $state, providers, manufacturers) {
        NProgress.done();

        $scope.providers = providers;
        $scope.manufacturers = manufacturers;
        $scope.new_voucher = {typee: "import_from_distributor",
                              agency_sender_receiver: $rootScope.currentUser.agency.name,
                              medicines: [{}]};

        $scope.available_medicines = list_medicines;
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

        $scope.reloadInfoMedicine = function(avaiable_medicine, idx) {
          $scope.new_voucher.medicines[idx] = JSON.parse(JSON.stringify(avaiable_medicine));
        }

        $scope.removeMedicine = function(index) {
          $scope.new_voucher.medicines.splice(index, 1);
        }

        $scope.addMoreMedicine = function () {
          $scope.new_voucher.medicines.push({});
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
          ReceivedVoucher_ImportNew.create($scope.new_voucher).success(function (response) {
            NProgress.done();
            if(response.code == 1) {
              $state.reload();
              $uibModalInstance.dismiss();
              toastr.success(response.message);
              $state.go("main.received_vouchers", {}, {reload: true});
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
      $scope.vouchers = vouchers;
      $rootScope.voucher_search = {
        "typee": "",
        "status": "",
        "code": "",
        "type": "",
        "date_end": "",
        "date_start": "",
        "provider": ""
      }
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
