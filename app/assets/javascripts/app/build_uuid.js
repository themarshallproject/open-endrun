window.request_uuid = (function() {
	// based on Math.uuid.js (v1.4)
	var i;
	var num_chars = 16;
	var chars = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'.split('');
	var chars_length = chars.length;
	var uuid_array = [];
	for (i=0; i<num_chars; i++) {
		uuid_array[i] = chars[0 | Math.random()*chars_length];
	}	
	var uuid = uuid_array.join('');
	window.request_uuid = uuid;	
	return function() {
		return uuid; // TODO: deprecate?
	}
}).call(this);

window.generateUUID = function(chars) {
	// based on Math.uuid.js (v1.4)
	var i;
	var num_chars = chars || 16;
	var chars = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'.split('');
	var chars_length = chars.length;
	var uuid_array = [];
	for (i=0; i<num_chars; i++) {
		uuid_array[i] = chars[0 | Math.random()*chars_length];
	}	
	return uuid_array.join('');
}