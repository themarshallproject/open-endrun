(function() {
	var data;
	try {
		data = JSON.parse(localStorage['v1_grafs_seen'])
	} catch (e) {
		data = {};
	}
	$(document).on('ready page:load', function() {
		$('*')
			.filter(function() {
				return ($(this).attr('data-md5') !== undefined)
			})				
			.each(function() {
				var hash = $(this).attr('data-md5');
				console.log('h', hash, data[hash])
				if (data[hash] === undefined) {						
					$(this).addClass('first-seen')
					data[hash] = parseInt( ((new Date()).getTime())/1000 )
					localStorage['v1_grafs_seen'] = JSON.stringify(data);
				}
			});

	});
	
})();