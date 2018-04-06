// angular.module("AccountApp")
//   .config(['$stateProvider', '$urlRouterProvider',
//     function ($stateProvider, $urlRouterProvider) {
//   $stateProvider
//   .state('main.daily_report', {
//     url: "/admin/daily_report",
//     templateUrl: "/templates/admin/reports/daily_report.html",
//     controller: "AdminDailyReportController",
//     resolve: {
//       data: ['DailyReport', function(DailyReport) {
//         return DailyReport.index().then(function(response) {
//           return response.data.data;
//         });
//       }]
//     },
//     requireLogin: true,
//     requireRoles: ["admin"]
//   })
// }]);
