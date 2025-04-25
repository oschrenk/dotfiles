# README

1. [Get a Jira API token](https://id.atlassian.com/manage-profile/security/api-tokens)
2. Delete existing config `rm $HOME/.config/jira/.config`

3. Set the following

```
# set to empty string
# see https://github.com/ankitpokhrel/jira-cli/issues/746
export JIRA_AUTH_TYPE=""

```

4. Create config

```
# go through questions
jira config
```

5. Now create keychain entry

```
# the keychain UI doesn't allow pasting passwords containing a dash
export EMAIL_USERNAME="..."
export JIRA_API_TOKEN="..."

security add-generic-password -s "jira-cli" -a "$EMAIL_USERNAME" -w "$JIRA_API_TOKEN" -l "jira-cli" -j "API Token for Jira CLI, see more at https://github.com/ankitpokhrel/jira-cli/discussions/356"
```

6. Open a new terminal and now it should work

