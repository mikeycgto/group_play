!function(directives){
  directives.directive('body', ['$eventSource', '$player', function($eventSource, $player){
    window.$player = $player;

    return {
      restrict: 'E',

      controller:function($scope){
        // Link playlist array
        $scope.playlist = $player.playlist;

        // Set initial nowPlaying
        $scope.nowPlaying = $player.nowPlaying();
      },

      link:function($scope, $elem, $attrs){
        $scope.events = $eventSource('/subscribe').on({
          enqueue:function(track){
            $scope.$apply(function(){
              // Enqueue track (scope sees playing change)
              $player.enqueue(track);
            });
          },

          dequeue:function(np){
            $scope.$apply(function(){
              // Dequeue player and set $scope's nowPlaying
              $scope.nowPlaying = $player.dequeue();
            });
          },

          //play_time:function(np){
            //$scope.$apply(function(){
              //$player.nowPlayingTime = np;
            //});
          //}
        });
      }
    };
  }]);
}(angular.module('gp.Directives'));
