var watch_char_count = function($field) {
	var max_char_count = parseInt($field.attr('data-max-character-count'), 10);
	var $counter = $('<div class="max-char-counter"></div>').insertAfter($field);
	$field.on('keydown keyup boot', function() {
		var current_char_count = $field.val().length;
		var delta = max_char_count - current_char_count;
		$counter.html(delta);
		if (delta < 0) {
			$counter.addClass('post-over-max-character-count');
		} else {
			$counter.removeClass('post-over-max-character-count');
		}
	})
	$field.trigger('boot');		
}

$(document).ready(function() {
	$('*[data-max-character-count]').each(function() {
		watch_char_count($(this));		
	});
});