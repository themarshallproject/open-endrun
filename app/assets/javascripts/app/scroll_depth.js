$(document).ready(function() {
  var $top_of_post    = $('span[data-mark="top-of-post"]')
    , $bottom_of_post = $('span[data-mark="bottom-of-post"]')
    , events_sent = [];

  if ($top_of_post.length === 0 && $bottom_of_post.length === 0) {
    // we don't have the markers, so don't compute any of the following.
    return true;
  }

  var post_height = $bottom_of_post.position().top - $top_of_post.position().top;

  var scroll_markers = [0.0, 0.2, 0.4, 0.6, 0.8, 1.0].map(function(fraction) {
    return {
      fraction: fraction,
      pixels:  (fraction * post_height) + $top_of_post.position().top
    }
  });

  var check_scroll_depth = function() {
    var window_bottom = $(window).scrollTop() + $(window).height();

    scroll_markers.filter(function(marker) {
      return marker.pixels <= window_bottom;
    }).forEach(function(active_marker) {
      if (events_sent.indexOf(active_marker.fraction) >= 0) {
        // already sent this event, no-op
      } else {
        events_sent.push(active_marker.fraction);
        var percent_scroll_event_label = 100*active_marker.fraction+"%";
        report('story_scrollmark_1', percent_scroll_event_label);
      }
    });
  }
  check_scroll_depth();
  $(window).on('tmp_scroll', function() {
    check_scroll_depth();
  });
});