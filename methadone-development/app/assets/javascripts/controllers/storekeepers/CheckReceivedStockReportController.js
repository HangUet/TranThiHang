app.controller("Storekeeper_CheckReceivedStockReportController", ['$scope', '$state',
'allInvoiceNumber', '$uibModal', 'providers', function ($scope, $state, allInvoiceNumber, $uibModal, providers) {

  $scope.providers = providers;

  $scope.voucher = {};
  $scope.councils = {"data": [{}]};

  $scope.reloadInvoiceNumber = function() {
    if($scope.voucher.invoice_number) {
      $scope.voucher.invoice_number = '';
    }
    allInvoiceNumber.index($scope.voucher).success(function(response) {
      $scope.invoice_numbers = response.data;
    });
  }

  $scope.addCouncil = function() {
    $scope.councils.data.push({});
  }

  $scope.deleteCouncil = function(index) {
    $scope.councils.data.splice(index, 1);
  }
  $scope.showPrintModal = function(voucher, council) {
    NProgress.start();
    var modalInstance = $uibModal.open({
      templateUrl: "/templates/storekeeper/check_received_stock_report/print.html",
      size: 'lg',
      resolve: {
        medicines: ['allInvoiceNumber', '$stateParams', function(DoctorAPI, $stateParams) {
          return allInvoiceNumber.show(voucher).then(function(response) {
            return response.data;
          });
        }],
        voucher: $scope.voucher,
        councils: $scope.councils
      },
      controller: ['$scope', '$uibModalInstance', 'toastr', '$state', 'voucher',
        'councils', 'medicines', function ($scope, $uibModalInstance, toastr,
        $state, voucher, councils, medicines) {
        NProgress.done();
        $scope.close = function() {
          $uibModalInstance.dismiss();
        }
        $scope.medicines = medicines;
        $scope.voucher = voucher;
        $scope.datee = $scope.voucher.datee.split("/");
        $scope.currentDate = currentDate;
        $scope.currentMonth = currentMonth;
        $scope.currentYear = currentYear
        $scope.councils = councils;

        $scope.check = 0;
        if($scope.voucher.provider) {
          if($scope.voucher.invoice_number) {
            $scope.check = 1;
          } else {
            $scope.check = 2;
          }
        }

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
