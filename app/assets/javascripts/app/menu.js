$(document).ready(function() {
	$('.header-menu-trigger').click(function(e) {
		e.preventDefault();

		$('.header-menu-button').toggleClass('active'); // do the animation

		var menu_wrapper = $('.menu-wrapper');

		menu_wrapper.toggleClass('menu-hidden');
		if (menu_wrapper.hasClass('menu-hidden')) {
			$('body').removeClass('lock-scrolling');
			restore_page();
			report('menu-trigger', 'closed-icon');
			// $('body>.featured-container,body>.container,body>.stream').animate({'margin-left':'0px'}, 333);

		} else {
			$('body').addClass('lock-scrolling');
			dim_page();
			report('menu-trigger', 'opened');
			// $('body>.featured-container,body>.container,body>.stream').animate({'margin-left':'320px'}, 333);
		}
	});

	$('.lights-out').css('display', 'inline').css('z-index', '-999');

	var dim_page = function() {

		setTimeout(function() {
			$('.lights-out').css('opacity', '0.6').css('z-index', '10');
		}, 1);

	}
	var restore_page = function() {
		setTimeout(function() {
			$('.lights-out').css('opacity', '0').css('z-index', '-999');
		}, 1);
	}

	$('body').on('click', '.lights-out', function() {
		$('.menu-wrapper').addClass('menu-hidden');
		$('.header-menu-button').toggleClass('active');
		$('body').removeClass('lock-scrolling');
		restore_page();
		report('menu-trigger', 'closed-offmenu');
	});
	// $(window).scroll(function() {
	// 	$('.menu-wrapper').addClass('menu-hidden');
	// })
});
