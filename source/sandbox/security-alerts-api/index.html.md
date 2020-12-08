---
title: Security alerts API

category: detect-and-respond

search: true

code_clipboard: true
---

# Security alerts API

## Overview

You review alert notifications and manage alert rules using the Alerts menu of the Code42 console. To automate the process of viewing alert notifications, adding notes, or opening or dismissing alert notifications, you can write scripts that use the Alerts management APIs. This article introduces those APIs and shows examples of their use.

## Considerations 

* The tasks in this article require use of the [Code42 API](https://support.code42.com/Administrator/Cloud/Monitoring_and_managing/Code42_API_resources/Introduction_to_the_Code42_API).
    * If you are not familiar with using Code42 APIs, review [Code42 API syntax and usage](https://support.code42.com/Administrator/Cloud/Monitoring_and_managing/Code42_API_resources/Code42_API_syntax_and_usage).
    * For assistance with using the Code42 API, contact your Customer Success Manager (CSM) to engage the Code42 Professional Services team. Or, [post your question to the Code42 community](https://success.code42.com/home) to get advice from fellow Code42 administrators.
* To perform tasks in this article, you must: 
    * Have either the [Customer Cloud Admin](https://support.code42.com/Administrator/Cloud/Monitoring_and_managing/Roles_reference#Customer_Cloud_Admin) or [Security Center User](https://support.code42.com/Administrator/Cloud/Monitoring_and_managing/Roles_reference#Security_Center_User) role.
    * Obtain an authentication token and your organization's tenant ID.
* You can also use the Code42 command-line interface (CLI) to work with alert notifications and rules. For more information, see the [Code42 CLI documentation](https://clidocs.code42.com/en/latest/commands/alerts.html).

## Manage alert notifications 

To work with alert notifications, use the API query commands to search for alert notifications. Once you [identify specific alert IDs](#locate-alert-rule-ids), you can then add a note, dismiss, or reopen those alert notifications.

### Search for alert notifications by alert filter criteria 

To search for alert notifications using filter criteria and identify alert IDs, use the `api/v1/query-alerts` API command. 

```bash
curl -X POST \
"<RequestURL>/query-alerts" \
-H "accept: text/plain" \
-H "Authorization: v3_user_token <AuthToken>" \
-H "Content-Type: application/json" \
-d '{ "tenantId": "<SampleTenant>", "groups": [ { "filters": [ { "term": "<FilterType>", "operator": "<OperatorValue>", "value": "<Criteria>" } ], "filterClause": "AND" } ], "groupClause": "OR", "pgSize": "20", "pgNum": "0", "srtKey": "CreatedAt", "srtDirection": "DESC" }'
```

In the preceding example:
* Replace <RequestURL> with the [request URL](#summary) of your Code42 cloud instance, for example,
`https://alert-service-default.prod.ffs.us2.code42.com/svc/api/v1/`
* Replace <AuthToken> with the authentication token you obtained in the [Authentication](#authentication) section.
* Replace <SampleTenant> with the tenant ID you obtained in the [Get your organization's tenant ID](#get-your-organizations-tenant-id) section.
* Replace <FilterType> with the filter, <OperatorValue> with the operator option, and <Criteria> with the search term to use in the search. See [Filter syntax for the query-alerts API command](#filter-syntax-for-the-query-alerts-API-command) below for details.

A successful response returns basic information about the alert notifications that match your search criteria, including the alert IDs of those notifications (look for the `"id":"value"` entry):

```json
{"type$":"ALERT_SUMMARY","tenantId":"123456","type":"FED_ENDPOINT_EXFILTRATION","name":"Departing employee endpoint exfiltration system rule","description":"System rule for departing employee endpoint exfiltration.","actor":"burt.morales@example.com","target":"N/A","severity":"HIGH","ruleId":"123456789424242","ruleSource":"Departing Employee","id":"987654321424242","createdAt":"2020-04-03T15:21:44.6139300Z","state":"OPEN"}],"totalCount":1,"problems":[]}
```

### Search for multiple alert notifications by alert IDs 

After you've located the alert IDs for specific alerts, use the `/api/v1/query-details` API command to search those IDs and view more details about those alert notifications. 

```bash
curl -X POST \
"<RequestURL>/query-details" \
-H "accept: text/plain" \
-H "Authorization: v3_user_token <AuthToken>" \
-H "Content-Type: application/json" \
-d '{ "alertIds": [ "<SampleAlertID1>", "<SampleAlertID2>" ]}'
```

In the preceding example:
* Replace <RequestURL> with the [request URL](#summary) of your Code42 cloud instance, for example, `https://alert-service-default.prod.ffs.us2.code42.com/svc/api/v1/`
* Replace <AuthToken> with the authentication token you obtained in the [Authentication](#authentication) section.
* Replace <SampleAlertID1> and <SampleAlertID2> with the IDs of the alert notifications. Enclose each ID in quotation marks and separate them with commas.

A successful response returns full details about the alert notifications, including a list of files involved in the activity.

```bash
{"type$":"ALERT_DETAILS_RESPONSE","alerts":[{"type$":"ALERT_DETAILS","tenantId":"123456","type":"FED_ENDPOINT_EXFILTRATION","name":"Departing employee endpoint exfiltration system rule","description":"System rule for departing employee endpoint exfiltration.","actor":"burt.morales@example.com","target":"N/A","severity":"HIGH","ruleId":"123456789424242","ruleSource":"Departing Employee","id":"987654321424242","createdAt":"2020-04-08T13:50:25.3644410Z","state":"OPEN","observations":[{"type$":"OBSERVATION","id":"112233445566","observedAt":"2020-04-08T13:40:00.0000000Z","type":"FedEndpointExfiltration","data":"{\"type$\":\"OBSERVED_ENDPOINT_ACTIVITY\",\"id\":\"665544332211\",\"sources\":[\"Endpoint\"],\"exposureTypes\":[\"ApplicationRead\",\"CloudStorage\"],\"firstActivityAt\":\"2020-04-08T13:40:00.0000000Z\",\"lastActivityAt\":\"2020-04-08T13:45:00.0000000Z\",\"fileCount\":2,\"totalFileSize\":311096,\"fileCategories\":[{\"type$\":\"OBSERVED_FILE_CATEGORY\",\"category\":\"Image\",\"fileCount\":2,\"totalFileSize\":311096,\"isSignificant\":false}],\"files\":[{\"type$\":\"OBSERVED_FILE\",\"eventId\":\"998877665544\",\"path\":\"C:/Users/burt.morales/\",\"name\":\"1586353274_family_photo.png\",\"category\":\"Image\"},{\"type$\":\"OBSERVED_FILE\",\"eventId\":\"334455667788\",\"path\":\"C:/Users/burt.morales/Dropbox/\",\"name\":\"1586353274_family_photo.png\",\"category\":\"Image\"}],\"syncToServices\":[\"Dropbox\"],\"sendingIpAddresses\":[\"192.0.2.0\"]}"}]}]}
```

### Search for a single notification by alert ID 

Use the `/api/v1/query-details-aggregate` API command to search for a single alert notification using its alert ID. 

```bash
curl -X POST \
"<RequestURL>/query-details-aggregate" \
-H "accept: text/plain" \
-H "Authorization: v3_user_token <AuthToken>" \
-H "Content-Type: application/json" \
-d '{ "alertId": "<SampleAlertID>"}'
```

In the preceding example:
* Replace <RequestURL> with the request URL of your Code42 cloud instance, for example,
`https://alert-service-default.prod.ffs.us2.code42.com/svc/api/v1/`
* Replace <AuthToken> with the authentication token you obtained in the [Authentication](#authentication) section.
* Replace <SampleAlertID> with the alert ID.

A successful response returns full details about the alert notification with all file activity aggregated into a single Observation value.

```json
{"type$":"ALERT_DETAILS_IN_AGGREGATE_RESPONSE","alert":{"type$":"ALERT_DETAILS_AGGREGATE","tenantId":"123456","type":"FED_ENDPOINT_EXFILTRATION","name":"Departing employee endpoint exfiltration system rule","description":"System rule for departing employee endpoint exfiltration.","actor":"burt.morales@c42se.com","target":"N/A","severity":"HIGH","ruleId":"1234567894242","ruleSource":"Departing Employee","id":"9876543214242","createdAt":"2020-04-08T13:50:25.3644410Z","state":"OPEN","observation":{"type$":"OBSERVATION_AGGREGATE","observedAt":"2020-04-08T13:40:00.0000000Z","type":"FedEndpointExfiltration","data":"{\"type$\":\"OBSERVED_ENDPOINT_ACTIVITY\",\"id\":\"112233445566\",\"sources\":[\"Endpoint\"],\"exposureTypes\":[\"ApplicationRead\",\"CloudStorage\"],\"firstActivityAt\":\"2020-04-08T13:40:00.0000000Z\",\"lastActivityAt\":\"2020-04-08T13:45:00.0000000Z\",\"fileCount\":2,\"totalFileSize\":311096,\"fileCategories\":[{\"type$\":\"OBSERVED_FILE_CATEGORY\",\"category\":\"Image\",\"fileCount\":2,\"totalFileSize\":311096,\"isSignificant\":false}],\"files\":[{\"type$\":\"OBSERVED_FILE\",\"eventId\":\"998877665544\",\"path\":\"C:/Users/burt.morales/\",\"name\":\"1586353274_family_photo.png\",\"category\":\"Image\"},{\"type$\":\"OBSERVED_FILE\",\"eventId\":\"334455667788\",\"path\":\"C:/Users/burt.morales/Dropbox/\",\"name\":\"1586353274_family_photo.png\",\"category\":\"Image\"}],\"syncToServices\":[\"Dropbox\"],\"sendingIpAddresses\":[\"192.0.2.0\"],\"isRemoteActivity\":false}"}}}
```

### Add a note to an alert notification 

To add a note to an alert notification, first locate its alert ID using one of the queries above. Then use the `/api/v1/add-note` command to add a note to that alert. Be aware that any note you add overwrites any existing note attached to the alert.

```bash
curl -X POST \
"<RequestURL>/add-note" \
-H "accept: application/json" \
-H "Authorization: v3_user_token <AuthToken>" \
-H "Content-Type: application/json" \
-d '{ "tenantId": "<SampleTenant>", "alertId": "<SampleAlertID>", "note": "This is an example note." }'
```

In the preceding example:
* Replace <RequestURL> with the request URL of your Code42 cloud instance, for example,
`https://alert-service-default.prod.ffs.us2.code42.com/svc/api/v1/`
* Replace <AuthToken> with the authentication token you obtained in the [Authentication](#authentication) section.
* Replace <SampleTenant> with the tenant ID you obtained in the [Get your organization's tenant ID](#get-your-organization's-tenant-ID) section.
* Replace <SampleAlertID> with the alert ID.

### Dismiss alert notifications 

You can dismiss multiple alert notifications at once using the API. To dismiss alert notifications, first locate the alert IDs using one of the queries above. Then use the `/api/v1/resolve-alert` command to dismiss those alerts. 

```bash
curl -X POST \
"<RequestURL>/resolve-alert" \
-H "accept: application/json" \
-H "Authorization: v3_user_token <AuthToken>" \
-H "Content-Type: application/json" \
-d '{ "tenantId": "<SampleTenant>", "alertIds": [ "<SampleAlertID1>", <SampleAlertID2>" ], "note": "This is an example note."}'
```

In the preceding example:
* Replace <RequestURL> with the [request URL](#summary) of your Code42 cloud instance, for example, `https://alert-service-default.prod.ffs.us2.code42.com/svc/api/v1/`
* Replace <AuthToken> with the authentication token you obtained in the [Authentication](#authentication) section.
* Replace <SampleTenant> with the tenant ID you obtained in the [Get your organization's tenant ID](#get-your-organization's-tenant-ID) section.
* Replace <SampleAlertID1> and <SampleAlertID2> with the IDs of the alert notifications. Enclose each ID in quotation marks and separate them with commas.
* Be aware that any note you enter overwrites any existing note attached to the alert. If you want to dismiss the alert without adding a note (or want to preserve existing notes), delete the "note" term and sample text from the command.

### Reopen dismissed alert notifications 
You can reopen multiple dismissed alert notifications at once using the API. To reopen alert notifications, first locate the alert IDs using one of the queries above. Then use the /api/v1/reopen-alert command to reopen those alerts. 

```bash
curl -X POST \
"<RequestURL>/reopen-alert" \
-H "accept: application/json" \
-H "Authorization: v3_user_token <AuthToken>" \
-H "Content-Type: application/json" \
-d '{ "tenantId": "<SampleTenant>", "alertIds": [ "<SampleAlertID1>", <SampleAlertID2>" ], "note": "This is an example note."}'
```

In the preceding example:
* Replace <RequestURL> with the request URL of your Code42 cloud instance, for example,
`https://alert-service-default.prod.ffs.us2.code42.com/svc/api/v1/`
* Replace <AuthToken> with the authentication token you obtained in the [Authentication](#authentication) section.
* Replace <SampleTenant> with the tenant ID you obtained in the [Get your organization's tenant ID](#get-your-organization's-tenant-ID) section.
* Replace <SampleAlertID1> and <SampleAlertID2> with the IDs of the alert notifications. Enclose each ID in quotation marks and separate them with commas.
* Be aware that any note you enter overwrites any existing note attached to the alert. If you want to reopen the alert without adding a note (or want to preserve existing notes), delete the "note" term and sample text from the command.

## Manage alert rule user lists 

If a rule either applies only to specific users or applies to all users except specific users, you can manage the users in those inclusion or exclusion lists using the API. As with alert notifications, you'll need to identify the rule ID associated with the rule before you can manage the users to which it applies.

<aside class="notice">

**Be careful with request URLs**
The API commands in this section use different request URLs, so use caution when crafting the calls.
</aside>

### Locate alert rule IDs 

Before you can manage the users associated with an alert rule, you need to view details about alert rules and identify the rule IDs for which you want to manage users. Use the `/api/v1/Rules/query-rule-metadata` API command to locate alert rule IDs. 

<aside class="success">

**Rule IDs are also included in alert notification searches**
The API commands for alert notification searches described above also include the ID of the rule that generated the alert. Look for the "ruleID": "<value>" entry in the details returned by the query.
</aside>

```bash
curl -X POST \
"<Request URL>/Rules/query-rule-metadata" \
-H "accept: text/plain" \
-H "Authorization: v3_user_token <AuthToken>" \
-H "Content-Type: application/json" \
-d '{ "tenantId": "<SampleTenant>", "groups": [ { "filters": [ { "term": "<FilterTerm>", "operator": "<OperatorValue>", "value": "<Criteria>" } ], "filterClause": "AND" } ], "groupClause": "OR", "pgSize": "20", "pgNum": "0", "srtKey": "CreatedAt", "srtDirection": "DESC"}'
```

In the preceding example:
* Replace <RequestURL> with the request URL of your Code42 cloud instance, for example,
`https://alert-service-default.prod.ffs.us2.code42.com/svc/api/v1/`
* Replace <AuthToken> with the authentication token you obtained in the [Authentication](#authentication) section.
* Replace <SampleTenant> with the tenant ID you obtained in the [Get your organization's tenant ID](#get-your-organization's-tenant-ID) section.
*Replace <FilterType> with the filter, <OperatorValue> with the operator option, and <Criteria> with the search term to use in the search. See [Filter syntax for the rules/query-rule-metadata API command](#filter-syntax-for-the-rules/query-rule-metadata-API-command) below for details.

A successful response returns basic information about the alert notifications that match your search criteria, including the rule IDs of those notifications (look for the "observerRuleId":"value" entry):

```json
{"type$":"RULE_METADATA_SEARCH_RESPONSE","ruleMetadata":[{"type$":"RULE_METADATA","modifiedBy":"Code42","modifiedAt":"2020-06-04T21:07:03.5417950Z","name":"Exposure on an endpoint","description":"This default rule alerts you when departing employees move data from an endpoint.","severity":"HIGH","isSystem":true,"isEnabled":false,"ruleSource":"Departing Employee","tenantId":"123456","observerRuleId":"1234567894242","type":"FED_ENDPOINT_EXFILTRATION","id":"9876543214242","createdBy":"Code42","createdAt":"2020-01-10T12:16:40.7765970Z"}],"totalCount":8,"problems":[]}
```

### View an alert rule's user list 

Use the `/api/v1/Rules/query-users` API command to view a list of users that are either included in or excluded from a specific alert rule. The output from this command groups the user email addresses and cloud aliases in the rule's inclusion or exclusion list by the user ID associated with those details (which is generally the userUID value in Code42). You can then use this user ID to remove specific email addresses and cloud aliases from a rule's inclusion or exclusion list as needed. 

```bash
curl -X POST \
"<RequestURL>/Rules/query-users" \
-H "accept: text/plain" \
-H "Authorization: v3_user_token <AuthToken>" \
-H "Content-Type: application/json" \
-d '{ "tenantId": "<SampleTenant>", "ruleId": "<SampleRuleID>"}'
```

In the preceding example:
* Replace <RequestURL> with the request URL of your Code42 cloud instance, for example,
`https://fed-observer-default.prod.ffs.us2.code42.com/svc/api/v1/`
* Replace <AuthToken> with the authentication token you obtained in the [Authentication](#authentication) section.
* Replace <SampleTenant> with the tenant ID you obtained in the [Get your organization's tenant ID](#get-your-organization's-tenant-ID) section.
* Replace <SampleRuleID> with the ID of the alert rule for which you want to view users.

A successful response lists the email addresses and cloud aliases of the users in the alert rule's inclusion or exclusion list, grouped by the user ID value (identified by the "userIdFromAuthority" label) associated with that information. The "usersToAlertOn" label identifies whether the rule applies only to the specified users in an inclusion list (SPECIFIED_USERS), to all users except the specified users in an exclusion list (ALL_USERS_NOT_SPECIFIED), or to all users (ALL_USERS).

```json
{"type$":"USERS_IN_RULE_RESPONSE","users":[{"type$":"USER_BAG","userIdFromAuthority":"947210378478595410","userAliasList":["SCassidy","SeanCassidy","sean.cassidy@example.com"]}],"usersToAlertOn":"SPECIFIED_USERS"}
```

If a user ID was not provided when users were added to the alert rule (as is common when users are added using the Code42 command-line interface or manually with Alerts in the Code42 console), the results note that the "userIdFromAuthority" value is null. To work with an alert rule's inclusion or exclusion list if the user ID value is null, use the Alerts screens in the Code42 console to manually add and remove users. Alternately, you can use the `/api/v1/Rules/remove-all-users` API command to remove all email addresses and aliases from a rule, and then re-add user information to that rule using the `/api/v1/Rules/add-users` using the users' userUIDs in Code42.

```json
{"type$":"USERS_IN_RULE_RESPONSE","users":[{"type$":"USER_BAG","userIdFromAuthority":"Null UserIdFromAuthority.  These usernames must be edited in the web app.","userAliasList":["burt.morales@example.com","astrid.ludwig@example.com"]}],"usersToAlertOn":"SPECIFIED_USERS"}
```

### Add users to an alert rule 

If the rule applies to specific users, or if it applies to all users except specific users, you can add users to those inclusion or exclusion lists with the `/api/v1/Rules/add-users` API command. You cannot add users to rules that monitor all users.

Manage default rule user lists with the Code42 console or Detection List Management APIs
You cannot use these alerts APIs to add or remove users from the inclusion or exclusion lists of default rules created by the Departing Employees list or High Risk Employees list. Instead, users are added to and removed from these lists directly in the Departing Employees list and High Risk Employees list or with the Detection List Management APIs.

```bash
curl -X POST \
"<RequestURL>/Rules/add-users" \
-H "accept: application/json" \
-H "Authorization: v3_user_token <AuthToken>" \
-H "Content-Type: application/json" \
-d '{ "tenantId": "<SampleTenant>", "ruleId": "<SampleRuleId>", "userList": [ { "userIdFromAuthority": "<SampleUserUID>", "userAliasList": [ "<SampleAlias1>", "<SampleAlias2>" ] } ]}'
```

In the preceding example:
* Replace <RequestURL> with the [request URL](#summary) of your Code42 cloud instance, for example, `https://fed-observer-default.prod.ffs.us2.code42.com/svc/api/v1/`
* Replace <AuthToken> with the authentication token you obtained in the [Authentication](#authentication) section.
* Replace <SampleTenant> with the tenant ID you obtained in the [Get your organization's tenant ID](#get-your-organization's-tenant-ID) section.
* Replace <SampleRuleID> with the ID of the alert rule from which you want to remove users.
* Replace <SampleUserID> with a value that uniquely identifies the user you want to add. As a best practice, use the user's userUID in Code42 for this value. See the Identify userUIDs section to locate these values.
* The `userAliasList` parameter identifies the list of email addresses or cloud aliases to associate with that <SampleUserID>. Replace <SampleAlias1> and <SampleAlias2> with the email addresses or cloud aliases you want to add to the rule's inclusion or exclusion list for that user ID.
    * If you want to enter only one email address or cloud alias, use this construction: `"userAliasList": [ "<SampleAlias1>" ]`
    * If you want to enter multiple email addresses or cloud aliases for that user ID, enclose each ID in quotation marks and separate them with commas.

The aliases that you enter here become the values that are added to the rule's inclusion or exclusion list and used to trigger or filter alert notifications.

### Remove specific users from an alert rule 

You can also remove users' email addresses or cloud aliases from an alert rule's inclusion or exclusion list with the `/api/v1/Rules/remove-users` API command. This command removes all of the email addresses or cloud aliases associated with the user's ID from the specified rule. You cannot remove users from rules that monitor all users.

<aside class="notice">

**Manage default rule user lists with the Code42 console or Detection List Management APIs**
You cannot use these alerts APIs to add or remove users from the inclusion or exclusion lists of default rules created by the Departing Employees list or High Risk Employees list. Instead, users are added to and removed from these lists directly in the [Departing Employees list](https://support.code42.com/Administrator/Cloud/Monitoring_and_managing/Add_departing_employees) and [High Risk Employees list](https://support.code42.com/Administrator/Cloud/Monitoring_and_managing/Add_high_risk_employees) or with the [Detection List Management APIs](https://support.code42.com/Administrator/Cloud/Monitoring_and_managing/Code42_API_resources/Detection_list_management_APIs).
</aside>

```bash
curl -X POST \
"<Request URL>/Rules/remove-users" \
-H "accept: application/json" \
-H "Authorization: v3_user_token <AuthToken>" \
-H "Content-Type: application/json" \
-d '{ "tenantId": "<SampleTenant>", "ruleId": "<SampleRuleID>", "userIdList": [ "<SampleUserUID>" ]}'
```

In the preceding example:
* Replace <RequestURL> with the request URL of your Code42 cloud instance, for example,
`https://fed-observer-default.prod.ffs.us2.code42.com/svc/api/v1/`
* Replace <AuthToken> with the authentication token you obtained in the [Authentication](#authentication) section.
* Replace <SampleTenant> with the tenant ID you obtained in the [Get your organization's tenant ID](#get-your-organization's-tenant-ID) section.
* Replace <SampleRuleID> with the ID of the alert rule from which you want to remove users.
* Replace <SampleUserUID> with the value that uniquely identifies the alias list of the user you want to remove (such as the [user's userUID in Code42](#identifyuseruids)).

<aside class="notice">

**Results depend on the user ID value**
The `/api/v1/Rules/remove-users` API command uses the <SampleUserUID> value to identify the user alias list to remove from the rule. This value may not always be supplied when users are added to rules, such as when users are added via the Code42 command-line interface or manually with Alerts in the Code42 console. Therefore, results from using `/api/v1/Rules/remove-users` may not be what you expect: if no <SampleUserUID> value exists, the corresponding alias list cannot be identified and no users are removed.

To resolve this issue using the API, use the `/api/v1/Rules/remove-all-users` API command to remove all users from a rule's inclusion or exclusion list, then use the `/api/v1/Rules/add-users` to add user aliases that are associated with a <SampleUserUID> value. 
</aside>

### Remove a user's aliases from an alert rule 

Before removing user information from an alert rule's inclusion or exclusion list, use the `/api/v1/Rules/query-users` API command to identify what user information is contained in that list and whether it is associated with a user ID. After identifying the user ID associated with the email addresses or cloud aliases in a rule's inclusion or exclusion list, you can then use the `/api/v1/Rules/remove-user-aliases` API command to remove only that user information from the list.

<aside class="notice">

**Requires the user ID**
If there are no user IDs associated with the user information in an alert rule's inclusion or exclusion list, you cannot remove specific email addresses or cloud aliases from that list with this API command. Instead, you can use one of these methods to work with a rule's user information:
* Use the Alerts screen in the Code42 console to manually add and remove users
* Use the `/api/v1/Rules/remove-all-users` and `/api/v1/Rules/add-users` API commands to remove all user information and then re-add the email addresses and cloud aliases (associated with a Code42 userUID value) that you want to keep
</aside>

```bash
curl -X POST \
"<RequestURL>/Rules/remove-user-aliases" \
-H "accept: application/json" \
-H "Authorization: v3_user_token <AuthToken>" \
-H "Content-Type: application/json" \
-d '{ "tenantId": "<SampleTenant>", "ruleId": "<SampleRuleID>", "userList": [ { "userIdFromAuthority": "<SampleUserID>", "userAliasList": [ "<SampleAlias1>", "<SampleAlias2>" ] } ]}'
```

In the preceding example:
* Replace <RequestURL> with the request URL of your Code42 cloud instance, for example,
`https://fed-observer-default.prod.ffs.us2.code42.com/svc/api/v1/`
* Replace <AuthToken> with the authentication token you obtained in the [Authentication](#authentication) section.
* Replace <SampleTenant> with the tenant ID you obtained in the [Get your organization's tenant ID](#get-your-organization's-tenant-ID) section.
* Replace <SampleRuleID> with the ID of the alert rule from which you want to remove users.
* Replace <SampleUserID> with the value that is associated with the email addresses or cloud aliases that you want to remove.
* The userAliasList parameter identifies the email addresses or cloud aliases associated with that <SampleUserID> that should be removed from the list. Replace <SampleAlias1> and <SampleAlias2> with the email addresses or cloud aliases you want to remove from the rule's inclusion or exclusion list for that user ID.
    * If you want to remove only one email address or cloud alias, use this construction: `"userAliasList": [ "<SampleAlias1>" ]`
    * If you want to remove multiple email addresses or cloud aliases for that user ID, enclose each ID in quotation marks and separate them with commas.
    * If there are multiple email addresses or cloud aliases associated with that user ID but you want to remove only one or two, specify only the values to remove.

### Remove all users from an alert rule 

If you do not know the user ID associated with the list of email addresses or cloud aliases for a user, you can use the `/api/v1/Rules/remove-all-users` to remove all users from an alert rule's inclusion or exclusion list. You can then use the add-users API command to rebuild those lists using known user IDs.

```bash
curl -X POST \
"<Request URL>/Rules/remove-all-users" \
-H "accept: application/json" \
-H "Authorization: v3_user_token <AuthToken>" \
-H "Content-Type: application/json" \
-d '{ "tenantId": "<SampleTenant>", "ruleId": "<SampleRuleID>" }'
```

In the preceding example:
* Replace <RequestURL> with the [request URL](#summary) of your Code42 cloud instance, for example, `https://fed-observer-default.prod.ffs.us2.code42.com/svc/api/v1/`
* Replace <AuthToken> with the authentication token you obtained in the [Authentication](#authentication) section.
* Replace <SampleTenant> with the tenant ID you obtained in the [Get your organization's tenant ID](#get-your-organization's-tenant-ID) section.
* Replace <SampleRuleID> with the ID of the alert rule from which you want to remove all users.

## Alerts management API structure and syntax 

### Summary 

**Request URL**
* United States alerts
    * If you sign in to the Code42 console at [https://www.crashplan.com/console](https://www.crashplan.com/console), use:
`https://alert-service-default.prod.ffs.us2.code42.com/svc/api/v1/<resource>`
    * If you sign in to the Code42 console at [https://console.us.code42.com/console](https://console.us.code42.com/console), use: 
`https://alert-service-east.us.code42.com/svc/api/v1/<resource>`
    * If you sign in to the Code42 console for the Code42 federal environment at [https://console.gov.code42.com/console](https://console.gov.code42.com/console), use: 
`https://alert-service-default.gov.code42.com/svc/api/v1/<resource>`
* United States alert rule list management
    * If you sign in to the Code42 console at [https://www.crashplan.com/console](https://www.crashplan.com/console), use:
`https://fed-observer-default.prod.ffs.us2.code42.com/svc/api/v1/<resource>`
    * If you sign in to the Code42 console at [https://console.us.code42.com/console](https://console.us.code42.com/console), use: 
`https://fed-observer-east.us.code42.com/svc/api/v1/<resource>`
    * If you sign in to the Code42 console for the Code42 federal environment at [https://console.gov.code42.com/console](https://console.gov.code42.com/console), use: `https://fed-observer-default.gov.code42.com/svc/api/v1/<resource>`
* Ireland
    * For alerts, if you sign in to the Code42 console at [https://console.ie.code42.com/console](https://console.ie.code42.com/console), use: 
https://alert-service-default.ie.code42.com/svc/api/v1/<resource>
    * For alert rule list management, if you sign in to the Code42 console at [https://console.ie.code42.com/console](https://console.ie.code42.com/console), use: 
`https://fed-observer-default.ie.code42.com/svc/api/v1/<resource>`

**Resources**
* Alerts API commands
    * `resolve-alert`: Dismiss an alert.
    * `reopen-alert`: Reopen an alert.
    * `add-note`: Add a note to an alert.
    * `query-alerts`: Search for alerts using alert filter criteria. See [Filter syntax for the query-alerts API command](#filter-syntax-for-the-query-alerts-api-command) below for details.
    * `query-details`: Search for alerts by alert ID.
    * `query-details-aggregate`: Search for an alert by its alert ID. Details about the alert are aggregated into a single Observation value.
    * `rules/query-rule-metadata`: Search for alert rules in your organization's tenant using filter criteria and view basic rule information. See [Filter syntax for the rules/query-rule-metadata](#filter-syntax-for-the-rules/query-rule-metadata) below for details.
* Alert list management API commands
    * `rules/update-is-enabled`: Enable or disable a list of alert rules.
    * `rules/add-users`: Add users to a rule's inclusion or exclusion list.
    * `rules/remove-users`: Remove users (and all aliases associated with those users) from a rule's inclusion or exclusion list.
    * `rules/remove-user-aliases`: Remove specific user aliases from a rule's inclusion or exclusion list.
    * `rules/remove-all-users`: Remove all users (and all aliases associated with those users) from a rule's inclusion or exclusion list.
    * `rules/query-cloud-share-permissions-rule`: Search for **Cloud share permissions changes** alert rules by rule ID.
    * `rules/query-endpoint-exfiltration-rule`: Search for **Exposure on an endpoint alert** alert rules by rule ID.
    * `rules/query-file-type-mismatch-rule`: Search for **Suspicious file mismatch** alert rules by rule ID.

**Authentication method:** Include a token in the request header. See the [Authentication](#authentication) section below.

**Tenant ID:** Many of the API commands require a tenant ID. See the [Get your organization's tenant ID](#get-your-organization's-tenant-ID) section below.

**Complete API documentation**
* United States
    * [https://alert-service-default.prod.ffs.us2.code42.com/svc/swagger/index.html](https://alert-service-default.prod.ffs.us2.code42.com/svc/swagger/index.html) and     * [https://fed-observer-default.prod.ffs.us2.code42.com/svc/swagger/index.html](https://fed-observer-default.prod.ffs.us2.code42.com/svc/swagger/index.html)
    * [https://alert-service-east.us.code42.com/svc/swagger/index.html](https://alert-service-east.us.code42.com/svc/swagger/index.html) and [https://fed-observer-east.us.code42.com/svc/swagger/index.html](https://fed-observer-east.us.code42.com/svc/swagger/index.html)
    * [https://alert-service-default.gov.code42.com/svc/swagger/index.html](https://alert-service-default.gov.code42.com/svc/swagger/index.html) and [https://fed-observer-default.gov.code42.com/svc/swagger/index.html](https://fed-observer-default.gov.code42.com/svc/swagger/index.html)
* Ireland
[https://alert-service-default.ie.code42.com/svc/swagger/index.html](https://alert-service-default.ie.code42.com/svc/swagger/index.html) and [https://fed-observer-default.ie.code42.com/svc/swagger/index.html](https://fed-observer-default.ie.code42.com/svc/swagger/index.html)

#### Filter syntax for the query-alerts API command 

The `query-alerts` API uses these filter types, operators, and criteria values to search for alert notifications.


Filter Type | Operator  | Criteria
-------------- | -------------- | --------------
DateObserved|On, On or after, On or before | Date the alert was triggered, in YYYY-MM-DD format
Actor|Is, Is not, Contains, Does not contain | The username or cloud alias (actor) of the person who caused the event, or portions thereof
Severity | Is, Is not | High, Medium, or Low
RuleName | Is, Is not, Contains, Does not contain | The name of the rule, or portions thereof
Description | Is, Is not, Contains, Does not contain | The description of the rule, or portions thereof
AlertState | Is, Is not | Open or Dismissed
AlertID | Is | The ID of a specific alert notification


#### Filter syntax for the rules/query-rule-metadata API command 

The `rules/query-rule-metadata` uses these filter types, operators, and criteria values to search for alert rules.

 
Filter Type | Operator | Criteria
-------------- | -------------- | --------------
TenantId | Is | The ID of your organization or tenant in {{c42}}
ObserverRuleId | Is | The ID of a specific alert rule.
Type | Is, Is not | The rule's exposure type (Cloud share permissions changes rules: FED_CLOUD_SHARE_PERMISSIONS), (Exposure on an endpoint rules: FED_ENDPOINT_EXFILTRATION), (Suspicious file mismatch rules: FED_FILE_TYPE_MISMATCH) 
Name | Is, Is not, Contains, Does not contain | The name of the rule, or portions thereof
Description | Is, Is not, Contains, Does not contain | The description of the rule, or portions thereof
Severity | Is, Is not | High, Medium, or low
IsSystem | Is | True or False. Indicates whether the rule is a default rule created by the Departing Employee list or High Risk Employees list
IsEnabled | Is | True or False. Indicates whether the rule is enabled or disabled.
RuleSource | Is, Is not | The source that created the rule. For rules created manually: Alerting. For rules created by the Departing Employee list: Departing Employee. For rules created by the High Risk Employees list: High Risk Employee
ModifiedAt | On, On or after, On or before | Date the rule was modified, in YYYY-MM-DD format
ModifiedBy | Is, Is not, Contains, Does not contain | Username of the person who last modified the rule. For default rules created by the Departing Employee list or High Risk Employees list, use Code42 as the user name.
CreatedAt | On, On or after, On or before | Date the rule was created, in YYYY-MM-DD format
CreatedBy | Is, Is not, Contains, Does not contain | Username of the person who created the rule. For default rules created by the Departing Employee list or High Risk Employees list, use Code42 as the user name.


## Authentication 

This API resource requires an [authentication token](https://support.code42.com/Administrator/Cloud/Monitoring_and_managing/Code42_API_resources/Code42_API_authentication_methods#Use_token_authentication) in the header of all requests. To obtain an authentication token, use your Code42 administrator credentials to submit a `GET` request to:

* United States: 
    * If you sign in to the Code42 console at [https://www.crashplan.com/console](https://www.crashplan.com/console), use: 
`https://www.crashplan.com/c42api/v3/auth/jwt?useBody=true`
    * If you sign in to the Code42 console at [https://console.us.code42.com/console](https://console.us.code42.com/console), use: 
`https://console.us.code42.com/c42api/v3/auth/jwt?useBody=true`
    * If you sign in to the Code42 console for the Code42 federal environment at [https://console.gov.code42.com/console](https://console.gov.code42.com/console), use:
`https://console.gov.code42.com/c42api/v3/auth/jwt?useBody=true`
* Ireland: If you sign in to the Code42 console at [https://console.ie.code42.com/console](https://console.ie.code42.com/console), use: `https://console.ie.code42.com/c42api/v3/auth/jwt?useBody=true`

For example:

```bash
curl -X GET -u "username" -H "Accept: application/json" "https://www.crashplan.com/c42api/v3/auth/jwt?useBody=true"
```

If your organization uses [two-factor authentication for local users](https://support.code42.com/Administrator/Cloud/Configuring/Two-factor_authentication_for_local_users), you must also include a `totp-auth` header value containing the Time-based One-Time Password (TOTP) supplied by the Google Authenticator mobile app. The example below includes a TOTP value of 424242.

```bash
curl -X GET -u "username" -H "totp-auth: 424242" "Accept: application/json" "https://www.crashplan.com/c42api/v3/auth/jwt?useBody=true"
```

A successful request returns an authentication token. For example:

```json
{"v3_user_token": "eyJjdHkiO_bxYJOOn28y...5HGtGHgJzHVCE8zfy1qRBf_rhchA"}
```

**Token considerations**
* Use this authentication token in your requests.
* Authentication tokens expire after 30 minutes.
* You must have credentials for a Code42 user with the [Customer Cloud Admin](https://support.code42.com/Administrator/Cloud/Monitoring_and_managing/Roles_reference#Customer_Cloud_Admin) role.
* The authentication example above only applies to users who authenticate locally with Code42. Single sign-on (SSO) users must also complete SAML authentication with their SSO provider. If you need assistance with this process, contact your SSO provider.

### Get your organization's tenant ID 

The APIs require that you provide the unique ID of your organization (or tenant) in the Code42 cloud. To obtain the tenant ID, use your Code42 administrator credentials to submit a GET request to:
* United States: 
    * If you sign in to the Code42 console at [https://www.crashplan.com/console](https://www.crashplan.com/console), use: `https://www.crashplan.com/c42api/v3/customer/my`
    * If you sign in to the Code42 console at [https://console.us.code42.com/console](https://console.us.code42.com/console), use: 
`https://console.us.code42.com/c42api/v3/customer/my` 
    * If you sign in to the Code42 console for the Code42 federal environment at [https://console.gov.code42.com/console](https://console.gov.code42.com/console), use: 
https://console.gov.code42.com/c42api/v3/customer/my 
* Ireland: If you sign in to the Code42 console at [https://console.ie.code42.com/console](https://console.ie.code42.com/console), use: `https://console.ie.code42.com/c42api/v3/customer/my`

In the following example, replace <AuthToken> with the authentication token you obtained and replace console.us.code42.com with the URL of your Code42 cloud instance:

```bash
curl -vvv -X GET -H "Authorization: v3_user_token <AuthToken>" 'https://console.us.code42.com/c42api/v3/customer/my'
```

A successful response returns the tenantUid:

```json
{"data":{"name":"My Org","registrationKey":"4s42ukut7pwpwr4c","deploymentModel":"PUBLIC","maintenanceMode":false,"tenantUid":"42b42dfe-4242-4242-428a-8a1dfd352f2f","masterServicesAgreement":{"accepted":true,"acceptanceRequired":false}},"error":null,"warnings":null}
```

### Identify userUIDs
 
Each user in Code42 is uniquely identified by a userUID value. You use this userUID with the `/api/v1/rules/add-user` and `api/v1/rules/remove-user` to associate a list of email addresses or cloud aliases with a specific user, and to add and remove those alias lists in alert rules.

You can locate userUIDs directly in the Code42 console:
* Export a [list of Code42 users to a CSV file](https://support.code42.com/Administrator/Cloud/Code42_console_reference/Users_reference#CSV_export). The file includes each user's userUID.
* View userUIDs in the [User Backup report](https://support.code42.com/Administrator/Cloud/Code42_console_reference/User_Backup_report_reference#User_Backup_report) and [Device Status report](https://support.code42.com/Administrator/Cloud/Code42_console_reference/Device_Status_report_reference#Device_Status_report).

You can also use the `/api/User` API command to [identify a userUID](https://support.code42.com/Administrator/Cloud/Code42_console_reference/Device_Status_report_reference#Device_Status_report). In the following example:
* Replace <YourUsername> with your username in Code42
* Replace <RequestURL> with the address you use to access the Code42 console, for example, `https://www.crashplan.com/`
* Replace <Code42Username> with the Code42 username of the user whose userUID value you want to view.

```bash
curl -X GET -u '<YourUsername>' '<RequestURL>/api/User?q=<Code42Username>&active=true'
```

When prompted, enter your Code42 password. A successful response lists information about that user, including the userUID.

```json
{"metadata":{"timestamp":"2020-06-12T19:45:41.962Z","params":{"q":"astrid.ludwig@example.com","active":"true"}},"data":{"totalCount":1,"users":[{"userId":199520,"userUid":"933431721358889954","status":"Active","username":"astrid.ludwig@example.com","email":"astrid.ludwig@example.com","firstName":"Astrid","lastName":"Ludwig","quotaInBytes":-1,"orgId":4203,"orgUid":"933427843360873352","orgName":"OktaOrg","userExtRef":null,"notes":null,"active":true,"blocked":false,"emailPromo":true,"invited":false,"orgType":"ENTERPRISE","usernameIsAnEmail":true,"creationDate":"2019-12-23T15:51:01.871Z","modificationDate":"2019-12-23T15:51:02.057Z","passwordReset":false,"localAuthenticationOnly":false,"licenses":["admin.securityTools"]}]}}
```

