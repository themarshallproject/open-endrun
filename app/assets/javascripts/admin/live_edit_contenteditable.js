$('body').on('dblclick', '[data-remote]:not([data-remote=""])', function(item) {
	(function($item) {
		$item.attr('contenteditable', 'true');
		$item.focus();
		$item.blur(function() {
			$item.attr('contenteditable', 'false');
			$.post('/api/v1/inline_edit', {
				key: $item.attr('data-remote'),
				value: $item.text().trim()
			}).done(function(result) {
				console.log(result);
			});
		});
	})($(this));
});