app.controller("Doctor_PatientsController",['$scope', '$state', '$filter', 'toastr', 'patients',
 '$ngBootbox', '$rootScope', 'provinces', 'ethnicities',  'issuingAgencies', 'API',
  function ($scope, $state, $filter, toastr, patients, $ngBootbox, $rootScope, provinces, ethnicities, issuingAgencies, API) {
  $scope.patients = patients;
  $scope.provinces = provinces;
  $scope.ethnicities = ethnicities;
  if ($rootScope.currentUser.role == "admin") {
    $scope.issuingAgencies = issuingAgencies;
    $scope.patient = {};
  }
  $scope.prescription_status= [{name: "maintain", value: 1}, {name: "detect_the_dose", value: 2},
    {name: "reduce_the_dose", value: 3}];
  $scope.advanceSearch = false;
  $scope.identification_types = [{id:0 , name:'identity_card'}, {id:1 , name:'household_registration_book'},
    {id:2, name:'driving_license'}, {id:3, name:'passport'}];
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

  if(($state.current.name === 'main.patients') && $scope.patients.total) {
    $state.go("main.patients.action.detail.executive_info", {id: $scope.patients.data[0].id});
  }
  if($state.current.name != 'main.patients.new' && $state.params.keyword && $scope.patients.total) {
    $state.go("main.patients.action.detail.executive_info", {id: $scope.patients.data[0].id});
  }
  $scope.currentPage = $state.params.page || 1;
  $scope.keyword = $state.params.keyword;
  $scope.type = $state.params.type || null;
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
      API.advanceSearch($scope.patient, $scope.currentPage).success(function (response) {
        NProgress.done();
        if(response.code == 1) {
          if ($rootScope.currentUser.role == "admin") {
            $scope.agency_name = $scope.findAgencyById($scope.patient.agency);
          }
          $scope.patients = response;
          $state.go("main.patients.action.detail.executive_info", {id: $scope.patients.data[0].id});
        }
      });
    } else {
      $state.go($state.current, {page: $scope.currentPage, type: $scope.type});
    }
  }
  $scope.filter_patient = function (type) {
    $state.go("main.patients", {type: type})
  }

  $scope.all_patients = function () {
    $state.go($state.current, {type: null})
  }

  $scope.check_change_agency = function(patient) {
    API.getPatient(patient.id).success(function (response) {
      if(response.code == 1 && response.data.pending_change_agency) {
        if(response.data.pending_change_agency.status == 'pending') {
          toastr.error("Bệnh nhân đang chờ chuyển cơ sở");
          $state.go("main.patients.action.detail.executive_info", {id: patient.id}, {reload: true});
        }
      }
    })
  }

  $scope.searchPatient = function() {
    NProgress.start();
    API.advanceSearch($scope.patient).success(function (response) {
      NProgress.done();
      if(response.code == 1) {
        if ($rootScope.currentUser.role == "admin") {
            $scope.agency_name = $scope.findAgencyById($scope.patient.agency);
        }
        $scope.patients = response;
        $scope.advanceSearch = true;
        $('#myModal').modal('hide');
        if($scope.patients.length > 0) {
          $state.go("main.patients.action.detail.executive_info", {id: $scope.patients.data[0].id});
        }
      } else {
        $('#myModal').modal('hide');
      }
    });
  }

  $scope.searchAndExport = function() {
    NProgress.start();
    API.searchAndExport($scope.patient).success(function (response) {
      NProgress.done();
      var blob = new Blob([response], { type: "attachment/xlsx" });
      saveAs(blob, "Danh_sach.xlsx");
      toastr.success($filter("translator")("export_excel", "main"));
    });
  }

  $scope.showDeletePatientModal = function(patient) {
    $ngBootbox.confirm($filter("translator")("confirm_delete", "main") + ' "' + patient.name + '"?').then(function() {
      NProgress.start();
      API.deletePatient(patient.id).success(function(response) {
        NProgress.done();
        if(response.code == 1) {
          $state.go("main.patients", {keyword: $scope.keyword, page: $scope.currentPage, type: $scope.type}, {reload: true});
          toastr.success(response.message);
        } else {
          toastr.error(response.message);
        }
      });
    });
  }

  $scope.findAgencyById = function(id) {
    for (var i = 0; i < $scope.issuingAgencies.length - 1; i++) {
      if ($scope.issuingAgencies[i].id == id) {
        return $scope.issuingAgencies[i].name;
      }
    }
  }
}]);
