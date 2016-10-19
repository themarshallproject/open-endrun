var report = function(category, action, label) {
	if (!window['ga']) {
		window._tmp_no_ga = true;
		return false;
	}
	try {
		ga('send', 'event', category, action, label, {'nonInteraction': 1});
	} catch(e) {		
		console.log('error reporting event', category, action, label, e);
	}
}