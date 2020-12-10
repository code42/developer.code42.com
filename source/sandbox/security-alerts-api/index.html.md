---
title: Security alerts API

category: detect-and-respond

search: true

code_clipboard: true
---

# Security alerts API

## Overview

You review alert notifications and manage alert rules using the [Alerts menu of the Code42 console](https://support.code42.com/Administrator/Cloud/Code42_console_reference/Alerts_reference). To automate the process of viewing alert notifications, adding notes, or opening or dismissing alert notifications, you can write scripts that use the [Rules APIs](/sandbox/api/#tag/Rules) and [Alerts APIs](/sandbox/api/#tag/Alerts). This article introduces those APIs and shows examples of their use.

## Considerations

* The tasks in this article require use of the Code42 API. For assistance with using the Code42 API, contact your Customer Success Manager (CSM) to engage the Code42 Professional Services team. Or, [post your question to the Code42 community](https://success.code42.com/home) to get advice from fellow Code42 administrators.
* The examples in this article use [curl](https://curl.se/). For other tools that you can use, see [Tools for interacting with the Code42 API](https://support.code42.com/Administrator/Cloud/Monitoring_and_managing/Code42_API_resources/Tools_for_interacting_with_the_Code42_API).
* To perform tasks in this article, you must:
  * Have the [Customer Cloud Admin](https://support.code42.com/Administrator/Cloud/Monitoring_and_managing/Roles_reference#Customer_Cloud_Admin) or [Security Center User](https://support.code42.com/Administrator/Cloud/Monitoring_and_managing/Roles_reference#Security_Center_User) role.
  * Know the [request URL](/sandbox/intro-to-developer-portal/#request-urls) of your Code42 cloud instance.
  * Obtain an [authentication token](/sandbox/intro-to-developer-portal/#authentication) and a [tenant ID](/sandbox/intro-to-developer-portal/#get-a-tenant-id).
* You can also use the Code42 command-line interface (CLI) to work with alert notifications and rules. For more information, see the [Code42 CLI documentation](https://clidocs.code42.com/en/latest/commands/alerts.html).

## Manage alert notifications

To work with alert notifications, use the API query commands to search for alert notifications. Once you [identify specific alert IDs](#locate-alert-rule-ids), you can then add a note, dismiss, or reopen those alert notifications.

### Search for alert notifications by alert filter criteria

To search for alert notifications using filter criteria and identify alert IDs, use the [/v1/alerts/query-alerts](/sandbox/api/#operation/Alerts_QueryAlert) API command.

```bash
curl -X POST "<RequestURL>/v1/alerts/query-alerts" \
-H "accept: text/plain" \
-H "Authorization: Bearer <AuthToken>" \
-H "Content-Type: application/json" \
-d '{ "tenantId": "<SampleTenant>", "groups": [ { "filters": [ { "term": "<FilterType>", "operator": "<OperatorValue>", "value": "<Criteria>" } ], "filterClause": "AND" } ], "groupClause": "OR", "pgSize": "20", "pgNum": "0", "srtKey": "CreatedAt", "srtDirection": "DESC" }'
```

In the preceding example:

* Replace `<RequestURL>` with the [request URL](/sandbox/intro-to-developer-portal/#request-urls) of your Code42 cloud instance.
* Replace `<AuthToken>` with the [authentication token](/sandbox/intro-to-developer-portal/#authentication).
* Replace `<SampleTenant>` with the [tenant ID](/sandbox/intro-to-developer-portal/#get-a-tenant-id).
* Replace `<FilterType>` with the filter, `<OperatorValue>` with the operator option, and `<Criteria>` with the search term to use in the search. See [Filter syntax for the query-alerts API command](#filter-syntax-for-the-query-alerts-API-command) below for details.

A successful response returns basic information about the alert notifications that match your search criteria, including the alert IDs of those notifications (look for the `"id":"value"` entry):

```json
{"type$":"ALERT_SUMMARY","tenantId":"123456","type":"FED_ENDPOINT_EXFILTRATION","name":"Departing employee endpoint exfiltration system rule","description":"System rule for departing employee endpoint exfiltration.","actor":"burt.morales@example.com","target":"N/A","severity":"HIGH","ruleId":"123456789424242","ruleSource":"Departing Employee","id":"987654321424242","createdAt":"2020-04-03T15:21:44.6139300Z","state":"OPEN"}],"totalCount":1,"problems":[]}
```

### Search for multiple alert notifications by alert IDs

After you've located the alert IDs for specific alerts, use the [/v1/alerts/query-details](/sandbox/api/#operation/Alerts_QueryAlertDetails) API command to search those IDs and view more details about those alert notifications.

```bash
curl -X POST "<RequestURL>/v1/alerts/query-details" \
-H "accept: text/plain" \
-H "Authorization: Bearer <AuthToken>" \
-H "Content-Type: application/json" \
-d '{ "alertIds": [ "<SampleAlertID1>", "<SampleAlertID2>" ]}'
```

In the preceding example:

* Replace `<RequestURL>` with the [request URL](/sandbox/intro-to-developer-portal/#request-urls) of your Code42 cloud instance.
* Replace `<AuthToken>` with the [authentication token](/sandbox/intro-to-developer-portal/#authentication).
* Replace `<SampleAlertID1>` and `<SampleAlertID2>` with the IDs of the alert notifications. Enclose each ID in quotation marks and separate them with commas.

A successful response returns full details about the alert notifications, including a list of files involved in the activity.

```bash
{"type$":"ALERT_DETAILS_RESPONSE","alerts":[{"type$":"ALERT_DETAILS","tenantId":"123456","type":"FED_ENDPOINT_EXFILTRATION","name":"Departing employee endpoint exfiltration system rule","description":"System rule for departing employee endpoint exfiltration.","actor":"burt.morales@example.com","target":"N/A","severity":"HIGH","ruleId":"123456789424242","ruleSource":"Departing Employee","id":"987654321424242","createdAt":"2020-04-08T13:50:25.3644410Z","state":"OPEN","observations":[{"type$":"OBSERVATION","id":"112233445566","observedAt":"2020-04-08T13:40:00.0000000Z","type":"FedEndpointExfiltration","data":"{\"type$\":\"OBSERVED_ENDPOINT_ACTIVITY\",\"id\":\"665544332211\",\"sources\":[\"Endpoint\"],\"exposureTypes\":[\"ApplicationRead\",\"CloudStorage\"],\"firstActivityAt\":\"2020-04-08T13:40:00.0000000Z\",\"lastActivityAt\":\"2020-04-08T13:45:00.0000000Z\",\"fileCount\":2,\"totalFileSize\":311096,\"fileCategories\":[{\"type$\":\"OBSERVED_FILE_CATEGORY\",\"category\":\"Image\",\"fileCount\":2,\"totalFileSize\":311096,\"isSignificant\":false}],\"files\":[{\"type$\":\"OBSERVED_FILE\",\"eventId\":\"998877665544\",\"path\":\"C:/Users/burt.morales/\",\"name\":\"1586353274_family_photo.png\",\"category\":\"Image\"},{\"type$\":\"OBSERVED_FILE\",\"eventId\":\"334455667788\",\"path\":\"C:/Users/burt.morales/Dropbox/\",\"name\":\"1586353274_family_photo.png\",\"category\":\"Image\"}],\"syncToServices\":[\"Dropbox\"],\"sendingIpAddresses\":[\"192.0.2.0\"]}"}]}]}
```

### Search for a single notification by alert ID

Use the [/v1/alerts/query-details-aggregate](/sandbox/api/#operation/Alerts_QueryAlertDetailsAggregate) API command to search for a single alert notification using its alert ID.

```bash
curl -X POST "<RequestURL>/v1/alerts/query-details-aggregate" \
-H "accept: text/plain" \
-H "Authorization: Bearer <AuthToken>" \
-H "Content-Type: application/json" \
-d '{ "alertId": "<SampleAlertID>"}'
```

In the preceding example:

* Replace `<RequestURL>` with the [request URL](/sandbox/intro-to-developer-portal/#request-urls) of your Code42 cloud instance.
* Replace `<AuthToken>` with the [authentication token](/sandbox/intro-to-developer-portal/#authentication).
* Replace `<SampleAlertID>` with the alert ID.

A successful response returns full details about the alert notification with all file activity aggregated into a single Observation value.

```json
{"type$":"ALERT_DETAILS_IN_AGGREGATE_RESPONSE","alert":{"type$":"ALERT_DETAILS_AGGREGATE","tenantId":"123456","type":"FED_ENDPOINT_EXFILTRATION","name":"Departing employee endpoint exfiltration system rule","description":"System rule for departing employee endpoint exfiltration.","actor":"burt.morales@c42se.com","target":"N/A","severity":"HIGH","ruleId":"1234567894242","ruleSource":"Departing Employee","id":"9876543214242","createdAt":"2020-04-08T13:50:25.3644410Z","state":"OPEN","observation":{"type$":"OBSERVATION_AGGREGATE","observedAt":"2020-04-08T13:40:00.0000000Z","type":"FedEndpointExfiltration","data":"{\"type$\":\"OBSERVED_ENDPOINT_ACTIVITY\",\"id\":\"112233445566\",\"sources\":[\"Endpoint\"],\"exposureTypes\":[\"ApplicationRead\",\"CloudStorage\"],\"firstActivityAt\":\"2020-04-08T13:40:00.0000000Z\",\"lastActivityAt\":\"2020-04-08T13:45:00.0000000Z\",\"fileCount\":2,\"totalFileSize\":311096,\"fileCategories\":[{\"type$\":\"OBSERVED_FILE_CATEGORY\",\"category\":\"Image\",\"fileCount\":2,\"totalFileSize\":311096,\"isSignificant\":false}],\"files\":[{\"type$\":\"OBSERVED_FILE\",\"eventId\":\"998877665544\",\"path\":\"C:/Users/burt.morales/\",\"name\":\"1586353274_family_photo.png\",\"category\":\"Image\"},{\"type$\":\"OBSERVED_FILE\",\"eventId\":\"334455667788\",\"path\":\"C:/Users/burt.morales/Dropbox/\",\"name\":\"1586353274_family_photo.png\",\"category\":\"Image\"}],\"syncToServices\":[\"Dropbox\"],\"sendingIpAddresses\":[\"192.0.2.0\"],\"isRemoteActivity\":false}"}}}
```

### Add a note to an alert notification

To add a note to an alert notification, first locate its alert ID using one of the queries above. Then use the [/v1/alerts/add-note](/sandbox/api/#operation/Alerts_AddNoteToAlert) API command to add a note to that alert. Be aware that any note you add overwrites any existing note attached to the alert.

```bash
curl -X POST "<RequestURL>/v1/alerts/add-note" \
-H "accept: application/json" \
-H "Authorization: Bearer <AuthToken>" \
-H "Content-Type: application/json" \
-d '{ "tenantId": "<SampleTenant>", "alertId": "<SampleAlertID>", "note": "This is an example note." }'
```

In the preceding example:

* Replace `<RequestURL>` with the [request URL](/sandbox/intro-to-developer-portal/#request-urls) of your Code42 cloud instance.
* Replace `<AuthToken>` with the [authentication token](/sandbox/intro-to-developer-portal/#authentication).
* Replace `<SampleTenant>` with the [tenant ID](/sandbox/intro-to-developer-portal/#get-a-tenant-id).
* Replace `<SampleAlertID>` with the alert ID.

### Dismiss alert notifications

You can dismiss multiple alert notifications at once using the API. To dismiss alert notifications, first locate the alert IDs using one of the queries above. Then use the [/v1/alerts/update-state](/sandbox/api/#operation/Alerts_UpdateAlertState) API command with a `state` value of `RESOLVED` to dismiss those alerts.

```bash
curl -X POST "<RequestURL>/v1/alerts/update-state" \
-H "accept: application/json" \
-H "Authorization: Bearer <AuthToken>" \
-H "Content-Type: application/json" \
-d '{ "tenantId": "<SampleTenant>", "alertIds": [ "<SampleAlertID1>", "<SampleAlertID2>" ], "state": "RESOLVED", "note": "This is an example note."}'
```

In the preceding example:

* Replace `<RequestURL>` with the [request URL](/sandbox/intro-to-developer-portal/#request-urls) of your Code42 cloud instance.
* Replace `<AuthToken>` with the [authentication token](/sandbox/intro-to-developer-portal/#authentication).
* Replace `<SampleTenant>` with the [tenant ID](/sandbox/intro-to-developer-portal/#get-a-tenant-id).
* Replace `<SampleAlertID1>` and `<SampleAlertID2>` with the IDs of the alert notifications. Enclose each ID in quotation marks and separate them with commas.
* Be aware that any note you enter overwrites any existing note attached to the alert. If you want to dismiss the alert without adding a note (or want to preserve existing notes), delete the "note" term and sample text from the command.

### Reopen dismissed alert notifications

You can reopen multiple dismissed alert notifications at once using the API. To reopen alert notifications, first locate the alert IDs using one of the queries above. Then use the [/v1/alerts/update-state](/sandbox/api/#operation/Alerts_UpdateAlertState) API command with the OPEN state value to reopen those alerts.

```bash
curl -X POST "<RequestURL>/v1/alerts/update-state" \
-H "accept: application/json" \
-H "Authorization: Bearer <AuthToken>" \
-H "Content-Type: application/json" \
-d '{ "tenantId": "<SampleTenant>", "alertIds": [ "<SampleAlertID1>", "<SampleAlertID2>" ], "state": "OPEN", "note": "This is an example note."}'
```

In the preceding example:

* Replace `<RequestURL>` with the [request URL](/sandbox/intro-to-developer-portal/#request-urls) of your Code42 cloud instance.
* Replace `<AuthToken>` with the [authentication token](/sandbox/intro-to-developer-portal/#authentication).
* Replace `<SampleTenant>` with the [tenant ID](/sandbox/intro-to-developer-portal/#get-a-tenant-id).
* Replace `<SampleAlertID1>` and `<SampleAlertID2>` with the IDs of the alert notifications. Enclose each ID in quotation marks and separate them with commas.
* Be aware that any note you enter overwrites any existing note attached to the alert. If you want to reopen the alert without adding a note (or want to preserve existing notes), delete the "note" term and sample text from the command.

## Manage alert rule user lists

If a rule either applies only to specific users or applies to all users except specific users, you can manage the users in those inclusion or exclusion lists using the API. As with alert notifications, you'll need to identify the rule ID associated with the rule before you can manage the users to which it applies.

### Locate alert rule IDs

Before you can manage the users associated with an alert rule, you need to view details about alert rules and identify the rule IDs for which you want to manage users. Use the [/v1/alerts/rules/query-rule-metadata](/sandbox/api/#operation/Rules_QueryRuleMetadata) API command to locate alert rule IDs.

**Note:** The API commands for alert notification searches described above also include the ID of the rule that generated the alert. Look for the "ruleID": `"<value>"` entry in the details returned by the query.

```bash
curl -X POST "<RequestURL>/v1/alerts/rules/query-rule-metadata" \
-H "accept: text/plain" \
-H "Authorization: Bearer <AuthToken>" \
-H "Content-Type: application/json" \
-d '{ "tenantId": "<SampleTenant>", "groups": [ { "filters": [ { "term": "<FilterTerm>", "operator": "<OperatorValue>", "value": "<Criteria>" } ], "filterClause": "AND" } ], "groupClause": "OR", "pgSize": "20", "pgNum": "0", "srtKey": "CreatedAt", "srtDirection": "DESC"}'
```

In the preceding example:

* Replace `<RequestURL>` with the [request URL](/sandbox/intro-to-developer-portal/#request-urls) of your Code42 cloud instance.
* Replace `<AuthToken>` with the [authentication token](/sandbox/intro-to-developer-portal/#authentication).
* Replace `<SampleTenant>` with the [tenant ID](/sandbox/intro-to-developer-portal/#get-a-tenant-id).
* Replace `<FilterType>` with the filter, `<OperatorValue>` with the operator option, and `<Criteria>` with the search term to use in the search. See [Filter syntax for the rules/query-rule-metadata API command](#filter-syntax-for-the-rules/query-rule-metadata-API-command) below for details.

A successful response returns basic information about the alert notifications that match your search criteria, including the rule IDs of those notifications (look for the "observerRuleId":"value" entry):

```json
{"type$":"RULE_METADATA_SEARCH_RESPONSE","ruleMetadata":[{"type$":"RULE_METADATA","modifiedBy":"Code42","modifiedAt":"2020-06-04T21:07:03.5417950Z","name":"Exposure on an endpoint","description":"This default rule alerts you when departing employees move data from an endpoint.","severity":"HIGH","isSystem":true,"isEnabled":false,"ruleSource":"Departing Employee","tenantId":"123456","observerRuleId":"1234567894242","type":"FED_ENDPOINT_EXFILTRATION","id":"9876543214242","createdBy":"Code42","createdAt":"2020-01-10T12:16:40.7765970Z"}],"totalCount":8,"problems":[]}
```

### View an alert rule's user list

Use the [/v1/alert-rules/query-users](/sandbox/api/#operation/Rules_QueryUsersOnRule) API command to view a list of users that are either included in or excluded from a specific alert rule. The output from this command groups the user email addresses and cloud aliases in the rule's inclusion or exclusion list by the user ID associated with those details (which is generally the [userUID value in Code42](/sandbox/intro-to-developer-portal/#get-useruid)). You can then use this user ID to remove specific email addresses and cloud aliases from a rule's inclusion or exclusion list as needed.

```bash
curl -X POST "<RequestURL>/v1/alert-rules/query-users" \
-H "accept: text/plain" \
-H "Authorization: Bearer <AuthToken>" \
-H "Content-Type: application/json" \
-d '{ "tenantId": "<SampleTenant>", "ruleId": "<SampleRuleID>"}'
```

In the preceding example:

* Replace `<RequestURL>` with the [request URL](/sandbox/intro-to-developer-portal/#request-urls) of your Code42 cloud instance.
* Replace `<AuthToken>` with the [authentication token](/sandbox/intro-to-developer-portal/#authentication).
* Replace `<SampleTenant>` with the [tenant ID](/sandbox/intro-to-developer-portal/#get-a-tenant-id).
* Replace `<SampleRuleID>` with the ID of the alert rule for which you want to view users.

A successful response lists the email addresses and cloud aliases of the users in the alert rule's inclusion or exclusion list, grouped by the user ID value (identified by the "userIdFromAuthority" label) associated with that information. The "usersToAlertOn" label identifies whether the rule applies only to the specified users in an inclusion list (`SPECIFIED_USERS`), to all users except the specified users in an exclusion list (`ALL_USERS_NOT_SPECIFIED`), or to all users (`ALL_USERS`).

```json
{"type$":"USERS_IN_RULE_RESPONSE","users":[{"type$":"USER_BAG","userIdFromAuthority":"947210378478595410","userAliasList":["SCassidy","SeanCassidy","sean.cassidy@example.com"]}],"usersToAlertOn":"SPECIFIED_USERS"}
```

If a user ID was not provided when users were added to the alert rule (as is common when users are added using the Code42 command-line interface or manually with [Alerts in the Code42 console](https://support.code42.com/Administrator/Cloud/Code42_console_reference/Alerts_reference)), the results note that the "userIdFromAuthority" value is null. To work with an alert rule's inclusion or exclusion list if the user ID value is null, use the [Alerts screens in the Code42 console](https://support.code42.com/Administrator/Cloud/Code42_console_reference/Alerts_reference#Review_Alerts) to manually add and remove users. Alternately, you can use the [/v1/alert-rules/remove-all-users](/sandbox/api/#operation/Rules_RemoveAllUsersFromRule) API command to remove all email addresses and aliases from a rule, and then re-add user information to that rule using the [/v1/alert-rules/add-users](/sandbox/api/#operation/Rules_AddUsersToRule) using the [users' userUID in Code42](/sandbox/intro-to-developer-portal/#get-useruid).

```json
{"type$":"USERS_IN_RULE_RESPONSE","users":[{"type$":"USER_BAG","userIdFromAuthority":"Null UserIdFromAuthority.  These usernames must be edited in the web app.","userAliasList":["burt.morales@example.com","astrid.ludwig@example.com"]}],"usersToAlertOn":"SPECIFIED_USERS"}
```

### Add users to an alert rule

If the rule applies to specific users, or if it applies to all users except specific users, you can add users to those inclusion or exclusion lists with the [/v1/alert-rules/add-users](/sandbox/api/#operation/Rules_AddUsersToRule) API command. You cannot add users to rules that monitor all users.

**Note:** You cannot use these alerts APIs to add or remove users from the inclusion or exclusion lists of default rules created by the Departing Employees list or High Risk Employees list. Instead, users are added to and removed from these lists directly in the [Departing Employees list](https://support.code42.com/Administrator/Cloud/Code42_console_reference/Departing_Employees_reference) and [High Risk Employees list](https://support.code42.com/Administrator/Cloud/Code42_console_reference/High_Risk_Employees_reference) or with the [Detection List Management API](/sandbox/detection-list-management-api/#detection-list-management-api).

```bash
curl -X POST "<RequestURL>/v1/alert-rules/add-users" \
-H "accept: application/json" \
-H "Authorization: Bearer <AuthToken>" \
-H "Content-Type: application/json" \
-d '{ "tenantId": "<SampleTenant>", "ruleId": "<SampleRuleId>", "userList": [ { "userIdFromAuthority": "<SampleUserUID>", "userAliasList": [ "<SampleAlias1>", "<SampleAlias2>" ] } ]}'
```

In the preceding example:

* Replace `<RequestURL>` with the [request URL](/sandbox/intro-to-developer-portal/#request-urls) of your Code42 cloud instance.
* Replace `<AuthToken>` with the [authentication token](/sandbox/intro-to-developer-portal/#authentication).
* Replace `<SampleTenant>` with the [tenant ID](/sandbox/intro-to-developer-portal/#get-a-tenant-id).
* Replace `<SampleRuleID>` with the ID of the alert rule from which you want to remove users.
* Replace `<SampleUserID>` with a value that uniquely identifies the user you want to add. As a best practice, use [the user's userUID in Code42](/sandbox/intro-to-developer-portal/#get-useruid) for this value.
* The `userAliasList` parameter identifies the list of email addresses or cloud aliases to associate with that `<SampleUserID>`. Replace `<SampleAlias1>` and `<SampleAlias2>` with the email addresses or cloud aliases you want to add to the rule's inclusion or exclusion list for that user ID.
  * If you want to enter only one email address or cloud alias, use this construction: `"userAliasList": [ "<SampleAlias1>" ]`
  * If you want to enter multiple email addresses or cloud aliases for that user ID, enclose each ID in quotation marks and separate them with commas.

The aliases that you enter here become the values that are added to the rule's inclusion or exclusion list and used to trigger or filter alert notifications.

### Remove specific users from an alert rule

You can also remove users' email addresses or cloud aliases from an alert rule's inclusion or exclusion list with the [/v1/alert-rules/remove-users](/sandbox/api/#operation/Rules_RemoveUsersFromRule) API command. This command removes all of the email addresses or cloud aliases associated with the user's ID from the specified rule. You cannot remove users from rules that monitor all users.

**Note:** You cannot use these alerts APIs to add or remove users from the inclusion or exclusion lists of [default rules](https://support.code42.com/Administrator/Cloud/Monitoring_and_managing/How_to_create_a_security_alert#Default_alert_rules_and_notifications) created by the Departing Employees list or High Risk Employees list. Instead, users are added to and removed from these lists directly in the [Departing Employees list](https://support.code42.com/Administrator/Cloud/Monitoring_and_managing/Add_departing_employees) and [High Risk Employees list](https://support.code42.com/Administrator/Cloud/Monitoring_and_managing/Add_high_risk_employees) or with the [Detection List Management API](/sandbox/detection-list-management-api/#detection-list-management-api).

```bash
curl -X POST "<RequestURL>/v1/alert-rules/remove-users" \
-H "accept: application/json" \
-H "Authorization: Bearer <AuthToken>" \
-H "Content-Type: application/json" \
-d '{ "tenantId": "<SampleTenant>", "ruleId": "<SampleRuleID>", "userIdList": [ "<SampleUserUID>" ]}'
```

In the preceding example:

* Replace `<RequestURL>` with the [request URL](/sandbox/intro-to-developer-portal/#request-urls) of your Code42 cloud instance.
* Replace `<AuthToken>` with the [authentication token](/sandbox/intro-to-developer-portal/#authentication).
* Replace `<SampleTenant>` with the [tenant ID](/sandbox/intro-to-developer-portal/#get-a-tenant-id).
* Replace `<SampleRuleID>` with the ID of the alert rule from which you want to remove users.
* Replace `<SampleUserUID>` with the value that uniquely identifies the alias list of the user you want to remove (such as the [user's userUID in Code42](/sandbox/intro-to-developer-portal/#get-useruid)).

**Note:** The [/v1/alert-rules/remove-users](/sandbox/api/#operation/Rules_RemoveUsersFromRule) API command uses the `<SampleUserUID>` value to identify the user alias list to remove from the rule. This value may not always be supplied when users are added to rules, such as when users are added via the Code42 command-line interface or manually with [Alerts in the Code42 console](https://support.code42.com/Administrator/Cloud/Code42_console_reference/Alerts_reference). Therefore, results from using [/v1/alert-rules/remove-users](/sandbox/api/#operation/Rules_RemoveUsersFromRule) may not be what you expect: if no `<SampleUserUID>` value exists, the corresponding alias list cannot be identified and no users are removed. To resolve this issue using the API, use the [/v1/alert-rules/remove-all-users](/sandbox/api/#operation/Rules_RemoveAllUsersFromRule) API command to remove all users from a rule's inclusion or exclusion list, then use the [/v1/alert-rules/add-users](/sandbox/api/#operation/Rules_AddUsersToRule) API command to add user aliases that are associated with a `<SampleUserUID>` value.

### Remove a user's aliases from an alert rule

Before removing user information from an alert rule's inclusion or exclusion list, use the [/v1/alert-rules/query-users](/sandbox/api/#operation/Rules_QueryUsersOnRule) API command to identify what user information is contained in that list and whether it is associated with a user ID. After identifying the user ID associated with the email addresses or cloud aliases in a rule's inclusion or exclusion list, you can then use the [/v1/alert-rules/remove-user-aliases](/sandbox/api/#operation/Rules_RemoveUserAliasesFromRule) API command to remove only that user information from the list.

**Note:** If there are no user IDs associated with the user information in an alert rule's inclusion or exclusion list, you cannot remove specific email addresses or cloud aliases from that list with this API command. Instead, you can use one of these methods to work with a rule's user information:

* Use the [Alerts screen in the Code42 console](https://support.code42.com/Administrator/Cloud/Code42_console_reference/Alerts_reference) to manually add and remove users.
* Use the [/v1/alert-rules/remove-all-users](/sandbox/api/#operation/Rules_RemoveAllUsersFromRule) and [/v1/alert-rules/add-users](/sandbox/api/#operation/Rules_AddUsersToRule) API commands to remove all user information and then re-add the email addresses and cloud aliases (associated with a [Code42 userUID](/sandbox/intro-to-developer-portal/#get-useruid) value) that you want to keep.

```bash
curl -X POST "<RequestURL>/v1/alert-rules/remove-user-aliases" \
-H "accept: application/json" \
-H "Authorization: Bearer <AuthToken>" \
-H "Content-Type: application/json" \
-d '{ "tenantId": "<SampleTenant>", "ruleId": "<SampleRuleID>", "userList": [ { "userIdFromAuthority": "<SampleUserID>", "userAliasList": [ "<SampleAlias1>", "<SampleAlias2>" ] } ]}'
```

In the preceding example:

* Replace `<RequestURL>` with the [request URL](/sandbox/intro-to-developer-portal/#request-urls) of your Code42 cloud instance.
* Replace `<AuthToken>` with the [authentication token](/sandbox/intro-to-developer-portal/#authentication).
* Replace `<SampleTenant>` with the [tenant ID](/sandbox/intro-to-developer-portal/#get-a-tenant-id).
* Replace `<SampleRuleID>` with the ID of the alert rule from which you want to remove users.
* Replace `<SampleUserID>` with the value that is associated with the email addresses or cloud aliases that you want to remove.
* The userAliasList parameter identifies the email addresses or cloud aliases associated with that `<SampleUserID>` that should be removed from the list. Replace `<SampleAlias1>` and `<SampleAlias2>` with the email addresses or cloud aliases you want to remove from the rule's inclusion or exclusion list for that user ID.
  * If you want to remove only one email address or cloud alias, use this construction: `"userAliasList": [ "<SampleAlias1>" ]`
  * If you want to remove multiple email addresses or cloud aliases for that user ID, enclose each ID in quotation marks and separate them with commas.
  * If there are multiple email addresses or cloud aliases associated with that user ID but you want to remove only one or two, specify only the values to remove.

### Remove all users from an alert rule

If you do not know the user ID associated with the list of email addresses or cloud aliases for a user, you can use the [/v1/alert-rules/remove-all-users](/sandbox/api/#operation/Rules_RemoveAllUsersFromRule) API command to remove all users from an alert rule's inclusion or exclusion list. You can then use the add-users API command to rebuild those lists using known user IDs.

```bash
curl -X POST "<RequestURL>/v1/alert-rules/remove-all-users" \
-H "accept: application/json" \
-H "Authorization: Bearer <AuthToken>" \
-H "Content-Type: application/json" \
-d '{ "tenantId": "<SampleTenant>", "ruleId": "<SampleRuleID>" }'
```

In the preceding example:

* Replace `<RequestURL>` with the [request URL](/sandbox/intro-to-developer-portal/#request-urls) of your Code42 cloud instance.
* Replace `<AuthToken>` with the [authentication token](/sandbox/intro-to-developer-portal/#authentication).
* Replace `<SampleTenant>` with the [tenant ID](/sandbox/intro-to-developer-portal/#get-a-tenant-id).
* Replace `<SampleRuleID>` with the ID of the alert rule from which you want to remove all users.

#### Filter syntax for the query-alerts API command

The [/v1/alerts/query-alerts](/sandbox/api/#operation/Alerts_QueryAlert) API uses these filter types, operators, and criteria values to search for alert notifications.

Filter Type | Operator | Criteria
-------------- | -------------- | --------------
DateObserved | On, On or after, On or before | Date the alert was triggered, in yyyy-MM-dd format
Actor | Is, Is not, Contains, Does not contain | The username or cloud alias (actor) of the person who caused the event, or portions thereof
Severity | Is, Is not | High, Medium, or Low
RuleName | Is, Is not, Contains, Does not contain | The name of the rule, or portions thereof
Description | Is, Is not, Contains, Does not contain | The description of the rule, or portions thereof
AlertState | Is, Is not | Open or Dismissed
AlertID | Is | The ID of a specific alert notification

#### Filter syntax for the rules/query-rule-metadata API command

The [/v1/alerts/rules/query-rule-metadata](/sandbox/api/#operation/Rules_QueryRuleMetadata) API uses these filter types, operators, and criteria values to search for alert rules.

Filter Type | Operator | Criteria
-------------- | -------------- | --------------
TenantId | Is | The ID of your organization or tenant in Code42.
ObserverRuleId | Is | The ID of a specific alert rule.
Type | Is, Is not | The rule's exposure type (Cloud share permissions changes rules: FED_CLOUD_SHARE_PERMISSIONS), (Exposure on an endpoint rules: FED_ENDPOINT_EXFILTRATION), (Suspicious file mismatch rules: FED_FILE_TYPE_MISMATCH)
Name | Is, Is not, Contains, Does not contain | The name of the rule, or portions thereof
Description | Is, Is not, Contains, Does not contain | The description of the rule, or portions thereof
Severity | Is, Is not | High, Medium, or low
IsSystem | Is | True or False. Indicates whether the rule is a default rule created by the Departing Employee list or High Risk Employees list
IsEnabled | Is | True or False. Indicates whether the rule is enabled or disabled.
RuleSource | Is, Is not | The source that created the rule. For rules created manually: Alerting. For rules created by the Departing Employee list: Departing Employee. For rules created by the High Risk Employees list: High Risk Employee
ModifiedAt | On, On or after, On or before | Date the rule was modified, in yyyy-MM-dd format
ModifiedBy | Is, Is not, Contains, Does not contain | Username of the person who last modified the rule. For default rules created by the Departing Employee list or High Risk Employees list, use Code42 as the user name.
CreatedAt | On, On or after, On or before | Date the rule was created, in yyyy-MM-dd format
CreatedBy | Is, Is not, Contains, Does not contain | Username of the person who created the rule. For default rules created by the Departing Employee list or High Risk Employees list, use Code42 as the user name.
