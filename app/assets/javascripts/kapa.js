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
//= require bootstrap-multiselect
//= require_tree .

jQuery(document).ready(function($) {

  // Submit a form if data-submit attribute is set
  $('button[data-submit]').click(function() {
    $($(this).attr('data-submit')).submit();
  });

  // Reset a form if data-reset attribute is set
  $('button[data-reset]').click(function() {
    var form_id = $(this).attr('data-reset');
    $(form_id).trigger('reset');
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

  $('.kapa-multiselect').multiselect({
    numberDisplayed: 1,
    enableCaseInsensitiveFiltering: true,
    includeSelectAllOption: true,
    buttonContainer: '<div class="btn-group kapa-multiselect-btn-group"></div>',
    buttonClass: 'btn btn-default kapa-multiselect-btn'
  });

  $(".btn-delete").popConfirm({
    title: "Confirm", // The title of the confirm
    content: "Are you sure you want to delete this?", // The message of the confirm
    placement: "right", // The placement of the confirm (top, right, bottom, left)
    container: "body", // The html container
    yesBtn: "Delete",
    noBtn: "Cancel"
  });

});
