(function() {

    var generateShareButtons = function(el, facebookURL, twitterURL) {

        var twitterHTML = '<svg version="1.1" id="Layer_1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" viewBox="0 0 21 21" enable-background="new 0 0 21 21" xml:space="preserve"><g><path fill="#111111" d="M1.2,16.9c1.9-0.2,3.4-0.4,5.1-1.8c-3.2-0.2-3.3-3.2-3.9-4.9C1.7,8.4,0.7,5.8,2,3.3 c1.9,1.8,3.9,3.2,6.2,3.8c1.3,0.3,2,0.4,2.3-1.4c0.4-2.7,3-3.9,5.5-2.9c0.7,0.3,1.3,0.7,2.3,0.7c1.1,0,1.8,1.2,1,2.1 c-0.8,0.9-0.9,1.9-1,2.9C17.4,16.6,8.5,21.2,1.2,16.9z"></path></g></svg>';

        var facebookHTML = '<svg version="1.1" id="Layer_1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" viewBox="0 0 21 21" enable-background="new 0 0 21 21" xml:space="preserve"><g><path fill="#111111" d="M8.3,15.5c0-1.2,0-2.3,0-3.5c0-0.8-0.1-1.5-1.1-1.5c-1.4,0.1-1.4-0.8-1.4-1.8c0-0.9,0.1-1.7,1.3-1.6 c1.7,0.1,1.2-1.3,1.2-2.1c0.3-3.5,1.4-4.5,4.9-4.4c1,0,2-0.2,2,1.4c0,1.2,0,2.1-1.6,2c-1.2-0.1-1.5,0.7-1.5,1.8 c0,1.2,0.6,1.4,1.6,1.4c0.7,0,1.7-0.1,1.4,1.1c-0.2,0.9,0.3,2.3-1.3,2.2c-1.6,0-1.7,0.8-1.7,2c0.1,2.2,0,4.3,0,6.5 c0.1,1.5-0.8,1.5-1.9,1.5c-1.1,0-2,0-1.9-1.5C8.4,17.8,8.3,16.7,8.3,15.5z"></path></g></svg>"';

        // facebook

        var facebook = document.createElement('div');
        facebook.className = 'share-button';
        facebook.setAttribute('data-action', 'facebook');
        facebook.innerHTML = facebookHTML;

        var facebookLink = document.createElement('a');
        facebookLink.className = 'share-button-link';
        facebookLink.href = facebookURL;
        facebook.appendChild(facebookLink);

        el.appendChild(facebook);

        // twitter

        var twitter = document.createElement('div');
        twitter.className = 'share-button';
        twitter.setAttribute('data-action', 'twitter');
        twitter.innerHTML = twitterHTML;

        var twitterLink = document.createElement('a');
        twitterLink.className = 'share-button-link';
        twitterLink.href = twitterURL;
        twitter.appendChild(twitterLink);

        el.appendChild(twitter);

        return el;
    }

    var generate = function() {
        var post_id = 123;
        var selector = "#endrun-post-sharables-" + post_id;

        var shareables = JSON.parse( $(selector).html() );
        $('.generate-shareable-v1').each(function(__, el) {
            generateShareButtons(el, 'fb', 'tw');
        });
    }

    $(document).ready(function() {
        generate();
    });
    
})();
