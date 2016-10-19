// // disabled 20151103
//
// $(document).ready(function() {
// 	if (window.is_post_index_admin === undefined) {
// 		return false;
// 	}

// 	var median = function(arr) {
// 		var sorted = arr.sort(function(a, b){return a-b});
// 		var offset = Math.floor(sorted.length/2.0);
// 		return sorted[offset];
// 	}

// 	$.getJSON('/admin/thriller/social_snapshot').done(function(json) {	
// 		var facebook_counts = json.links.map(function(item) { return item.facebook });
// 		var facebook_median = median(facebook_counts);
		
// 		var twitter_counts = json.links.map(function(item) { return item.twitter });
// 		var twitter_median = median(twitter_counts);

// 		json.links.forEach(function(link) {
// 			var $fb = $('.post-admin-index-social-facebook[data-url="'+link.url+'"]');
// 			$fb.find('a').html(link.facebook);
// 			$fb.find('a').attr('title', Math.round(100.0*link.facebook/facebook_median, 1)+"% of Facebook median ("+facebook_median+")");

// 			var $tw = $('.post-admin-index-social-twitter[data-url="'+link.url+'"]');
// 			$tw.find('a').html(link.twitter);
// 			$tw.find('a').attr('title', Math.round(100.0*link.twitter/twitter_median, 1)+"% of Twitter median ("+twitter_median+")");
// 		});
// 	});
// });