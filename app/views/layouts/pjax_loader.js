(function() {
	console.log('uo')
	var last_load_start;
	var loading_timer;
	$(document).on("page:fetch", function() {
		last_load_start = (new Date()).getTime();
		loading_timer = setTimeout(function() {
			console.log('slow page, showing load-header...')
			//$('.load-header').show();
		}, 200)		
	});
	$(document).on("page:receive", function() {
		clearTimeout(loading_timer);
		$('.load-header').hide();
		console.log(':receive...')
	});
})();