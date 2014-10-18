$(document).ready(function() {
  $('.star').click(function() {
    // Toggle a display of star
    $(this).toggleClass('favorited');
    var isFavorited = $(this).hasClass('favorited');

    // Get a package name
    // var pname = $(this).attr('milkode-package-name');

    // ajax
    // $.post(
    //   '<%= url_for "/command" %>',
    //   {
    //     kind:      'favorite',
    //     name:      pname,
    //     favorited: isFavorited
    //   },
    //   function(data) {
    //     $(".favorite_list").html(data);
    //   }
    // );
  });
});