$(document).ready(function() {

	(function() {
		// push the data-href on the TopShelf sticky <a> into the href.
		// prevents some spiders from crawling them?
		setTimeout(function() {
			[].map.call(
				document.querySelectorAll('.ts1-os-data-href'),
				function(link) {
					link.href = link.getAttribute('data-href');
				}
			);
		}, 1000);
	}).call(this);

	var setup_topshelf_instance = function(el) {

		var $topshelf = $(el);
		var placement = $topshelf.attr('data-placement');

		var index = 0; // index into the li list

		var config = null;
		try {
			config = JSON.parse($topshelf.attr('data-config'))
		} catch(e) {
			// pass
		}

		var panes;
		var set_panes = function(num) {
			panes = 1.0*num; // changes variable declared in higher scope...
		}
		set_panes(3);

		var number_of_items = function() { return $topshelf.find('ul.active').find('li').length }
		var ul_wrap_width = function() {   return $topshelf.find('.ul-wrap').width() }
		var li_width = function() {
			var width = (ul_wrap_width() + gutter_width()) / panes;

			return width;
		}

		var gutter_width = function() {
			if (config != null && config.gutter_width != null) {
				return config.gutter_width;
			} else {
				return 30; //default
			}
		}

		var max_acceptable_index = function() {
			return parseInt(number_of_items() - panes, 10);
		}

		var current_panel_number = function() {
			return Math.ceil( (1.0*index/panes) + 1 );
		}
		var max_panel_number = function() {
			return Math.ceil( (1.0*max_acceptable_index() / panes) + 1 );
		}

		var update_nav_circles = function($container, current, max) {
			var $circles = $container.find('.nav-circles');

			if ($circles.length === 0) {
				// no nav-circles, so we're not in a stream promo... done.
				return true;
			}

			while ($circles.find('.nav-dot').length < max) {
				$circles.append($("<div />").addClass('nav-dot'));
			}

			while ($circles.find('.nav-dot').length > max) {
				$circles.find('.nav-dot').first().remove();
			}

			$circles.find('.nav-dot').each(function(index, dot) {
				if ((index+1) === current) {
					$(dot).addClass('active');
				} else {
					$(dot).removeClass('active');
				}
			});
		}

		var redraw = function(via_interaction) {

			var $ul = $topshelf.find('ul.active')
			  , $li = $ul.find('li');

			if (config === null) {

				if (window.innerWidth < 1080) {
					set_panes(2);
				} else {
					set_panes(3);
				}

			} else {
				var width = window.innerWidth;
				var breakpoint = config.breakpoints.filter(function(breakpoint) {
					if (breakpoint.min !== null && breakpoint.min >= width) {
						return false;
					}
					if (breakpoint.max !== null && breakpoint.max <= width) {
						return false;
					}
					return true;
				})[0];
				set_panes(breakpoint.panes);
			}

			$ul.removeClass('transition-active');
			$ul.css('width', number_of_items()*li_width()+'px');
			$li.css('width', li_width()+'px');

			if (config !== null) {
				$topshelf.find('.topshelf-name').css('width', (li_width() - config.gutter_width)+'px');
			}

			window.requestAnimationFrame(function() {
				if (via_interaction === true) {
					$ul.addClass('transition-active');
				}
				$ul.css('left', -1*index*li_width()+"px" );
				var counter_text = current_panel_number() + " of " + max_panel_number();
				$topshelf.find('.topshelf-counter').text(counter_text)
			});

			if (current_panel_number() === 1) {
				$topshelf.find('.left-arrow').removeClass('active')
			} else {
				$topshelf.find('.left-arrow').addClass('active')
			}

			if (current_panel_number() === max_panel_number()) {
				$topshelf.find('.right-arrow').removeClass('active')
			} else {
				$topshelf.find('.right-arrow').addClass('active')
			}

			update_nav_circles($topshelf, current_panel_number(), max_panel_number());

			window.requestAnimationFrame(function() {

				$('ul.active .topshelf-headline-truncatable').each(function() {

					(function($item) {
						var $tester = $topshelf.find('.topshelf-height-tester');
						var html = $item.attr('data-original');

						$tester.css('width', $item.width()+'px');
						$tester.html(html);

						if ($tester.height() >= 64) {
							$item.addClass('truncate')
						} else {
							$item.removeClass('truncate')
						}

						while ($tester.height() >= 64) {
							var contents = $tester.html();
							var pieces = contents.split(" ");
							pieces.pop();
							$tester.html(pieces.join(" "));
						}

						$item.html($tester.html())

					})($(this));

				})
			});
		}

		redraw();
		$(window).on('tmp_resize', redraw);

		$topshelf.find('.left-arrow').click(function(e) {
			e.preventDefault();
			index -= panes;
			if (index < 0) {
				index = 0;
			}
			redraw(true);
			report('topshelf:'+placement, 'left_arrow');
		})
		$topshelf.find('.right-arrow').click(function(e) {
			e.preventDefault();
			index += panes;
			if (index >= max_acceptable_index()) {
				index = max_acceptable_index();
			}
			redraw(true);
			report('topshelf:'+placement, 'right_arrow');
		});

		// var $picker = $topshelf.find('.topshelf-picker');

		$topshelf.find('.topshelf-title, .topshelf-picker').hover(function() {
			$(this).addClass('hover');
		}, function() {
			$(this).removeClass('hover');
		});

		var show_menu = function() {
			var $picker = $topshelf.find('.topshelf-picker');
			$topshelf.find('.topshelf-title').addClass('active');
			window.requestAnimationFrame(function() {
				$picker.css('display', 'block');//.css('opacity', 1);
			});
		}

		var hide_menu = function() {
			var $picker = $topshelf.find('.topshelf-picker');
			$picker.css('display', 'none');
			$topshelf.find('.topshelf-title').removeClass('active');
			// $picker.css('opacity', 0);
			// setTimeout(function() {
			// 	if (hover_count() === 0) {
			// 		$picker.css('display', 'none');
			// 	}
			// }, 250);
		}

		var hover_count = function() {
			return $topshelf.find('.topshelf-title, .topshelf-picker').map(function(index, item) {
				return $(this).hasClass('hover');
			}).toArray().filter(function(item) {
				return item === true;
			}).length;
		}

		$topshelf.find('.topshelf-title, .topshelf-picker').mouseenter(function() {
			show_menu();
		});
		$topshelf.find('.topshelf-title, .topshelf-picker').mouseleave(function() {
			window.requestAnimationFrame(function() {
				if (hover_count() === 0) {
					hide_menu();
				}
			});
		});

		var set_ul = function(slug, animate) {
			$topshelf.find('ul').removeClass('active').hide();
			var $ul = $topshelf.find('ul.'+slug+'-items');
			$ul.css('display', 'block').addClass('active');

			$topshelf.find('.topshelf-desc').hide();
			$topshelf.find('.topshelf-desc-'+slug).show();

			var title_display = $topshelf.find(".picker-item[data-selection=\""+slug+"\"]").text();
			$topshelf.find('.topshelf-title-display').text( title_display );

			$topshelf.find('.picker-item').each(function() {
				if ($(this).attr('data-selection') === slug) {
					$(this).hide();
				} else {
					$(this).show();
				}
			});


			if (animate === true) {
				index = 2;
				redraw(false); // dont animate
			}
			window.requestAnimationFrame(function() {
				index = 0;
				redraw(true);  // now animate
			});
		}

		if ($topshelf.attr('data-default-tab') !== undefined) {
			set_ul($topshelf.attr('data-default-tab'));
		} else {
			set_ul('opening-statement');
		}


		$topshelf.find('.picker-item').click(function(e) {
			e.preventDefault();
			var slug = $(this).attr('data-selection');
			report('topshelf:'+placement, 'select:'+slug)
			set_ul(slug, true);
			hide_menu();
		});

		$topshelf.find('.signup-scroll-return').click(function(e) {
			e.preventDefault();
			index = 0;
			redraw(true);

			$topshelf.find('.email-signup-field').focus();
		});

	}

	var start_tracking_scroll = function(el) {

		(function(el) {
			var $el = $(el);
			var placement = $el.attr('data-placement');
			var id = $el.attr('data-topshelf-id');
			var $dock = $('.topshelf-dock[data-topshelf-id=' + id + ']');
			var dock_top = $dock.position().top;
			var ts_height =  $el.height();
			$dock.css('height', ts_height+'px');

			var last_scroll = 0;
			var last_direction = 'down';
			var inflection_reference_depth = 0;

			var enable_sticky = function() {
				$el.addClass('sticky-active');
				$dock.addClass('sticky-active');
			}
			var disable_sticky = function() {
				$el.removeClass('sticky-active');
				$dock.removeClass('sticky-active');
			}

			var show_sticky = function() {
				if (window.disableTopshelfShow && window.disableTopshelfShow > (new Date()).getTime()) {
					console.log('preventing show_sticky w dTS')
					return false;
				}
				if ($el.hasClass('sticky-hide-up') === true) {
					$el.removeClass('sticky-hide-up');
					report('topshelf:'+placement, 'scrollup_show');
				}
			}

			var hide_sticky = function() {
				if ($el.hasClass('sticky-hide-up') === false) {
					$el.addClass('sticky-hide-up');
				}
			}

			$(window).on('tmp_scroll', function() {
				var scroll_top = $(window).scrollTop();
				var current_direction = (last_scroll > scroll_top) ? 'up' : 'down';

				var is_shown = function() { return ($el.hasClass('sticky-hide-up') === false); }
				var scrollup_tolerance = 100;
				var scrolldown_tolerance = 15;
				var nav_height = 64;
				var acceptable_turnaround_point = dock_top + 2*ts_height + scrollup_tolerance;

				if (last_direction != current_direction) {
					inflection_reference_depth = scroll_top;
				}

				var inflection_distance = Math.abs(inflection_reference_depth - scroll_top);

				if (current_direction === 'up') {
					if (scroll_top < dock_top-nav_height) {
						disable_sticky();
						hide_sticky();
					} else if ((inflection_distance >= scrollup_tolerance) && (inflection_reference_depth > acceptable_turnaround_point)) {
						enable_sticky();
						show_sticky();
					}

					// if we're up and in the zone and it's not shown... make sure it's not fixed. TODO
				}

				if (current_direction === 'down') {
					if ((inflection_distance > scrolldown_tolerance) && (scroll_top > dock_top+ts_height)) {
						hide_sticky();
					}
				}

				last_scroll = scroll_top;
				last_direction = current_direction;
			});

		})(el);
	}

	setup_topshelfs = function() {
		$('.topshelf, .topshelf-collection').each(function() {
			if (!$(this).hasClass('ts-running')) {
				$(this).addClass('ts-running')
				setup_topshelf_instance($(this));

				if ($(this).hasClass('topshelf-collection') === false) {
					start_tracking_scroll($(this));
				}
			}
		});
	}

	$(window).on('setup_topshelf', function() {
		setup_topshelfs();
	});
	setup_topshelfs();

});
