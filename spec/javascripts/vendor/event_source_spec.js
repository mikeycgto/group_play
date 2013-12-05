function MockEventSource(url){
  this.constructor.$$lastInstance = this;
  this.$$events = {};
  this.$$url = url;
}

function MockEventSourceBackend(){
  this.$get = ['$window', function(){
    return {
      open:function(url){
        return new MockEventSource(url);
      }
    };
  }];
};

MockEventSource.prototype.addEventListener = function(event, callback){
  (this.$$events[event] || (this.$$events[event] = [])).push(callback);
};

MockEventSource.prototype.trigger = function(event, msg){
  angular.forEach(this.$$events[event], function(callback){
    callback({ data: msg });
  });
};

describe('ngPush.$eventSource', function($eventSource){
  var $es, $mock;

  beforeEach(module('ngPush'));
  beforeEach(module(function($provide){
    $provide.provider('$eventSourceBackend', MockEventSourceBackend);
  }));

  beforeEach(inject(function($eventSource){
    $es = $eventSource('/test/url');
    $mock = MockEventSource.$$lastInstance;
  }));

  it('defines #on method', function(){
    expect(typeof $es.on).toEqual('function');
  });

  describe('#on', function(){
    it('adds event listeners', function(){
      $es.on({
        typeA:function(){},
        typeB:function(){}
      });

      expect($mock.$$events).toBeDefined();
      expect($mock.$$events.typeA.length).toEqual(1);
      expect($mock.$$events.typeB.length).toEqual(1);
    });

    it('incoming events invokes proper callback', function(){
      $es.on({
        typeA:function(data){
          expect(data).toEqual({ message: 'value' });
        }
      });

      $mock.trigger('typeA', '{"message":"value"}');
    });
  });
});
