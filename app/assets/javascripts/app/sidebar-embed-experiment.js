(function() {
	// check out post id=429-how-germany-does-prison

	var create = function(tagName, className, innerText) {
		var el = document.createElement(tagName);
		if (className) {
			el.className = className;
		}
		if (innerText) {
			el.innerText = innerText;
		}
		return el;
	}

	var getPostId = function(el) {
		var article = $(el).closest('article');
		return parseInt( article.attr('class').split('-')[1], 10 ); // yuck
	}

	var hideChrome = function(el) {
		return $(el).parent().find('.hide-if-empty').hide();
	}

	var slicePosts = function(el, posts) {
		var maxPostsString = $(el).attr('data-max-posts');
		if (maxPostsString !== undefined) {
			var maxPosts = parseInt(maxPostsString, 10);
			return posts.slice(0, maxPosts);
		} else {
			return posts;
		}		
	}

	var template = function(el, data) {
		var postId = getPostId(el);

		if (data.posts.length === 0) {
			hideChrome(el);
			return;
		}

		if (data.posts.length === 1 && data.posts[0].id === postId) {
			hideChrome(el);
			return;
		}

		slicePosts(el, data.posts).filter(function(post) {
			return post.id != postId;
		}).forEach(function(post) {
			var li = create('li', 'item');
			
			var date = create('div', 'date');			
			var dateSpan = create('span', '', moment(post.published_at).format("MM.DD.YYYY"));
			date.appendChild(dateSpan);
			li.appendChild(date);

			var headline = create('div', 'headline');
			var headlineA = create('a', '', post.title);
			headlineA.href = post.url;
			headline.appendChild(headlineA);
			li.appendChild(headline);

			el.appendChild(li);
		});

		// el.appendChild(ul);
	}

	var fetch = function(el) {
		if (el.getAttribute('data-loaded') === 'true') {
			return;
		} else {
			el.setAttribute('data-loaded', 'true');
		}

		var path = el.getAttribute('data-path');
		$.getJSON(path).done(function(data) {
			template(el, data);
		});
	}
	var setup = function() {
		$('[data-sidebar-v1],[data-sidebar-germany]').each(function(_, el) {
			fetch(el);
		});
	}

	$(document).ready(setup);
	$(window).on('tmp_stream_open', setup);
})();