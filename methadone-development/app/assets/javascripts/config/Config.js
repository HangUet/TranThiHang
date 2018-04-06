app.config(['$locationProvider', '$httpProvider', function($locationProvider, $httpProvider) {
  $locationProvider.html5Mode(true);
  $httpProvider.interceptors.push(["$injector", "toastr", '$rootScope', '$window', '$filter',
    function ($injector, toastr, $rootScope, $window, $filter) {
    return {
      responseError: function (rejection) {
        console.log(rejection);
        console.log("haha")
        if (rejection.status == 401) {
          $rootScope.currentUser = null;
          $window.localStorage.clear();
          $injector.get('$state').go("signin", {}, {reload: true, inherit: false});
          location.reload();
        } else {
          if($(".toast.toast-error").length == 0)
            toastr.error((rejection.data && rejection.data.message) || $filter("translator")("connection_error", "main"));

        }
      },
      request: function(config) {
        if(config.url.match(/templates.*html$/)) {
          config.url = config.url + '?v=' + APP_VERSION;
        }
        return config;
      }
    };
  }]);
}]);
