(function() {
	$(document).ready(function() {
		var textWithoutChildren = function($el) {
			return $el.clone().children().remove().end().text();
		}
		var annoBodyForSelector = function(el) {
			var index = $(el).attr('data-index');
			return $('.post-annotation-2-body[data-index="' + index + '"]');
		}
		var distToTop = function(el) {
			var bodyTop = document.body.getBoundingClientRect().top;
			var elTop = el.getBoundingClientRect().top;
			var headerHeight = document.querySelector('header').getBoundingClientRect().height;
			return elTop - bodyTop + headerHeight;
		}
		var recalculateOffset = function($selector, $body) {
			var selectorOffset = distToTop($selector[0]);
			//var bodyOffset     = distToTop($body[0]);
			// var delta = bodyOffset - selectorOffset;

			var title = textWithoutChildren($selector);
			var titleEl = $body.find('.title');
			titleEl.text(title);

			if ($('body').hasClass('mobile')) {
				// if we're on mobile, don't position:absolute, let them flow
				$body.css({ 
					'position': 'static',
					'top': '0' 
				}).show();
				return true;
			}

			window.requestAnimationFrame(function() {
				$body.css({ 
					'position': 'absolute',
					'top': selectorOffset+"px" 
				}).show();				
			});

			return $body;
		}

		var buildAnnotations = function() {
			$('.post-annotation-2-body').hide();

			$('.post-annotation-2-selector').each(function(index, selector) {
				var $selector = $(selector);
				var $body = annoBodyForSelector(selector);

				recalculateOffset($selector, $body);

				window.requestAnimationFrame(function() {
					recalculateOffset($selector, $body);	
				});

				$(window).on('tmp_resize', function() {
					recalculateOffset($selector, $body);
				});

				$(window).on('tmp_reflow', function() {
					recalculateOffset($selector, $body);
				});

				setTimeout(function() {
					recalculateOffset($selector, $body);
				}, 250);

				setTimeout(function() {
					recalculateOffset($selector, $body);
				}, 2500);

			});
		}
		buildAnnotations();
		$(window).on('tmp_stream_open', function() {
			buildAnnotations();
		});

	});
})();