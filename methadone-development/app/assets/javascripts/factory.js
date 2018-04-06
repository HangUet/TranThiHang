var factory_app = angular.module("app.factory", [])
.factory("AvatarUploader", ["$http", "$rootScope", "$window", function ($http, $rootScope, $window) {
  return {
    upload: function(file) {
      var formData = new FormData();
      formData.append('file', file);
      return $http.post("/api/v1/avatar_uploaders/", formData, { headers: { 'Content-Type': undefined }});
    }
  }
}]);
