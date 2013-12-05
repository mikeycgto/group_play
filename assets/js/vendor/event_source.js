!function(push){
  function parse(obj){
    try { var json = JSON.parse(obj); }
    catch(e) { json = {}; }
    finally { return json; }
  }

  push.provider('$eventSourceBackend', function(){
    this.$get = ['$window', function($window){
      return {
        open: function(url){
          return new $window.EventSource(url);
        }
      };
    }];
  });

  push.factory('$eventSource', ['$eventSourceBackend', function($eventSourceBackend){
    return function(url){
      var esrc = $eventSourceBackend.open(url);

      return {
        on:function(handlers){
          angular.forEach(handlers, function(callback, type){
            esrc.addEventListener(type, function(ev){
              if (console.debug) console.debug('ev', type, ev);

              callback(parse(ev.data));
            });
          });

          return this;
        }
      };
    }
  }]);
}(angular.module('ngPush', ['ng']));
