$(document).ready(function() {
  $(document).on('click', '.star', function(e) {
    // Toggle a display of star
    $(this).toggleClass('favorited');
    var isFavorited = $(this).hasClass('favorited');

    // Get a page info
    var id = $(this).attr('honyomi-id');
    var page_no = $(this).attr('honyomi-page-no');

    // ajax
    $.post(
      '/command',
      {
        kind:      'favorite',
        id:        id,
        page_no:   page_no,
        favorited: isFavorited
      },
      function(data) {
        // Return a result of POST
      }
    );

    e.preventDefault();
  });
});