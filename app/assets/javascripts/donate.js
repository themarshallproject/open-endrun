var process_stripe_result = function(status, response) {
  var $form = $('.donation-form');
  if (response.error) {
    $form.find('.payment-errors').text(response.error.message);
    $form.find('button').prop('disabled', false);
  } else {
    var token = response.id;
    $form.append($('<input type="hidden" name="donate[stripeToken]" />').val(token));
    $form.get(0).submit();
  }
};

var setup_form_toggles = function() {
  $('.type-picker').click(function() {
    if ($(this).attr('value') === 'charge') {
      $('.type-charge').show();
      $('.type-recurring').hide();
    } else {
      $('.type-charge').hide();
      $('.type-recurring').show();
    }
  });
}

$(document).ready(function() {
    setup_form_toggles();
    $('.donation-form').submit(function(e) {
        var $form = $(this);
        $form.find('button').prop('disabled', true);
        Stripe.card.createToken($form, process_stripe_result);
        return false;
    });
});
