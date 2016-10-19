(function() {
	var getMeta = function(property) {
		var content = "";
		var el = document.querySelector('meta[property="'+property+'"]');
		try {
			content = el.getAttribute('content');			
		} catch(e) { }
		return content;
	}
	var url_query = [
		['url', window.location], 
		['title', document.title],
		['og_image', getMeta('og:image')],
		['og_title', getMeta('og:title')]
	].map(function(parts) {
		return parts[0] + "=" + encodeURIComponent(parts[1]);
	}).join('&');
	var popup = window.open(
		window.TMPGatorBase+"?"+url_query,
		"Gator",
		"width=700,height=700,left=400,top=200,directories=no,titlebar=no,toolbar=no,location=no,status=no,menubar=no,scrollbars=no"
	);
	popup.focus();
	console.log(url, title, og_image, url_query);
})();