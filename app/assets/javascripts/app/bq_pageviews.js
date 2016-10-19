(function() {

	var random_string = function(chars) {
		// based on Math.uuid.js (v1.4)
		var i;
		var num_chars = chars || 16;
		var chars = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'.split('');
		var chars_length = chars.length;
		var uuid_array = [];
		for (i=0; i<num_chars; i++) {
			uuid_array[i] = chars[0 | Math.random()*chars_length];
		}	
		return uuid_array.join('');
	}

	var run = function() {

		var user_id = function() {
			var cookieName = "uid_bqb"; // uid_(randomString)
			var previousId = window.readCookie(cookieName);

			if (previousId) {
				return previousId;
			} 

			var newId = "u_" + random_string(20);
			window.setCookie(cookieName, newId);
			return newId;
		}

		var page_id = "p_" + random_string(20);

		// these are more ruby-y, not the JS DOM methods
		var url      = window.location.href;
		var path     = window.location.pathname;
		var host     = window.location.hostname;
		var query    = window.location.search;
		var fragment = window.location.hash;

		var user_agent = navigator.userAgent;

		var width = window.innerWidth;
		var height = window.innerHeight;
		var pixel_ratio = null;
		if (window['devicePixelRatio']) {
			// not supported before IE11
			pixel_ratio = window.devicePixelRatio;
		}

		var referrer = document.referrer;
		var referrer_host = "";
		if (document.referrer.length > 0) {
			var a = document.createElement('a');
			a.href = document.referrer;
			referrer_host = a.hostname;
		}

		var data = {
			pageview_id: page_id,
			user_id: user_id(),
			url: url,
			path: path,
			query: query,
			fragment: fragment,
			referrer: referrer,
			referrer_host: referrer_host,
			width: width,
			height: height,
			pixel_ratio: pixel_ratio,
			user_agent: user_agent,
		}
		
		var reporting_url = window.endrun_config.lovestory_bq;		
		var json = JSON.stringify(data);
		var img = new Image(1, 1);
		img.src = reporting_url + "/pageview?json=" + encodeURIComponent(json);

		return true;
	}
	
	setTimeout(run, 100); // wait for pushState, etc

})();