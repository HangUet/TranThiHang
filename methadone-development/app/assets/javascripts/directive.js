angular.module("app.directive", [])
.directive('form', function () {
  return {
    restrict: 'E',
    link: function (scope, elem, attrs, control) {
      $(elem).on("submit", function() {
        $(this).find(":input.ng-invalid:first").focus();
      });
    }
  };
})
.directive('metisMenu', function () {
  return {
    restrict: 'A',
    link: function (scope, elem, attrs, control) {
      $(elem).metisMenu({
        activeClass: 'active'
      });
    }
  };
})
.directive('datepicker', ['$timeout', '$window', function ($timeout, $window) {
  return {
    restrict: 'A',
    require: 'ngModel',
    link: function (scope, element, attrs, ctrl) {
      function changeDate(date) {
        ctrl.$setViewValue(date);
        scope.$apply();
      }
      $timeout(function() {
        $(element).datepicker({
          format: "dd/mm/yyyy",
          language: $window.localStorage.language,
          todayHighlight: true,
          autoclose: true
        });
      }, 100);
      element.bind('blur', function() {
        if(!this.value && attrs.default) {
          this.value = attrs.default;
        }
        var $this = this;
        $timeout(function() {
          changeDate($this.value);
        }, 20);
      });
    }
  };
}])
.directive('maxdatepicker', ['$timeout', '$window', function ($timeout, $window) {
  return {
    restrict: 'A',
    require: 'ngModel',
    link: function (scope, element, attrs, ctrl) {
      function changeDate(date) {
        ctrl.$setViewValue(date);
        scope.$apply();
      }
      $timeout(function() {
        $(element).datepicker({
          format: "dd/mm/yyyy",
          language: $window.localStorage.language,
          endDate: TODAY,
          todayHighlight: true,
          autoclose: true
        });
      }, 100);
      element.bind('blur', function() {
        if(!this.value && attrs.default) {
          this.value = attrs.default;
        }
        var $this = this;
        $timeout(function() {
          changeDate($this.value);
        }, 20);
      });
    }
  };
}])
.directive('mindatepicker', ['$timeout', '$window', function ($timeout, $window) {
  return {
    restrict: 'A',
    require: 'ngModel',
    link: function (scope, element, attrs, ctrl) {
      function changeDate(date) {
        ctrl.$setViewValue(date);
        scope.$apply();
      }
      $timeout(function() {
        $(element).datepicker({
          format: "dd/mm/yyyy",
          language: $window.localStorage.language,
          startDate: scope.mindate,
          todayHighlight: true,
          autoclose: true
        });
      }, 100);
      element.bind('blur', function() {
        if(!this.value && attrs.default) {
          this.value = attrs.default;
        }
        var $this = this;
        $timeout(function() {
          changeDate($this.value);
        }, 20);
      });
    }
  };
}])
.directive('monthpicker', ['$timeout', '$window', function ($timeout, $window) {
  return {
    restrict: 'A',
    require: 'ngModel',
    link: function (scope, element, attrs, ctrl) {
      function changeDate(date) {
        ctrl.$setViewValue(date);
        scope.$apply();
      }
      $timeout(function() {
        $(element).datepicker({
          format: "mm/yyyy",
          language: $window.localStorage.language,
          autoclose: true,
          viewMode: "months",
          minViewMode: "months",
          todayHighlight: true,
          pickTime: false
        });
      }, 100);
      element.bind('blur', function() {
        if(!this.value && attrs.default) {
          this.value = attrs.default;
        }
        var $this = this;
        $timeout(function() {
          changeDate($this.value);
        }, 20);
      });
    }
  };
}])
.directive('ngModel', function(){
  return {
    restrict: 'A',
    require: 'ngModel',
    link: function(scope, elem, attrs, ctrl) {
      if(elem[0].type == "text") {
        elem.bind("input", function() {
          ctrl.$setViewValue(elem[0].value.substr(0, 255));
          ctrl.$render()
        });
      } else {
        if(elem[0].type == "number") {
          elem.bind("input", function() {
            var transformedInput = elem[0].value.replace("-", '');
            ctrl.$setViewValue(transformedInput.substring(0, 9));
            ctrl.$render()
          });
        }
      }
    }
  }
})
.directive('fileUpload', function () {
  return {
    restrict: "A",
    scope: {
      model: "="
    },
    link: function (scope, el, attrs) {
      el.bind('change', function (event) {
        var file = event.target.files.item(0);
        if (file) {
          if(attrs.multiple) {
            scope.model = scope.model || [];
            scope.model.push(file);
          } else {
            scope.model = file;
          }
          scope.$apply();
        }
      });
    }
  };
})
.directive('preview', function () {
  return {
    restrict: "A",
    scope: {
      preview: "="
    },
    link: function (scope, el, attrs) {
      scope.$watch("preview", function() {
        if(angular.isObject(scope.preview)) {
          var reader = new FileReader();
          reader.onload = function(event) {
            $(el).attr("src", event.target.result);
          }
          reader.readAsDataURL(scope.preview);
        }
      });
    }
  };
})
.directive('tooltip', function () {
  return {
    restrict: 'A',
    link: function (scope, element, attrs) {
      $(element).hover(function () {
        $(element).tooltip('show');
    }, function () {
        $(element).tooltip('hide');
      });
  }
  };
})
.directive('equalTo', function () {
  return {
    restrict: 'A',
    require: 'ngModel',
    link: function (scope, elem, attrs, control) {
      scope.$watch(function () {
          return scope.$eval(attrs.ngModel) == scope.$eval(attrs.equalTo);
      }, function (result) {
          control.$setValidity("equalTo", result);
      });
    }
  };
})
.directive('biggerThan', function () {
  return {
    restrict: 'A',
    require: 'ngModel',
    link: function (scope, elem, attrs, control) {
      scope.$watch(function () {
          return scope.$eval(attrs.ngModel) > 0 && scope.$eval(attrs.biggerThan) > 0 && (scope.$eval(attrs.ngModel) < scope.$eval(attrs.biggerThan));
      }, function (result) {
          control.$setValidity("biggerThan", result);
      });
    }
  };
})
.directive('lessThan', function () {
  return {
    restrict: 'A',
    require: 'ngModel',
    link: function (scope, elem, attrs, control) {
      scope.$watch(function () {
          return scope.$eval(attrs.ngModel) > 0 && scope.$eval(attrs.lessThan) > 0 && (scope.$eval(attrs.ngModel) <= scope.$eval(attrs.lessThan));
      }, function (result) {
          control.$setValidity("lessThan", result);
      });
    }
  };
})
.directive('dateBigger', function() {
  return {
    restrict: 'A',
    require: 'ngModel',
    link: function (scope, elem, attrs, control) {
      var checker = function() {
        var day1 = scope.$eval(attrs.dateBigger);
        var day2 = scope.$eval(attrs.ngModel);

        if(day1 && day2) {
          var startDate = moment(day1, 'DD/MM/YYYY');
          var endDate = moment(day2, 'DD/MM/YYYY');
          var days = endDate.diff(startDate, 'days');
          return days > 0;
        }
      }
      scope.$watch(checker, function (result) {
        control.$setValidity("dateBigger", result);
      })
    }
  }
})
.directive('dateLess', function() {
  return {
    restrict: 'A',
    require: 'ngModel',
    link: function (scope, elem, attrs, control) {
      var checker = function() {
        var day1 = scope.$eval(attrs.dateLess);
        var day2 = scope.$eval(attrs.ngModel);

        if(day1 && day2) {
          var startDate = moment(day1, 'DD/MM/YYYY');
          var endDate = moment(day2, 'DD/MM/YYYY');
          var days = endDate.diff(startDate, 'days');
          return days < 0;
        }
      }
      scope.$watch(checker, function (result) {
        control.$setValidity("dateLess", result);
      })
    }
  }
})
.directive('year', function () {
  return {
    require: 'ngModel',
    restrict: 'A',
    link: function (scope, element, attr, ctrl) {
      function inputValue(val) {
        if (val) {
          var digits = val.toString().replace(/[^0-9]/g, '');

          if (digits !== val) {
            ctrl.$setViewValue(digits);
            ctrl.$render();
          }
          return parseInt(digits, 10);
        }
        return undefined;
      }
      ctrl.$parsers.push(inputValue);
      element.bind("blur", function() {
        var val = parseInt(this.value);
        if(val)
          ctrl.$setViewValue(val);
        else
          ctrl.$setViewValue(CURRENT_YEAR);
      });
    }
  };
})
.directive('dropdownMenuHover', function () {
  return {
    link: function (scope, elem) {
      elem.dropdownHover();
    }
  };
})
.directive('onScrollToBottom', function () {
  return {
    restrict: 'A',
    link: function (scope, element, attrs) {
      var fn = scope.$eval(attrs.onScrollToBottom);
      element.on('scroll', function (e) {
        var el = e.target;
        if ((el.scrollHeight - el.scrollTop - 50) < element[0].clientHeight) {
          scope.$apply(fn);
        }
      });
    }
  };
  })
  .directive('armchart', function () {
  return {
    link: function (scope) {
      $("#chartdiv").css("height", scope.height);
      $("#chartdiv1").css("height", scope.height);
      var chart = AmCharts.makeChart( "chartdiv", {
        "type": "serial",
        "addClassNames": true,
        "theme": "light",
        "autoMargins": false,
        "marginLeft": 30,
        "marginRight": 8,
        "marginTop": 10,
        "marginBottom": 26,
        "balloon": {
          "adjustBorderColor": false,
          "horizontalPadding": 10,
          "verticalPadding": 8,
          "color": "#ffffff"
        },

        "dataProvider": scope.dataProvider,
        "valueAxes": [ {
          "axisAlpha": 0,
          "position": "left",
          "minimum": 0,
          "maximum": 110,
        } ],
        "startDuration": 1,
        "graphs": [ {
          "alphaField": "alpha",
          "balloonText": "<span style='font-size:12px;'>Tình hình sử dụng thuốc tháng [[tháng]]:<br><span style='font-size:20px;'>[[value]]%</span> [[additional]]</span>",
          "fillAlphas": 1,
          "title": "Bệnh nhân",
          "type": "column",
          "valueField": "Bệnh nhân",
          "dashLengthField": "dashLengthColumn"
        }],
        "categoryField": "tháng",
        "categoryAxis": {
          "gridPosition": "start",
          "axisAlpha": 0,
          "tickLength": 0,
        },
        // "export": {
        //   "enabled": true
        // }
      });
      var chart1 = AmCharts.makeChart( "chartdiv1", {
        "type": "serial",
        "addClassNames": true,
        "theme": "light",
        "autoMargins": false,
        "marginLeft": 30,
        "marginRight": 8,
        "marginTop": 10,
        "marginBottom": 26,
        "balloon": {
          "adjustBorderColor": false,
          "horizontalPadding": 10,
          "verticalPadding": 8,
          "color": "#ffffff"
        },

        "dataProvider": scope.dataProvider1,
        "valueAxes": [ {
          "axisAlpha": 0,
          "position": "left",
          "integersOnly": true,
          "maximum": 20,
          "minimum": 0,
          "autoGridCount": false,
          "gridCount": 20
        } ],
        "startDuration": 1,
        "graphs": [ {
          "alphaField": "alpha",
          "balloonText": "<span style='font-size:12px;'>Số bệnh nhân bỏ điều trị tháng [[tháng]]:<br><span style='font-size:20px;'>[[value]]</span> [[additional]]</span>",
          "fillAlphas": 1,
          "title": "Bệnh nhân",
          "type": "column",
          "valueField": "Bệnh nhân",
          "dashLengthField": 10
        }],
        "categoryField": "tháng",
        "categoryAxis": {
          "gridPosition": "start",
          "axisAlpha": 1,
          "tickLength": 1,
        },
        // "export": {
        //   "enabled": true
        // }
      });
    }
  };
})
.directive('ngModel', function(){
  return {
    restrict: 'A',
    require: 'ngModel',
    link: function(scope, elem, attrs, ctrl) {
      if(elem[0].type == "text") {
        elem.bind("input", function() {
          ctrl.$setViewValue(elem[0].value.substr(0, 255));
          ctrl.$render()
        });
      }
    }
  }
})
.directive('clickedDisable', function(){
  return {
    restrict: 'A',
    link: function(scope, element, attrs){
      $(element).click(function(){
        $(element).attr('disabled', true);
      });
    }
  }
})
.directive('noSpecialChar', function() {
  // return {
  //   require: 'ngModel',
  //   restrict: 'A',
  //   link: function(scope, element, attrs, modelCtrl) {
  //     modelCtrl.$parsers.push(function(inputValue) {
  //       if (inputValue == null)
  //         return ''
  //       cleanInputValue = inputValue.replace(/[^\w\s]/gi, '');
  //       if (cleanInputValue != inputValue) {
  //         modelCtrl.$setViewValue(cleanInputValue);
  //         modelCtrl.$render();
  //       }
  //       return cleanInputValue;
  //     });
  //   }
  // }
})
.directive("portletFixedHeight", ["$timeout", function($timeout) {
  return {
    restrict: "C",
    link: function(scope, element) {
      if($(window).width() <  992) return;
      $timeout(function() {
        var height = $(window).height() - $(element).children(".portlet-title").height() - 150;
        $(element).children(".portlet-body").height(height);
      }, 1);
    }
  }
}]);
