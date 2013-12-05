!function(controllers){
  controllers.controller('UploadCtrl', ['$scope', '$http', '$location', function($scope, $http, $location){
    $scope.upload = function(){
      var file = $scope.file.files[0];
      var form = new FormData;

      form.append('file', file);

      $http.post('/enqueue/file', {}, {
        headers: { 'Content-Type': undefined },
        transformRequest:function(){ return form; }
      }).success(function(){
        $location.path('/');
      });
    };
  }]);
}(angular.module('gp.Controllers'));
