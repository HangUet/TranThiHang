app.controller("AdminReportSummaryController", ['$scope', '$state', '$uibModal',
  '$ngBootbox', 'API', 'toastr', '$filter', 'provinces', function ($scope, $state, $uibModal,
    $ngBootbox, API, toastr, $filter, provinces) {

    $scope.report = {};
    $scope.check = false;
    $scope.data = [];
    $scope.type = "";
    $scope.provinces = provinces;
    $scope.issuing_agencies = [];

    $scope.createReport = function() {
      NProgress.start();
      API.getSummaryReport($scope.report.type, $scope.report.from_date,
        $scope.report.to_date, $scope.report.province_id,
        $scope.report.district_id, $scope.report.ward_id,
        $scope.report.issuing_agency_id).success(function (response) {
        NProgress.done();
        if(response.code == 1) {
          $scope.data = response.data;
          $scope.type = $scope.report.type;
          if($scope.data) {
            $scope.check = true;
          }
        } else {
          toastr.error(response.message);
        }
      });
    }

    $scope.loadDistrict = function(province_id) {
      API.getDistricts(province_id).success(function(response) {
        $scope.districts = response.data;
      });

      API.getIssuingAgenciesOption(province_id).success(function(response) {
        $scope.issuing_agencies = response.data;
      });
    }

    $scope.reloadDistrict = function(province_id) {
      $scope.report.district_id = "";
      $scope.report.ward_id = "";
      $scope.wards = [];
      $scope.loadDistrict(province_id);
    }

    $scope.loadWard = function(district_id) {
      API.getWards(district_id).success(function(response) {
        $scope.wards = response.data;
      });

      API.getIssuingAgenciesOption(null, district_id).success(function(response) {
        $scope.issuing_agencies = response.data;
      });
    }

    $scope.reloadWard = function(district_id) {
      $scope.report.ward_id = "";
      $scope.loadWard(district_id);
    }

    $scope.reloadIssuingAgency = function(ward_id) {
      API.getIssuingAgenciesOption(null, null, ward_id).success(function(response) {
        $scope.issuing_agencies = response.data;
      });
    }


    $scope.export_excel = function() {
      NProgress.start();
      API.getSummaryReportExcel($scope.report.type, $scope.report.from_date,
        $scope.report.to_date, $scope.report.province_id,
        $scope.report.district_id, $scope.report.ward_id,
        $scope.report.issuing_agency_id).success(function (response) {
        NProgress.done();
        var blob = new Blob([response], { type: "attachment/xlsx" });
        saveAs(blob, "Bao_cao.xlsx");
        toastr.success("Xuất báo cáo thành công");
      });
    }

}]);
