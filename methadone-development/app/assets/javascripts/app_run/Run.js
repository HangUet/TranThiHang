app.run(['$state', '$window', '$http', '$rootScope', 'Auth', 'API', function ($state, $window, $http, $rootScope, Auth, API) {
  NProgress.configure({
    template: '<div class="bar" role="bar"><div class="peg"></div></div>\
              <div class="page-spinner-bar">\
                  <div class="bounce1"></div>\
                  <div class="bounce2"></div>\
                  <div class="bounce3"></div>\
              </div>'
  });
  NProgress.start();
  Layout.initSidebar($state);
  $rootScope.language = $window.localStorage.language || 'vi';

  if($window.localStorage.token) {
    $rootScope.currentUser = JSON.parse($window.localStorage.user);
    $http.defaults.headers.common["Authorization"] = 'Bearer ' + $window.localStorage.token;
    $state.go("main");
  } else {
    $state.go("signin");
  }

  $rootScope.changeLanguage = function(language) {
    $rootScope.language = language;
    $window.localStorage.language = language;
  }

  $rootScope.$on('$stateChangeStart', function (event, toState, toParams) {
    NProgress.start();
    if (toState.requireLogin && !Auth.isSignedIn()) {
      event.preventDefault();
      $state.go("signin");
    }
    if($rootScope.currentUser) {
      if (toState.requireRoles && toState.requireRoles.indexOf($rootScope.currentUser.role) < 0) {
        event.preventDefault();
        $state.go("main");
      }
    }
  });
  $rootScope.$on('$stateChangeSuccess', function () {
    NProgress.done();
    if ($rootScope.currentUser) {
      var now = moment();
      if(!$rootScope.lastTimeLoadNotification || now.diff($rootScope.lastTimeLoadNotification, "seconds") >= 2) {
        $rootScope.lastTimeLoadNotification = now;
        API.getNotifications(1).success(function(response) {
          if(response.code == 1) {
            $rootScope.notifications = response;
          }
        });
      }
    }
  });
  $rootScope.loadMoreNotification = function() {
    if($rootScope.loadingMoreNotification || $rootScope.notifications.data.length == $rootScope.notifications.total)
      return
    $rootScope.loadingMoreNotification = true;
    API.getNotifications($rootScope.notifications.page + 1).success(function(response) {
      if(response.code == 1) {
        $rootScope.notifications.data = $rootScope.notifications.data.concat(response.data);
        $rootScope.notifications.page = response.page;
        $rootScope.loadingMoreNotification = false;
      }
    });
  }
  $rootScope.seeNotification = function(notification) {
    if(notification.status == "seen") return;
    notification.status = "seen";
    $rootScope.notifications.total_unseen--;
    API.seeNotification(notification.id);
  }
}]);
