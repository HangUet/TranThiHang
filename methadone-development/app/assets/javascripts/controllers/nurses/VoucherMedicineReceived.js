app.controller("Nurses_VoucherMedicineReceivedController",
  ['$scope', '$state', 'API', 'vouchers', 'voucher_medicines_import', 'voucher_medicines', '$ngBootbox', '$filter', 'toastr',
  function ($scope, $state, API, vouchers, voucher_medicines_import, voucher_medicines, $ngBootbox, $filter, toastr) {
  $scope.vouchers = vouchers.data;
  if($scope.vouchers && $scope.vouchers.status == '0') {
    $scope.voucher_medicines = voucher_medicines.data;
  } else {
    $scope.voucher_medicines = voucher_medicines_import.data;
  }
  $scope.showAcceptVoucherModal = function() {
    $ngBootbox.confirm($filter("translator")("confirm_accept_import", "main") + '?').then(function() {
      NProgress.start();
      API.AcceptVoucherImport($scope.voucher_medicines).success(function(response) {
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
