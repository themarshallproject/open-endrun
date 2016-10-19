$(document).ready(function() {
	$('body').on('click', '.set-to-now', function(e) {
		e.preventDefault();
		var target_selector = $(this).attr('data-target');
		var year    = $(target_selector+'_1i');
		var month   = $(target_selector+'_2i');
		var day     = $(target_selector+'_3i');
		var hour    = $(target_selector+'_4i');
		var minute  = $(target_selector+'_5i');

		var pad = function(i) {
			return ("0"+i).slice(-2);
		}

		var now = new Date();
		year.val(       now.getFullYear() );
		month.val(      now.getMonth()+1  );
		day.val(        now.getDate()     );
		hour.val(   pad(now.getHours())   );
		minute.val( pad(now.getMinutes()) );
	});
	$('body').on('click', '.set-to-715', function(e) {
		e.preventDefault();
		var target_selector = $(this).attr('data-target');
		var hour    = $(target_selector+'_4i');
		var minute  = $(target_selector+'_5i');
		hour.val("07");
		minute.val("15");
	});
});