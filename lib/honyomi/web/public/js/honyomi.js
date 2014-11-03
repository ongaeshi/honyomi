$(document).ready(function() {
  $(document).on('click', '.star', function(e) {
    if (!$(this).hasClass('favorited')) {
      // NEW
      $('#modal-bookmark-new').modal();

    } else {
      // EDIT
      $(this).toggleClass('favorited');

      var id = $(this).attr('honyomi-id');
      var page_no = $(this).attr('honyomi-page-no');

      // ajax
      $.post(
        '/command',
        {
          kind:      'favorite',
          id:        id,
          page_no:   page_no,
          favorited: false
        },
        function(data) {
          // Return a result of POST
        }
      );
    }

    e.preventDefault();
  });

  $("#modal-bookmark-new .btn-primary").click(function (e) {
    // var id = $(this).attr('honyomi-id');
    // var page_no = $(this).attr('honyomi-page-no');
    var id = '53';
    var page_no = '146';

    $("#star-" + id + "-" + page_no).addClass('favorited');

    $.post(
      '/command',
      {
        kind:      'favorite',
        id:        id,
        page_no:   page_no,
        favorited: true
      }
    );
  });
});