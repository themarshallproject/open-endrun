(function() {
  var viewportMidpoint = function() {
    return $(window).scrollTop() + $(window).height()/2.0;
  }
  var enabledElements = function() {
    return $('[data-hotzone]');
  }
  var elementMidpoint = function($el) {
    return ($el.position().top + $el.height()/2.0) - viewportMidpoint();
  }
  var elementTop = function($el) {
    return $el.position().top - $(window).scrollTop();
  }
  var isActive = function($el) {

    var hotzoneTopRatio    = (1/12.0);
    var hotzoneBottomRatio = (1/3.0);

    var str_hotzoneTopRatio = $el.attr('data-hotzone-top-ratio');
    if (str_hotzoneTopRatio) {
      hotzoneTopRatio = parseFloat(str_hotzoneTopRatio);
    }

    var str_hotzoneBottomRatio = $el.attr('data-hotzone-bottom-ratio');
    if (str_hotzoneBottomRatio) {
      hotzoneBottomRatio = parseFloat(str_hotzoneBottomRatio);
    }

    var windowHeight = window.innerHeight;
    var hotzoneTop    = hotzoneTopRatio    * windowHeight;
    var hotzoneBottom = hotzoneBottomRatio * windowHeight;

    // console.log($el.attr('data-audioplayer-src'), 'h T, B', hotzoneTop, hotzoneBottom);

    if (elementTop($el) >= hotzoneTop && elementTop($el) <= hotzoneBottom) {
      // console.log($el, hotzoneTop, hotzoneBottom, elementTop($el))
      return true;
    } else {
      return false;
    }
    //return Math.abs(elementMidpoint($el)) < /6.0;
  }

  var dispatchEvent = function(el, eventName) {
    try {
      if (document.createEvent) {
        var evt = new Event(eventName);
        el.dispatchEvent(evt);
      } else {
        var evt = document.createEventObject();
          el.fireEvent('on'+eventName, evt);
      }
    } catch(e) {
      console.log('error in dispatchEvent')
    }
  }

  var dispatchIfEdge = function(el, incomingEventName) {
    var $el = $(el);
    if ($el.attr('data-hotzone-last-event') !== incomingEventName) {
      $el.attr('data-hotzone-last-event', incomingEventName);
      dispatchEvent(el, incomingEventName);
      dispatchEvent(document, 'tmp-hotzone-change');
    }
  }

  var checkVisibility = function(el) {
    var $el = $(el);
    var lastState = ($el.attr('data-visibility') === 'true');

    var scrollTop = $(window).scrollTop();
    var windowHeight = $(window).height();
    var elHeight = $el.height();
    var elTop = $el.position().top;

    var aboveBottom = elTop < (scrollTop + windowHeight);
    var belowTop = (elHeight + elTop) > scrollTop;
    var currentState = (aboveBottom && belowTop);

    if (currentState !== lastState) {
      $el.attr('data-visibility', currentState);
      if (currentState === true) {
        dispatchEvent(el, 'tmp_hotzone_will_appear');
      } else {
        dispatchEvent(el, 'tmp_hotzone_will_disappear');
      }
    }
  }

  var updateElements = function() {
    enabledElements().map(function(_, el) {
      var $el = $(el);
      if (isActive($el) === true) {
        $el.attr('data-hotzone-state', 'on');
        dispatchIfEdge(el, 'tmp_hotzone_start');
      } else {
        $el.attr('data-hotzone-state', 'off');
        dispatchIfEdge(el, 'tmp_hotzone_end');
      }

      checkVisibility(el);

      return $el;
    });
  }
  $(document).ready(function() {
    $(window).on('tmp_scroll', function() {
      updateElements();
    });
    updateElements();
  });

}).call(this);

// youtube hotzone
// <div data-youtube-hotzone data-youtube-id="nfWlot6h_JM"></div> is the form to generate this.
// TK TK TK
(function() {

  var generateElementID = function() {
    var i;
    var num_chars = 6;
    var chars = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'.split('');
    var chars_length = chars.length;
    var uuid_array = [];
    for (i=0; i<num_chars; i++) {
      uuid_array[i] = chars[0 | Math.random()*chars_length];
    }
    return uuid_array.join('');
  }

  var loadYoutubeAPI = function() {
    if (window._youtube_api_loaded === true) {
      return true;
    }
    var script_tag = document.createElement('script');
    script_tag.src = "https://www.youtube.com/iframe_api";
    var firstScriptTag = document.getElementsByTagName('script')[0];
    firstScriptTag.parentNode.insertBefore(script_tag, firstScriptTag);
    window._youtube_api_loaded = true;
  }

  var findYouTubePlayers = function() {
    // find YouTube players, inject YouTube API if we find one
    $("[data-youtube-id]").each(function(_, el) {
      loadYoutubeAPI();
    });
  }
  findYouTubePlayers();

  var setupYoutubePlayers = function() {
    $("[data-youtube-hotzone]").each(function(_, el) {
      buildPlayer(el);
    });
    $(window).on('tmp_stream_open', function() {
      $('[data-vimeo-id]').each(function(_, el) {
        buildPlayer(el);
      });
    });
  }


  window.onYouTubeIframeAPIReady = function() {
    // this needs to be on window so the YouTube API can find it. keep the rest scoped inside here.
    setupYoutubePlayers();
    $(window).on('tmp_stream_open', function() {
      findYouTubePlayers();
      setupYoutubePlayers();
    });
  }

  var buildPlayer = function(source_el) {
    var videoPlayerId = "youtube_"+generateElementID();
    source_el.id = videoPlayerId;

    var videoId = source_el.getAttribute('data-youtube-id');

    var player = new YT.Player(videoPlayerId, {
      height: '400',
      width: '100%',
      videoId: videoId,
      events: {
        'onReady': onPlayerReady,
        'onStateChange': onPlayerStateChange
      }
    });

    var el = document.getElementById(videoPlayerId);

    el.setAttribute('data-hotzone', 'true');

    el.addEventListener("tmp_hotzone_start", function() {
      if (player !== undefined) {
        player.playVideo();
      } else {
        console.log('player undefined during hotzone start')
      }
    });

    el.addEventListener("tmp_hotzone_end", function() {
      if (player !== undefined) {
        player.pauseVideo();
      } else {
        console.log('player undefined during hotzone end')
      }
    });

  }

  var onPlayerStateChange = function(event) {
    // noop
  }
  var onPlayerReady = function(event) {
    // noop
  }

})();

(function() {

  var getIframeSrc = function(videoId, playerId) {
    return ['https://player.vimeo.com/video/', videoId, '?api=1&player_id=', playerId].join('');
  };

  function insertAfter(newNode, referenceNode) {
    // http://stackoverflow.com/a/4793630
    referenceNode.parentNode.insertBefore(newNode, referenceNode.nextSibling);
  }

  var generateElementID = function() {
    var i;
    var num_chars = 6;
    var chars = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'.split('');
    var chars_length = chars.length;
    var uuid_array = [];
    for (i=0; i<num_chars; i++) {
      uuid_array[i] = chars[0 | Math.random()*chars_length];
    }
    return uuid_array.join('');
  }
  var buildPlayer = function(source_el) {
    var playerId = "vimeo_"+generateElementID();
    var videoId = source_el.getAttribute('data-vimeo-id');

    var el = document.createElement('iframe');
    el.id = playerId;
    el.setAttribute('data-hotzone', 'true');
    el.src = getIframeSrc(videoId, playerId);
    el.width = "100%";
    el.height = "400";
    el.setAttribute('frameborder', 0);

    insertAfter(el, source_el);
    source_el.remove();

    el.addEventListener("tmp_hotzone_start", function() {
      postToIframe(el, "play");
    });

    el.addEventListener("tmp_hotzone_end", function() {
      postToIframe(el, "pause");
    });
  }

  var postToIframe = function(el, action, value) {
    var data = { method: action };
    if (value) { data.value = value; }
    var message = JSON.stringify(data);
    el.contentWindow.postMessage(message, '*');
  }

  $(document).ready(function() {
    $('[data-vimeo-id]').each(function(_, el) {
      buildPlayer(el);
    });
    $(window).on('tmp_stream_open', function() {
      $('[data-vimeo-id]').each(function(_, el) {
        buildPlayer(el);
      });
    });
  });


})();
