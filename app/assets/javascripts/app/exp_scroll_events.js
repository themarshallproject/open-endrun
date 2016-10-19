(function() {	

	var makeId = function(chars) {
		// based on Math.uuid.js (v1.4)
		var i;
		var num_chars = 16;
		var chars = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'.split('');
		var chars_length = chars.length;
		var uuid_array = [];
		for (i=0; i<num_chars; i++) {
			uuid_array[i] = chars[0 | Math.random()*chars_length];
		}	
		return uuid_array.join('');
	}
	var yScrollTop = function() {
		// https://stackoverflow.com/questions/11193453/find-the-vertical-position-of-scrollbar-without-jquery
		return (window.pageYOffset !== undefined) ? window.pageYOffset : (document.documentElement || document.body.parentNode || document.body).scrollTop;
	}
	var getTime = function() {
		return (new Date()).getTime();
	}

	var deviceWidth = function() {
		return window.innerWidth || document.body.clientWidth;
	}
	var deviceHeight = function() {
		return window.innerHeight || document.body.clientHeight;
	}

	var loadTime = getTime();
	var events = [];
	var pageId = makeId();


	var sync = function() {
		var json = JSON.stringify({
			page_id: pageId,
			device_width: deviceWidth(),
			device_height: deviceHeight(),
			referrer: document.referrer,
			path: window.location.pathname,
			url: window.location.href,
			events: events.join('|')
		});

		var baseUrl = window.endrun_config.lovestory_si;
		var img = new Image(1, 1);
		var url = baseUrl + "/api/v1/scroll?json=" + encodeURIComponent(json);
		img.src = url;
	}

	var report = function() {
		var secondsFloat = (getTime() - loadTime) / 1000.0;
		var seconds = Number(secondsFloat).toFixed(2);
		var yOffset = yScrollTop();
		events.push(seconds+","+yOffset);
	}

	report();
	var timer_100ms   = setInterval(report, 100);
	var timer_500ms   = setInterval(report, 500);
	var timer_5000ms = setInterval(report, 5000);
	setTimeout(function() { clearInterval(timer_100ms); },        10 * 1000);  // 10 Hz
	setTimeout(function() { clearInterval(timer_500ms); },        30 * 1000);  // 2 Hz
	setTimeout(function() { clearInterval(timer_5000ms); },  30 * 60 * 1000);  // 0.2 Hz for 30 minutes,  if anyone leaves this open for 30 minutes, give up

	setTimeout(sync, 2500);
	setTimeout(sync, 5000);
	setTimeout(sync, 7500);

	setTimeout(sync, 15000);

	var slowSync = setInterval(sync, 10*1000);
	setTimeout(function() {
		clearInterval(slowSync);
	}, 31 * 60 * 1000);
})();