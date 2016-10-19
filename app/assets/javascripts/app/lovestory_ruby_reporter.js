$(window).load(function() {	
	var send_boot_pixel = function() {
		var p = {
			event: 'boot',
			path: window.endrun_config.path,
			params: window.location.search,
			referer: document.referrer,			
			uuid: window.request_uuid(),
			//cookie: document.cookie,
			user_token: decodeURIComponent(window.read_cookie('t')),
			width: window.innerWidth,
			height: window.innerHeight,
			retina: window.devicePixelRatio,
			template: window.endrun_config.template,
			//engaged_time: 0,
			cache_t: (new Date()).getTime(),
			initial_hash: '',
			final_hash: ''
		}		
		var img = new Image(1, 1);
		img.src = window.endrun_config.lovestory_zero_endpoint+"?"+jQuery.param(p);		
		// consider: https://gist.github.com/ivarvong/74a7d3f0e6c144908877
	}	
	send_boot_pixel();	
});