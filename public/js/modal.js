$(function () {

    openModal();

    $('body.pc div#modal-wrapper').on('click', closeModal );
    $('body.sp div#modal-content').on('click', closeModal );
    $('body.pc div#modal-content img.close_button').on('click', closeModal);

    function openModal () {
        $('div#modal').fadeIn(200);
    };

    function closeModal () {
        $('div#modal').fadeOut(200);
    };

    function fetchCookie (name) {
    var result = null;
    var cookieName = name + '=';
    var allCookies = document.cookie;

    var position = allCookies.indexOf(cookieName);
    if (position != -1) {
      var startIndex = position + cookieName.length;
      var endIndex = allCookies.indexOf(';', startIndex);
      if (endIndex == -1) {
        endIndex = allCookies.length;
      }

      result = decodeURIComponent(allCookies.substring(startIndex, endIndex));
    }
    return result;
  }
});