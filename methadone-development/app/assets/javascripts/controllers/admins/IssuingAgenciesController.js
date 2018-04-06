app.controller("Admin_IssuingAgenciesController", ['$scope', '$state', 'issuing_agencies', '$uibModal', '$ngBootbox', 'API', 'toastr',
  '$filter', function ($scope, $state, issuing_agencies, $uibModal, $ngBootbox, API, toastr, $filter) {
  $scope.issuing_agencies = issuing_agencies.data;
  $scope.page = issuing_agencies.page;
  $scope.keyword = $state.params.keyword;
  $scope.currentPage = $state.params.page || 1;
  $scope.pageChanged = function() {
    $state.go($state.current, {page: $scope.currentPage});
  }
  $scope.showCreateIssuingAgencyModal = function() {
    NProgress.start();
    var modalInstance = $uibModal.open({
      templateUrl: "/templates/admin/issuing_agencies/create.html",
      size: 'lg',
      backdrop: 'static',
      keyboard: false,
      resolve: {
        provinces: ['API', function(API) {
          return API.getProvinces().then(function(response) {
            return response.data.data;
          });
        }]
      },
      controller: ['$scope', '$uibModalInstance', 'toastr', '$state', 'provinces', 'API',
        function($scope, $uibModalInstance, toastr, $state, provinces, API) {
        NProgress.done();
        $scope.provinces = provinces;
        $scope.issuing_agency = {}
        $scope.loadDistrict = function(province_id) {
          API.getDistricts(province_id).success(function(response) {
            $scope.districts = response.data
          });
        }

        $scope.reloadDistrict = function(province_id) {
          $scope.issuing_agency.district_id = "";
          $scope.issuing_agency.ward_id = "";
          $scope.wards = [];
          $scope.loadDistrict(province_id);
        }

        $scope.loadWard = function(district_id) {
          API.getWards(district_id).success(function(response) {
            $scope.wards = response.data
          });
        }

        $scope.reloadWard = function(district_id) {
          $scope.issuing_agency.ward_id = "";
          $scope.loadWard(district_id);
        }

        $scope.createIssuingAgency = function () {
          NProgress.start();
          API.createIssuingAgency($scope.issuing_agency).success(function (response) {
            NProgress.done();
            if(response.code == 1) {
              $state.reload($state.current);
              $uibModalInstance.dismiss();
              toastr.success(response.message);
            } else {
              toastr.error(response.message);
            }
          });
        }
        $scope.close = function () {
          $uibModalInstance.dismiss();
        }
      }]
    });
  }
  $scope.showEditIssuingAgencyModal = function(issuing_agency_id) {
    NProgress.start();
    var modalInstance = $uibModal.open({
      templateUrl: "/templates/admin/issuing_agencies/edit.html",
      backdrop: 'static',
      keyboard: false,
      resolve: {
        edit_issuing_agency: ["API", function(API) {
          return API.getOneIssuingAgency(issuing_agency_id).then(function(response) {
            return response.data;
          });
        }],
        provinces: ['API', function(API) {
          return API.getProvinces().then(function(response) {
            return response.data.data;
          });
        }]
      },
      size: 'lg',
      controller: ['$scope', 'edit_issuing_agency', 'provinces', '$uibModalInstance', 'toastr', '$state', 'API',
        function ($scope, edit_issuing_agency, provinces, $uibModalInstance, toastr, $state, API) {
        NProgress.done();
        $scope.edit_issuing_agency = edit_issuing_agency.data;
        $scope.provinces = provinces;
        $scope.loadDistrict = function(province_id) {
          API.getDistricts(province_id).success(function(response) {
            $scope.districts = response.data
          });
        }

        $scope.reloadDistrict = function(province_id) {
          $scope.edit_issuing_agency.district_id = "";
          $scope.edit_issuing_agency.ward_id = "";
          $scope.wards = [];
          $scope.loadDistrict(province_id);
        }

        $scope.loadWard = function(district_id) {
          API.getWards(district_id).success(function(response) {
            $scope.wards = response.data
          });
        }

        $scope.reloadWard = function(district_id) {
          $scope.edit_issuing_agency.ward_id = "";
          $scope.loadWard(district_id);
        }

        $scope.loadDistrict($scope.edit_issuing_agency.province_id);
        $scope.loadWard($scope.edit_issuing_agency.district_id);

        $scope.editIssuingAgency = function () {
          NProgress.start();
          API.updateIssuingAgency(issuing_agency_id, $scope.edit_issuing_agency).success(function (response) {
            NProgress.done();
            if(response.code == 1) {
              $state.reload($state.current);
              $uibModalInstance.dismiss();
              toastr.success(response.message);
            } else {
              toastr.error(response.message);
            }
          });
        }
        $scope.close = function () {
          $uibModalInstance.dismiss();
        }
      }]
    });
  }

  $scope.showDeleteIssuingAgencyModal = function(issuing_agency) {
    $ngBootbox.confirm($filter("translator")("confirm_delete", "main") + ' "' + issuing_agency.name + '"?').then(function() {
      NProgress.start();
      API.deleteIssuingAgency(issuing_agency.id).success(function(response) {
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

  $scope.search = function() {
    $state.go($state.current, {keyword: $scope.keyword});
  }
}]);
