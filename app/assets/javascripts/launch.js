//= require 'jquery'
//= require 'admin/underscore'
$(document).ready(function() {	

	var report = function(event, data) {
		ga('send', 'event', event, data.action);
	}

	$.get("/api/v1/token").done(function(token){
		window.csrf_token = token;
		$.ajaxSetup({
			headers: { 'X-CSRF-Token': token }
		});
		report('launch_page', {action: 'recieve_csrf'});
	});

	var last_resize = 0;
	var resize_words = function() {
		if ((new Date()).getTime() - last_resize > 300) {
			var h = $(document).height() + 'px';
			$('.words').height(h);
			last_resize = (new Date()).getTime();
		} 
	};

	$(window).resize(resize_words);
	resize_words();

	var valid_email = function(value) {
		// return (value.indexOf('@') >= 0) && (value.indexOf('.') >= 0) && (value.length > 6);
		return /^[^@]+@[^@]+\.[^@]+$/.exec(value) !== null;
	}

	var validate_email_addresses = function() {
		$('.js-validate-email').each(function() {
			var $this = $(this);
			(function($input) {
				var $submit = $input.parent().find('button');
				
				$submit.attr('disabled', 'true');
				$submit.addClass('js-not-valid');
				$input.on('keyup', function() {
					var value = $input.val();
					var is_valid = valid_email(value);
					if (is_valid === true) {
						
						$submit.removeClass('js-not-valid');
						$this.addClass('js-valid');
						$submit.addClass('js-valid');
						$submit.removeAttr('disabled');							
						
					} else {
						$submit.removeClass('js-valid'); /* refactor... duped above. TODO */
						$this.removeClass('js-valid');
						$submit.addClass('js-not-valid');
						$submit.attr('disabled', 'true');
					}
				});
			})($this);
		});
	}
	validate_email_addresses();

	var perform_email_signup = function(email) {
		$.post('/api/v1/email/subscribe', {
			email: email
		}).fail(function(error) {
			console.error(error);
			update_email_ui('fail');
			report('launch_page', {action: 'email_signup_fail'});
		}).done(function(continue_token) {
			window.continue_token = continue_token;
			update_email_ui('success');
			report('launch_page', {action: 'email_signup_success'});
		});
	}

	var update_email_ui = function(result) {
		var $container  = $('.email-signup-container');

		$container
			.animate({opacity: 0}, 250, function() {
				$container
					.html(  $('.success-message').html() )
					.animate({opacity: 1}, 250)
			});				
		
	}

	var process_form = function() {
		var email = $('.email-signup-field').val();
		// if (valid_email(email) === true) {
			perform_email_signup(email);
		// } else {
		// 	// TK
		// }		
	}

	$('form').submit(function(e) {
		e.preventDefault();
		process_form();
	});

	$('.submit-email').click(function() {
		process_form();
	});
});