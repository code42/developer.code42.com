---
title: Respond to an alert

category: use-cases

search: true

code_clipboard: true
---

# Respond to an alert

## Overview

You can use the Code42 APIs to respond to a high-value alert and add it to a case for further investigation. This article provides a use case showing how to use the APIs to:

1. Search alerts to find one of interest.
2. View the alert's details.
3. Open a case.
4. Add file events from the alert to the case.

For more information about the APIs described in this article, see:

* [Security alerts API](/security-alerts-api/#security-alerts-api)
* [Forensic Search API](/forensic-search-api/#forensic-search-api)

## Considerations

* The tasks in this article require use of the Code42 API. For assistance with using the Code42 API, contact your Customer Success Manager (CSM) to engage the Code42 Professional Services team. Or, [post your question to the Code42 community](https://success.code42.com/home) to get advice from fellow Code42 administrators.
* The examples in this article use [curl](https://curl.se/).
* To perform tasks in this article, you must:
    * Know the [request URL](/intro-to-developer-portal/#request-urls) of your Code42 cloud instance.
    * Obtain an [authentication token](/intro-to-developer-portal/#authentication) and a [tenant ID](/intro-to-developer-portal/#get-a-tenant-id).
* This functionality is available only if your [product plan](https://support.code42.com/Terms_and_conditions/Code42_customer_support_resources/Code42_product_plans) includes alerts. Contact your Customer Success Manager (CSM) for assistance with licensing, or to upgrade to the Incydr Advanced product plan for a free trial​​​. If you don't know who your CSM is, email [csmsupport@code42.com](mailto:csmsupport@code42.com).
* To investigate file activity exposed by alerts, you must have [roles that provide the necessary permissions](https://support.code42.com/Administrator/Cloud/Monitoring_and_managing/Role_assignment_use_cases#Use_case_2:_Investigate_suspicious_file_activity).
* You can also use the Code42 command-line interface (CLI) to work with alerts. For more information, see the [Code42 CLI documentation](https://clidocs.code42.com/en/latest/commands/alerts.html).

## Before you begin

### Set up monitoring and alerts

Before you can receive alerts about employees' file activity, do the following:

* Enable endpoint monitoring.
See [Enable endpoint monitoring for file exfiltration detection](https://support.code42.com/Administrator/Cloud/Configuring/Endpoint_monitoring).
* Create rules to alert you when suspicious file activity occurs.
To create alert rules with the Code42 console, see [Create and manage alerts](https://support.code42.com/Administrator/Cloud/Monitoring_and_managing/How_to_create_a_security_alert). You can also [manage rules with the rules API](/security-alerts-api/#manage-alert-rule-user-lists).
* (Optional) Set up additional monitoring to capture file activity.
See the following articles:
    * [Detect and respond to insider threats](https://support.code42.com/Administrator/Cloud/Monitoring_and_managing/Detect_and_respond_to_insider_threats#Part_1:_Capture_file_activity)
    * [Data Preferences reference](https://support.code42.com/Administrator/Cloud/Code42_console_reference/Data_Preferences_reference)
    * [Introduction to adding data connections](https://support.code42.com/Administrator/Cloud/Configuring/Introduction_to_adding_data_connections)

### Plan your work

Before you start writing scripts to handle alerts using the Code42 APIs, consider the following questions to help you plan your work:

**Why do you want to automate responding to alerts?**

Using APIs to automatically respond to alerts provides economies of scale. If you monitor insider risk at a small company, you could [use the the Code42 console](https://support.code42.com/Administrator/Cloud/Code42_console_reference/Alerts_reference) to receive notifications about suspicious file activity. But for larger companies with many more employees to track, automating the process with the Code42 APIs provides a faster and more efficient method. As an added benefit, you can [integrate the Code42 APIs](https://support.code42.com/Administrator/Cloud/Monitoring_and_managing/Code42_integrations_resources) with other systems such as your company's security tools. Planning and implementing Code42 APIs can take some time. Before you begin using Code42 APIs to manage alerts, consider the effort involved to set them up against the time savings provided when they run.

**What are the kinds of alerts you want to receive?**

You want to receive alerts when users perform actions that are considered high risk. Determine the kinds of actions that you want to receive alerts about and then [create alerts](https://support.code42.com/Administrator/Cloud/Monitoring_and_managing/How_to_create_a_security_alert) that will be triggered by those actions. Creating the right kinds of alerts provides the best monitoring possible of high risk file activity.

### Gather your inputs

Before attempting to write scripts using the Code42 API examples in this article, gather the following inputs:

- **Authentication token**

[Authentication tokens](/intro-to-developer-portal/#authentication) are required to run the APIs. The tokens must be generated by a Code42 administrator with the proper [role assignments](https://support.code42.com/Administrator/Cloud/Monitoring_and_managing/Role_assignment_use_cases).

- **Tenant ID**

Your company's entity in the Code42 cloud is known as a "tenant". To obtain your [tenant ID](/intro-to-developer-portal/#get-a-tenant-id), submit a request to the [customer API](/api/#tag/Customer).

- **Code42 usernames for the people you want to add to alert rules**

The names of employees you want to add to alert rules may come from a number of sources, such as an HR system or a directory service. While you can integrate with such systems using the Code42 API, remember that you need the Code42 username of these employees to be able to add them to alerts. The Code42 username is assigned when the user is [added to Code42](https://support.code42.com/Administrator/Cloud/Configuring/Add_users_from_the_Code42_console#Add_users_manually). You can obtain usernames via [CSV export](https://support.code42.com/Administrator/Cloud/Code42_console_reference/Users_reference#CSV_export), [user reports](https://support.code42.com/Administrator/Cloud/Code42_console_reference/User_Backup_report_reference#User_Backup_report), or the [user API](/intro-to-developer-portal/#get-useruids).

## Steps

### Search for significant alerts

Alerts are an excellent way to get notifications about suspicious file activity. However, sometimes it can be difficult to separate the truly important ones from the rest.
To find alerts that are worthy of further investigation, use the [/v1/alerts/query-alerts](/api/#operation/Alerts_QueryAlert) API command to search for alert notifications by alert filter criteria. By using filters you can uncover only the alerts that you want to follow up on.

```bash
curl -X POST "<RequestURL>/v1/alerts/query-alerts" \
-H "accept: text/plain" \
-H "Authorization: Bearer <AuthToken>" \
-H "Content-Type: application/json" \
-d '{ "tenantId": "<SampleTenant>", "groups": [ { "filters": [ { "term": "<FilterType>", "operator": "<OperatorValue>", "value": "<Criteria>" } ], "filterClause": "AND" } ], "groupClause": "OR", "pgSize": "20", "pgNum": "0", "srtKey": "CreatedAt", "srtDirection": "DESC" }'
```

In the preceding example:

* Replace `<RequestURL>` with the [request URL](/intro-to-developer-portal/#request-urls) of your Code42 cloud instance.
* Replace `<AuthToken>` with the [authentication token](/intro-to-developer-portal/#authentication).
* Replace `<SampleTenant>` with the [tenant ID](/intro-to-developer-portal/#get-a-tenant-id).
* For the [filter syntax](/security-alerts-api/#filter-syntax-for-the-query-alerts-api-command), replace `<FilterType>` with the filter, `<OperatorValue>` with the operator option, and `<Criteria>` with the search term to use in the search.

A successful response returns basic information about the alert notifications that match your search criteria, including the alert IDs of notifications returned by the query (look for the "id" entry):

```json
{
    "type$": "ALERT_SUMMARY",
    "tenantId": "123456",
    "type": "FED_ENDPOINT_EXFILTRATION",
    "name": "Departing employee endpoint exfiltration system rule",
    "description": "System rule for departing employee endpoint exfiltration.",
    "actor": "burt.morales@example.com",
    "target": "N/A",
    "severity": "HIGH",
    "ruleId": "123456789424242",
    "ruleSource": "Departing Employee",
    "id": "987654321424242",
    "createdAt": "2020-04-03T15:21:44.6139300Z",
    "state": "OPEN",
    "totalCount": 1,
    "problems": []
}
```

**Note:** You can further filter alerts by adding more [filter types](/security-alerts-api/#filter-syntax-for-the-query-alerts-api-command) to your query. For example, you could use the Severity filter to find only those alerts that were high severity, or the RuleName filter to find only alerts from a particular rule.

### View alert details

After you've located the ID for an alert you want to investigate further, use the [/v1/alerts/query-details](/api/#operation/Alerts_QueryAlertDetails) API command to view details about the alert, including the files involved in the file events that triggered the alert.

```bash
curl -X POST "<RequestURL>/v1/alerts/query-details" \
-H "accept: text/plain" \
-H "Authorization: Bearer <AuthToken>" \
-H "Content-Type: application/json" \
-d '{ "alertIds": [ "<SampleAlertID>" ]}'
```

In the preceding example:

* Replace `<RequestURL>` with the [request URL](/intro-to-developer-portal/#request-urls) of your Code42 cloud instance.
* Replace `<AuthToken>` with the [authentication token](/intro-to-developer-portal/#authentication).
* Replace `<SampleAlertID>` with the ID of an alert notification listed in the response in the "[Search for significant alerts](#search-for-significant-alerts)" section above.

A successful response returns full details about the alert notification, including event IDs (look for "eventid") and a list of files involved in the event (look for "files" followed by "name").

```json
{
    "type$": "ALERT_DETAILS_RESPONSE",
    "alerts": [
        {
            "type$": "ALERT_DETAILS",
            "tenantId": "123456",
            "type": "FED_ENDPOINT_EXFILTRATION",
            "name": "Departing employee endpoint exfiltration system rule",
            "description": "System rule for departing employee endpoint exfiltration.",
            "actor": "burt.morales@example.com",
            "target": "N/A",
            "severity": "HIGH",
            "ruleId": "123456789424242",
            "ruleSource": "Departing Employee",
            "id": "987654321424242",
            "createdAt": "2020-04-08T13:50:25.3644410Z",
            "state": "OPEN",
            "observations": [
                {
                    "type$": "OBSERVATION",
                    "id": "112233445566",
                    "observedAt": "2020-04-08T13:40:00.0000000Z",
                    "type": "FedEndpointExfiltration",
                    "data": "{\"type$\":\"OBSERVED_ENDPOINT_ACTIVITY\",\"id\":\"665544332211\",\"sources\":[\"Endpoint\"],\"exposureTypes\":[\"ApplicationRead\",\"CloudStorage\"],\"firstActivityAt\":\"2020-04-08T13:40:00.0000000Z\",\"lastActivityAt\":\"2020-04-08T13:45:00.0000000Z\",\"fileCount\":2,\"totalFileSize\":311096,\"fileCategories\":[{\"type$\":\"OBSERVED_FILE_CATEGORY\",\"category\":\"Image\",\"fileCount\":2,\"totalFileSize\":311096,\"isSignificant\":false}],\"files\":[{\"type$\":\"OBSERVED_FILE\",\"eventId\":\"998877665544\",\"path\":\"C:/Users/burt.morales/\",\"name\":\"1586353274_family_photo.png\",\"category\":\"Image\"},],\"syncToServices\":[\"Dropbox\"],\"sendingIpAddresses\":[\"192.0.2.0\"]}"
                }
            ]
        }
    ]
}
```

### Look for the files involved in the alert

Use the [Forensic Search APIs](/forensic-search-api) to look for the files identified in the preceding alert query response.
The following Forensic Search API [sample request](/forensic-search-api/#sample-request) using the [/v1/file-events](/api/#operation/searchEventsUsingPOST) API command demonstrates a search for all files on all devices with the file extension **.docx** that exist anywhere in the file path **C:/Users**. Use this simple example as a starting point for your own searches and replace the content of the -d section with your specific search criteria.

```bash
curl -X POST  <RequestURL>/v1/file-events \
-H 'content-type: application/json' \
-H "authorization: Bearer <AuthToken>" \
-d '{
    "groups": [{
        "filters": [{
            "operator": "IS",
            "term": "fileName",
            "value": "*.docx"
        },
        {
            "operator": "IS",
            "term": "filePath",
            "value": "C:/Users*"
        }
    ],
    "filterClause": "AND"
    }],
    "groupClause": "AND",
    "pgNum": 1,
    "pgSize": 100
}'
```

### Open a case

To track your investigation of the event that triggered the alert, use the [/v1/cases](/api/#operation/createCaseUsingPOST) API command to create a case.
Only the `"name"` parameter is required. To leave a field blank, supply the value `null`.

```bash
curl -X POST <RequestURL>/v1/cases \
-H 'content-type: application/json' \
-H 'authorization: Bearer <AuthToken>' \
-d '{
    "name": "Sample case name",
    "description": "Sample description",
    "findings": "Sample findings",
    "subject":  <UserUID>,
    "assignee": null
}'
```

In the preceding example:

* Replace `<RequestURL>` with the [request URL](/intro-to-developer-portal/#request-urls) of your Code42 cloud instance.
* Replace `<AuthToken>` with the [authentication token](/intro-to-developer-portal/#authentication).
* Replace `<UserUID>` with the [user UID](/intro-to-developer-portal/#useruids) of the person who is being investigated.

Following is an example response showing the case number.

```json
{
    "number": 1,
    "name": "Sample case name",
    "createdAt": "2020-10-27T15:16:05.369203Z",
    "updatedAt": "2020-10-27T15:16:05.369203Z",
    "description": "Sample description",
    "findings": "Sample findings",
    "subject": null,
    "subjectUsername": null,
    "status": "OPEN",
    "assignee": null,
    "assigneeUsername": null,
    "createdByUserUid": "806154242834341101",
    "createdByUsername": "user@example.com",
    "lastModifiedByUserUid": "806154242834341101",
    "lastModifiedByUsername": "user@example.com"
}
```

### Add file events to the case

To populate the new case with information about the alert, add file events from the alert to the case using the [/v1/cases/\<CaseNumber\>/fileevent/\<EventID\>](/api/#operation/addEventToCaseUsingPOST) API command. Repeat this action for all the file events from the alert.

```bash
curl -X POST '<RequestURL>/v1/cases/<CaseNumber>/fileevent/<EventID>' \
-H 'content-type: application/json' \
-H 'authorization: Bearer <AuthToken>'
```

In the preceding example:

* Replace `<RequestURL>` with the [request URL](/intro-to-developer-portal/#request-urls) of your Code42 cloud instance.
* Replace `<CaseNumber>` with the case number shown in the response in the "[View filter alerts](#view-filter-alerts)" section above.
* Replace `<EventID>` with an event ID shown in the response in the "[View alert details](#view-alert-details)" section above.
* Replace `<AuthToken>` with the [authentication token](/intro-to-developer-portal/#authentication).
