---
title: Track file activity of a high risk employee

category: Use cases

toc_footers:
  - <a href='https://github.com/slatedocs/slate'>Documentation Powered by Slate</a>

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

* [Detection list management APIs](https://support.code42.com/Administrator/Cloud/Monitoring_and_managing/Code42_API_resources/Detection_list_management_APIs)
* [Manage security alerts with the Code42 API](https://support.code42.com/Administrator/Cloud/Monitoring_and_managing/Code42_API_resources/Manage_security_alerts_with_the_Code42_API)

## Considerations

* The tasks in this article require use of the [Code42 API](https://support.code42.com/Administrator/Cloud/Monitoring_and_managing/Code42_API_resources/Introduction_to_the_Code42_API).
    * If you are not familiar with using Code42 APIs, review [Code42 API syntax and usage](https://support.code42.com/Administrator/Cloud/Monitoring_and_managing/Code42_API_resources/Code42_API_syntax_and_usage).
    
    * For assistance with using the Code42 API, contact your Customer Success Manager (CSM) to engage the Code42 Professional Services team. Or, [post your question to the Code42 community](https://success.code42.com/) to get advice from fellow Code42 administrators.

* The examples in this article use the command line tool curl to interact with the Code42 API. For a list of tools that can be used to interact with the API, see [Tools for interacting with the Code42 API](https://support.code42.com/Administrator/Cloud/Monitoring_and_managing/Code42_API_resources/Tools_for_interacting_with_the_Code42_API).

* This functionality is available only if your [product plan](https://support.code42.com/Terms_and_conditions/Code42_customer_support_resources/Code42_product_plans) includes [Risk Detection lenses](https://support.code42.com/Administrator/Cloud/Monitoring_and_managing/Secure_data_throughout_employee_tenure). Contact your Customer Success Manager (CSM) for assistance with licensing, or to upgrade to the Incydr Advanced product plan for a free trial​​​. If you don't know who your CSM is, email [csmsupport@code42.com](mailto:csmsupport@code42.com). 

* To add users to the High Risk Employees list, you must have [roles that provide the necessary permissions](https://support.code42.com/Administrator/Cloud/Monitoring_and_managing/Role_assignment_use_cases#Use_case_1:_Add_users_to_detection_lists).  

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
[Authentication tokens](https://support.code42.com/Administrator/Cloud/Monitoring_and_managing/Code42_API_resources/Detection_list_management_APIs#Authentication) are required to run the APIs. The tokens must be generated by a Code42 administrator with the proper [role assignments to add users to the High Risk Employees list](https://support.code42.com/Administrator/Cloud/Monitoring_and_managing/Role_assignment_use_cases#Use_case_1:_Add_users_to_detection_lists).

* **Tenant ID** <br>
Your company's entity in the Code42 cloud is known as a "tenant". To [obtain your tenant ID](https://support.code42.com/Administrator/Cloud/Monitoring_and_managing/Code42_API_resources/Detection_list_management_APIs#Get_a_tenant_ID), use your Code42 administrator credentials to submit a request to the customer API.

* **Code42 usernames for the people you want to add to the High Risk Employees list** <br>
The names of employees you want to add to the High Risk Employees list may come from a number of sources, such as an HR system or a directory service. While you can integrate with such systems using the Code42 API, remember that you need the Code42 username of these employees to be able to add them to the High Risk Employees list. The Code42 username is assigned when the [user is added to Code42](https://support.code42.com/Administrator/Cloud/Configuring/Add_users_from_the_Code42_console#Add_users_manually). You can obtain usernames via [CSV export](https://support.code42.com/Administrator/Cloud/Code42_console_reference/Users_reference#CSV_export) or the [user API](https://console.us.code42.com/swagger/#/Private/getUsers). 

## Steps

### Add the user to the High Risk Employees list

#### Create a detection list profile

Before you can add the user to the High Risk Employees list using the Code42 API, you must [create a detection list profile for the user](https://support.code42.com/Administrator/Cloud/Monitoring_and_managing/Code42_API_resources/Detection_list_management_APIs#Create_a_detection_list_profile_for_a_user). This profile will contain all the user's information, including their risk factors and notes about why they are considered high risk.

To create a detection list profile, use the `api/v2/user/create`  API command as shown in the following example.

```bash
curl -X POST <requestURL>/create \
-H 'content-type: application/json' \
-H "authorization: v3_user_token <AuthToken>" \
-d '{"tenantId": "<SampleTenant>", "userName": "<Code42Username>", "notes": "<UserNotes>", "riskFactors": ["<Risk1>", "<Risk2>", "<Risk3>"], "cloudUsernames": ["<UsernameInCloudService>"]}'
```

In the preceding example:

* Replace <RequestURL> with the [request URL](https://support.code42.com/Administrator/Cloud/Monitoring_and_managing/Code42_API_resources/Detection_list_management_APIs#Summary) of your Code42 cloud instance, for example, 
`https://ecm-default.prod.ffs.us2.code42.com/svc/api/v2/user/`

* Replace `<AuthToken>` with the [authentication](https://support.code42.com/Administrator/Cloud/Monitoring_and_managing/Code42_API_resources/Detection_list_management_APIs#Authentication) token.

* Replace `<SampleTenant>` with the [tenant ID](https://support.code42.com/Administrator/Cloud/Monitoring_and_managing/Code42_API_resources/Detection_list_management_APIs#Get_a_tenant_ID).

* Replace `<Code42Username>` with the Code42 username. The username is assigned when the [user is added to Code42](https://support.code42.com/Administrator/Cloud/Configuring/Add_users_from_the_Code42_console#Add_users_manually).

* Replace `<UserNotes>` with an explanation of why the user is considered high risk.

* Replace `<Risk1>`, `<Risk2>`, etc. with the [risk factors](https://support.code42.com/Administrator/Cloud/Code42_console_reference/High_Risk_Employees_reference#Risk+Factors) associated with the user. You can also [add risk factors later with the API](https://support.code42.com/Administrator/Cloud/Monitoring_and_managing/Code42_API_resources/Track_file_activity_of_a_high_risk_employee_with_the_Code42_API#Step_2:_Add_risk_factors).

* Replace `<UsernameInCloudService>` with the username of the user in a cloud service (such as Google Drive) if the username is different than the Code42 username. 


#### Add the user to the High Risk Employees list

To [add the user to the High Risk Employees list](https://support.code42.com/Administrator/Cloud/Monitoring_and_managing/Code42_API_resources/Detection_list_management_APIs#Add_a_high_risk_employee), use the `api/v2/highriskemployee/add`  API command.

```bash
curl -X POST <RequestURL>/add \
-H 'content-type: application/json' \
-H "authorization: v3_user_token <AuthToken>" \
-d '{ "tenantId": "<SampleTenant>", "userId": "<ID>" }'
```

Use the `api/v2/highriskemployee/add` API command as shown in the following example.

<aside class="notice">
To add multiple users at once, you can use the <a href="https://clidocs.code42.com/en/latest/">Code42 command-line interface</a> to <a href="https://clidocs.code42.com/en/latest/commands/highriskemployee.html?highlight=%22bulk%20add%20users%20to%20the%20high%20risk%20employees%22#high-risk-employee-bulk-add">bulk add users to the High Risk Employees list</a>.
For an introduction to the CLI, see <a href="https://support.code42.com/Administrator/Cloud/Monitoring_and_managing/Introduction_to_the_Code42_command-line_interface">Introduction to the Code42 command-line interface</a>.    
</aside>

In the preceding example: 

* Replace `<RequestURL>` with the [request URL](https://support.code42.com/Administrator/Cloud/Monitoring_and_managing/Code42_API_resources/Detection_list_management_APIs#Summary) of your Code42 cloud instance, for example, 
`https://ecm-default.prod.ffs.us2.code42.com/svc/api/v2/highriskemployee`

* Replace `<AuthToken>` with the [authentication](https://support.code42.com/Administrator/Cloud/Monitoring_and_managing/Code42_API_resources/Detection_list_management_APIs#Authentication) token.

* Replace `<SampleTenant>` with the [tenant ID](https://support.code42.com/Administrator/Cloud/Monitoring_and_managing/Code42_API_resources/Detection_list_management_APIs#Get_a_tenant_ID).

* Replace `<ID>` with the user ID generated in the [Create a detection list profile](https://support.code42.com/Administrator/Cloud/Monitoring_and_managing/Code42_API_resources/Track_file_activity_of_a_high_risk_employee_with_the_Code42_API#Create_a_detection_list_profile) section. If you don't know a user's ID, you can [look it up using the Code42 username](https://support.code42.com/Administrator/Cloud/Monitoring_and_managing/Code42_API_resources/Detection_list_management_APIs#Get_the_detection_list_profile_for_a_user).

### Add risk factors

#### Add risk factors to the user

 To add risk factors to the user, use the `/api/v2/user/addriskfactors`  API command from the [detection list management API](https://support.code42.com/Administrator/Cloud/Monitoring_and_managing/Code42_API_resources/Detection_list_management_APIs#Summary). (To remove risk factors from the user, use the `/api/v2/user/removeriskfactors` [API resource](https://support.code42.com/Administrator/Cloud/Monitoring_and_managing/Code42_API_resources/Detection_list_management_APIs#Summary).)

Use the `/api/v2/user/addriskfactors`  API command as shown in the following example.

```bash
curl -X POST <requestURL>/addriskfactors \
-H 'content-type: application/json' \
-H "authorization: v3_user_token <AuthToken>" \
-d '{"tenantId": "<SampleTenant>", "userName": "<Code42Username>", "riskFactors": ["<Risk1>", "<Risk2>", "<Risk3>"] }'
```

In the preceding example:

* Replace `<RequestURL>` with the [request URL](https://support.code42.com/Administrator/Cloud/Monitoring_and_managing/Code42_API_resources/Detection_list_management_APIs#Summary) of your Code42 cloud instance, for example, 
`https://ecm-default.prod.ffs.us2.code42.com/svc/api/v2/user/` 

* Replace `<AuthToken>` with the [authentication](https://support.code42.com/Administrator/Cloud/Monitoring_and_managing/Code42_API_resources/Detection_list_management_APIs#Authentication) token.

* Replace `<SampleTenant>` with the [tenant ID](https://support.code42.com/Administrator/Cloud/Monitoring_and_managing/Code42_API_resources/Detection_list_management_APIs#Get_a_tenant_ID). 

* Replace `<Code42Username>` with the Code42 username. The username is assigned when the [user is added to Code42](https://support.code42.com/Administrator/Cloud/Configuring/Add_users_from_the_Code42_console#Add_users_manually).

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

To [view details of the user](https://support.code42.com/Administrator/Cloud/Monitoring_and_managing/Code42_API_resources/Detection_list_management_APIs#View_details_of_a_user_in_a_detection_list) in the High Risk Employees list, including their risk factors, use the `api/v2/highriskemployee/get`  API command as shown in the following example.

```bash
curl -X POST <RequestURL>/get \
-H 'content-type: application/json' \
-H "authorization: v3_user_token <AuthToken>" \
-d '{ "tenantId": "<SampleTenant>", "userId": "<ID>" }'
```

In the preceding example: 

* Replace `<RequestURL>` with the [request URL](https://support.code42.com/Administrator/Cloud/Monitoring_and_managing/Code42_API_resources/Detection_list_management_APIs#Summary) of your Code42 cloud instance, for example, 
`https://ecm-default.prod.ffs.us2.code42.com/svc/api/v2/highriskemployee` 

* Replace `<AuthToken>` with the [authentication](https://support.code42.com/Administrator/Cloud/Monitoring_and_managing/Code42_API_resources/Detection_list_management_APIs#Authentication) token.

* Replace `<SampleTenant>` with the [tenant ID](https://support.code42.com/Administrator/Cloud/Monitoring_and_managing/Code42_API_resources/Detection_list_management_APIs#Get_a_tenant_ID).

* Replace `<ID>` with the user ID generated in the [Create a detection list profile](https://support.code42.com/Administrator/Cloud/Monitoring_and_managing/Code42_API_resources/Track_file_activity_of_a_high_risk_employee_with_the_Code42_API#Create_a_detection_list_profile) section. If you don't know a user's ID, you can [look it up using the Code42 username](https://support.code42.com/Administrator/Cloud/Monitoring_and_managing/Code42_API_resources/Detection_list_management_APIs#Get_the_detection_list_profile_for_a_user).

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

Do the following to add the user to alerts using the APIs. Before adding the user to alerts, make sure you have enabled alerts for all users in the High Risk Employees list.

#### Add the user to default High Risk Employees alert rules

When the user is added to the High Risk Employees list they are automatically added to the the High Risk Employees default alert rules. Because all users in the High Risk Employees list are added to the default alert rules, there is no need to use the API to add the user to, or remove a user from, default alert rules.

#### Add the user to other alert rules

You can use the API to add the user to other existing [alert rules](https://support.code42.com/Administrator/Cloud/Code42_console_reference/Alerts_reference#Manage_Rules) that monitor user file activity. 

To [add the user to an alert rule](https://support.code42.com/Administrator/Cloud/Monitoring_and_managing/Code42_API_resources/Manage_security_alerts_with_the_Code42_API#Add_users_to_an_alert_rule), use the following `/api/v1/Rules/add-users` API command.

```bash
curl -X POST \
"<RequestURL>/Rules/add-users" \
-H "accept: application/json" \
-H "Authorization: v3_user_token <AuthToken>" \
-H "Content-Type: application/json" \
-d '{ "tenantId": "<SampleTenant>", "ruleId": "<SampleRuleId>", "userList": [ { "userIdFromAuthority": "<SampleUserUID>", "userAliasList": [ "<SampleAlias1>", "<SampleAlias2>" ] } ]}'
```

In the preceding example:

* Replace `<RequestURL>` with the [request URL](https://support.code42.com/Administrator/Cloud/Monitoring_and_managing/Code42_API_resources/Manage_security_alerts_with_the_Code42_API#Summary) of your Code42 cloud instance, for example,
`https://fed-observer-default.prod.ffs.us2.code42.com/svc/api/v1/`

* Replace `<AuthToken>` with the [authentication](https://support.code42.com/Administrator/Cloud/Monitoring_and_managing/Code42_API_resources/Detection_list_management_APIs#Authentication) token.

* Replace `<SampleTenant>` with the [tenant ID](https://support.code42.com/Administrator/Cloud/Monitoring_and_managing/Code42_API_resources/Detection_list_management_APIs#Get_a_tenant_ID).

* Replace `<SampleRuleID>` with the ID of the alert rule from which you want to remove users.

* Replace `<SampleUserID>` with a value that uniquely identifies the user you want to add. As a best practice, use the user's [userUID](https://support.code42.com/Administrator/Cloud/Monitoring_and_managing/Code42_API_resources/Manage_security_alerts_with_the_Code42_API#Identify_userUIDs) in Code42 for this value.
The userAliasList parameter identifies the list of email addresses or cloud aliases to associate with that `<SampleUserID>`.

* Replace `<SampleAlias1>` and `<SampleAlias2>` with the email addresses or cloud aliases you want to add to the rule's inclusion or exclusion list for that user ID.

    * If you want to enter only one email address or cloud alias, use this construction: `"userAliasList": [ "<SampleAlias1>" ]`

    * If you want to enter multiple email addresses or cloud aliases for that user ID, enclose each ID in quotation marks and separate them with commas.

The aliases that you enter here become the values that are added to the rule's inclusion or exclusion list and used to trigger or filter alert notifications.

### Search for alert activity

To find alerts triggered by the user, [search for alerts](https://support.code42.com/Administrator/Cloud/Monitoring_and_managing/Code42_API_resources/Manage_security_alerts_with_the_Code42_API#Search_for_alert_notifications_by_alert_filter_criteria) with the [Actor filter](https://support.code42.com/Administrator/Cloud/Monitoring_and_managing/Code42_API_resources/Manage_security_alerts_with_the_Code42_API#Filter_syntax_for_the_query-alerts_API_command) using the `api/v1/query-alerts` API command as shown in the following example:

```bash
curl -X POST \
"<RequestURL>/query-alerts" \
-H "accept: text/plain" \
-H "Authorization: v3_user_token <AuthToken>" \
-H "Content-Type: application/json" \
-d '{ "tenantId": "<SampleTenant>", "groups": [ { "filters": [ { "term": "Actor, "operator": "Is", "value": "<ActorUsername>" } ], "filterClause": "AND" } ], "groupClause": "OR", "pgSize": "20", "pgNum": "0", "srtKey": "CreatedAt", "srtDirection": "DESC" }'
```

#### Search for alerts triggered by the user

In the preceding example:

* Replace `<RequestURL>` with the [request URL](https://support.code42.com/Administrator/Cloud/Monitoring_and_managing/Code42_API_resources/Manage_security_alerts_with_the_Code42_API#Summary) of your Code42 cloud instance, for example,
`https://alert-service-default.prod.ffs.us2.code42.com/svc/api/v1/`

* Replace `<AuthToken>` with the [authentication](https://support.code42.com/Administrator/Cloud/Monitoring_and_managing/Code42_API_resources/Detection_list_management_APIs#Authentication) token.

* Replace `<SampleTenant>` with the [tenant ID](https://support.code42.com/Administrator/Cloud/Monitoring_and_managing/Code42_API_resources/Detection_list_management_APIs#Get_a_tenant_ID).

* Replace `<ActorUsername>` with the Code42 username of the user. See the [filter syntax for the query-alerts API command](https://support.code42.com/Administrator/Cloud/Monitoring_and_managing/Code42_API_resources/Manage_security_alerts_with_the_Code42_API#Filter_syntax_for_the_query-alerts_API_command) for details.

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

You can further filter alerts by adding more [filter types](https://support.code42.com/Administrator/Cloud/Monitoring_and_managing/Code42_API_resources/Manage_security_alerts_with_the_Code42_API#Filter_syntax_for_the_query-alerts_API_command). For example, you could use the Severity filter to find only those alerts that were high severity, or the RuleName filter to find only alerts from a particular rule.

#### Search the user's file activity

In addition to using alerts to identify file activity, you can use the [Forensic Search API](https://support.code42.com/Administrator/Cloud/Monitoring_and_managing/Code42_API_resources/Forensic_Search_API) to search for the user's file activity. 

### Remove the user from the High Risk Employees list

You can [remove the user from the High Risk Employees list](https://support.code42.com/Administrator/Cloud/Monitoring_and_managing/Code42_API_resources/Detection_list_management_APIs#Remove_a_user_from_a_detection_list) using the `api/v2/highriskemployee/remove`  API.  Using this API removes the user from the High Risk Employees list and system alerts, but it does not remove risk factors associated with the user.

<aside class="notice">
To remove multiple users at once, you can use the <a href="https://clidocs.code42.com/en/latest/">Code42 command-line interface</a> to <a href="https://clidocs.code42.com/en/latest/commands/highriskemployee.html?highlight=bulk%20remove#high-risk-employee-bulk-remove">bulk remove users from the High Risk Employees list</a>.
For an introduction to the CLI, see <a href="https://support.code42.com/Administrator/Cloud/Monitoring_and_managing/Introduction_to_the_Code42_command-line_interface">Introduction to the Code42 command-line interface</a>.     
</aside>

To remove a user from the High Risk Employees list, use the `api/v2/highriskemployee/remove`  API command as shown in the following example.

```bash
curl -X POST <RequestURL>/remove \
-H 'content-type: application/json' \
-H "authorization: v3_user_token <AuthToken>" \
-d '{ "tenantId": "<SampleTenant>", "userId": "<ID>" }'
```

In the preceding example: 

* Replace `<RequestURL>` with the [request URL](https://support.code42.com/Administrator/Cloud/Monitoring_and_managing/Code42_API_resources/Detection_list_management_APIs#Summary) of your Code42 cloud instance, for example, 
`https://ecm-default.prod.ffs.us2.code42.com/svc/api/v2/highriskemployee `

* Replace `<AuthToken>` with the [authentication](https://support.code42.com/Administrator/Cloud/Monitoring_and_managing/Code42_API_resources/Detection_list_management_APIs#Authentication) token.

* Replace `<SampleTenant>` with the [tenant ID](https://support.code42.com/Administrator/Cloud/Monitoring_and_managing/Code42_API_resources/Detection_list_management_APIs#Get_a_tenant_ID). 

* Replace `<ID>` with the user ID generated in the [Create a detection list profile](https://support.code42.com/Administrator/Cloud/Monitoring_and_managing/Code42_API_resources/Track_file_activity_of_a_high_risk_employee_with_the_Code42_API#Create_a_detection_list_profile) section. If you don't know a user's ID, you can [look it up using the Code42 username](https://support.code42.com/Administrator/Cloud/Monitoring_and_managing/Code42_API_resources/Detection_list_management_APIs#Get_the_detection_list_profile_for_a_user).

To verify that the user is removed, [obtain a listing of all users in the detection list](https://support.code42.com/Administrator/Cloud/Monitoring_and_managing/Code42_API_resources/Detection_list_management_APIs#Obtain_a_listing_of_all_users_in_a_detection_list).
