$(document).ready(function() {
	// clicks
	$('body').on('click', '.share-button a', function(e) {
		report('share-tools', $(this).parent().attr('data-action')+':click');
	});

	// hovers
	$('body').on('mouseover', '.share-button a', function(e) {		
		debounce_event( $(this).parent().attr('data-action') );
	});
	var debounce_event = _.debounce(function(action) {
		report('share-tools', action+':hover');
	}, 500, true);	

});