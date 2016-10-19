(function() {

	var validEmail = function(email) {
		return email.match(/[^@]+@[^@]+/) !== null;
	}

	var findTargets = function() {
		return $('.email-onboard');
	}

	var getContext = function($el) {
		return JSON.parse($el.attr('data-context'));
	}
	var setContext = function($el, context) {
		$el.attr('data-context', JSON.stringify(context));
	}

	var recalcEl = function($el) {
		var width = $el.width();
		var height = $el.height();

		var context = getContext($el);

		context.checkboxes = $el.attr('data-checkboxes') === 'true';
		// if (context.checkboxes && !context.occasionalEnabled) {
		// 	// this introduces a bug where if check boxes are enabled, but the screen shinks,
		// 	// then the screen expands again, they won't be re-enabled. wontfix for now.
		// 	context.checkboxes = (width >= 1010); // this is a JavaScript breakpoint, basically.
		// }
		context.oneLine = (height <= 70);     // this is a JavaScript breakpoint, basically.
		context.emailValid = true;
		context.formFloatRight = (width >= 880);

		setContext($el, context);
		render($el);
	}

	var dynamicSizing = function($el) {
		$(window).on('tmp_resize', function() {
			recalcEl($el);
		});
		recalcEl($el);
	}

	var successCallback = function(data) {
		$('.email-signup').hide();
		// var $response = $el.find('.response');
	}

	var failureCallback = function($el, err) {
		var $response = $el.find('.response');
		var data = JSON.parse(err.responseText);
		$response.text(data.error.message);
	}

	var submitEmail = function($el, email, options, callback) {

		// console.log($el)

		if (email === "") {
			console.error("no email address provided");
			return;
		}

		var $submit = $el.find('.submit');
		var $input = $el.find('.email');

		$el.find('.response').text('');

		var previousSubmitLabel = $submit.attr('value');
		$submit.attr('value', 'Saving...')

		var placement = $el.attr('data-placement') || 'unknown';

		var options = options || {};
		var endpoint = "/api/v3/email/subscribe";
		var payload = JSON.stringify({
			signup: {
				email: email,
				options: options,
				placement: placement,
				url: window.location.href,
				referer: document.referrer,
				t: window.readCookie('t'),
				_utpv: window.readCookie('_utpv'),
				user_agent: window.navigator.userAgent,
			}
		});
		// console.log('submitting')
		$.ajax({
			method: 'POST',
			url: endpoint,
			headers: {
				'X-CSRF-Token': window.csrf_token,
				'Content-Type': 'application/json',
				'X-Page-Referer': document.referrer,
				'X-Page-URL': window.location.href
			},
			data: payload // stringified
		}).fail(function(err){
			// console.log('error')
			$submit.attr('value', previousSubmitLabel);

			failureCallback($el, err);
		}).done(function(data) {
			// console.log('done')
			$submit.text('Thanks!');
			$submit.prop('disabled', true);
			$input.prop('disabled', true);

			successCallback(data);

			report('web-email-signup', 'subscribe', placement);
			$(window).trigger('tmp_email_signup_success');
		});
	}

	var getOptions = function($el) {
		var daily      = $el.find('.checkbox-daily').attr('data-checked') === 'true';
		var weekly     = $el.find('.checkbox-weekly').attr('data-checked') === 'true';
		var occasional = $el.find('.checkbox-occasional').attr('data-checked') === 'true';

		var options = {
			daily: daily,
			weekly: weekly,
			occasional: occasional
		}

		if (getContext($el).checkboxes === false) {
			// if we don't have checkboxes visible, enroll in the default segments
			options.daily = true;
			options.weekly = true;
			options.occasional = false;
		}
		// console.log(options)

		return options;
	}

	var registerHandlers = function(el) {
		var $el = $(el);
		$el.on('click', '.submit', function() {
			var email = $(el).find('.email-address').val();
			var options = getOptions($(el));
			submitEmail($el, email, options);
		});

		if ($(window).width() > 700) {
			$el.on('keydown', 'input.email-address', function (e) {
				if (e.which === 13) {
					var email = $(el).find('.email-address').val();
					var options = getOptions($(el));
					submitEmail($el, email, options);
					return false;
				}
				return true;
			});
		} else {
			// skip "enter" key for email submit
		}

		$el.on('click', '.checkbox-outer', function() {
			var $fakebox = $(this).find('.fakebox');
			var previousState = $fakebox.attr('data-checked') === 'true';
			if (previousState === true) {
				$fakebox.attr('data-checked', 'false');
			} else {
				$fakebox.attr('data-checked', 'true');
			}
			updateCheckboxes($el);
		});
	}

	var updateCheckboxes = function($el) {
		var fakeboxes = $el.find('.fakebox');
		fakeboxes.each(function() {
			var checked = $(this).attr('data-checked') === 'true'
			if (checked === true) {
				$(this).html("✔");
			} else {
				$(this).html("&nbsp;");
			}
		});
	}

	var render = function($el) {
		var isAlreadyRendered = $el.closest('.email-onboard-container-wrapper').hasClass('rendered');
		if (isAlreadyRendered) {
			return;
		}
		// console.log('render', $el, isAlreadyRendered)

		var context = JSON.parse($el.attr('data-context'));
		$el.html('');

		var components = [];
		if (context.onlyForm) {
			components.push(templates.form(context.form));
		} else {
			components = [
				templates.copy(context),
				templates.archive_link(context),
				templates.form(context),
				templates.checkboxes(context),
			];
		}
		components.forEach(function(child) {
			$el.append(child)
		});
		updateCheckboxes($el);
	}

	var buildEl = function(tag, contents, className) {
		var el = document.createElement(tag);
		el.className = className;
		el.innerHTML = contents; 
		return el;
	}
	var div = function(contents, className) {
		return buildEl('div', contents, className);
	}
	var span = function(contents, className) {
		return buildEl('span', contents, className);
	}
	var link = function(href, contents, className) {
		var el = buildEl('a', contents, className);
		el.href = href;
		return el;
	}

	var templates = {
		copy: function(context) {
			if (!context.copy) {
				return "";
			}

			var el = div("", "copy");
			el.appendChild(span(context.title, 'title'));
			el.appendChild(span(context.body,  'body'));
			return el;
		},
		archive_link: function(context) {
			if (context.archiveLink) {
				return link(context.archiveLink, 'Most Recent Email', 'archive-link');
			} else {
				return '';
			}
		},
		checkboxes: function(context) {
			if (context.checkboxes === false) {
				return '';
			}

			var boxes = [
				'<div class="checkbox-outer"><div class="fakebox checkbox-daily"  data-value="daily"   data-checked="true"></div> Daily</div>',
				'<div class="checkbox-outer"><div class="fakebox checkbox-weekly" data-value="weekly"  data-checked="true"></div> Weekly</div>',
			];
			if (context.occasionalEnabled === true) {
				boxes.push('<div class="checkbox-outer"><div class="fakebox checkbox-occasional" data-value="occasional"  data-checked="true"></div> Occasional Updates</div>');
			}

			return div(boxes.join(''), 'checkboxes');
		},

		form: function(context) {
			var buttonLabel = 'Subscribe';
			var placeholder = 'email@example.com';

			var className = 'form';
			if (context.formFloatRight) {
				className += ' float-right ';
			}

			return div(
				[
				  	'<span class="response"></span>',
					'<input type="text" name="email" value="" class="email-address" placeholder="'+placeholder+'">',
				  	'<button type="submit" class="submit">'+buttonLabel+'</button>',
				].join(''),
				className
			)
		}
	}

	var generateContext = function($el) {
		var checkboxes = $el.attr('data-checkboxes') === "true";
		var occasionalEnabled = $el.attr('data-include-occasional') === "true";
		var archiveLink = $el.attr('data-archive-link');
		var copy = $el.attr('data-copy') !== 'false';

		return {
			title: 'Opening Statement',
			body: 'The best criminal justice news from around the web, delivered daily.',
			archiveLink: archiveLink,
			copy: copy,
			checkboxes: checkboxes,
			occasionalEnabled: occasionalEnabled,
		}
	}

	var boot = function() {
		findTargets().map(function(_id, el) {
			var $el = $(el);

			if ($el.attr('data-rendered') === 'true') {
				return true;
			}
			$el.attr('data-rendered', 'true');

			var context = generateContext($el);
			// console.log(context)
			setContext($el, context);

			render($el);
			registerHandlers($el);
			dynamicSizing($el);

			$el.closest('.email-onboard-container-wrapper').addClass('rendered'); // used to enable CSS			
		});
	}

	$(document).ready(function() {
		boot();
	});
	$(window).on('tmp_stream_open', function() {
		boot();
	});
	$(window).on('tmp_detect_email_signup', function() {
		boot();
	})


})();
