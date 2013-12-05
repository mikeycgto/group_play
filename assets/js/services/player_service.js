!function(services){
  var extend = angular.extend;

  services.service('$player', ['playerData', function(data){
    var nowPlaying = data.nowPlaying;
    var playlist   = data.playlist;

    var service = {
      playlist: playlist,

      enqueue:function(track){
        playlist.push(track);

        return this;
      },

      dequeue:function(){
        nowPlaying = playlist.shift();

        return nowPlaying;
      },

      nowPlaying:function(){
        return nowPlaying;
      }
    };

    return service;
  }]);
}(angular.module('gp.Services'));
