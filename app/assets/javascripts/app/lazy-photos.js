(function() {

	window.recordImageLoad = function(el) {
		window.imagesLazyLoaded = window.imagesLazyLoaded || [];
		window.imagesLazyLoaded.push({
			time: (new Date()).getTime(),
			el: el
		});
		//console.log(el, 'finished loading')
		$(window).trigger('tmp_recalc_max_photos');
		window.requestAnimationFrame(function() {
			$(window).trigger('tmp_reflow');
		});
	}

	var setupBackgroundImages = function() {
		$("*[data-background-image]").each(function() {
			var $this = $(this);
			var currentImage = $this.css('background-image');
			var url = $this.attr('data-background-image');
			if (url === currentImage) {
				// already loaded
			} else {
				$this.css('background-image', 'url("'+url+'")');
			}
		});
	}

	var forceAllPhotos = function() {
		$("img[data-src]").each(function() {
			var $this = $(this);
			var src = $this.attr('data-src');
			var currentSrc = $this.attr('src');
			if (src !== currentSrc) {
				$this.attr('src', src);
			}
		});
	}

	var setupPhotos = function() {
		// the number of pixels between the item about to come on screen
		// and the bottom of the screen (amount of 'lookahead')
		var threshold = 1000; //px

		$("img").each(function() {
			var $this = $(this);
			if (!$(this).attr('data-src')) {
				return;
			}

			var el = $this.get(0);
			var elDelta = el.getBoundingClientRect().top - window.innerHeight;
			var inView = elDelta < threshold;

			if (inView === false) {
				// img is too far below scroll, skip
				return false;
			}

			var src = el.getAttribute('data-src');
			var currentSrc = el.getAttribute('src');
			if (src !== currentSrc) {
				//console.log('loading', src, el);
				el.setAttribute('src', src);
			}

		});
	}

	$(document).ready(function() {
		window.requestAnimationFrame(function() {
			setupBackgroundImages();
			setupPhotos();
		});

		forceAllPhotos();
	});

	$(window).on('tmp_scroll', function() {
		window.requestAnimationFrame(function() {
			setupPhotos();
			setupBackgroundImages();
		});
	});

	$(window).on('tmp_stream_added_items', function() {
		setupBackgroundImages();
		setupPhotos();
	});

	$(window).on('tmp_stream_open', function() {
		setupBackgroundImages();
		setupPhotos();
	});

})();
