// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require codemirror/lib/codemirror
//= require codemirror/mode/javascript/javascript
//= require codemirror/mode/css/css
//= require codemirror/mode/xml/xml
//= require codemirror/mode/htmlmixed/htmlmixed
//= require codemirror/addon/display/autorefresh
//= require kapa/liquid

jQuery(document).ready(function($) {

  $('.editor').each(function(index, elem){
    var cm = CodeMirror.fromTextArea(elem, {
      lineWrapping: true,
      mode: "liquid",
      theme: "default",
      tabSize: 2,
      lineNumbers: true,
      autoRefresh: true,
    });
    cm.setSize(null, 800);
    cm.on('change',function(cm){
      cm.save();
    });
  });

  $('button[data-submit="#update_contents_form"]').off('click');
  $('button[data-submit="#update_contents_form"]').click(function(e) {
    e.preventDefault();
    $.ajax({
      type: 'PUT',
      url: $('#update_contents_form').attr('action'),
      data: $('#update_contents_form').serialize(),
      success: function (data) {
        location.reload();
      }
    });
  });
  
});
