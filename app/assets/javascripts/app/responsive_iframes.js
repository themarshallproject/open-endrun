$(document).ready(function() {

	var iframe_config_ratios = [
		{
			domain: 'youtube.com',
			ratio: 9.0/16.0
		},
		{
			domain: 'mediamtvnservq-a.akamaihd.net',
			ratio: 9.0/16.0
		},
		{
			domain: 'vimeo.com',
			ratio: 9.0/16.0
		},
		{
			domain: 'facebook.com',
			ratio: 9.0/16.0
		},
		{
			domain: 'player.ooyala.com',
			ratio: 9.0/16.0
		}
	];

	var resize_iframes = function() {
		$('iframe').each(function() {
			var $iframe = $(this);
			var host = $iframe.attr('src');
			if (!host) {
				// iframe doesn't have a src/host, jump to next
				return;
			}

			var configArray = iframe_config_ratios.filter(function(candidate) {
				return host.indexOf(candidate.domain) >= 0;
			});

			if (configArray.length === 0) {
				// console.log('skipping responseive iframe for', host);
				return;
			}

			var config = configArray[0];
			var width = $iframe.width();
			var height = Math.ceil(width * config.ratio);
			// $iframe.attr('width', '100%');
			window.requestAnimationFrame(function() {
				$iframe.attr('height', height);
			});
		});
	}

	resize_iframes();

	$(window).on('tmp_resize tmp_stream_open', function() {
		resize_iframes();
	});

	setTimeout(function() {
		resize_iframes();
	}, 500)
});
