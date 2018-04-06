app.controller("Nurses_VoucherMedicineDeliveryController",
  ['$scope', '$state', 'API', 'vouchers', 'voucher_medicines', '$ngBootbox', '$filter', 'toastr',
  function ($scope, $state, API, vouchers, voucher_medicines, $ngBootbox, $filter, toastr) {
  $scope.vouchers = vouchers.data;
  $scope.voucher_medicines = voucher_medicines.data;
  $scope.showAcceptVoucherModal = function() {
    $ngBootbox.confirm($filter("translator")("confirm_accept", "main") + '?').then(function() {
      NProgress.start();
      API.AcceptVoucher($scope.vouchers.id).success(function(response) {
        NProgress.done();
        if(response.code == 1) {
          $state.reload($state.current);
          toastr.success(response.message);
        } else {
          toastr.error(response.message);
        }
      });
    });
  }
}]);
