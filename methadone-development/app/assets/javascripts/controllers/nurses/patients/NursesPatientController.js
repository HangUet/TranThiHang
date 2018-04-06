app.controller("Nurses_PatientController", ['$scope', '$state', 'patients', 'toastr',
  'provinces', 'API', '$filter', function ($scope, $state, patients, toastr,
    provinces, API, $filter) {
  $scope.patients = patients;
  $scope.provinces = provinces;
  $scope.patient = {};
  $scope.statuses = [{name: "wait", value: 0}, {name: "allocated", value: 1}, {name: "taked", value: 2}];
  $scope.prescription_status= [{name: "maintain", value: 1}, {name: "detect_the_dose", value: 2},
    {name: "reduce_the_dose", value: 3}];
  if($scope.patients.total && $state.current.name == 'main.nurse_patients') {
    $state.go("main.nurse_patients.medicine_allocation", {id: $scope.patients.data[0].id});
  }

  if($scope.patients.total && $state.params.keyword && $state.params.gofirst != 0) {
    $state.go("main.nurse_patients.medicine_allocation", {id: $scope.patients.data[0].id});
  }
  $scope.currentPage = $state.params.page || 1;
  $scope.keyword = $state.params.keyword;
  $scope.search = function() {
    if ($scope.advanceSearch == true) {
      $state.go($state.current, {keyword: $scope.keyword, type: $scope.type, page: 1}, {reload: true});
    } else {
      $state.go($state.current, {keyword: $scope.keyword, type: $scope.type, page: 1});
    }
  }
  $scope.pageChanged = function() {
    if ($scope.advanceSearch == true) {
      NProgress.start();
      API.advanceNurseSearch($scope.patient, $scope.currentPage).success(function (response) {
        NProgress.done();
        if(response.code == 1) {
          $scope.patients = response;
          $scope.advanceSearch = true;
          $('#myModal').modal('hide');
          if($scope.patients.total && $state.current.name == 'main.nurse_patients') {
            $state.go("main.nurse_patients.medicine_allocation", {id: $scope.patients.data[0].id});
          }
        } else {
          $('#myModal').modal('hide');
        }
      });
    } else {
      $state.go($state.current, {page: $scope.currentPage});
    }
  }
  $scope.advanceSearch = false;
  $scope.loadDistrict = function(province_id) {
    API.getDistricts(province_id).success(function(response) {
      $scope.districts = response.data;
    });
  }
  $scope.reloadDistrict = function(province_id) {
    $scope.patient.district_id = "";
    $scope.patient.ward_id = "";
    $scope.wards = [];
    $scope.loadDistrict(province_id);
  }
  $scope.loadWard = function(district_id) {
    API.getWards(district_id).success(function(response) {
      $scope.wards = response.data;
    });
  }
  $scope.reloadWard = function(province_id) {
    $scope.patient.ward_id = "";
    $scope.loadWard(province_id);
  }
  $scope.loadDistrictResident = function(province_id) {
    API.getDistricts(province_id).success(function(response) {
      $scope.resident_districts = response.data;
    });
  }
  $scope.loadWardResident = function(district_id) {
    API.getWards(district_id).success(function(response) {
      $scope.resident_wards = response.data;
    });
  }
  $scope.reloadWardResident = function(province_id) {
    $scope.patient.resident_ward_id = "";
    $scope.loadWardResident(province_id);
  }
  $scope.reloadDistrictResident = function(province_id) {
    $scope.patient.resident_district_id = "";
    $scope.patient.resident_ward_id = "";
    $scope.wards = [];
    $scope.loadDistrictResident(province_id);
  }

  $scope.reloadAddress = function() {
    if ($scope.patient.type_address == undefined) {
      $scope.patient.province_id = undefined;
      $scope.patient.district_id = undefined;
      $scope.patient.ward_id = undefined;
    }
  }

  $scope.searchPatient = function() {
    NProgress.start();
    API.advanceNurseSearch($scope.patient).success(function (response) {
      NProgress.done();
      if(response.code == 1) {
        $scope.patients = response;
        $scope.advanceSearch = true;
        $('#myModal').modal('hide');
        if($scope.patients.length > 0) {
          $state.go("main.nurse_patients.medicine_allocation", {id: $scope.patients.data[0].id});
        }
      } else {
        $('#myModal').modal('hide');
      }
    });
  }

  $scope.searchAndExport = function() {
    NProgress.start();
    API.searchAndNurseExport($scope.patient).success(function (response) {
      NProgress.done();
      var blob = new Blob([response], { type: "attachment/xlsx" });
      saveAs(blob, "Danh_sach.xlsx");
      toastr.success($filter("translator")("export_excel", "main"));
    });
  }
}]);
