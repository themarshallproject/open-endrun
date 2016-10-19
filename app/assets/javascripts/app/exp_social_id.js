(function() {

	// production: https://d1ce9cuexq46rp.cloudfront.net
	// logs: https://console.aws.amazon.com/s3/home?region=us-east-1&bucket=tmp-analytics-test-logs

	var hashOnLoad = window.location.hash; // create a copy of the hash on page load
	var hasRun = false;

	var genRandom = function(prefix, chars) {
		// based on Math.uuid.js (v1.4)
		var i;
		var num_chars = chars || 16;
		var chars = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'.split('');
		var chars_length = chars.length;
		var uuid_array = [];
		for (i=0; i<num_chars; i++) {
			uuid_array[i] = chars[0 | Math.random()*chars_length];
		}
		return prefix + uuid_array.join('');
	}

	var getUserId = function() {
		var cookieName = "uid_bqb"; // uid_(randomString)
		var previousId = window.readCookie(cookieName);

		if (previousId) {
			return previousId;
		}

		var newId =  genRandom('u_', 12);
		window.setCookie(cookieName, newId);
		return newId;
	}

	var cleanHash = function(hash) {
		// remove # and/or . from a window.location.hash (only report the alphanum id)
		return hash.replace('#', '').replace('.', '');
	}

	var getSocialHash = function() {
		var hash = window.location.hash;
		if (isEligibleHash(hash) === true) {
			return cleanHash(hash);
		} else {
			return null;
		}
	}

	var isEligibleHash = function(hash) {
		if (hash === "") {
			return true;
		}
		var re = new RegExp("^#\.[0-9a-zA-Z]{9}$");
		if (re.test(hash) === true) {
			return true;
		}
		return false;
	}

	var generateHash = function() {
		var hash = genRandom('.', 9);
		window.location.hash = hash;
		return hash;
	}

	var run = function() {
		if (hasRun === true) {
			return false;
		}
		hasRun = true;

		var user_id = getUserId();
		var pageview_id = genRandom('p_', 12);

		var referrer_social_id = '';
		var social_id = '';

		if (isEligibleHash(hashOnLoad)) {
			newHash = generateHash();
			referrer_social_id = cleanHash(hashOnLoad);
			social_id = cleanHash(newHash);
		}

		var url      = window.location.href;
		var path     = window.location.pathname;
		var referrer = document.referrer;

		var user_agent = navigator.userAgent;
		var width = window.innerWidth;
		var height = window.innerHeight;

		var data = {
			pageview_id: pageview_id,
			user_id: user_id,
			post_id: window.endrun_config.post_id, // provided only if a post page, empty string otherwise
			url: url,
			path: path,
			social_id: social_id,
			referrer_social_id: referrer_social_id,
			referrer: referrer,
			width: width,
			height: height,
			user_agent: user_agent,
		}
		var json = JSON.stringify(data);

		$(window).load(function() {
			var url = window.endrun_config.lovestory_si;
			var img = new Image(1, 1);
			img.src = url + "/api/pageview?json=" + encodeURIComponent(json) + "&t=" + (new Date()).getTime();

			// segment.io tracking:
			if (window['analytics']) {
				window.analytics.page({
					referrer_social_id: referrer_social_id,
					social_id: social_id
				});
			} else {
				console.log('skipping window.analytics.page, not present on window')
			}
		});

		return true;
	}

	setTimeout(run, 100); // wait for pushState, etc
	window._expHashForce = generateHash;
})();