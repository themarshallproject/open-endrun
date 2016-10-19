$(document).ready(function() {

	try {
		var evicted_items = 0;
		for (var i=0, l=localStorage.length; i<l; i++) {
			var key = localStorage.key(i) || "";
			if (key.indexOf('post:') >= 0) { // careful, the matches more than just the beginning
				evicted_items += 1;
				localStorage.removeItem(key);
			}
		}
	} catch(e) {
		// log
	}
	// console.log('evicted', evicted_items, 'items from localStorage');

	$('body').on('mouseenter', '.stream-post, .stream-newsletter', function() {
		$(this).addClass('hover');
	});
	$('body').on('mouseleave', '.stream-post, .stream-newsletter', function() {
		$(this).removeClass('hover');
	});

	$('body').on('click', '.stream-newsletter', function(e) {
		var $this = $(this);
		window.location = $this.attr('data-path');
	});

	$('body').on('click', '.js-trigger-stream-expandable', function(e) {
		if (e.target.tagName.toLowerCase() === 'a') {
			// don't hijack <a>, needed for rubric and bio links
			return true;
		}

		e.preventDefault();
		// var $link = $(this).find('.stream-expandable');
		// $link.click();
		show_post( $(this).closest('section').attr('data-post-id') );
	});

	$('body').on('click', '.js-trigger-stream-click', function(e) {
		if (e.target.tagName.toLowerCase() === 'a') {
			// don't hijack <a>, needed for rubric and bio links
			return true;
		}

		e.preventDefault();
		var $link = $(this).find('.post-link');
		window.location.href = $link.attr('href');
		return false;
	});

	var scroll_opened_promo = function($item) {
		var menu_height = $('header').height();
		var article_top = $item.position().top;
		// var hed = $item.find('h1');
		// var hed_top = hed.position().top + hed.height()/2.0;
		var window_top = $(window).scrollTop();
		var header_bottom = $(window).scrollTop() + menu_height;
		var window_height = $(window).height();
		var article_top_to_header_bottom = article_top - header_bottom;
		// var hed_mid_delta = hed_to_window_top - 0.50 * window_height;
		// console.log(hed_mid_delta);

		// var test_animation_length = 150 + Math.pow(article_top_to_header_bottom, 0.8);
		// console.log(article_top_to_header_bottom, test_animation_length)

		$("html, body").animate({
			scrollTop: ($(window).scrollTop() + article_top_to_header_bottom)+'px',
		}, 350);

	}

	window.get_open_stories = function() {
		return $('section.stream-post').filter(function() {
			return $(this).attr('data-opened-at') !== undefined;
		}).sort(function(item) {
			return parseInt($(item).attr('data-opened-at'), 10);
		});
	}

	window.is_story_open = function($story) {
		return $story.attr('data-opened-at') !== undefined;
	}

	window.close_story = function($story) {
		// console.log('in close_story', $story);
		var post_id = $story.attr('data-post-id');
		var promo_html = localStorage.getItem("stream:post:"+post_id);
		//console.log('restoring promo html: ', promo_html);
		$story.html(promo_html);
		$story.removeAttr('data-opened-at');
	}

	window.window_pop_state = function(event_state, callback) {

		// var $closing_story = $( get_open_stories()[0] );
		// var closing_post_id = $closing_story.attr('data-post-id');

		// $closing_story.html( localStorage.getItem("stream:post:"+closing_post_id) );
		// $closing_story.removeAttr('data-opened-at');

		// setTimeout(function() {
		// 	$closing_story.css('opacity', 0);
		// }, 1);

		if (window.stream_config.is_homepage !== true && window.location.pathname === '/') {
			window.location = '/';
		} else {
			if (window.stream_config.is_homepage !== true) {
				window.jump_to_top = true;
				//console.log('should jump to top.')
			}
		}

		if (event.state !== null) {

			// we got a post ID. one of a couple things is happening:
			// 1. we clicked 'back'    -- we need to close current the story, then jump to the current thing
			// 2. we clicked 'forward' -- we need to open  next the story, then jump to it

  			// console.log('restore to:', event.state);
  			var post_id = event.state.post_id;
  			show_post(post_id);

  		} else {

  			// we did not get a post id
  			// we're probably now on the homepage with no promos opened
  			// so we scroll to the most recently *closed* one

  			var open_stories = get_open_stories();

  			$(open_stories).addClass('visited');

  			var $most_recently_opened_story = $( open_stories[0] );
  			// console.log('open_stories:', open_stories, typeof open_stories);//, 'closing all and scrolling to:', $most_recently_opened_story)

			if ($most_recently_opened_story.length === 0) {
				//console.log('MROP empty, jumping out of pop_state')
				return true;
			}

			open_stories.each(function(index, item) {
				//console.log('should close', item);
				close_story($(item));
			});

			// if (window.jump_to_top === true) {
			// 	setTimeout(function() {
			// 		$(window).scrollTop(0);
			// 	}, 1);
			// 	return true;
			// }

			window.requestAnimationFrame(function() {

	  			$("html, body").scrollTop($most_recently_opened_story.position().top - 120);

	  			window.requestAnimationFrame(function() {
						$("html, body").animate({
					 		scrollTop: ($most_recently_opened_story.position().top-60)+'px',
					 	}, 400);
	  				// $(window).scrollTop($most_recently_opened_story.position().top - 150)
	  			});

  			});

  		}

	}


	window.stream_keys = function() {
		return $('section').map(function() {
			return $(this).attr('data-stream-key');
		}).toArray();
	}

	window.onpopstate = function(event) {
  		window_pop_state(event.state);
  		report('stream', 'onpopstate');
	};

	var url_for_stream_item = function($item) {
		return $item.attr('data-post-path');
	}

	var find_post_by_id = function(id) {
		var el = $('section').filter(function() {
			return $(this).attr('data-post-id') === ('' + id);
		})[0];
		return $(el);
	}

	var show_post = function(post_id) {

		var $post = find_post_by_id(post_id);
		var post_updated_at = $post.attr('data-post-updated-at');

		if (is_story_open($post) === true) {
			//console.log('destination story is open, move to it.')
			move_to_story($post);
			$post.trigger('tmp_stream_restore');
		} else {
			//console.log('destination story is closed, open and move to it.')
			try {
				open_stream_promo($post);
			} catch(e) {
				setTimeout(function() {
					window.location = $post.attr('data-post-path');
				}, 5);
				report('stream', 'faied_open_stream_promo');
			}
		}

		generate_ga_event($post.attr('data-ga-config'));
	}

	var generate_ga_event = function(stringified_json) {
		var data = JSON.parse(stringified_json);
		//console.log('sending event w/', data);

		if (!window['ga']) {
			console.log('skipping GA event for', stringified_json);
			return;
		}

		ga('send', 'pageview', {
			'page': data.path,
			'title': data.title,
  			'dimension1':  data.dimension1,
  			'dimension2':  data.dimension2,
  			'dimension3':  data.dimension3
		});
		$(window).trigger('stream_open_analytics_event', [data.path]);

	}

	var move_to_story = function($item) {
		window.requestAnimationFrame(function() {
			$(window).scrollTop($item.position().top);
		});
	}

	var open_stream_promo = function($post) {
		var post_id = $post.attr('data-post-id')
		var post_updated_at = $post.attr('data-post-updated-at');
		$post.attr('data-opened-at', (new Date()).getTime());
		//console.log('setting stream_post_promo html', $post.html());
		try {
			localStorage.setItem("stream:post:"+post_id, $post.html()); // stash the promo so we can grab it if they collapse the post ('back')
		} catch(e) {
			window.localstorage_failing = true;
			//console.log('localStorage failed')
		}
		// console.log(localStorage.getItem("stream:post:"+post_id));

		var animation_length = 350; // ms. defined in CSS too unfortunately

		$post.css('opacity', 0); // this will animate because of a "transition: opacity 0.XXs;" in CSS

		var _fetch_start = (new Date()).getTime();

		get_post_html(post_id, post_updated_at, function(html, error) {
			var post_html = html;

			var _fetch_time = (new Date()).getTime() - _fetch_start;

			report('stream', 'open'); // because adhoc analytics?!

			// what if the post takes longer than 350ms to load?!
			var callback_fired = false;
			$post.one('webkitTransitionEnd otransitionend oTransitionEnd msTransitionEnd transitionend', function(e) {
				if (callback_fired === true) {
					// only allow this to fire once. jump out.
					return true;
				}
				callback_fired = true;

				history.pushState({ post_id: post_id }, '', url_for_stream_item($post) );

				window.requestAnimationFrame(function() {
					// wrap this so that if there's an invalid script tag
					// in what we're about in inject (below this function)
					// this will still run.
					// without this, the page stays at opacity 0 because the thrown error
					// prevents the new page from being brought in.
					// TODO: there's probably a smarter way to do this.

					$post.css('opacity', 1); // animated in CSS

					//console.log('pushState about to happen to:', url_for_stream_item($post));

					if (url_for_stream_item($post) === undefined) {
						return false;
					}
					scroll_opened_promo($post);

					$post.trigger('tmp_stream_open');
					$(window).trigger('tmp_stream_open');

				}); // this will run a bit *after* the html() call below. so if inserting <script> or whatever happens, this will still run and fade in the post.

				$post.html(post_html);

			});


		}); //get_post_html end
	}


	var get_post_html = function(post_id, post_updated_at, callback) {
		// callback is (data, error)
		var cache_key = "post:"+post_id+":"+post_updated_at;
		var post_html = null;
		try {
			post_html = localStorage.getItem(cache_key);
		} catch (err) {
			console.log('get_post_html: error getting localStorage item', err);
		}

		if (post_html !== null) {
			//console.log('get_post_html', cache_key, 'from localStorage');
			callback(post_html);
			return true;
		}

		if (post_id === undefined) {
			callback("no post id!", null);
			return;
		}

		$.get('/api/v1/post_html/'+post_id).done(function(html) {
			try {
				localStorage.setItem(cache_key, html);
			} catch (err) {
				console.log('get_post_html: error setting localStorage item', err);
			}
			//console.log('get_post_html', cache_key, 'from AJAX');
			callback(html);
		}).fail(function(error) {
			callback(null, error);
		});
	}

	window.prefetching_posts = [];
	$('body').on('mouseenter touchstart', 'section.stream-post', function() {
		var post_id = $(this).attr('data-post-id');
		var post_updated_at = $(this).attr('data-post-updated-at');
		var cache_key = "post:"+post_id+":"+post_updated_at;

		if (prefetching_posts.indexOf(cache_key) === -1) {
			prefetching_posts.push(cache_key);
			get_post_html(post_id, post_updated_at, function() {
				//console.log('successfully prefeched', cache_key);
			});
		}
	});

	$('body').on('click', 'section.stream-post a.stream-expandable', function(e) {

		if (window.stream_open === false) {
			return true;
		}
		//console.log('got click on streampromo')
		e.preventDefault();
		var $item = $(this).closest('section.stream-post'); // parent, up a few. the 'wrapper' for the promo/expanded story
		var post_id = $item.attr('data-post-id');

		show_post(post_id);
	});

	window.stream_load_if_close_to_bottom = function () {
		var $bottom_of_stream = $('.bottom-of-stream');

		if ($bottom_of_stream.length !== 1) {
			return false;
		}

		var depth = ($bottom_of_stream.position().top - $(window).scrollTop()) - $(window).height();
		if (depth < 500) {
			if (stream_is_downloading === true) {
				return false;
			}
			stream_is_downloading = true;
			add_more_items_to_stream();
		}
	};
	$(window).bind('tmp_scroll', stream_load_if_close_to_bottom);

	window.oldest_stream_post = function() {
		var dateslugs = $("*[data-stream-dateslug]").map(function() {
			return  parseInt( $(this).attr('data-stream-dateslug'), 10);
		}).toArray().sort();

		var oldest_date = dateslugs[0];
		if (oldest_date === undefined) {
			return ""; // no posts, like on a hottub'd post. so no date, which will then default to today's content
		} else {
			return oldest_date;
		}
	}

	window.is_stream_key_on_page = function(key) {
		return stream_keys().indexOf(key) >= 0;
	}

	window.is_post_on_except_list = function(item) {
		if (item.key.indexOf('post:') === -1) {
			// only filtering posts. the post stream key starts with 'post:'
			return false;
		}
		var except_posts = window.stream_config.except_posts;
		var post_id = parseInt(item.key.split(":")[1], 10);
		if (except_posts.indexOf(post_id) >= 0) {
			// console.log('NOT allowed', post_id, except_posts);
			return true;
		} else {
			// console.log('IS allowed', post_id, except_posts);
			return false;
		}

	}

	window.stream_is_downloading = false;  // TODO global state
	var add_more_items_to_stream = function() {
		var endpoint = '/api/v1/stream/' + oldest_stream_post();
		//console.log('requesting', endpoint);
		$.get(endpoint).done(function(result) {
			stream_is_downloading = false;
			result.items.forEach(function(item) {

				if (is_stream_key_on_page(item.key) === false && is_post_on_except_list(item) === false) {
					$('.bottom-of-stream').before(item.html);
				} else {
					//console.log('stream_key', item.key, 'already on page, skipping');
				}
			});
			report('stream', 'add_more_items');
			$(window).trigger('tmp_stream_added_items'); // check for lazyload background-images
		});
	}
});
