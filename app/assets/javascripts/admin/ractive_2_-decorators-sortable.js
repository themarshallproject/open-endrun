/*

	Ractive-decorators-sortable
	===========================

	Version 0.1.0.

	This plugin adds a 'sortable' decorator to Ractive, which enables
	elements that correspond to array members to be re-ordered using
	the HTML5 drag and drop API. Doing so will update the order
	of the array.

	==========================

	Troubleshooting: If you're using a module system in your app (AMD or
	something more nodey) then you may need to change the paths below,
	where it says `require( 'Ractive' )` or `define([ 'Ractive' ]...)`.

	==========================

	Usage: Include this file on your page below Ractive, e.g:

	    <script src='lib/Ractive.js'></script>
	    <script src='lib/Ractive-decorators-sortable.js'></script>

	Or, if you're using a module loader, require this module:

	    // requiring the plugin will 'activate' it - no need to use
	    // the return value
	    require( 'Ractive-decorators-sortable' );

	Then use the decorator like so:

	    <!-- template -->
	    <ul>
	      {{#list}}
	        <li decorator='sortable'>{{.}}</li>
	      {{/list}}
	    </ul>

	    var ractive = new Ractive({
	      el: myContainer,
	      template: myTemplate,
	      data: { list: [ 'Firefox', 'Chrome', 'Internet Explorer', 'Opera', 'Safari', 'Maxthon' ] }
	    });

	When the user drags the source element over a target element, the
	target element will have a class name added to it. This allows you
	to render the target differently (e.g. hide the text, add a dashed
	border, whatever). By default this class name is 'droptarget'.

	You can configure the class name like so:

	    Ractive.decorators.sortable.targetClass = 'aDifferentClassName';

	PS for an entertaining rant about the drag and drop API, visit
	http://www.quirksmode.org/blog/archives/2009/09/the_html5_drag.html

*/

(function ( global, factory ) {

	'use strict';

	// Common JS (i.e. browserify) environment
	if ( typeof module !== 'undefined' && module.exports && typeof require === 'function' ) {
		factory( require( 'Ractive' ) );
	}

	// AMD?
	else if ( typeof define === 'function' && define.amd ) {
		define([ 'Ractive' ], factory );
	}

	// browser global
	else if ( global.Ractive ) {
		factory( global.Ractive );
	}

	else {
		throw new Error( 'Could not find Ractive! It must be loaded before the Ractive-decorators-sortable plugin' );
	}

}( typeof window !== 'undefined' ? window : this, function ( Ractive ) {

	'use strict';

	var sortable,
		ractive,
		sourceKeypath,
		sourceArray,
		sourceIndex,
		dragstartHandler,
		dragenterHandler,
		removeTargetClass,
		preventDefault,
		errorMessage;

	sortable = function ( node ) {
		node.draggable = true;

		node.addEventListener( 'dragstart', dragstartHandler, false );
		node.addEventListener( 'dragenter', dragenterHandler, false );
		node.addEventListener( 'dragleave', removeTargetClass, false );
		node.addEventListener( 'drop', removeTargetClass, false );

		// necessary to prevent animation where ghost element returns
		// to its (old) home
		node.addEventListener( 'dragover', preventDefault, false );

		return {
			teardown: function () {
				node.removeEventListener( 'dragstart', dragstartHandler, false );
				node.removeEventListener( 'dragenter', dragenterHandler, false );
				node.removeEventListener( 'dragleave', removeTargetClass, false );
				node.removeEventListener( 'drop', removeTargetClass, false );
				node.removeEventListener( 'dragover', preventDefault, false );
			}
		};
	};

	sortable.targetClass = 'droptarget';

	errorMessage = 'The sortable decorator only works with elements that correspond to array members';

	dragstartHandler = function ( event ) {
		var storage = this._ractive, lastDotIndex;

		sourceKeypath = storage.keypath;

		// this decorator only works with array members!
		lastDotIndex = sourceKeypath.lastIndexOf( '.' );

		if ( lastDotIndex === -1 ) {
			throw new Error( errorMessage );
		}

		sourceArray = sourceKeypath.substr( 0, lastDotIndex );
		sourceIndex = +( sourceKeypath.substring( lastDotIndex + 1 ) );

		if ( isNaN( sourceIndex ) ) {
			throw new Error( errorMessage );
		}

		event.dataTransfer.setData( 'foo', true ); // enables dragging in FF. go figure

		// keep a reference to the Ractive instance that 'owns' this data and this element
		ractive = storage.root;
	};

	dragenterHandler = function () {
		var targetKeypath, lastDotIndex, targetArray, targetIndex, array, source;

		// If we strayed into someone else's territory, abort
		if ( this._ractive.root !== ractive ) {
			return;
		}

		targetKeypath = this._ractive.keypath;

		// this decorator only works with array members!
		lastDotIndex = targetKeypath.lastIndexOf( '.' );

		if ( lastDotIndex === -1 ) {
			throw new Error( errorMessage );
		}

		targetArray = targetKeypath.substr( 0, lastDotIndex );
		targetIndex = +( targetKeypath.substring( lastDotIndex + 1 ) );

		// if we're dealing with a different array, abort
		if ( targetArray !== sourceArray ) {
			return;
		}

		// if it's the same index, add droptarget class then abort
		if ( targetIndex === sourceIndex ) {
			this.classList.add( sortable.targetClass );
			return;
		}

		array = ractive.get( sourceArray );

		// remove source from array
		source = array.splice( sourceIndex, 1 )[0];

		// the target index is now the source index...
		sourceIndex = targetIndex;

		// add source back to array in new location
		array.splice( sourceIndex, 0, source );
	};

	removeTargetClass = function () {
		this.classList.remove( sortable.targetClass );
	};

	preventDefault = function ( event ) { event.preventDefault(); };

	Ractive.decorators.sortable = sortable;

}));