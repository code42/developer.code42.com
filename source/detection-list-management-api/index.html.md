---
title: Detection List Management API

category: detect-and-respond

search: true

code_clipboard: true
---

# Detection List Management API

## Overview

You can manually manage users in the [High Risk Employees list](https://support.code42.com/Administrator/Cloud/Code42_console_reference/High_Risk_Employees_reference) and [Departing Employees list](https://support.code42.com/Administrator/Cloud/Code42_console_reference/Departing_Employees_reference) from the Code42 console. To automate the process of managing users in these detection lists, you can write scripts that use the [High Risk Employee APIs](/api/#operation/HighRiskEmployeeControllerV2_AddEmployee) and [Departing Employee APIs](/api/#operation/DepartingEmployeeControllerV2_AddEmployee). This article provides an introduction to the APIs.

## Considerations

* The tasks in this article require use of the Code42 API. For assistance with using the Code42 API, contact your Customer Success Manager (CSM) to engage the Code42 Professional Services team. Or, [post your question to the Code42 community](https://success.code42.com/home) to get advice from fellow Code42 administrators.
* The examples in this article use [curl](https://curl.se/). For other tools that you can use, see [Tools for interacting with the Code42 API](https://support.code42.com/Administrator/Cloud/Monitoring_and_managing/Code42_API_resources/Tools_for_interacting_with_the_Code42_API).
* To perform tasks in this article, you must:
  * Have the [Customer Cloud Admin](https://support.code42.com/Administrator/Cloud/Monitoring_and_managing/Roles_reference#Customer_Cloud_Admin) role.
  * Know the [request URL](/api/#section/Getting-started/Request-URLs) of your Code42 cloud instance.
  * Obtain an [authentication token](/api/#section/Getting-started/Authentication) and a [tenant ID](/api/#section/Getting-started/Get-a-tenant-ID).
  * [Create a detection list profile](#create-a-detection-list-profile-for-a-user) for each user you want to manage in a detection list.
* You can also use the Code42 command-line interface (CLI) to work with the High Risk Employees list or the Departing Employees list. For more information, see the [Code42 CLI documentation](https://clidocs.code42.com/en/latest/userguides/detectionlists.html).

## Manage users

### Create a detection list profile for a user

Before you can manage a Code42 user with the detection management list APIs, you must create a detection list profile for the user with the [/v1/detection-lists/user/create](/api/#operation/UserControllerV2_Create) API. This profile is for an existing Code42 user and contains the details needed to manage that user on the High Risk Employees and Departing Employees lists. It includes information about the user specifically for use in detection lists, such as notes, risk attributes, and cloud user names. When you add the user to any detection list, the profile accompanies them.

When you create a detection list profile for a user, a user ID is generated. You must submit this user ID whenever you run any subsequent APIs to manage the user in a detection list.

Keep in mind that a detection list profile is created automatically when you add Code42 users to detection lists using the Code42 console. You only have to create a detection list profile for a user if one has not been created yet.

**Note:** Before attempting to create a detection list profile for a user, [check to see if a profile already exists](#get-the-detection-list-profile-for-a-user) by running the [/v1/detection-lists/user/getbyusername](/api/#operation/UserControllerV2_GetByUsername) API or [/v1/detection-lists/user/getbyid](/api/#operation/UserControllerV2_GetByUserId) API. If a profile already exists, attempting to create a profile for the user results in an error.

To create a detection list profile, use the [/v1/detection-lists/user/create](/api/#operation/UserControllerV2_Create) API command as shown in the following example.

```bash
curl -X POST <requestURL>/v1/detection-lists/user/create \
-H 'content-type: application/json' \
-H "authorization: Bearer <AuthToken>" \
-d '{"tenantId": "<SampleTenant>", "userName": "<Code42Username>", "notes": "This is an example user note.", "riskFactors": ["FLIGHT_RISK", "HIGH_IMPACT_EMPLOYEE"], "cloudUsernames": ["<UsernameInCloudService>"]}'
```

In the preceding example:

* Replace `<RequestURL>` with the [request URL](/api/#section/Getting-started/Request-URLs) of your Code42 cloud instance.
* Replace `<AuthToken>` with the [authentication token](/api/#section/Getting-started/Authentication).
* Replace `<SampleTenant>` with the [tenant ID](/api/#section/Getting-started/Get-a-tenant-ID).
* Replace `<Code42Username>` with the Code42 username. The username is assigned when the [user is added to Code42](https://support.code42.com/Administrator/Cloud/Configuring/Add_users_from_the_Code42_console#Add_users_manually).
* Replace `<UsernameInCloudService>` with the username of the user in a cloud service (such as Google Drive) if the username is different than the Code42 username.

An excerpt of an example successful response:

````json
{
  "type$": "USER_V2",
  "tenantId": "1233456",
  "userId": "123456789424242",
  "userName": "john.doe@example.com",
  "displayName": "John Doe",
  "notes": "This is an example user note.",
  "cloudUsernames": [
    "john.doe@gmail.com",
    "john.doe@example.com"
  ],
  "riskFactors": [
    "FLIGHT_RISK",
    "HIGH_IMPACT_EMPLOYEE"
  ]
}
````

### Get the detection list profile for a user

If you need to get a user's detection list profile to find information about the user, use the [/v1/detection-lists/user/getbyusername](/api/#operation/UserControllerV2_GetByUsername) API or [/v1/detection-lists/user/getbyid](/api/#operation/UserControllerV2_GetByUserId) API.

For example, if you don't know a user's ID as assigned in the profile, you can find it by running the [/v1/detection-lists/user/getbyusername](/api/#operation/UserControllerV2_GetByUsername) API command as shown in the following example.

```bash
curl -X POST <requestURL>/v1/detection-lists/user/getbyusername \
-H 'content-type: application/json' \
-H "authorization: Bearer <AuthToken>" \
-d '{ "tenantId": "<SampleTenant>", "username": "<Code42Username>"}'
```

In the preceding example:

* Replace `<RequestURL>` with the [request URL](/api/#section/Getting-started/Request-URLs) of your Code42 cloud instance.
* Replace `<AuthToken>` with the [authentication token](/api/#section/Getting-started/Authentication).
* Replace `<SampleTenant>` with the [tenant ID](/api/#section/Getting-started/Get-a-tenant-ID).
* Replace `<Code42Username>` with the Code42 username of the user. The username is assigned when the [user is added to Code42](https://support.code42.com/Administrator/Cloud/Configuring/Add_users_from_the_Code42_console#Add_users_manually).

A successful response returns the user ID and other information:

```json
{"type$":"USER_V2","tenantId":"123456","userId":"123456789424242","userName":"john.doe@example.com","displayName":"John Doe","notes":"This is an example user note.","cloudUsernames":["john.doe@gmail.com","john.doe@example.com"],"riskFactors":["FLIGHT_RISK","HIGH_IMPACT_EMPLOYEE"]}
```

## Some available actions

Following are some of the actions you can perform using the [High Risk Employee APIs](/api/#tag/High-Risk-Employee) and [Departing Employee APIs](/api/#tag/Departing-Employee).

### Add a user to a detection list

You can add a user to the High Risk Employees list using the [/v1/detection-lists/highriskemployee/add](/api/#operation/HighRiskEmployeeControllerV2_AddEmployee) API or add a user to the Departing Employees list using the [/v1/detection-lists/departingemployee/add](/api/#operation/DepartingEmployeeControllerV2_AddEmployee) API.

**Note:**  To add multiple users at once, see the [Code42 command-line interface](https://clidocs.code42.com/en/latest/userguides/detectionlists.html?highlight=departing%20employee#add-users-to-the-departing-employees-list).

#### Add a high risk employee

The following example demonstrates how to add a user to the High Risk Employees list using the [/v1/detection-lists/highriskemployee/add](/api/#operation/HighRiskEmployeeControllerV2_AddEmployee) API.

```bash
curl -X POST <RequestURL>/v1/detection-lists/highriskemployee/add \
-H 'content-type: application/json' \
-H "authorization: Bearer <AuthToken>" \
-d '{ "tenantId": "<SampleTenant>", "userId": "<ID>" }'
```

In the preceding example:

* Replace `<RequestURL>` with the [request URL](/api/#section/Getting-started/Request-URLs) of your Code42 cloud instance.
* Replace `<AuthToken>` with the [authentication token](/api/#section/Getting-started/Authentication).
* Replace `<SampleTenant>` with the [tenant ID](/api/#section/Getting-started/Get-a-tenant-ID).
* Replace `<ID>` with the user ID generated in the [Create a detection list profile for a user](#create-a-detection-list-profile-for-a-user) section. If you don't know a user's ID, you can [look it up using the Code42 username](#get-the-detection-list-profile-for-a-user).

An excerpt of an example successful response:

```json
{
  "type$": "HIGH_RISK_EMPLOYEE_V2",
  "tenantId": "123456",
  "userId": "123456789424242",
  "userName": "john.doe@example.com",
  "displayName": "John Doe",
  "notes": "This is an example user note.",
  "createdAt": "2020-03-31T19:35:49.4400509Z",
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

#### Add a departing employee

The following example demonstrates how to add a user to the Departing Employees list using the [/v1/detection-lists/departingemployee/add](/api/#operation/DepartingEmployeeControllerV2_AddEmployee) API.

```bash
curl -X POST <RequestURL>/v1/detection-lists/departingemployee/add \
-H 'content-type: application/json' \
-H "authorization: Bearer <AuthToken>" \
-d '{ "tenantId": "<SampleTenant>", "userId": "<ID>", "departureDate": "<Date>" }'
```

In the preceding example:

* Replace `<RequestURL>` with the [request URL](/api/#section/Getting-started/Request-URLs) of your Code42 cloud instance.
* Replace `<AuthToken>` with the [authentication token](/api/#section/Getting-started/Authentication).
* Replace `<SampleTenant>` with the [tenant ID](/api/#section/Getting-started/Get-a-tenant-ID).
* Replace `<ID>` with the user ID generated in the [Create a detection list profile for a user](#create-a-detection-list-profile-for-a-user) section. If you don't know a user's ID, you can [look it up using the Code42 username](#get-the-detection-list-profile-for-a-user).
* Replace `<Date>` with the user's departure date in year-month-day format, for example "2020-04-07".

An excerpt of an example successful response:

```json
{
  "type$": "DEPARTING_EMPLOYEE_V2",
  "tenantId": "123456",
  "userId": "123456789424242",
  "userName": "john.doe@example.com",
  "displayName": "John Doe",
  "notes": "This is an example of a user note.",
  "createdAt": "2020-03-31T19:22:18.5651922Z",
  "status": "OPEN",
  "cloudUsernames": [
    "john.doe@gmail.com",
    "john.doe@example.com"
  ],
  "departureDate": "2020-04-07"
}
```

### Obtain a listing of all users in a detection list

You can obtain a list of all users in the  High Risk Employees list using the [/v1/detection-lists/highriskemployee/search](/api/#operation/HighRiskEmployeeControllerV2_Search) API , or obtain a list of all users in the Departing Employees list using the [/v1/detection-lists/departingemployee/search](/api/#operation/DepartingEmployeeControllerV2_Search) API.

#### Obtain a list of high risk employees

Obtain a list of high risk employees in Code42 by running the [/v1/detection-lists/highriskemployee/search](/api/#operation/HighRiskEmployeeControllerV2_Search) API.

```bash
curl -X POST <RequestURL>/v1/detection-lists/highriskemployee/search  \
-H 'content-type: application/json' \
-H "authorization: Bearer <AuthToken>" \
-d '{ "tenantId": "<SampleTenant>", "filterType": "OPEN", "pgSize": "20", "pgNum": "1", "srtKey": "DISPLAY_NAME", "srtDirection": "ASC" }'
```

In the preceding example:

* Replace `<RequestURL>` with the [request URL](/api/#section/Getting-started/Request-URLs) of your Code42 cloud instance.
* Replace `<AuthToken>` with the [authentication token](/api/#section/Getting-started/Authentication).
* Replace `<SampleTenant>` with the [tenant ID](/api/#section/Getting-started/Get-a-tenant-ID).

An excerpt of an example successful response:

```json
{
  "type$": "HIGH_RISK_SEARCH_RESPONSE_V2",
  "items": [
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
    },
    {
      "type$": "HIGH_RISK_EMPLOYEE_V2",
      "tenantId": "123456",
      "userId": "987654321424242",
      "userName": "jane.smith@example.com",
      "displayName": "Jane Smith",
      "notes": "This is an example note.",
      "createdAt": "2020-03-31T19:45:30.3092900Z",
      "status": "OPEN",
      "cloudUsernames": [
        "jane.smith@gmail.com",
        "jane.smith@example.com"
      ],
      "managerUid": "Jack.Shep",
      "managerUsername": "Jack.Shep@example.com",
      "managerDisplayName": "Jack Shep",
      "title": "People Person",
      "division": "Acme",
      "department": "Human Resources",
      "employmentType": "Full Time",
      "city": "The Island",
      "state": "MN",
      "country": "US",
      "riskFactors": [
        "FLIGHT_RISK",
        "HIGH_IMPACT_EMPLOYEE"
      ]
    }
  ],
  "totalCount": 2,
  "rollups": [
    {
      "type$": "HIGH_RISK_FILTER_ROLLUP_V2",
      "filterType": "OPEN",
      "totalCount": 2
    },
    {
      "type$": "HIGH_RISK_FILTER_ROLLUP_V2",
      "filterType": "EXFILTRATION_24_HOURS",
      "totalCount": 0
    },
    {
      "type$": "HIGH_RISK_FILTER_ROLLUP_V2",
      "filterType": "EXFILTRATION_30_DAYS",
      "totalCount": 0
    }
  ],
  "filterType": "OPEN",
  "pgSize": 20,
  "pgNum": 1,
  "srtKey": "DISPLAY_NAME",
  "srtDirection": "ASC"
}
```

#### Obtain a list of departing employees

Obtain a list of departing employees in Code42 by running the [/v1/detection-lists/departingemployee/search](/api/#operation/DepartingEmployeeControllerV2_Search) API.

```bash
curl -X POST <RequestURL>/v1/detection-lists/departingemployee/search  \
-H 'content-type: application/json' \
-H "authorization: Bearer <AuthToken>" \
-d '{ "tenantId": "<SampleTenant>", "filterType": "OPEN", "pgSize": "20", "pgNum": "1", "srtKey": "DISPLAY_NAME", "srtDirection": "ASC" }'
```

In the preceding example:

* Replace `<RequestURL>` with the [request URL](/api/#section/Getting-started/Request-URLs) of your Code42 cloud instance.
* Replace `<AuthToken>` with the [authentication token](/api/#section/Getting-started/Authentication).
* Replace `<SampleTenant>` with the [tenant ID](/api/#section/Getting-started/Get-a-tenant-ID).

An excerpt of an example successful response:

```json
{
  "type$": "DEPARTING_EMPLOYEE_SEARCH_RESPONSE_V2",
  "items": [
    {
      "type$": "DEPARTING_EMPLOYEE_V2",
      "tenantId": "123456",
      "userId": "123456789424242",
      "userName": "john.doe@example.com",
      "displayName": "John Doe",
      "notes": "This is an example user note.",
      "createdAt": "2020-03-31T19:22:18.5651920Z",
      "status": "OPEN",
      "cloudUsernames": [
        "john.doe@gmail.com",
        "john.doe@example.com"
      ],
      "departureDate": "2020-04-07"
    }
  ],
  "totalCount": 1,
  "rollups": [
    {
      "type$": "DEPARTING_EMPLOYEE_FILTER_ROLLUP_V2",
      "filterType": "OPEN",
      "totalCount": 1
    },
    {
      "type$": "DEPARTING_EMPLOYEE_FILTER_ROLLUP_V2",
      "filterType": "LEAVING_TODAY",
      "totalCount": 0
    },
    {
      "type$": "DEPARTING_EMPLOYEE_FILTER_ROLLUP_V2",
      "filterType": "EXFILTRATION_24_HOURS",
      "totalCount": 0
    },
    {
      "type$": "DEPARTING_EMPLOYEE_FILTER_ROLLUP_V2",
      "filterType": "EXFILTRATION_30_DAYS",
      "totalCount": 0
    }
  ],
  "filterType": "OPEN",
  "pgSize": 20,
  "pgNum": 1,
  "srtKey": "DISPLAY_NAME",
  "srtDirection": "ASC"
}
```

### View details of a user in a detection list

You can view details of a user in the High Risk Employees list using the [/v1/detection-lists/highriskemployee/get](/api/#operation/HighRiskEmployeeControllerV2_GetEmployee) API, or view details of a user in the Departing Employees list using the [/v1/detection-lists/departingemployee/get](/api/#operation/DepartingEmployeeControllerV2_GetEmployee) API.

The commands to view the details of high risk or departing employee are similar. The following example shows how to view the details of a high risk employee using the [/v1/detection-lists/highriskemployee/get](/api/#operation/HighRiskEmployeeControllerV2_GetEmployee) API.

```bash
curl -X POST <RequestURL>/v1/detection-lists/highriskemployee/get \
-H 'content-type: application/json' \
-H "authorization: Bearer <AuthToken>" \
-d '{ "tenantId": "<SampleTenant>", "userId": "<ID>" }'
```

In the preceding example:

* Replace `<RequestURL>` with the [request URL](/api/#section/Getting-started/Request-URLs) of your Code42 cloud instance.
* Replace `<AuthToken>` with the [authentication token](/api/#section/Getting-started/Authentication).
* Replace `<SampleTenant>` with the [tenant ID](/api/#section/Getting-started/Get-a-tenant-ID).
* Replace `<ID>` with the user ID generated in the [Create a detection list profile for a user](#create-a-detection-list-profile-for-a-user) section. If you don't know a user's ID, you [can look it up using the Code42 username](#get-the-detection-list-profile-for-a-user).

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

### Enable or disable alerts for all users in a detection list

You can enable or disable alerts for all users in a detection list using the [/v1/detection-lists/highriskemployee/setalertstate](/api/#operation/HighRiskEmployeeControllerV2_SetAlertState) API or the [/v1/detection-lists/departingemployee/setalertstate](/api/#operation/DepartingEmployeeControllerV2_SetAlertState) API.

The commands to enable or disable alerts for all high risk or departing employees are similar. The following example shows how to enable alerts for all high risk employees using the [/v1/detection-lists/highriskemployee/setalertstate](/api/#operation/HighRiskEmployeeControllerV2_SetAlertState) API.

```bash
curl -X POST <RequestURL>/v1/detection-lists/highriskemployee/setalertstate \
-H 'content-type: application/json' \
-H "authorization: Bearer <AuthToken>" \
-d '{ "tenantId": "<SampleTenant>", "alertsEnabled": true }'
```

In the preceding example:

* Replace `<RequestURL>` with the [request URL](/api/#section/Getting-started/Request-URLs) of your Code42 cloud instance.
* Replace `<AuthToken>` with the [authentication token](/api/#section/Getting-started/Authentication).
* Replace `<SampleTenant>` with the [tenant ID](/api/#section/Getting-started/Get-a-tenant-ID).

To disable alerts, run the command with the alertsEnabled value set to false.

To verify that the alerts setting is changed as desired, select **Alert Settings** in the [High Risk Employees list](https://support.code42.com/Administrator/Cloud/Code42_console_reference/High_Risk_Employees_reference) or [Departing Employees list](https://support.code42.com/Administrator/Cloud/Code42_console_reference/Departing_Employees_reference) in the Code42 console.

### Remove a user from a detection list

You can remove a user from the High Risk Employees list using the [/v1/detection-lists/highriskemployee/remove](/api/#operation/HighRiskEmployeeControllerV2_RemoveUser) API, or remove a user froom the Departing Employees list using the [/v1/detection-lists/departingemployee/remove](/api/#operation/DepartingEmployeeControllerV2_RemoveUser) API.

**Note:** To remove multiple users at once, see [the Code42 command-line interface](https://clidocs.code42.com/en/latest/commands/departingemployee.html?highlight=remove#departing-employee-bulk-remove).

The commands to remove a user from the High Risk Employees or Departing Employees lists are similar. The following example shows how to remove a user from the High Risk Employees list using the [/v1/detection-lists/highriskemployee/remove](/api/#operation/HighRiskEmployeeControllerV2_RemoveUser) API.

```bash
curl -X POST <RequestURL>/v1/detection-lists/highriskemployee/remove \
-H 'content-type: application/json' \
-H "authorization: Bearer <AuthToken>" \
-d '{ "tenantId": "<SampleTenant>", "userId": "<ID>" }'
```

In the preceding example:

* Replace `<RequestURL>` with the [request URL](/api/#section/Getting-started/Request-URLs) of your Code42 cloud instance.
* Replace `<AuthToken>` with the [authentication token](/api/#section/Getting-started/Authentication).
* Replace `<SampleTenant>` with the [tenant ID](/api/#section/Getting-started/Get-a-tenant-ID).
* Replace `<ID>` with the user ID generated in the [Create a detection list profile for a user](#create-a-detection-list-profile-for-a-user) section. If you don't know a user's ID, you can [look it up using the Code42 username](#get-the-detection-list-profile-for-a-user).

To verify that the user is removed, generate a listing of all users in the detection list as shown in [Obtain a listing of all users in a detection list](#obtain-a-listing-of-all-users-in-a-detection-list).
