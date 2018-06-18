// ******** VENDOR
//
//= require turbolinks
//= require jquery3
//= require jquery_ujs
//= require chosen-jquery
//= require sweetalert2
//= require jquery.sticky-kit.min
//= require Chart.min

// ******** APP
//
//= require rails-ujs-overrides
//= require chosen-init
//= require flash-msgs
//= require tabs
//= require image-uploaders
//= require modals
//= require forms
//= require season-schedule
//= require saved-searches
//= require charts
//= require jobs
//= require sticky-cols

document.addEventListener("turbolinks:load", function() {
  $(".accordion-toggle").on("click", function(e) {
    e.preventDefault();

    $accordion = $($(this).data("accordion"));

    $accordion.addClass('open');

    $(this).hide().next(".accordion-open").show();
  });

  $(document).on("change", "[data-remote-select]", function(evt) {
    var $el = $(this),
        data = {}

    data[$el.data('modelName')] = {}
    data[$el.data('modelName')][$el.data('fieldName')] = evt.target.value

    $.ajax({
      method: "POST",
      url: $el.data('url'),
      data: data,
    })
  })
});

$(document).ajaxSend(function(_, xhr) {
  xhr.setRequestHeader(
    'X-CSRF-Token',
    $('meta[name="csrf-token"]').attr('content')
  );
});