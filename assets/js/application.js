/*
 *= require_self
 *= require_tree ./controllers
 *= require_tree ./factories
 *= require_tree ./services
 *= require_tree ./directives
 *= require_tree ./filters
 */

!function(deps){
  for (var i = 0, len = deps.length; i < len; i++)
    angular.module((deps[i] = 'gp.' + deps[i]), []);

  // for $eventSource
  deps.unshift('ngPush');

  angular.module('gp', deps).config(function($routeProvider, $locationProvider, $httpProvider){
    $routeProvider.when('/', {
      controller: 'PlaylistCtrl',
      templateUrl: 'playlist.html'
    }).when('/upload', {
      controller: 'UploadCtrl',
      templateUrl: 'upload.html'
    });

    $locationProvider.html5Mode(true);

    $httpProvider.defaults.headers.common['Accept'] = 'application/json';
  });
}(['Configs', 'Controllers', 'Directives', 'Factories', 'Services', 'Filters']);
