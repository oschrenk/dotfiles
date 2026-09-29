_:

{
  warnings = [
    "Keyboard: keyRepeatRate and delayUntilRepeat require logout to take effect"
  ];

  programs.nix-plist-manager.options.applications.systemSettings.keyboard = {
    # In 15 ms steps, lower is faster.
    # Experiment with speeds: https://mac-os-key-repeat.vercel.app/
    keyRepeatRate = 3;
    delayUntilRepeat = 10;

    # Tab focus reaches all controls (buttons, checkboxes, etc.)
    keyboardNavigation = true;

    pressGlobeKeyTo = "Do Nothing";

    textInput = {
      capitalizeWordsAutomatically = false;
      addPeriodWithDoubleSpace = false;
      useSmartQuotesAndDashes = false;
    };
  };
}
