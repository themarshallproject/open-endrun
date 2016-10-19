$(window).load(function() {

	(function() {

		// var getMetaContentAsInt = function(prop) {
		// 	var selector = 'meta[property="' + prop + '"]';
		// 	var el = document.querySelector(selector);
		// 	if (el) {
		// 		return parseInt(el.getAttribute('content'), 10);
		// 	} else {
		// 		return null;
		// 	}
		// }

		var _updated = false; // track if this is the first time this page has been transmitted, or a subsequent one
		var last_transmitted_time = null;

		var referer_host;
		if (document.referrer.length > 0) {
			var _ref_a = document.createElement('a');
			_ref_a.href = document.referrer;
			referer_host = _ref_a.hostname;
		}
		window._referer_host = referer_host;

		var pixel = function() {

			if (window._hidden === true) { 				
 				// don't log if the window isn't in view
 				// see page-visibility.js which is setting this based on 
 				// the JS page vis API
 				return true;
 			}

			var engaged_time = window.engagedTime();
			if (engaged_time === last_transmitted_time) {				
				return false;
			} else {
				last_transmitted_time = engaged_time;
			}
			var p = {
				updated: _updated,
				path: window.endrun_config.path,
				post_id: window.endrun_config.post_id,
				params: window.location.search, // ie query params
				referer: document.referrer,
				referer_host: referer_host,	
				uuid: window.request_uuid(),
				user_token: decodeURIComponent(window.read_cookie('t')),
				width: window.innerWidth,
				height: window.innerHeight,
				pixel_ratio: window.devicePixelRatio,
				template: window.endrun_config.template,
				engaged_time: engaged_time,
				max_scroll: max_scroll()
			}
			_updated = true;

			var img = new Image(1, 1);
			img.src = window.endrun_config.lovestory_url+"?"+jQuery.param(p);

		}	

		var update = function() {
			// things that change afer page load, like engaged time, scroll depth
			
			// var readingTime = getMetaContentAsInt('tmp:reading_time');
			// var engagedTimePercent = null;
			// if (readingTime) {
			// 	engagedTimePercent = window.engagedTime() / readingTime;
			// } 
 
 			if (window._hidden === true) { 				
 				// don't log if the window isn't in view
 				// see page-visibility.js which is setting this based on 
 				// the JS page vis API
 				return true;
 			}

			var p = {
				uuid: window.request_uuid(),
				path: window.endrun_config.path,
				href: window.location.href,
				post_id: window.endrun_config.post_id,
				referer: document.referrer,
				referer_host: window._referer_host,
				params: window.location.search,
				engaged_time: window.engagedTime(),
				max_scroll: window.max_scroll(),
				width: window.innerWidth,
				height: window.innerHeight,
				user_token: decodeURIComponent(window.readCookie('t')),
				total_pvs: window._utpv,
				first_seen_delta: window._ufs_delta,
				// engaged_time_percent: engagedTimePercent,
				// expected_reading_time: readingTime,
				total_selections: window.getSelectionCount()
			}
			var img = new Image(1, 1);
			img.src = window.endrun_config.lovestory_rt+"?data="+encodeURIComponent(JSON.stringify(p));
		}

		pixel(); // window.onload, so this is okay

		update();
		setInterval(function() { pixel()  }, 30000);
		setInterval(function() { update() }, 15000);


	}).call(this);
});