app.controller("Nurses_SubMedicines",
  ['$scope', '$state', 'sub_medicines', 'SubMedicine',
  function ($scope, $state, sub_medicines, SubMedicine) {
  $scope.sub_medicines = sub_medicines;
}]);
