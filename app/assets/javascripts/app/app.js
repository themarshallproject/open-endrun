//= require 'app/ga_reporting_helpers'
//= require 'app/cookie_helpers'
//= require 'app/resize_fullbleed_photos'
//= require 'app/menu'
//= require 'app/stream'
//= require 'app/build_uuid'
//= require 'app/scroll_depth'
//= require 'app/responsive_iframes'
//= require 'app/share_tool_analytics'
//= require 'app/topshelf'
//= require 'app/hotzone'
//= require 'app/svg_arc_helpers'
//= require 'app/audioplayer_1'
//= require 'app/annotation_2'
//= require 'app/moment'
//= require 'app/sidebar-embed-experiment'
//= require 'app/lazy-photos'
//= require 'app/fb-inline-share'
//= require 'app/email-signup'
//= require 'app/page-visibility'
//= require 'app/mailchimp_goal_tracking'
//= require 'app/email_modal_v1'
//= require 'app/exp_social_id'
//= require 'app/mustache'


(function() {
	$(document).ready(function() {
		$('html').removeClass('no-js').addClass('has-js');
	});
})();

(function() {
    var lastTime = 0;
    var vendors = ['webkit', 'moz'];
    for(var x = 0; x < vendors.length && !window.requestAnimationFrame; ++x) {
        window.requestAnimationFrame = window[vendors[x]+'RequestAnimationFrame'];
        window.cancelAnimationFrame =
          window[vendors[x]+'CancelAnimationFrame'] || window[vendors[x]+'CancelRequestAnimationFrame'];
    }

    if (!window.requestAnimationFrame)
        window.requestAnimationFrame = function(callback, element) {
            var currTime = new Date().getTime();
            var timeToCall = Math.max(0, 16 - (currTime - lastTime));
            var id = window.setTimeout(function() { callback(currTime + timeToCall); },
              timeToCall);
            lastTime = currTime + timeToCall;
            return id;
        };

    if (!window.cancelAnimationFrame)
        window.cancelAnimationFrame = function(id) {
            clearTimeout(id);
        };
}());

function setup_document_cloud() {
	(function() {
	  // If the note embed is already loaded, don't repeat the process.
	  if (window.dc && window.dc.noteEmbedLoaded) return;

	  window.dc = window.dc || {};
	  window.dc.recordHit = "https://www.documentcloud.org/pixel.gif";

	  var loadCSS = function(url, media) {
	    var link   = document.createElement('link');
	    link.rel   = 'stylesheet';
	    link.type  = 'text/css';
	    link.media = media || 'screen';
	    link.href  = url;
	    var head   = document.getElementsByTagName('head')[0];
	    head.appendChild(link);
	  };

	  /*@cc_on
	  /*@if (@_jscript_version < 5.8)
	    loadCSS('https://s3.amazonaws.com/s3.documentcloud.org/note_embed/note_embed.css');
	  @else @*/
	    loadCSS('https://s3.amazonaws.com/s3.documentcloud.org/note_embed/note_embed-datauri.css');
	  /*@end
	  @*/

	  // Record the fact that the note embed is loaded.
	  dc.noteEmbedLoaded = true;

	  // Request the embed JavaScript.
	  // (done manually in the footer)
	})();
}

window.last_mousemove = (new Date()).getTime();
window.last_scroll    = (new Date()).getTime();
window.last_resize    = (new Date()).getTime();

window.csrf_token = null;
$(document).ready(function() {

	var get_csrf_token = function() {
		$.get("/api/v2/token", {
			referer: document.referrer,
			time: (new Date()).getTime()
		}).done(function(data) {
			window.csrf_token = data.csrf;
			window._ratchetHash = data.hash;
			$.ajaxSetup({
				beforeSend: function (xhr) {
					xhr.setRequestHeader('X-CSRF-Token', data.csrf);
				}
			});
			report('csrf_token', 'receive');
		}).fail(function() {
			report('csrf_token', 'fail');
		});
	}
	get_csrf_token();
	setInterval(function() {
		if (window.csrf_token === null) {
			report('csrf_token', 'retry');
			get_csrf_token();
		}
	}, 1000);

	$(window).trigger('tmp_ready');

	$(window).mousemove(_.throttle(function() {
		window.last_mousemove = (new Date()).getTime();
	}, 500));

	$(window).scroll(_.throttle(function() {
		window.last_scroll = (new Date()).getTime();
		$(window).trigger('tmp_scroll');
	}, 50));
	$(window).resize(_.throttle(function() {
		window.last_resize = (new Date()).getTime();
		set_device_class();
		$(window).trigger('tmp_resize');
	}, 100));

	var set_device_class = function() {
		var w = window.innerWidth
		  , $body = $('body')
		if (w < 740) {
			$body.removeClass('desktop').removeClass('tablet').addClass('mobile')
		} else if (w >= 740 && w <= 1200) {
			$body.removeClass('desktop').addClass('tablet').removeClass('mobile')
		} else {
			$body.addClass('desktop').removeClass('tablet').removeClass('mobile')
		}
	}
	set_device_class();

	try {
		window.is_retina = window.devicePixelRatio > 1;
		if (window.is_retina === true) {
			report('retina', 'true');
		} else {
			report('retina', 'false');
		}
	} catch(e) {
		// pass
	}

});

if (document.referrer.indexOf('facebook.com') >= 0) {
	window.set_cookie('_fb_ref', 'true');
}
if (document.referrer.indexOf('twitter.com') >= 0) {
	window.set_cookie('_tw_ref', 'true');
}

(function() {
	var lastSeen  = (new Date()).getTime();
	var engagedTime = 0;
	var idleTimeout = 5000;

	$(document).ready(function() {
		$(window).on('focus click scroll mousemove touchstart touchend touchcancel touchleave touchmove', function() {
			lastSeen = (new Date()).getTime();
		});
	});

	setInterval(function() {
		var timeSinceLastEvent = (new Date()).getTime() - lastSeen;
		if (timeSinceLastEvent < idleTimeout) {
			engagedTime += 1;
		}
	}, 1000);

	window.engagedTime = function() {
		return engagedTime;
	}
}).call(this);

(function() {
	// use GA events for 'engaged time' measurement... bucket to 10 second chunks
	$(document).ready(function() {
		var timing_events_sent = [];
		var timing_bucket_width = 10; // seconds

		var send_event = function(t) {
			timing_events_sent.push(t);
			report('v1_engaged_time', ''+t);
		}
		send_event(0); // baseline event

		setInterval(function() {
			var t = window.engagedTime();
			var bucketed_t = t - (t%timing_bucket_width); // 'rounds down'/floor to the nearest multiple of (bucket_width)

			if (timing_events_sent.indexOf(bucketed_t) === -1) {
				// if we havent sent this event, send it
				send_event(bucketed_t);
			}
		}, 2000); // check every 2 seconds if we have a new event to send
	});
}).call(this);


(function() {
	var max_scroll = 0;

	$(document).ready(function() {
		$(window).on('tmp_scroll', function() {
			var current_scrolltop = $(window).scrollTop();
			if (current_scrolltop > max_scroll) {
				max_scroll = current_scrolltop;
			}
		});
	});

	window.max_scroll = function() {
		return max_scroll;
	}
}).call(this);


(function() {
	var setup_doc_cloud_size_hacks = function() {
		$('.DC-note-excerpt').each(function() {
			var w = ($(this).closest('.DC-note-excerpt-wrap').width()-1) + 'px';
			if ($('body').hasClass('desktop') == false) {
				$(this).css('width', w);
				$(this).find('.DC-right-cover').remove();
			}
		});
	}
	$(window).load(function() {
		setTimeout(function() {
			setup_doc_cloud_size_hacks();
		}, 2000);
		setup_doc_cloud_size_hacks();
		$(window).on('tmp_stream_open', function() {
			setTimeout(function() {
				setup_doc_cloud_size_hacks();
			}, 1000);
		})
	});

}).call(this);

(function() {
	// Increment cookie, UserTotalPageView
	var cookieName = '_utpv'; // user total pageviews
	var total_pageviews;
	var total_pageviews_raw = window.readCookie(cookieName);

	if (total_pageviews_raw === null) {
		total_pageviews = 1;
	} else {
		total_pageviews = parseInt(total_pageviews_raw, 10);
		total_pageviews += 1;
	}
	window.setCookie(cookieName, total_pageviews);
	window._utpv = total_pageviews;
})();

(function() {
	// Set a cookie, UserFirstSeen, if it is not already present. Calculate the time between that cookie and now.
	var cookieName = '_ufs';
	if (window.readCookie(cookieName) === null) {
		window.setCookie(cookieName, ''+(new Date()).getTime());
	}
	var delta_ms = (new Date()).getTime() - parseInt(window.readCookie(cookieName), 10);
	var delta = Math.floor(delta_ms/1000); // ms -> seconds
	window._ufs_delta = delta;
})();

(function() {
	var totalSelections = 0;
	var selections = [];
	var getSelectionText = function() {
	    var text = "";
	    if (window.getSelection) {
	        text = window.getSelection().toString();
	    } else if (document.selection && document.selection.type != "Control") {
	        text = document.selection.createRange().text;
	    }
	    return text;
	}
	$(document).ready(function() {
	   $(document).mouseup(function(e) {
	       var text = getSelectionText();
	       if (text.length >= 4) { // TODO: is what is this threshold, why bother?
	       		totalSelections += 1;
	       		selections.push({
	       			time: (new Date()).getTime(),
	       			text: text
	       		});
	       }
	   });
	});
	window.getSelectionCount = function() {
		return totalSelections;
	}
	window.getSelectionHistory = function() {
		return selections;
	}
})();

(function() {
	var pageLoadTime = (new Date()).getTime();
	var samples = [];
	var lastSample = 0; // timestamp
	var sampleDelta = 100; // milliseconds
	$(window).scroll(function() {
		var now = (new Date()).getTime();
		if (now - lastSample > sampleDelta) {
			samples.push({
				time: now - pageLoadTime,
				scrollPosition: $(window).scrollTop()
			});
		}
	});
	window.getScrollSamples = function() {
		return samples;
	}
})();

(function() {
	$(document).ready(function() {
		$('body').on('click', 'a[data-track-url]', function(e) {
			e.preventDefault();
			window.location = this.getAttribute('data-track-url');
		});
	});
})();

(function() {
	$(document).ready(function() {
		$('body').on('click', 'a[data-anchor-jump]', function(e) {
			e.preventDefault();
			var $jump = $(this);
			var jumpId = $jump.attr('data-anchor-jump');
			var $land = $('[data-anchor-land="'+jumpId+'"]');
			var headerHeight = $('header').height();
			window.disableTopshelfShow = (new Date()).getTime() + 3000;
			var destScroll = $land.offset().top - headerHeight;
			$('html, body').animate({
        		scrollTop: destScroll
    		}, 1);
    	});
	});
})();

(function() {
	// when we open a post in the stream, notify Twitter embed to find any new widgets that need to be init'd
	$(window).on('tmp_stream_open', function() {
		if (window['twttr']) {
			twttr.widgets.load();
		}
	});
})();

(function() {
	$(document).ready(function() {
		window.requestAnimationFrame(function() {
			if (window.devicePixelRatio > 1) {
				var el = $('#nav-logo-img');
				el.attr('src', el.attr('data-retina-src'));
			}
		});
	});
})();
