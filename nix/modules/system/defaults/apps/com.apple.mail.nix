{ ... }:

# Mail.app preferences
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

      # Disable send and reply animations
      DisableReplyAnimations = true;
      DisableSendAnimations = true;
    };
  };
}
