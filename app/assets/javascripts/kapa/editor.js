// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require ace-builds/src-noconflict/ace
//= require ace-builds/src-noconflict/mode-liquid
//= require ace-builds/src-noconflict/theme-chrome

jQuery(document).ready(function($) {

  $('.editor').each(function(index, elem){
    textarea = $(elem)
    editor_id = elem.id + '_editor';
    textarea.hide();
    textarea.parent().append('<div id="' + editor_id + '" class="editor_area"></div>');
    var editor = ace.edit(editor_id);
    editor.setValue(textarea.val());
    editor.setTheme("ace/theme/chrome")
    editor.session.setOptions({
      mode: "ace/mode/liquid",
      tabSize: 2,
      useSoftTabs: true,
      wrap: true
    });
    editor.getSession().on("change", function () {
      textarea.val(editor.getSession().getValue());
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
