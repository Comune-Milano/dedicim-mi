/* eslint-disable no-invalid-this */

"use strict";

(function () {
  $(function () {

    $(".show-more").on("click", function () {
      $(this).hide();
      $(".show-more-panel").removeClass("hide");
    });
  });
})(window);
