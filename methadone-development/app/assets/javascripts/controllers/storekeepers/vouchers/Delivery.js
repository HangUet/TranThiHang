app.controller("Storekeeper_Voucher_Delivery",
  ['$scope', '$state', 'vouchers', 'DeliveryVouchers_Allocation',
   'DeliveryVouchers_Cancellations', '$uibModal', '$ngBootbox', '$filter', 'toastr',
   '$rootScope', 'DeliveryVoucher',
  function ($scope, $state, vouchers, DeliveryVouchers_Allocation,
    DeliveryVouchers_Cancellations, $uibModal, $ngBootbox, $filter, toastr,
    $rootScope, DeliveryVoucher) {
  $scope.vouchers = vouchers;

  if(($state.current.name === 'main.delivery_vouchers') && $scope.vouchers.length) {
    $state.go("main.delivery_vouchers.medicines", {id: $scope.vouchers[0].id});
  }
  $scope.showCreateVoucherModal = function() {
    NProgress.start();
    var modalInstance = $uibModal.open({
      templateUrl: "/templates/vouchers/delivery/create.html",
      size: 'full',
      backdrop: 'static',
      keyboard: false,
      resolve: {
        allMedicine: ['Selections_Medicine', function(Selections_Medicine) {
          return Selections_Medicine.index("main").then(function(response) {
            return response.data.data;
          });
        }]
      },
      controller: ['$scope', '$rootScope', '$uibModalInstance', 'toastr', '$state', 'allMedicine', 'API',
        function($scope, $rootScope, $uibModalInstance, toastr, $state, allMedicine, API) {
        NProgress.done();
        $scope.show = true;
        $scope.new_voucher = {typee: "export_allocation",
                              agency_sender_receiver: $rootScope.currentUser.agency.name,
                              "medicines": [{}]};
        $scope.available_medicines = [];
        $scope.available_medicines_origin = allMedicine;
        $scope.available_medicines.unshift({name: 'Tên thuốc', composition: 'Thành phần',
          concentration: 'Nồng độ', unit: 'Đơn vị tính', packing: 'Đóng gói', production_batch: 'Số lô',
          provider: 'Nhà phân phối', source: "Nguồn thuốc", expiration_date: 'Ngày hết hạn',
          remaining: 'SL tồn', manufacturer: 'Nhà sản xuất'});
        $scope.changed = function(typee) {
          // hien tai chi co 1 co so cap phat. kho nao co nhieu thi bo comment
          // if(typee == "export_out") {
          //   $scope.new_voucher.agency_sender_receiver = "";
          // } else
          // {
            $scope.new_voucher.agency_sender_receiver = $rootScope.currentUser.agency.name;
          // }
        }

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

        function toDate(dateStr) {
          const [day, month, year] = dateStr.split("/")
          return new Date(year, month - 1, day)
        }

        $scope.change = function() {
          $scope.$select.selected = undefined;
        }

        $scope.change_date = function() {
          reload_select();
          $scope.available_medicines_exist = ($scope.available_medicines.length > 1) ? true : false;
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

        $scope.createVoucher = function () {
          NProgress.start();
          if ($scope.new_voucher.typee == "export_allocation") {
            for (i = 0; i < $scope.new_voucher.medicines.length; i++) {
              if (toDate($scope.new_voucher.datee) < toDate($scope.new_voucher.medicines[i].init_date)) {
                $ngBootbox.alert("Có thuốc mà ngày tạo lớn hơn ngày xuất phiếu.");
                return;
              }
            }
            DeliveryVouchers_Allocation.create($scope.new_voucher).success(function (response) {
              NProgress.done();
              if(response.code == 1) {
                $state.reload();
                $uibModalInstance.dismiss();
                toastr.success(response.message);
                $state.go("main.delivery_vouchers", {}, {reload: true});
              } else {
                toastr.error(response.message);
              }
            });
          } else {
            DeliveryVouchers_Cancellations.create($scope.new_voucher).success(function (response) {
              NProgress.done();
              if(response.code == 1) {
                $state.reload();
                $uibModalInstance.dismiss();
                toastr.success(response.message);
                $state.go("main.delivery_vouchers", {}, {reload: true});
              } else {
                toastr.error(response.message);
              }
            });
          }
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
      $scope.vouchers = vouchers;
      $rootScope.voucher_search = {
        "typee": "",
        "status": "",
        "sender": "",
        "receiver": "",
        "code": "",
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
    "sender": "",
    "receiver": "",
    "code": "",
    "date_end": "",
    "date_start": "",
    "provider": ""
  }

  $scope.advance_search = false;

  $scope.showSearchModal = function() {
    NProgress.start();
    var modalInstance = $uibModal.open({
      templateUrl: "/templates/vouchers/delivery/advance_search.html",
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
          DeliveryVoucher.search($scope.keyword).success(function(response) {
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

        if(($state.current.name === 'main.delivery_vouchers') && $scope.vouchers.length) {
          $state.go("main.delivery_vouchers.medicines", {id: $scope.vouchers[0].id});
        }
      }
      $scope.keyword = [];
    });
  }
}]);
