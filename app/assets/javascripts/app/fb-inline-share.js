/*
Example:

	<a  href="#"
		class="fb-inline-share"
		data-fb-link="https://www.themarshallproject.org/2015/07/09/the-sex-offender-test#test"
		data-fb-picture="https://d1n0c1ufntxbvh.cloudfront.net/photo/7645d080/9277/1200x/"
		data-fb-description="Can the Abel Assessment tell if you're a potential child-molester? A lot of judges think so. TEST"
		data-fb-name="The Sex-Offender TEST"
	>Share on FB</a>
*/
(function() {

	var getBuilder = function(el) {
		return function(attr) {
			return el.getAttribute('data-fb-'+attr);
		}
	}

	var dispatch = function(el) {
		var get = getBuilder(el);
		var data = {
  			method:      'feed',
  			link:        get('link'),
  			caption:     get('caption'),
  			picture:     get('picture'),
  			description: get('description'),
  			name:        get('name'),
  			ref:         'inline'
		}

		FB.ui(data, function(response) {
			console.log('shareResponse', response)
		});
	}

	var setup = function() {
		$('body').on('click', '.fb-inline-share', function(e) {
			e.preventDefault();
			dispatch(this);
		});
	}

	$(window).load(function() {
		setTimeout(function(){
			// FB boot happens on window.load, so give it a second to settle
			setup();
		}, 100);
	});

})();
