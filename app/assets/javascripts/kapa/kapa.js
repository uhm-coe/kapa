// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery
//= require jquery_ujs
//= require moment
//= require bootstrap-sprockets
//= require bootstrap-datetimepicker
//= require bootstrap-multiselect
//= require dragula
//= require summernote

jQuery(document).ready(function ($) {

  // Submit a form if data-submit attribute is set
  $('button[data-submit]').click(function () {
    $($(this).attr('data-submit')).submit();
  });

  // Reset a form if data-reset attribute is set
  $('button[data-reset]').click(function () {
    var form_id = $(this).attr('data-reset');
    $(form_id).trigger('reset');
  });

  $('button[data-cancel]').click(function () {
    window.history.back();
  });


  $('.datepicker').datetimepicker({
    format: 'MM/DD/YYYY'
  }).on('changeDate',function (e) {
      $(this).datetimepicker('hide');
  }).on('keydown', function (e) {
      if (e.keyCode === 8) { // If backspace key is pressed
        e.preventDefault(); // Disable "back button" action; stay on the page
        $(this).find('.form-control').val(''); // Clear date in the input field
        $(this).datetimepicker('hide'); // Dismiss the calendar
      }
  });

  $('.datetimepicker').datetimepicker({
  }).on('changeDate',function (e) {
      $(this).datetimepicker('hide');
  }).on('keydown', function (e) {
      if (e.keyCode === 8) { // If backspace key is pressed
        e.preventDefault(); // Disable "back button" action; stay on the page
        $(this).find('.form-control').val(''); // Clear date in the input field
        $(this).datetimepicker('hide'); // Dismiss the calendar
      }
  });

  $('[multiple="multiple"]').multiselect({
    numberDisplayed: 3,
    enableCaseInsensitiveFiltering: true,
    buttonContainer: '<div class="btn-group kapa-multiselect-btn-group"></div>',
    buttonClass: 'btn btn-default kapa-multiselect-btn'
  });

  $('.search-select').multiselect({
    numberDisplayed: 1,
    enableCaseInsensitiveFiltering: true,
    includeSelectAllOption: true,
    buttonContainer: '<div class="btn-group kapa-multiselect-btn-group"></div>',
    buttonClass: 'btn btn-default kapa-multiselect-btn'
  });

  $('.tabs').each(function(i, e) {
    var index = $(e).find('.nav-tabs a').index($("a[href='" + document.location.hash + "_tab']"));
    index = index > 0 ? index : 0
    $(e).find('li:eq(' + index + ') a').tab('show')
  });

  $('[data-toggle="popover"]').popover();
  $('[data-toggle="tooltip"]').tooltip();

  $("a[rel~=popover], .has-popover").popover();
  $("a[rel~=tooltip], .has-tooltip").tooltip();
});
