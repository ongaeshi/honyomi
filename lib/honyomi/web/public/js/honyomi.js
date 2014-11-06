$(document).ready(function() {
  $(document).on('click', '.star', function(e) {
    var id = $(this).attr('honyomi-id');
    var page_no = $(this).attr('honyomi-page-no');
    var title = $(this).attr('honyomi-title');

    if (!$(this).hasClass('favorited')) {
      // NEW
      $(this).addClass('favorited');

      // ajax
      $.post(
        '/command',
        {
          kind:      'favorite',
          id:        id,
          page_no:   page_no,
          favorited: true
        },
        function(data) {
          // Return a result of POST
        }
      );

    } else {
      // EDIT
      $('#modal-bookmark-label').html(
        "<span class=\"modal-bookmark-data hidden\" " +
        "honyomi-id=\"" + id + "\" " +
        "honyomi-page-no=\"" + page_no + "\" " +
        "></span>" +
        title + " (P" + page_no + ")"
      );

      $(".modal-body textarea").val($(this).attr('honyomi-comment'));

      $('#modal-bookmark-edit').modal();
    }

    e.preventDefault();
  });

  $("#modal-bookmark-edit .btn-primary").click(function (e) {
    var id = $(".modal-bookmark-data").attr('honyomi-id');
    var page_no = $(".modal-bookmark-data").attr('honyomi-page-no');
    var comment = $(".modal-body textarea").val();

    $("#star-" + id + "-" + page_no).attr("honyomi-comment", comment);

    $.post(
      '/command',
      {
        kind:      'favorite-update',
        id:        id,
        page_no:   page_no,
        comment:   comment
      },
      function(data) {
        $("#" + page_no + " .comment").html(data);
      }
    );
  });

  $("#modal-bookmark-edit .btn-danger").click(function (e) {
    var id = $(".modal-bookmark-data").attr('honyomi-id');
    var page_no = $(".modal-bookmark-data").attr('honyomi-page-no');

    $("#star-" + id + "-" + page_no).removeClass('favorited');

    $.post(
      '/command',
      {
        kind:      'favorite',
        id:        id,
        page_no:   page_no,
        favorited: false
      }
    );
  });
});