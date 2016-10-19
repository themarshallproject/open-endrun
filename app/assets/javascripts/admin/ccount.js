(function() {

	var count = 0;

	var pull = function() {
		$.getJSON(window.CONFIG.CCOUNT_HOST+'/api/v1/today_count.json', {
			't': (new Date()).getTime(),
			'path': window.location.path
		}).success(function(data) {
			console.log(data);
			count = parseInt(data.count);
			render();
		}).error(function(err) {
			console.error(err);
		});
	}

	var render = function() {
		if (count > 0) {
			var current_count = parseInt($('.ccount-attach').text());
			/*_.range(current_count, count).each(function(idx, value){
				console.log(idx, val);
			});*/
			$('.ccount-attach').text(count);
		}
	}
	
	$(document).on('ready', function() {		
		//pull();
		//render();
		$(document).on('click', function() {			
			count += 1;
			render(); // optimistic

			/*$.post(window.CONFIG.CCOUNT_HOST+'/api/v1/click', {
				t: (new Date()).getTime()
			}).success(function(data) {
				console.log('saved click');
			}).error(function(err) {
				console.error(err);
			});*/
		});
	});


	//setInterval(pull, 3000);

})();