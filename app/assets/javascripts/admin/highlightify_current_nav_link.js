$(document).on('ready page:load', function() {
	$('.nav a[href="'+ window.location.pathname +'"]').parent().addClass('active');
});