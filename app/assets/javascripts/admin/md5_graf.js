(function(){
	var highlight_by_hash = function () {
		$('.hash-highlighted').css('background', 'rgba(0,0,0,0.0)').removeClass('hash-highlighted');
		var matching = $('*[data-md5="'+window.location.hash.replace('#', '')+'"]');
		matching.addClass('hash-highlighted').css('background', 'rgba(255, 255, 60, 0.8)');
	}
	$(window).on('hashchange', highlight_by_hash);
	$(document).on('ready page:load', function() {
		$('p, ul, li, h1, h2, h3').each(function() {
			if ($(this).attr('data-md5') !== undefined) {			
				$(this).click(function() {
					window.location.hash = $(this).attr('data-md5'); // TODO: this will dupe, probably, for the same graf contents
				});
			}
		});
		highlight_by_hash();
	});
})();