---
title: Cases API

category: detect-and-respond

search: true

code_clipboard: true
---

# Cases API

## Overview

This article explains how to use the Code42 API to interact with Cases.

The examples in this article use [curl](http://curl.haxx.se/), but the concepts apply to any tool you choose for interacting with the Code42 API.

## Request parameters 

In the sample use cases, items formatted as `<value>` represent values you need to customize for your specific request. See below for steps to obtain these values. Do not include the brackets in the request.

**For all requests below:**

* Replace `<request URL>` with the [request URL of your Code42 environment](/api/#section/Getting-started/Request-URLs).
* Replace `<token>`  with the [authentication token](/api/#section/Getting-started/Authentication).

**For requests about a specific case:**

Replace `<case number>` with the number of the case you want to view or modify. There are two ways to obtain the case number:

* Use the [Return list of cases filtered by status](#return-list-of-cases-filtered-by-status) request below to return a list of cases. The case number is the `number` field in the response.

* From the Code42 console:
    1. Select **Cases**.
    2. Select a case.
    3. Select the **Case Details** tab.
    4. Note the **Case ID**.

**For requests about a specific file event:**

Replace `<eventId>` with a specific event id string. To obtain the event id, either:

* Use the [Forensic Search API](/forensic-search-api/#forensic-search-api) to search for file events and obtain the value of the `eventId` parameter.
* Use the [Return events associated with a case](#return-events-associated-with-a-case) request below to return events for a case and note the `eventId`. (Note: The same event can be included in multiple cases, but duplicate events are not allowed in the same case.)

**Other values:**

* Replace `<status>` with either:
    * `OPEN` to keep the case active and editable.
    * `CLOSED` to resolve the case. Closed cases cannot be re-opened or modified.
* Replace `<subject User UID>` with the [user UID](/api/#section/Getting-started/Get-userUIDs) of the person being investigated in the case.
* Replace `<assignee User UID>` with the [user UID](/api/#section/Getting-started/Get-userUIDs) of the security analyst or administrator assigned to investigate the case.

## Sample use cases 

### Create a case 

**Request**

Only the `name` field is required. To leave a field blank, supply the value `null`.

```bash
curl -X POST '<request URL>/v1/cases' \
-H 'content-type: application/json' \
-H 'authorization: Bearer <token>' \
-d '{
    "name": "Sample case name",
    "description": "Sample description",
    "findings": "Sample findings",
    "subject":  null,
    "assignee": null
}'
```

**Response**

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
    "createdByUserUid": "806150685834341101",
    "createdByUsername": "05c28ad3-7eca-4d99-8bb7-a5d0995806c8",
    "lastModifiedByUserUid": "806150685834341101",
    "lastModifiedByUsername": "05c28ad3-7eca-4d99-8bb7-a5d0995806c8"
}
```

### Update an existing case 

Before updating a case, perform a `GET` request for that case number to obtain all existing values. For example:

```bash
curl -X GET '<request URL>/v1/cases/<case number>' \
-H 'content-type: application/json' \
-H 'authorization: Bearer <token>'
```

Note: Missing parameters are set to null. Resubmit all values in the sample `PUT` command below, even if they're not changing. If you don't send an explicit value for each of these fields, they will be updated to `null`.

**Request**

```bash
curl -X PUT '<request URL>/v1/cases/<case number>' \
-H 'content-type: application/json' \
-H 'authorization: Bearer <token>' \
-d '{
    "name": "<updated case name>",
    "description": "<updated description>",
    "findings": "<updated findings>",
    "subject": <subject user UID>,
    "assignee": <assignee user UID>,
    "status": "<status>"
}'
```

**Response**

```json
{
    "number": 1,
    "name": "Updated name",
    "createdAt": "2020-10-27T15:16:05.369203Z",
    "updatedAt": "2020-10-27T15:20:26.311894Z",
    "description": "Updated description",
    "findings": "Updated findings",
    "subject": 421380797518239242
    "subjectUsername": casey@example.com,
    "status": "OPEN",
    "assignee": 273411254592236331,    
    "assigneeUsername": admin@example.com,
    "createdByUserUid": "806150685834341101",
    "createdByUsername": "05c28ad3-7eca-4d99-8bb7-a5d0995806c8",
    "lastModifiedByUserUid": "806150685834341101",
    "lastModifiedByUsername": "05c28ad3-7eca-4d99-8bb7-a5d0995806c8"
}
```

### Add events to a case 

**Request**

```bash
curl -X POST '<request URL>/v1/cases/<case_number>/fileevent/<eventId>' \
-H 'content-type: application/json' \
-H 'authorization: Bearer <token>'

```

**Response**

```json
None (204 on success)
```

### Return events associated with a case 

**Request**

```bash
curl -X GET '<request URL>/v1/cases/<case_number>/fileevent' \
-H 'content-type: application/json' \
-H 'authorization: Bearer <token>'
```

**Response**

```bash
{
    "events": [
        {
            "eventId": "734430974935_09970279-be77-4cd1-ba08-19d958969832",
            "eventTimestamp": "2020-10-26T18:56:04.661Z",
            "exposure": [
                "SharedToDomain",
                "OutsideTrustedDomains"
            ],
            "fileName": "Products.png",
            "filePath": null
        }
    ]
}
```

### Return list of cases filtered by status 

The sample below filters for open cases. To filter for closed cases, change the query parameter to `?status=CLOSED`. Other parameters that support filtering include: `assignee`, `createdAt`, `isAssigned`, `lastModifiedBy`, `name`, `subject`, and `updatedAt`.

**Request**

```bash
curl -X GET '<request URL>/v1/cases?status=OPEN' \
-H 'content-type: application/json' \
-H 'authorization: Bearer <token>'
```

**Response**

```json
{
    "cases": [
        {
            "number": 1,
            "name": "Example Case",
            "createdAt": "2020-10-27T15:16:05.369203Z",
            "updatedAt": "2020-10-27T15:20:26.311894Z",
            "subject": null,
            "subjectUsername": null,
            "status": "OPEN",
            "assignee": null,
            "assigneeUsername": null,
            "createdByUserUid": "806150685834341101",
            "createdByUsername": "05c28ad3-7eca-4d99-8bb7-a5d0995806c8",
            "lastModifiedByUserUid": "806150685834341101",
            "lastModifiedByUsername": "05c28ad3-7eca-4d99-8bb7-a5d0995806c8"
        }
    ],
    "totalCount": 1
}
```

### Export a case 

There are two options for exporting cases:

* Case summary: Exports a PDF with the case subject, details, and findings. Detailed file activity is not included.
* File activity: Exports a CSV file with extensive file metadata details for all events in this case. For field definitions, see the [Forensic Search event details](https://support.code42.com/Administrator/Cloud/Code42_console_reference/Forensic_Search_reference_guide#Event).

**File export considerations with curl**

* Use the `-o <sample_export.csv>` argument to specify a unique filename. Update the filename as appropriate for your request. Do not include the brackets in the request.
* Use the `-O` argument (capital "O") to automatically name the file. This is not recommended if you need to export more than one file, because this method uses the same filename for each export and therefore overwrites the previous file.
* Files are saved in the directory from which you issue the curl request in the command line. For example, in the command prompt `COMPUTER:~ clyde.bailey$ curl -X GET...` the file is saved in the Users/clyde.bailey directory on the device that issued the request. 

### Case summary PDF 

**Request**

```bash
curl -X GET '<request URL>/v1/cases/<case number>/export' \
-o <sample_export.pdf> \
-H 'authorization: Bearer <token>'
```

**Response**

```json
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  1618    0  1618    0     0   2528      0 --:--:-- --:--:-- --:--:--  2524
```

The PDF is saved to your device.

### File activity CSV 

**Request**

```bash
curl -X GET '<request URL>/v1/cases/<case number>/fileevent/export' \
-o <sample_export.csv> \
-H 'authorization: Bearer <token>'
```

**Response**

```json
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  3771    0  3771    0     0   6843      0 --:--:-- --:--:-- --:--:--  6843
```

The CSV is saved to your device.
