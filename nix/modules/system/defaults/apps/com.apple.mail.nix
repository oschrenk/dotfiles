{ ... }:

# Mail.app preferences
# Source: home/.chezmoiscripts/run_onchange_03_configure_apps_mail.sh
#
# NOTE: The original script writes to both 'com.apple.mail' and 'com.apple.Mail'
# (different cases). Both are reproduced here to match the original behaviour.
{
  system.defaults.CustomUserPreferences = {
    "com.apple.mail" = {
      # Force messages to be displayed as plain text instead of formatted (false to reverse)
      PreferPlainText = true;

      # Don't add invitations to iCal automatically
      AddInvitationsToICalAutomatically = false;

      # Copy email addresses as foo@example.com instead of Foo Bar <foo@example.com>
      AddressesIncludeNameOnPasteboard = false;

      # Disable inline attachments (just show the icons)
      DisableInlineAttachmentViewing = true;
    };

    "com.apple.Mail" = {
      # Disable send and reply animations
      DisableReplyAnimations = true;
      DisableSendAnimations = true;
    };
  };
}
