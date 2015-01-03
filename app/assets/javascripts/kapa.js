// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery
//= require jquery_ujs
//= require twitter/bootstrap
//= require bootstrap-datepicker
//= require_tree .

jQuery(document).ready(function($) {

  //Submit a form if data-submit attribute is set.
  $('button[data-submit]').click(function() {
    $($(this).attr('data-submit')).submit();
  });

  $('.closable-tabs [data-toggle=tab]').click(function(){
    if ($(this).parent().hasClass('active')){
      $($(this).attr("href")).toggleClass('active');
    }
  });

  $('.kapa-datepicker').datepicker({
    format: 'yyyy-mm-dd'
  }).on('changeDate', function(event) {
    $(this).datepicker('hide');
  });

});
