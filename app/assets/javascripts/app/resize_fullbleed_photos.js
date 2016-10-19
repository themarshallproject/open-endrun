$(document).ready(function() {
	var resize_max_photos = function() {
		var window_width = $(window).width();

		$('.photo-max-shim').each(function() {
			var $shim = $(this);
			// var container_width = $shim.closest('.container').width();
		 //  var margin = (1.0* window_width - container_width) / 2;

			var container_width = $(this).closest('.container').width();
			var margin = (window_width - container_width) / 2;

			var $photo = $shim.find('.photo-max');
			$photo.css({
				'margin-left': -1*margin + 'px',
				'margin-right': 1*margin + 'px',
				'width': window_width
			})
			window.requestAnimationFrame(function() { // let it paint, then calc new height and update shim
				$shim.css({
					'height': $photo.outerHeight()+'px'
				});
			});

			// console.log(window_width, container_width, $shim);
		});


		$('.fullbleed-container').each(function() {
			var window_width = $(window).width();
			// var container_width = $(this).find('.container').width();
			// var margin = (window_width - container_width) / 2;

			var container_width = $(this).closest('.container').width();
			var margin = (window_width - container_width) / 2;
			// console.log($(this), window_width, container_width)
			$(this).css({
				'margin-left': -1*margin + 'px',
				'margin-right': 1*margin + 'px',
				'width': window_width
			});
			window.requestAnimationFrame(function() {
				$(window).trigger('tmp_fullbleed_container_updated');
			})
		});

	}

	resize_max_photos();
	window.requestAnimationFrame(function() {
		resize_max_photos();
	});

	setTimeout(function() {
		resize_max_photos();
	}, 10);
	setTimeout(function() {
		resize_max_photos();
	}, 1000);
	setTimeout(function() {
		resize_max_photos();
	}, 2000);
	setTimeout(function() {
		resize_max_photos();
	}, 5000);

	$(window).on('tmp_recalc_max_photos', resize_max_photos);
	$(window).on('tmp_resize', resize_max_photos); // rate-limited window.resize
	$(window).on('tmp_stream_open', function() {
		setTimeout(function() {
			resize_max_photos();
		}, 200);
		setTimeout(function() {
			resize_max_photos();
		}, 500);
		setTimeout(function() {
			resize_max_photos();
		}, 5000);
	});
});
