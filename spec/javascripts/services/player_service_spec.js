describe('gp.Services.$player', function(){
  var $player;

  beforeEach(module('gp'));
  beforeEach(inject(['$player', function(player){
    $player = player;
  }]));

  afterEach(function(){
    // empty the playlist queue
    while ($player.dequeue()) {}
  });

  it("enqueue adds to playlist", function(){
    $player.enqueue({ title: 'Test' });

    expect($player.playlist.length).toEqual(1);
  });

  it("dequeue removes from playlist", function(){
    $player.enqueue({ title: 'Test' });
    $player.dequeue();

    expect($player.playlist.length).toEqual(0);
  });

  it("dequeue returns nowPlaying", function(){
    $player.enqueue({ title: 'test' });

    expect($player.dequeue()).toEqual({
      title: 'test'
    });
  });

  it("dequeue set nowPlaying", function(){
    $player.enqueue({ title: 'test' });
    $player.dequeue();

    expect($player.nowPlaying()).toEqual({
      title: 'test'
    });
  });
});
