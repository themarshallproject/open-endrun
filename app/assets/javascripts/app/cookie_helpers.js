window.read_cookie = function(name) {
	var nameEQ = name + "=";
	var ca = document.cookie.split(';');
	for(var i=0;i < ca.length;i++) {
		var c = ca[i];
		while (c.charAt(0)==' ') c = c.substring(1,c.length);
		if (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length,c.length);
	}
	return null;
}
window.readCookie = function(name) {
	var nameEQ = name + "=";
	var ca = document.cookie.split(';');
	for(var i=0;i < ca.length;i++) {
		var c = ca[i];
		while (c.charAt(0)==' ') c = c.substring(1,c.length);
		if (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length,c.length);
	}
	return null;
}

window.set_cookie = function(key, value) {
	var d = new Date();
	d.setTime(d.getTime() + (5*365*24*60*60*1000)); // 5 years
	var expires = "expires="+d.toUTCString();
	document.cookie = key + "=" + value + "; " + expires;
}
window.setCookie = function(key, value) {
	var d = new Date();
	d.setTime(d.getTime() + (5*365*24*60*60*1000)); // 5 years
	var expires = "expires="+d.toUTCString();
	document.cookie = key + "=" + value + "; " + expires;
}