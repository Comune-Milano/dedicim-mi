// Checks if the form contains fields with special CSS classes added in
// Decidim::Admin::SettingsHelper and acts accordingly.
"use strict";

$(function () {
  // Prevents checkbox with ".participatory_texts_disabled" class from being clicked.
  var $participatoryTexts = $(".participatory_texts_disabled");

  $participatoryTexts.click(function (event) {
    event.preventDefault();
    return false;
  });

  // Target fields:
  // - amendments_wizard_help_text
  // - all fields with ".amendments_step_settings" class
  // (1) Hides target fields if amendments_enabled component setting is NOT checked.
  // (2) Toggles visibilty of target fields when amendments_enabled component setting is clicked.
  var $amendmentsEnabled = $("input#component_settings_amendments_enabled");

  if ($amendmentsEnabled.length > 0) {
    (function () {
      var $amendmentWizardHelpText = $("[id*='amendments_wizard_help_text']").parent();
      var $amendmentStepSettings = $(".amendments_step_settings").parent();

      if ($amendmentsEnabled.is(":not(:checked)")) {
        $amendmentWizardHelpText.hide();
        $amendmentStepSettings.hide().siblings(".help-text").hide();
      }

      $amendmentsEnabled.click(function () {
        $amendmentWizardHelpText.toggle();
        $amendmentStepSettings.toggle().siblings(".help-text").toggle();
      });
    })();
  }
});
