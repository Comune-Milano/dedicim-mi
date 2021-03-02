"use strict";

$(function () {
  var checkProgressPosition = function checkProgressPosition() {
    var progressFix = document.querySelector("[data-progressbox-fixed]"),
        progressRef = document.querySelector("[data-progress-reference]"),
        progressVisibleClass = "is-progressbox-visible";

    if (!progressRef) {
      return;
    }

    var progressPosition = progressRef.getBoundingClientRect().bottom;
    if (progressPosition > 0) {
      progressFix.classList.remove(progressVisibleClass);
    } else {
      progressFix.classList.add(progressVisibleClass);
    }
  };

  window.addEventListener("scroll", checkProgressPosition);

  window.DecidimBudgets = window.DecidimBudgets || {};
  window.DecidimBudgets.checkProgressPosition = checkProgressPosition;
});
"use strict";

$(function () {
  var $projects = $("#projects, #project");
  var $budgetSummaryTotal = $(".budget-summary__total");
  var $budgetExceedModal = $("#budget-excess");

  var totalBudget = parseInt($budgetSummaryTotal.attr("data-total-budget"), 10);

  var cancelEvent = function cancelEvent(event) {
    event.stopPropagation();
    event.preventDefault();
  };

  $projects.on("click", ".budget--list__action", function (event) {
    var currentBudget = parseInt($(".budget-summary__progressbox").attr("data-current-budget"), 10);
    var $currentTarget = $(event.currentTarget);
    var projectBudget = parseInt($currentTarget.attr("data-budget"), 10);

    if ($currentTarget.attr("disabled")) {
      cancelEvent(event);
    } else if ($currentTarget.attr("data-add") && currentBudget + projectBudget > totalBudget) {
      $budgetExceedModal.foundation("toggle");
      cancelEvent(event);
    }
  });
});
