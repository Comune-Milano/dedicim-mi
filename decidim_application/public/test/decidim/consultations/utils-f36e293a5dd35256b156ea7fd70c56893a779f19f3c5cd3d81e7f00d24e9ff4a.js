/* eslint-disable no-invalid-this, no-undefined */

"use strict";

(function () {
  $(".vote-button-caption").mouseover(function () {
    var replaceText = $(this).data("replace");

    if (replaceText !== null && replaceText !== undefined && replaceText !== "") {
      $(this).text(replaceText);
    }
  });

  $(".vote-button-caption").mouseout(function () {
    var originalText = $(this).data("original");

    if (originalText !== null && originalText !== undefined && originalText !== "") {
      $(this).text(originalText);
    }
  });
})(undefined);
