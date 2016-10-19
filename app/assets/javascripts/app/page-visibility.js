(function() {
  // from: daniemon.com/tech/webapps/page-visibility/
    'use strict';
    
    window._hidden = false;

    // Set the name of the "hidden" property and the change event for visibility
    var hidden, visibilityChange;

    if (typeof document.hidden !== "undefined") {
      hidden = "hidden";
      visibilityChange = "visibilitychange";
    } else if (typeof document.mozHidden !== "undefined") { // Firefox up to v17
      hidden = "mozHidden";
      visibilityChange = "mozvisibilitychange";
    } else if (typeof document.webkitHidden !== "undefined") { // Chrome up to v32, Android up to v4.4, Blackberry up to v10
      hidden = "webkitHidden";
      visibilityChange = "webkitvisibilitychange";
    }
    
    // If the page is hidden, pause the video;
    // if the page is shown, play the video
    var handleVisibilityChange = function() {
      if (document[hidden]) {
        window._hidden = true;
      } else {
        window._hidden = false;
      }
    }

    // Warn if the browser doesn't support addEventListener or the Page Visibility API
    if (typeof document.addEventListener === "undefined" || typeof document[hidden] === "undefined") {
      console && console.log("This demo requires a modern browser that supports the Page Visibility API.");
    } else {        
      document.addEventListener(visibilityChange, handleVisibilityChange, false);        
    }
})();