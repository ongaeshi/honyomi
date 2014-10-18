$(document).ready(function() {
  $('.star').click(function() {
    // Toggle a display of star
    $(this).toggleClass('favorited');
    var isFavorited = $(this).hasClass('favorited');

    // Get a package name
    // var pname = $(this).attr('milkode-package-name');

    // ajax
    $.post(
      '/command',
      {
        kind:      'favorite',
        id:        50,
        page_no:   32,
        favorited: isFavorited
      },
      function(data) {
        // Return a result of POST
      }
    );
  });
});