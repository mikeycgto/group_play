!function(directives){
  directives.directive('input', function(){
    return {
      restrict: 'E',

      link:function($scope, $elem, $attrs){
        var node = $elem[0];

        if (node.type == 'file')
          $scope[node.name] = node;
      }
    };
  });
}(angular.module('gp.Directives'));
