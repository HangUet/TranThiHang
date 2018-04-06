app.controller("Doctor_EditPatientController", ['$scope', '$state', 'toastr',
  'patient', 'ethnicities', 'provinces', 'AvatarUploader', 'API', '$uibModal',
  function ($scope, $state, toastr, patient, ethnicities, provinces, AvatarUploader, API, $uibModal) {
  $scope.patient = patient;
  $scope.ethnicities = ethnicities;
  $scope.provinces = provinces;
  $scope.today = moment(TODAY).format("DD/MM/YYYY");

  $scope.identification_types = ['identity_card', 'household_registration_book',
    'driving_license', 'passport'];

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
    $scope.resident_wards = [];
    $scope.loadDistrictResident(province_id);
  }
  $scope.loadDistrict($scope.patient.province_id);
  $scope.loadWard($scope.patient.district_id);
  $scope.loadDistrictResident($scope.patient.resident_province_id);
  $scope.loadWardResident($scope.patient.resident_district_id);
  var patient_tmp = $scope.patient;
  $scope.updatePatient = function() {
    NProgress.start();
    API.updatePatient($scope.patient).success(function (response) {
      NProgress.done();
      if(response.code == 1) {
        toastr.success(response.message);
        $state.go('main.patients.action.detail.executive_info', {id: response.id}, {reload: true});
      }
      else if(response.code == 3) {
        if(response.data) {
          toastr.error(response.message);
          NProgress.start();
          var modalInstance = $uibModal.open({
            templateUrl: "/templates/patients/same_patient.html",
            size: 'full',
            backdrop: 'static',
            keyboard: false,
            controller: ['$scope', '$uibModalInstance', 'toastr', '$state', 'API', '$ngBootbox', '$filter',
              function($scope, $uibModalInstance, toastr, $state, API, $ngBootbox, $filter) {
              NProgress.done();
              $scope.same_patient = response.data;
              $scope.status = response.status;
              $scope.agency = response.agency;
              $scope.current_agency = response.current_agency;
              $scope.check_same_agency = response.check_same_agency;
              $scope.agency_id = response.agency_id;
              $scope.current_agency_id = response.current_agency_id;
              $scope.same_identification_type = response.same_identification_type;
              $scope.check_stop_treatment = response.check_stop_treatment;
              $scope.isOpen = new Array($scope.same_patient.length);

              $scope.func = function(index) {
                for(var i = 0; i < $scope.same_patient.length; i++) {
                  $scope.isOpen[i] = false;
                }
                $scope.isOpen[index] = true;
              };
              $scope.closePopover = function(index) {
                $scope.isOpen[index] = false;
              };
              $scope.dynamicPopover = {
                templateUrl: 'InforPopoverTemplate.html',
              };
              var getString = function(string) {
                if(string) {
                  return string + " - ";
                }
                return "";
              };
              var endString = function(string) {
                if(string) {
                  return string;
                }
                return "";
              };
              $scope.household = function(patient) {
                return getString(patient.household_address) + getString(patient.household_hamlet)
                + getString(patient.household_ward) + getString(patient.household_district)
                + endString(patient.household_province);
              };
              $scope.resident = function(patient){
                return getString(patient.resident_address) + getString(patient.resident_hamlet)
                + getString(patient.resident_ward) + getString(patient.resident_district)
                + endString(patient.resident_province);
              };
              $scope.createPatient = function() {
                NProgress.start();
                $scope.patient_tmp = patient_tmp;
                $ngBootbox.confirm($filter("translator")("confirm_add_patient", "main") + patient_tmp.name + '?').then(function() {
                  NProgress.start();
                  $scope.patient_tmp.same_patient = 1;
                  API.updatePatient($scope.patient_tmp).success(function (response) {
                    NProgress.done();
                    if(response.code == 1) {
                      toastr.success(response.message);
                      $state.go('main.patients.action.detail.executive_info', {id: response.id}, {reload: true});
                      $uibModalInstance.dismiss();
                    } else {
                      toastr.error(response.message);
                    }
                  });
                });
              }
              $scope.sendSamePatient = function(current_agency_id, receive_agency_id, patient_id) {
                NProgress.start();
                $ngBootbox.confirm($filter("translator")("confirm_send_patient", "main")).then(function() {
                  API.sendSamePatient(current_agency_id, receive_agency_id, patient_id).success(function (response) {
                    NProgress.done();
                    if(response.code == 1) {
                      toastr.success(response.message);
                      $state.reload();
                      $uibModalInstance.dismiss();
                    }
                  });
                });
              }
              $scope.close = function () {
                $uibModalInstance.dismiss();
                NProgress.done();
              }
            }]
          });
        }
      } else {
        toastr.error(response.message);
      }
    });
  }

  $scope.addMoreContact = function() {
    $scope.patient.contacts.push({contact_type: ""});
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
  convert = function(string) {
    if(string != '')
      return string + " - ";
    return string;
  }
  $scope.copyResidentAddrres = function(index) {
    $scope.patient.contacts[index].address = convert($scope.patient.resident_address || '')
      + convert($scope.patient.resident_hamlet || '')
      + convert(find_by_id($scope.resident_wards, $scope.patient.resident_ward_id))
      + convert(find_by_id($scope.resident_districts, $scope.patient.resident_district_id))
      + find_by_id($scope.provinces, $scope.patient.resident_province_id);
  }

  $scope.copyHousehold = function() {
    $scope.resident_districts = $scope.districts;
    $scope.resident_wards = $scope.wards;
    $scope.patient.resident_province_id = $scope.patient.province_id;
    $scope.patient.resident_district_id = $scope.patient.district_id;
    $scope.patient.resident_ward_id = $scope.patient.ward_id;
    $scope.patient.resident_hamlet = $scope.patient.hamlet;
    $scope.patient.resident_address = $scope.patient.address;
  }

  $scope.copyHouseholdAddress = function(index) {
    $scope.patient.contacts[index].address = convert($scope.patient.address || '')
      + convert($scope.patient.hamlet || '')
      + convert(find_by_id($scope.wards, $scope.patient.ward_id))
      + convert(find_by_id($scope.districts, $scope.patient.district_id))
      + find_by_id($scope.provinces, $scope.patient.province_id);
  }

  $scope.removeContact = function(index) {
    $scope.patient.contacts.splice(index, 1);
  }
  $scope.$watch("$avatar", function() {
    if($scope.$avatar){
      AvatarUploader.upload($scope.$avatar).success(function(response) {
        $scope.patient.avatar = response.data;
      });
    }
  });
}])
