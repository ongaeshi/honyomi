function click_clear_button() {
  $(".form-control").val("").focus();
}

$(document).ready(function() {
  $(document).on('click', '.star', function(e) {
    var id = $(this).attr('honyomi-id');
    var page_no = $(this).attr('honyomi-page-no');
    var title = $(this).attr('honyomi-title');

    if (!$(this).hasClass('favorited')) {
      // NEW
      $(this).addClass('favorited');

      var num = parseInt($(".boomark-number").text());
      $(".boomark-number").text(num + 1);

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

  var updateMemo = function () {
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
        var comment = $("#" + page_no + " .comment");

        if (comment.size() == 0) {
          $('<div class="comment">' + data + '</div>').insertBefore("#" + page_no + " .main");
        } else {
          comment.html(data);
        }
      }
    );
  }

  $("#modal-bookmark-edit .btn-primary").click(function (e) {
    updateMemo();
  });

  $(".modal-body textarea").keydown(function (e) {
    if (e.ctrlKey && e.keyCode == 13) {
      $('#modal-bookmark-edit').modal('hide');
      updateMemo();
    }
  });

  $("#modal-bookmark-edit .btn-danger").click(function (e) {
    var id = $(".modal-bookmark-data").attr('honyomi-id');
    var page_no = $(".modal-bookmark-data").attr('honyomi-page-no');

    if (confirm("Delete this bookmark?")) {
      $("#star-" + id + "-" + page_no).removeClass('favorited');
      $("#" + page_no + " .comment").remove();

      var num = parseInt($(".boomark-number").text());
      $(".boomark-number").text(num - 1);

      $.post(
        '/command',
        {
          kind:      'favorite',
          id:        id,
          page_no:   page_no,
          favorited: false
        }
      );
    }
  });

  $(".edit-link").click(function (e) {
    $(".title").addClass('hide');
    $(".title-form").removeClass('hide');
    $("#title-form-title").val($("#book-title").text());
    $("#title-form-author").val($("#book-author").text());
    $("#title-form-url").val($("#book-url").text());
  });

  var hideTitleForm = function() {
    $(".title").removeClass('hide');
    $(".title-form").addClass('hide');
  }

  $("#title-form-save").click(function (e) {
    var id = $("#book-title").attr('honyomi-book-id');
    var title = $("#title-form-title").val();
    var author = $("#title-form-author").val();
    var url = $("#title-form-url").val();

    $("#book-title").text(title);
    $("#book-author").text(author);
    $("#book-url").attr('href', url);
    $("#book-url").text(url);

    $.post(
      '/command',
      {
        kind:      'title-form-save',
        id:        id,
        title:     title,
        author:    author,
        url:       url
      },
      function(data) {
        // Return a result of POST
      }
    );

    hideTitleForm();
  });

  $("#title-form-cancel").click(function (e) {
    hideTitleForm();
  });

  $(function() {
    document.addEventListener("dragover", function(e) {
      e.preventDefault();
    }, true);

    $('.droparea').on('drop', function(e) {
      e.preventDefault();
      e.stopPropagation();

      var files = e.originalEvent.dataTransfer.files;

      var fd = new FormData();

      for (var i = 0; i < files.length; i++) {
        fd.append("files[]", files[i]);
      }

      if (confirm("Upload?")) {
        $.ajax({
          url: "/upload",
          type: "POST",
          data: fd,
          processData: false,
          contentType: false,
          success: function(msg) {
          document.location = "/";
        }
        });
      }

      return false;
    });
  });

});