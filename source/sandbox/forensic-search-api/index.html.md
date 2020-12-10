---
title: Forensic Search API

category: detect-and-respond

search: true

code_clipboard: true
---

# Forensic Search API

## Overview

This article explains how to use the Code42 API with Forensic Search. While the Code42 console contains a flexible and powerful web interface for [Forensic Search](https://support.code42.com/Administrator/Cloud/Code42_console_reference/Forensic_Search_reference_guide) to perform searches and view results, the [File Events](/sandbox/api/#tag/File-Events) API provides additional capabilities for performing more complicated or customized searches.

Following are the [File Events](/sandbox/api/#tag/File-Events) API resources:

* [/v1/file-events](/sandbox/api/#operation/searchEventsUsingPOST): Search file activity and receive results in JSON format
* [/v1/file-events/export](/sandbox/api/#operation/exportUsingPOST): Search file activity receive results in CSV format
* [/v1/file-events/grouping](/sandbox/api/#operation/groupingUsingPOST): Group file activity results by a particular value and receive a count of unique events in each group

## Considerations

* The tasks in this article require use of the [Code42 API](https://support.code42.com/Administrator/Cloud/Monitoring_and_managing/Code42_API_resources/Introduction_to_the_Code42_API).
    * If you are not familiar with using Code42 APIs, review [Code42 API syntax and usage](https://support.code42.com/Administrator/Cloud/Monitoring_and_managing/Code42_API_resources/Code42_API_syntax_and_usage).
    
    * For assistance with using the Code42 API, contact your Customer Success Manager (CSM) to engage the Code42 Professional Services team. Or, [post your question to the Code42 community](https://success.code42.com/) to get advice from fellow Code42 administrators.

* The examples in this article use the command line tool curl to interact with the Code42 API. For a list of tools that can be used to interact with the API, see [Tools for interacting with the Code42 API](https://support.code42.com/Administrator/Cloud/Monitoring_and_managing/Code42_API_resources/Tools_for_interacting_with_the_Code42_API).

* To perform tasks in this article, you must: 
    * Have the [Customer Cloud Admin](https://support.code42.com/Administrator/Cloud/Monitoring_and_managing/Roles_reference#Customer_Cloud_Admin) or [Security Center User](https://support.code42.com/Administrator/Cloud/Monitoring_and_managing/Roles_reference#Security_Center_User) role.
    * Know the [request URL](/sandbox/intro-to-developer-portal/#request-urls) of your Code42 cloud instance.
    * Obtain an [authentication token](/sandbox/intro-to-developer-portal/#authentication) and a [tenant ID](/sandbox/intro-to-developer-portal/#get-a-tenant-id).

## Forensic Search API structure and syntax

### Groups and filters 

Forensic Search API queries are organized by groups of filters. This structure facilitates complicated requests with multiple `AND` or `OR` conditions. For example, use case 1 in the [Sample use cases](#sample-use-cases) section searches for files matching any one of 11 different file extensions that also exist in any one of nine different locations. Search queries are limited to a total of 1,024 criteria per request.

For example, the JSON below uses two groups of filters:

* The first group uses a `filterClause` value of `OR`, which returns results if any of the four MD5 values are found (`db349b97c37d22f5ea1d1841e3c89eb4` or `84c82835a5d21bbcf75a61706d8ab549` or `f351e1fcca0c4ea05fc44d15a17f8b36` or `7bf2b57f2a205768755c07f238fb32cc`).

* The second group uses a `filterClause` value of `AND`, which returns results only if all criteria in the filter are met (in this example, `on or after 2018-02-01` **and** `on or before 2018-02-07`).

* Finally, to link these two groups together, the `groupClause` value of `AND` returns results only if both the first group and second group criteria are met. 


```json
{
  "groups": [
    {
      "filters": [
        {
          "operator": "IS",
          "term": "md5Checksum",
          "value": "db349b97c37d22f5ea1d1841e3c89eb4"
        },
        {
          "operator": "IS",
          "term": "md5Checksum",
          "value": "84c82835a5d21bbcf75a61706d8ab549"
        },
        {
          "operator": "IS",
          "term": "md5Checksum",
          "value": "f351e1fcca0c4ea05fc44d15a17f8b36"
        },
        {
          "operator": "IS",
          "term": "md5Checksum",
          "value": "7bf2b57f2a205768755c07f238fb32cc"
        }
      ],
      "filterClause": "OR"
    },
    {
      "filters": [
        {
          "operator": "ON_OR_AFTER",
          "term": "eventTimestamp",
          "value": "2018-02-01T00:00:00.00Z"
        },
        {
          "operator": "ON_OR_BEFORE",
          "term": "eventTimestamp",
          "value": "2018-02-07T23:59:59.59Z"
        }
      ],
      "filterClause": "AND"
    }
  ],
  "groupClause": "AND",
  "pgNum": 1,
  "pgSize": 100,
  "srtDir": "asc",
  "srtKey": "eventTimestamp"
}
```

### Sample request 

This simple example demonstrates a search for all files on all devices with the file extension `.docx` that exist anywhere except the file path `C:/Users`. For more complicated examples with multiple groups and additional filters, see the [sample use cases](#sample-use-cases) in the next section. 

Use the following as a starting point for your own searches:

* Replace `<RequestURL>` with the [request URL](/sandbox/intro-to-developer-portal/#request-urls) of your Code42 cloud instance.
* Replace `<AuthToken>` with the [authentication token](/sandbox/intro-to-developer-portal/#authentication).
* Replace the content of the `-d` section with your specific search criteria.

```bash
curl -X POST <RequestURL>/v1/file-events \
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
            "operator": "IS_NOT",
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

**Note:** To receive results in CSV format instead of JSON, use the [/v1/file-events/export](/sandbox/api/#operation/exportUsingPOST) resource instead of [/v1/file-events](/sandbox/api/#operation/searchEventsUsingPOST). 

### API limits

* Request rate: To ensure optimal performance throughout your Code42 environment, Code42 limits API requests to 120 per minute. Requests that exceed this limit are blocked and do not return results.
* Result set:
   * `file-events` results are limited to 10,000 events per request. Requesting a page number that exceeds these limits returns an error (for example, a `file-events` query with `pgSize=10000` cannot display `pgNum=2`). To obtain more than 10,000 results, use the `pgToken` and `nextPgToken` request fields to submit multiple requests. (For `pgToken` implementation details, see the [/v1/file-events API documentation](/sandbox/api/#operation/searchEventsUsingPOST).)
   * `file-events/export` queries are limited to 200,000 events. 
   * `file-events/grouping` queries are limited to 1,000 groups

## Sample Use Cases 

### Use case 1: Search for application files in unexpected locations

The sample JSON below shows how to search for files with any of these extensions (.action, .app, .bat, .bin, .cmd, .com, .command, .cpl, .exe, .msc, .osx) that exist outside these locations:

* `C:\Program Files`
* `/Applications`
* `/Library`
* `/User/*/Applications`
* `/User/*/Library`
* `/usr/bin`
* `/usr/local/bin`
* `/sbin`
* `/bin`

#### Sample JSON search query for application files in specific locations 

Modify this sample to fit your environment and then include it in a request (as shown in the [Sample request](#sample-request) section above).

```json
{
  "groups": [
    {
      "filters": [
        {
          "operator": "IS",
          "term": "fileName",
          "value": "*.action"
        },
        {
          "operator": "IS",
          "term": "fileName",
          "value": "*.app"
        },
        {
          "operator": "IS",
          "term": "fileName",
          "value": "*.bat"
        },
        {
          "operator": "IS",
          "term": "fileName",
          "value": "*.bin"
        },
        {
          "operator": "IS",
          "term": "fileName",
          "value": "*.cmd"
        },
        {
          "operator": "IS",
          "term": "fileName",
          "value": "*.com"
        },
        {
          "operator": "IS",
          "term": "fileName",
          "value": "*.command"
        },
        {
          "operator": "IS",
          "term": "fileName",
          "value": "*.cpl"
        },
        {
          "operator": "IS",
          "term": "fileName",
          "value": "*.exe"
        },
        {
          "operator": "IS",
          "term": "fileName",
          "value": "*.msc"
        },
        {
          "operator": "IS",
          "term": "fileName",
          "value": "*.osx"
        }
      ],
      "filterClause": "OR"
    },
    {
      "filters": [
        {
          "operator": "IS_NOT",
          "term": "filePath",
          "value": "C:\\Program Files*"
        },
        {
          "operator": "IS_NOT",
          "term": "filePath",
          "value": "/Applications*"
        },
        {
          "operator": "IS_NOT",
          "term": "filePath",
          "value": "/Library*"
        },
        {
          "operator": "IS_NOT",
          "term": "filePath",
          "value": "/User/*/Applications*"
        },
        {
          "operator": "IS_NOT",
          "term": "filePath",
          "value": "/User/*/Library*"
        },
        {
          "operator": "IS_NOT",
          "term": "filePath",
          "value": "/usr/bin*"
        },
        {
          "operator": "IS_NOT",
          "term": "filePath",
          "value": "/usr/local/bin*"
        },
        {
          "operator": "IS_NOT",
          "term": "filePath",
          "value": "/sbin*"
        },
        {
          "operator": "IS_NOT",
          "term": "filePath",
          "value": "/bin*"
        }
      ],
      "filterClause": "AND"
    }
  ],
  "groupClause": "AND",
  "pgNum": 1,
  "pgSize": 100,
  "srtDir": "asc",
  "srtKey": "eventTimestamp"
}
```

#### Sample results of application files in specific locations 

```json
{
    "totalCount": 3,
    "fileEvents": [
        {
            "eventId": "0_1dcc9b7c-123d-40d7-b0fb-436520b2cab8_843278037859030533_843318595055164516_6",
            "eventType": "CREATED",
            "eventTimestamp": "2018-04-10T23:57:33.682Z",
            "filePath": "C:/$GetCurrent/SafeOS/",
            "fileName": "SetupComplete.cmd",
            "fileType": "FILE",
            "fileSize": 307,
            "fileOwner": "Administrators",
            "md5Checksum": "0582b19fa3b500db28f976ed33efa487",
            "createTimestamp": "2018-03-19T18:10:42.041Z",
            "modifyTimestamp": "2018-03-19T18:10:42.120Z",
            "deviceUserName": "clyde@example.com",
            "osHostName": "CO-SAMPLE-1",
            "domainName": 192.0.2.0,
            "publicIpAddress": "192.0.2.0",
            "privateIpAddresses": [
                "2001:db8:49a3:7d3:1309:8a2e:370:7342",
                "192.0.4.0",
                "0:0:0:0:0:0:0:1",
                "127.0.0.1"
            ],
            "deviceUid": "423278037859030542",
            "userUid": "424242424242424242"
        },
        {
            "eventId": "0_1dcc9b7c-123d-40d7-b0fb-436520b2cab8_843278037859030533_843318595055164516_7",
            "eventType": "CREATED",
            "eventTimestamp": "2018-04-10T23:57:33.682Z",
            "filePath": "C:/$GetCurrent/SafeOS/",
            "fileName": "preoobe.cmd",
            "fileType": "FILE",
            "fileSize": 74,
            "fileOwner": "Administrators",
            "md5Checksum": "2f9537b7f7cb5b559ed6ec3694832fe6",
            "createTimestamp": "2018-03-19T18:10:41.936Z",
            "modifyTimestamp": "2018-03-19T18:10:42.041Z",
            "deviceUserName": "paige@example.com",
            "osHostName": "CO-SAMPLE-2",
            "domainName": 192.0.2.0,
            "publicIpAddress": "192.0.2.0",
            "privateIpAddresses": [
                "2001:db8:49a3:7d3:1309:8a2e:370:7342",
                "192.0.4.0",
                "0:0:0:0:0:0:0:1",
                "127.0.0.1"
            ],
            "deviceUid": "423278037859030542",
            "userUid": "424242424242424243"
        },       
        {
            "eventId": "0_1dcc9b7c-123d-40d7-b0fb-436520b2cab8_843278037859030533_843419521787010148_344",
            "eventType": "CREATED",
            "eventTimestamp": "2018-04-11T16:40:11.090Z",
            "filePath": "C:/Windows/en-US/",
            "fileName": "bootfix.bin",
            "fileType": "FILE",
            "fileSize": 1024,
            "fileOwner": "TrustedInstaller",
            "md5Checksum": "eb145d5f87ddf43c8bd6f27e97db8bf2",
            "createTimestamp": "2017-09-29T14:41:10.345Z",
            "modifyTimestamp": "2017-09-29T14:41:10.346Z",
            "deviceUserName": "clyde@example.com",
            "osHostName": "CO-SAMPLE-3",
            "domainName": 192.0.4.0,
            "publicIpAddress": "192.0.4.0",
            "privateIpAddresses": [
                "2001:db8:49a3:7d3:1309:8a2e:370:7342",
                "192.0.4.0",
                "0:0:0:0:0:0:0:1",
                "127.0.0.1"
            ],
            "deviceUid": "423278037859030542",
            "userUid": "424242424242424242"
        }
    ],
    "problems": null
}
```

### Use case 2: Search for files on a device within a specific date range based on MD5 values

The sample JSON below shows how to search for files files matching any of four MD5 values that existed on devices between February 1 and 7, 2018. 

**Note:** To search for SHA256 hash values instead of MD5, replace `md5Checksum` with `sha256Checksum` in the sample JSON below.

#### Sample JSON search query for MD5 values between two dates 

Modify this sample to fit your environment and then include it in a request (as shown in the [Sample request](#sample-request) section above).

```json
{
  "groups": [
    {
      "filters": [
        {
          "operator": "IS",
          "term": "md5Checksum",
          "value": "db349b97c37d22f5ea1d1841e3c89eb4"
        },
        {
          "operator": "IS",
          "term": "md5Checksum",
          "value": "84c82835a5d21bbcf75a61706d8ab549"
        },
        {
          "operator": "IS",
          "term": "md5Checksum",
          "value": "f351e1fcca0c4ea05fc44d15a17f8b36"
        },
        {
          "operator": "IS",
          "term": "md5Checksum",
          "value": "7bf2b57f2a205768755c07f238fb32cc"
        }
      ],
      "filterClause": "OR"
    },
    {
      "filters": [
        {
          "operator": "ON_OR_AFTER",
          "term": "eventTimestamp",
          "value": "2018-02-01T00:00:00.00Z"
        },
        {
          "operator": "ON_OR_BEFORE",
          "term": "eventTimestamp",
          "value": "2018-02-07T23:59:59.59Z"
        }
      ],
      "filterClause": "AND"
    }
  ],
  "groupClause": "AND",
  "pgNum": 1,
  "pgSize": 100,
  "srtDir": "asc",
  "srtKey": "eventTimestamp"
}
```

#### Sample results of file events matching the MD5 values and date range 

```json
{
    "totalCount": 2,
    "fileEvents": [
        {
            "eventId": "0_1dcc9b7c-123d-40d7-b0fb-436520b2cab8_843278037859030533_843279264407737861_1",
            "eventType": "CREATED",
            "eventTimestamp": "2018-02-04T18:40:37.790Z",
            "filePath": "C:/Windows/",
            "fileName": "mssecsvc.exe",
            "fileType": "FILE",
            "fileSize": 282,
            "fileOwner": "clyde",
            "md5Checksum": "db349b97c37d22f5ea1d1841e3c89eb4",
            "createTimestamp": "2018-02-03T15:43:29.388Z",
            "modifyTimestamp": "2018-02-04T15:13:28.783Z",
            "deviceUserName": "clyde@example.com",
            "osHostName": "CO-SAMPLE-01",
            "domainName": "192.0.2.0",
            "publicIpAddress": "192.0.2.0",
            "privateIpAddresses": [
                "2001:db8:49a3:7d3:1309:8a2e:370:7342",
                "192.0.4.0",
                "0:0:0:0:0:0:0:1",
                "127.0.0.1"
            ],
            "deviceUid": "425916091791253442",
            "userUid": "424242424242424242"
        },
        {
            "eventId": "0_1dcc9b7c-123d-40d7-b0fb-436520b2cab8_843278037859030533_843317905847131236_1",
            "eventType": "MODIFIED",
            "eventTimestamp": "2018-02-02T23:50:42.294Z",
            "filePath": "C:/Users/Paige/Downloads/",
            "fileName": "tasksche.exe",
            "fileType": "FILE",
            "fileSize": 282,
            "fileOwner": "paige",
            "md5Checksum": "84c82835a5d21bbcf75a61706d8ab549",
            "createTimestamp": "2018-02-01T15:43:29.388Z",
            "modifyTimestamp": "2018-02-02T23:47:04.336Z",
            "deviceUserName": "paige@example.com",
            "osHostName": "CO-SAMPLE-02",
            "domainName": "192.0.4.0",
            "publicIpAddress": "192.0.4.0",
            "privateIpAddresses": [
                "2001:db8:49a3:7d3:1309:8a2e:370:7342",
                "192.0.4.0",
                "0:0:0:0:0:0:0:1",
                "127.0.0.1"
            ],
            "deviceUid": "423278037859030542",
            "userUid": "424242424242424243"
        }
    ],
    "problems": null
} 
```

### Use case 3: See all cloud sync destinations for a user

The sample JSON below shows how to use the [/v1/file-events/grouping](/sandbox/api/#operation/groupingUsingPOST) resource to find an approximate count of **Synced to cloud service** file events for a specific user for each cloud service. This sample groups by the `syncDestination` value, but you can choose any `groupingTerm` listed in the [/v1/file-events/grouping](/sandbox/api/#operation/groupingUsingPOST) API documentation in your requests.

#### Sample JSON search query for cloud service file event counts 

Modify this sample to fit your environment and then include it in a request (as shown in the [Sample request](#sample-request) section above). For grouping queries, you must use the [/v1/file-events/grouping](/sandbox/api/#operation/groupingUsingPOST) resource.

```json
{
    "groupingTerm": "syncDestination",
    "groups": [
        {
            "filters": [
                {
                    "operator": "IS",
                    "term": "deviceUserName",
                    "value": "clyde@example.com"
                }
            ]
        }
    ]
}
```

#### Sample results of cloud service file event counts

```json    
{
  "groups": [
    {
      "value": "Dropbox",
      "docCount": 114
    },
    {
      "value": "Google Drive",
      "docCount": 8
    }
  ]
}
```

**Missing or unknown values**

Some file events may not capture all metadata. Reasons for omitted metadata can include:

* The file did not exist on disk long enough for Code42 to capture all the metadata.
* Several values, including `deviceUserName` and `userUid`, are captured and reported from the Code42 cloud instead of directly from the user device. If those values haven't been reported yet, they may be blank or may display as `UNKNOWN` or `NAME_NOT_AVAILABLE`. 
