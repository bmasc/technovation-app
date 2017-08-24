(function() {
  document.addEventListener("turbolinks:load", function() {
    fadeOutExistingFlashes();

    $(document).on('click', '.flash .icon-close', function() {
      $(this).closest('.flash').fadeOut('easeout', function() {
        $(this).remove();
      });
    });
  });

  $(document).ajaxComplete(function(_, xhr) {
    if (xhr.status === 200) {
      var res = JSON.parse(xhr.responseText),
          $flash = $("<div>"),
          $flashText = $("<span>"),
          $flashClose = $("<span>");

      $flash.addClass("flash flash--success");
      $flashClose.addClass("icon-close");
      $flashText.text(res.flash.success);

      $flash.append($flashText);
      $flash.append($flashClose);

      $flash.hide();
      $("#flash").html($flash);
      $flash.fadeIn();

      fadeOutExistingFlashes();
    }
  });

  function fadeOutExistingFlashes() {
    setTimeout(function() {
      $("#flash .flash").fadeOut(function() {
        $(this).remove();
      })
    }, 5000);
  }
})();