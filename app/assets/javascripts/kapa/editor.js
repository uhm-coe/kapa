// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require codemirror/lib/codemirror
//= require codemirror/mode/xml/xml
//= require summernote/dist/summernote

jQuery(document).ready(function($) {
  $('#editor').summernote({
    height: 600,
    toolbar: [
      ['style', ['style']],
      ['font', ['bold', 'italic', 'underline', 'clear']],
//          ['fontname', ['fontname']],
      ['color', ['color']],
      ['para', ['ul', 'ol', 'paragraph']],
      ['height', ['height']],
      ['table', ['table']],
      ['insert', ['link', 'hr']],
      ['view', ['fullscreen', 'codeview']],
      ['help', ['help']]
    ],
    codemirror: { // codemirror options
      theme: 'monokai'
    }
  });
});
