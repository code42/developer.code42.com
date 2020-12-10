---
title: Track file activity of a high risk employee

category: use-cases

search: true

code_clipboard: true
---

# Track file activity of a high risk employee

## Overview

The Code42 APIs offer a way to automatically manage High Risk Employees from the time they are identified to when you no longer need to monitor their file activity. You can use the APIs to:

1. Add users to the High Risk Employees list.
2. Add risk factors to users.
3. Add users to alerts.
4. Search for alerts the users triggered.
5. Remove users from the High Risk Employees list when tracking is no longer desired.

This article describes in detail the Code42 APIs needed to follow users through the entire High Risk Employees lifecycle. 

For more information about these APIs, see the following articles:

* [Detection list management API](/sandbox/detection-list-management-api/#detection-list-management-api)
* [Security alerts API](/sandbox/security-alerts-api/#security-alerts-api)

## Considerations

* The tasks in this article require use of the Code42 API. For assistance with using the Code42 API, contact your Customer Success Manager (CSM) to engage the Code42 Professional Services team. Or, [post your question to the Code42 community](https://success.code42.com/home) to get advice from fellow Code42 administrators.
* The examples in this article use [curl](https://curl.se/). For other tools that you can use, see [Tools for interacting with the Code42 API](https://support.code42.com/Administrator/Cloud/Monitoring_and_managing/Code42_API_resources/Tools_for_interacting_with_the_Code42_API). 
* To perform tasks in this article, you must: 
    * Know the [request URL](/sandbox/intro-to-developer-portal/#request-urls) of your Code42 cloud instance.
    * Obtain an [authentication token](/sandbox/intro-to-developer-portal/#authentication) and a [tenant ID](/sandbox/intro-to-developer-portal/#get-a-tenant-id).
    * [Create a detection list profile](#create-a-detection-list-profile) for each user you want to manage in a detection list.
* This functionality is available only if your [product plan](https://support.code42.com/Terms_and_conditions/Code42_customer_support_resources/Code42_product_plans) includes [Risk Detection lenses](https://support.code42.com/Administrator/Cloud/Monitoring_and_managing/Secure_data_throughout_employee_tenure). Contact your Customer Success Manager (CSM) for assistance with licensing, or to upgrade to the Incydr Advanced product plan for a free trial​​​. If you don't know who your CSM is, email [csmsupport@code42.com](mailto:csmsupport@code42.com). 
* To add users to the High Risk Employees list, you must have [roles that provide the necessary permissions](https://support.code42.com/Administrator/Cloud/Monitoring_and_managing/Role_assignment_use_cases#Use_case_1:_Add_users_to_detection_lists).  
* You can also use the Code42 command-line interface (CLI) to work with the High Risk Employees list or the Departing Employees list. For more information, see the [Code42 CLI documentation](https://clidocs.code42.com/en/latest/userguides/detectionlists.html).

## Before you begin

### Plan your work

Before you start writing scripts using the Code42 APIs, consider the following questions to help you plan your work:

**Why do you want to automate adding users to the High Risk Employees list?**

Adding users to the High Risk Employees list automatically provides economies of scale. If you monitor insider risk at a small company, you could use the [High Risk Employees list in the Code42 console](https://support.code42.com/Administrator/Cloud/Monitoring_and_managing/Add_high_risk_employees) to track file activity. But for larger companies with many more employees to track, automating the process with the Code42 API provides a much faster and efficient method. As an added benefit, you can [integrate the Code42 APIs](https://support.code42.com/Administrator/Cloud/Monitoring_and_managing/Code42_integrations_resources) with other systems such as your company's security tools. Planning and implementing Code42 APIs can take some time. Before you begin using Code42 APIs to manage High Risk Employees, consider the effort involved to set them up against the time savings provided when they run.

**What are the kinds of alerts you want to receive?**

The primary reason to add users to the High Risk Employees list is to receive alerts when those users perform actions that are considered high risk. Before you start adding users, determine the kinds of actions that you want to receive alerts about and then [create alerts](https://support.code42.com/Administrator/Cloud/Monitoring_and_managing/How_to_create_a_security_alert) that will be triggered by those actions. Creating the right kinds of alerts provides the best monitoring possible of your High Risk Employees file activity. 

**What are "risk factors" and why might you assign them to people?**

"Risk factors" are predefined labels for the kinds of activities that are considered high risk. Before you start adding users to the High Risk Employees list, review Code42's [risk factors](https://support.code42.com/Administrator/Cloud/Code42_console_reference/High_Risk_Employees_reference#Risk+Factors) and determine which ones you want to assign to different kinds of employees. You might be able to devise some rules for which employees are assigned what risk factors. For example, you might assign the "Contract employee" risk factor to all temporary workers, or the "Performance concerns" factor to all employees who are on performance improvement plans. You can then set up alerts to be triggered when individuals with certain risk factors perform certain file activities. Good planning early on with risk factor assignments results in more precise alerting later.

**What other systems with data about risk factors should you consider?**

When determining risk factors to assign to employees, consider where else to look for supporting evidence, such as HR systems, security scanning tools, access management applications, Internet access monitoring tools, and so on. These can all provide additional information that you can place in the notes for the High Risk Employees, which will help guide any investigations that might be opened on these users.

### Gather your inputs

Before attempting to write scripts using the Code42 API examples in this article, gather the following inputs:

* **Authentication token** <br>
[Authentication tokens](/sandbox/intro-to-developer-portal/#authentication) are required to run the APIs. The tokens must be generated by a Code42 administrator with the proper [role assignments to add users to the High Risk Employees list](https://support.code42.com/Administrator/Cloud/Monitoring_and_managing/Role_assignment_use_cases#Use_case_1:_Add_users_to_detection_lists).

* **Tenant ID** <br>
Your company's entity in the Code42 cloud is known as a "tenant". To obtain your [tenant ID](/sandbox/intro-to-developer-portal/#get-a-tenant-id), use your Code42 administrator credentials to submit a request to the [customer API](/sandbox/api/#tag/Customer).

* **Code42 usernames for the people you want to add to the High Risk Employees list** <br>
The names of employees you want to add to the High Risk Employees list may come from a number of sources, such as an HR system or a directory service. While you can integrate with such systems using the Code42 API, remember that you need the Code42 username of these employees to be able to add them to the High Risk Employees list. The Code42 username is assigned when the [user is added to Code42](https://support.code42.com/Administrator/Cloud/Configuring/Add_users_from_the_Code42_console#Add_users_manually). You can obtain usernames via [CSV export](https://support.code42.com/Administrator/Cloud/Code42_console_reference/Users_reference#CSV_export) or the [user API](/sandbox/api/#operation/UserControllerV2_GetByUsername). 

## Steps

### Add the user to the High Risk Employees list

#### Create a detection list profile

Before you can add the user to the High Risk Employees list using the Code42 API, you must create a detection list profile for the user. This profile will contain all the user's information, including their risk factors and notes about why they are considered high risk.

To create a detection list profile, use the [/v1/detection-lists/user/create](/sandbox/api/#operation/UserControllerV2_Create)  API command as shown in the following example.

```bash
curl -X POST <RequestURL>/v1/detection-lists/user/create \
-H 'content-type: application/json' \
-H "authorization: Bearer <AuthToken>" \
-d '{
    "tenantId": "<SampleTenant>",
    "userName": "<Code42Username>",
    "notes": "<UserNotes>",
    "riskFactors": [
        "<Risk1>",
        "<Risk2>",
        "<Risk3>"
    ],
    "cloudUsernames": [
        "<UsernameInCloudService>"
    ]
}'
```

In the preceding example:

* Replace `<RequestURL>` with the [request URL](/sandbox/intro-to-developer-portal/#request-urls) of your Code42 cloud instance. 
* Replace `<AuthToken>` with the [authentication token](/sandbox/intro-to-developer-portal/#authentication).
* Replace `<SampleTenant>` with the [tenant ID](/sandbox/intro-to-developer-portal/#get-a-tenant-id).
* Replace `<Code42Username>` with the Code42 username. The username is assigned when the [user is added to Code42](https://support.code42.com/Administrator/Cloud/Configuring/Add_users_from_the_Code42_console#Add_users_manually).
* Replace `<UserNotes>` with an explanation of why the user is considered high risk.
* Replace `<Risk1>`, `<Risk2>`, etc. with the [risk factors](https://support.code42.com/Administrator/Cloud/Code42_console_reference/High_Risk_Employees_reference#Risk+Factors) associated with the user. You can also [add risk factors later with the API](#add-risk-factors-to-the-user).
* Replace `<UsernameInCloudService>` with the username of the user in a cloud service (such as Google Drive) if the username is different than the Code42 username. 

#### Add the user to the High Risk Employees list

To add the user to the High Risk Employees list, use the [/v1/detection-lists/highriskemployee/add](/sandbox/api/#operation/HighRiskEmployeeControllerV2_AddEmployee) API command.

```bash
curl -X POST <RequestURL>/v1/detection-lists/highriskemployee/add \
-H 'content-type: application/json' \
-H "authorization: Bearer <AuthToken>" \
-d '{ "tenantId": "<SampleTenant>", "userId": "<ID>" }'
```

In the preceding example: 

* Replace `<RequestURL>` with the [request URL](/sandbox/intro-to-developer-portal/#request-urls) of your Code42 cloud instance. 
* Replace `<AuthToken>` with the [authentication token](/sandbox/intro-to-developer-portal/#authentication).
* Replace `<SampleTenant>` with the [tenant ID](/sandbox/intro-to-developer-portal/#get-a-tenant-id).
* Replace `<ID>` with the user ID generated in the [Create a detection list profile](#create-a-detection-list-profile) section. 

**Note:** To add multiple users at once, you can use the Code42 command-line interface to [bulk add users to the High Risk Employees list](https://clidocs.code42.com/en/latest/commands/highriskemployee.html?highlight=%22bulk%20add%20users%20to%20the%20high%20risk%20employees%22#high-risk-employee-bulk-add).    

### Add risk factors

#### Add risk factors to the user

To add risk factors to the user, use the [/v1/detection-lists/user/addriskfactors](/sandbox/api/#operation/UserControllerV2_AddRiskFactors)  API resource. (To remove risk factors from the user, use the [/v1/detection-lists/user/removeriskfactors](/sandbox/api/#operation/UserControllerV2_RemoveRiskFactors) API resource.)

Use the [/v1/detection-lists/user/addriskfactors](/sandbox/api/#operation/UserControllerV2_AddRiskFactors) API command as shown in the following example.

```bash
curl -X POST <RequestURL>/v1/detection-lists/user/addriskfactors \
-H 'content-type: application/json' \
-H "authorization: Bearer <AuthToken>" \
-d '{
    "tenantId": "<SampleTenant>",
    "userId": "<UserUid>",
    "riskFactors": [
        "<Risk1>",
        "<Risk2>",
        "<Risk3>"
    ]
}'
```

In the preceding example:

* Replace `<RequestURL>` with the [request URL](/sandbox/intro-to-developer-portal/#request-urls) of your Code42 cloud instance. 
* Replace `<AuthToken>` with the [authentication token](/sandbox/intro-to-developer-portal/#authentication).
* Replace `<SampleTenant>` with the [tenant ID](/sandbox/intro-to-developer-portal/#get-a-tenant-id).
* Replace `<UserUid>` with [the user's userUID in Code42](/sandbox/intro-to-developer-portal/#get-useruid). 
* Replace `<UserNotes>` with an explanation of why the user is considered high risk. 
* Replace `<Risk1>`, `<Risk2>`, etc. with the [risk factors](https://support.code42.com/Administrator/Cloud/Code42_console_reference/High_Risk_Employees_reference#Risk+Factors) associated with the user. Valid values are:
    * CONTRACT_EMPLOYEE
    * ELEVATED_ACCESS_PRIVILEGES
    * FLIGHT_RISK
    * HIGH_IMPACT_EMPLOYEE
    * PERFORMANCE_CONCERNS
    * POOR_SECURITY_PRACTICES
    * SUSPICIOUS_SYSTEM_ACTIVITY

#### View risk factors in the user's details

To view details of the user in the High Risk Employees list, including their risk factors, use the [/v1/detection-lists/highriskemployee/get](/sandbox/api/#operation/HighRiskEmployeeControllerV2_GetEmployee) API command as shown in the following example.

```bash
curl -X POST <RequestURL>/v1/detection-lists/highriskemployee/get \
-H 'content-type: application/json' \
-H "authorization: Bearer <AuthToken>" \
-d '{ "tenantId": "<SampleTenant>", "userId": "<ID>" }'
```

In the preceding example: 

* Replace `<RequestURL>` with the [request URL](/sandbox/intro-to-developer-portal/#request-urls) of your Code42 cloud instance.
* Replace `<AuthToken>` with the [authentication token](/sandbox/intro-to-developer-portal/#authentication).
* Replace `<SampleTenant>` with the [tenant ID](/sandbox/intro-to-developer-portal/#get-a-tenant-id).
* Replace `<ID>` with the user ID generated in the [Create a detection list profile](#create-a-detection-list-profile) section. 

An excerpt of an example successful response:

```json
{
  "type$": "HIGH_RISK_EMPLOYEE_V2",
  "tenantId": "123456",
  "userId": "123456789424242",
  "userName": "john.doe@example.com",
  "displayName": "John Doe",
  "notes": "This is an example note.",
  "createdAt": "2020-03-31T19:35:49.4400500Z",
  "status": "OPEN",
  "cloudUsernames": [
    "john.doe@gmail.com",
    "john.doe@example.com"
  ],
  "riskFactors": [
    "FLIGHT_RISK",
    "HIGH_IMPACT_EMPLOYEE"
  ]
}
```

### Add the user to alerts

Do the following to add the user to alerts using the APIs. Before adding the user to alerts, make sure you have [enabled alerts for all users in the High Risk Employees list](https://support.code42.com/Administrator/Cloud/Monitoring_and_managing/Code42_API_resources/Detection_list_management_APIs#Enable_or_disable_alerts_for_all_users_in_a_detection_list).

#### Add the user to default High Risk Employees alert rules

When the user is added to the High Risk Employees list they are automatically added to the the [High Risk Employees default alert rules](https://support.code42.com/Administrator/Cloud/Monitoring_and_managing/How_to_create_a_security_alert#Default_alert_rules_and_notifications). Because all users in the High Risk Employees list are added to the default alert rules, there is no need to use the API to add the user to, or remove a user from, default alert rules.

#### Add the user to other alert rules

You can use the API to add the user to other existing [alert rules](https://support.code42.com/Administrator/Cloud/Code42_console_reference/Alerts_reference#Manage_Rules) that monitor user file activity. 

To use the API to add the user to an alert rule, use the following [/v1/alert-rules/add-users](/sandbox/api/#operation/Rules_AddUsersToRule) API command.

```bash
curl -X POST <RequestURL>/v1/alert-rules/add-users \
-H "accept: application/json" \
-H "Authorization: Bearer <AuthToken>" \
-H "Content-Type: application/json" \
-d '{
    "tenantId": "<SampleTenant>",
    "ruleId": "<SampleRuleId>",
    "userList": [
        {
            "userIdFromAuthority": "<SampleUserUID>",
            "userAliasList": [
                "<SampleAlias1>",
                "<SampleAlias2>"
            ]
        }
    ]
}}'
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

### Search for alert activity

#### Search for alerts triggered by the user

To find alerts triggered by the user, search for alerts with the Actor filter using the [/v1/alerts/query-alerts](/sandbox/api/#operation/Alerts_QueryAlert) API command as shown in the following example:

```bash
curl -X POST <RequestURL>/v1/alerts/query-alerts \
-H "accept: text/plain" \
-H "Authorization: Bearer <AuthToken>" \
-H "Content-Type: application/json" \
-d '{
    "tenantId": "<SampleTenant>",
    "groups": [
        {
            "filters": [
                {
                    "term": "Actor",
                    "operator": "Is",
                    "value": "<ActorUsername>"
                }
            ],
            "filterClause": "AND"
        }
    ],
    "groupClause": "OR",
    "pgSize": "20",
    "pgNum": "0",
    "srtKey": "CreatedAt",
    "srtDirection": "DESC"
}'
```

In the preceding example:

* Replace `<RequestURL>` with the [request URL](/sandbox/intro-to-developer-portal/#request-urls) of your Code42 cloud instance.
* Replace `<AuthToken>` with the [authentication token](/sandbox/intro-to-developer-portal/#authentication).
* Replace `<SampleTenant>` with the [tenant ID](/sandbox/intro-to-developer-portal/#get-a-tenant-id).
* Replace `<ActorUsername>` with the Code42 username of the user. 

A successful response returns basic information about the alert notifications that match your search criteria, including the alert IDs of those notifications (look for the `"id":"value"` entry):

```json
{
  "type$": "ALERT_SUMMARY",
  "tenantId": "123456",
  "type": "FED_ENDPOINT_EXFILTRATION",
  "name": "Exposure on an endpoint from High Risk Employees system rule",
  "description": "System rule for exposure on an endpoint from High Risk Employees.",
  "actor": "burt.morales@example.com",
  "target": "N/A",
  "severity": "HIGH",
  "ruleId": "123456789424242",
  "ruleSource": "High Risk Employee",
  "id": "987654321424242",
  "createdAt": "2020-04-03T15:21:44.6139300Z",
  "state": "OPEN"
}
```

#### Filter alerts

You can further filter alerts by adding more filter types. For example, you could use the `Severity` filter to find only those alerts that were high severity, or the `RuleName` filter to find only alerts from a particular rule.

#### Search the user's file activity

In addition to using alerts to identify file activity, you can use the [Forensic Search API](/sandbox/forensic-search-api/#forensic-search-api) to search for the user's file activity. 

### Remove the user from the High Risk Employees list

You can remove the user from the High Risk Employees list using the [/v1/detection-lists/highriskemployee/remove](/sandbox/api/#operation/HighRiskEmployeeControllerV2_RemoveUser) API.  Using this API removes the user from the High Risk Employees list and system alerts, but it does not remove risk factors associated with the user.

```bash
curl -X POST <RequestURL>/v1/detection-lists/highriskemployee/remove \
-H 'content-type: application/json' \
-H "authorization: Bearer <AuthToken>" \
-d '{ "tenantId": "<SampleTenant>", "userId": "<ID>" }'
```

In the preceding example: 

* Replace `<RequestURL>` with the [request URL](/sandbox/intro-to-developer-portal/#request-urls) of your Code42 cloud instance. 
* Replace `<AuthToken>` with the [authentication token](/sandbox/intro-to-developer-portal/#authentication).
* Replace `<SampleTenant>` with the [tenant ID](/sandbox/intro-to-developer-portal/#get-a-tenant-id).
* Replace `<ID>` with the user ID generated in the [Create a detection list profile](#create-a-detection-list-profile) section. 

To verify that the user is removed, obtain a listing of all users in the detection list by running the [/v1/detection-lists/highriskemployee/search](/sandbox/api/#operation/HighRiskEmployeeControllerV2_Search) API command.

**Note:** To remove multiple users at once, you can use the Code42 command-line interface to [bulk remove users from the High Risk Employees list](https://clidocs.code42.com/en/latest/commands/highriskemployee.html?highlight=bulk%20remove#high-risk-employee-bulk-remove). 
