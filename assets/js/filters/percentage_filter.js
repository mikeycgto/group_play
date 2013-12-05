!function(filters){
  filters.filter('percentage', function(){
    return function(input){
      if (typeof input == 'number')
        return input.toFixed(2).slice(2) + '%';

      return input;
    };
  });
}(angular.module('gp.Filters'));
