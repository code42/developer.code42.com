---
title: Forensic Search API

category: detect-and-respond

toc_footers:
  - <a href='https://github.com/slatedocs/slate'>Documentation Powered by Slate</a>

search: true

code_clipboard: true
---

# Forensic Search API

## Overview

This article explains how to use the Code42 API with Forensic Search. While the Code42 console contains [a flexible and powerful web interface](https://support.code42.com/Administrator/Cloud/Code42_console_reference/Forensic_Search_reference_guide) to perform searches and view results, the Code42 API provides additional capabilities for performing more complicated or customized searches.

The examples in this article use [curl](https://curl.se/), but the concepts apply to [any tool you choose for interacting with the Code42 API](https://support.code42.com/Administrator/Cloud/Monitoring_and_managing/Code42_API_resources/Tools_for_interacting_with_the_Code42_API).

## Forensic Search API structure and syntax 

### Summary 

**Request URL** 

* United States:

    * If you sign in to the Code42 console at [https://console.us.code42.com/console](https://console.us.code42.com/console), use: 
`https://forensicsearch-east.us.code42.com/forensic-search/queryservice/api/v1/`
    * If you sign in to the Code42 console at [https://www.crashplan.com/console](https://www.crashplan.com/console), use:
`https://forensicsearch-default.prod.ffs.us2.code42.com/forensic-search/queryservice/api/v1/`
    * If you sign in to the Code42 console for the Code42 federal environment at [https://console.gov.code42.com/console](https://console.gov.code42.com/console), use: 
`https://forensicsearch-default.gov.code42.com/forensic-search/queryservice/api/v1/`

* Ireland: `https://forensicsearch-default.ie.code42.com/forensic-search/queryservice/api/v1/`

**Resource names:**

* `fileevent`: To search file activity and receive results in JSON format
* `fileevent/export`: To search file activity receive results in CSV format
* `fileevent/grouping`: To group file activity results by a particular value and receive a count of unique events in each group

**Authentication method:** In the authorization request header, specify a scheme of `v3_user_token` and include the token as the credentials. See the [Authentication](#authentication) section below for steps to obtain the token.

**Complete API documentation**

* United States:

    * [https://forensicsearch-east.us.code42.com/forensic-search/queryservice/swagger-ui.html#/file-event-controller](https://forensicsearch-east.us.code42.com/forensic-search/queryservice/swagger-ui.html#/file-event-controller), or

    * [https://forensicsearch-default.prod.ffs.us2.code42.com/forensic-search/queryservice/swagger-ui.html#/file-event-controller/](https://forensicsearch-default.prod.ffs.us2.code42.com/forensic-search/queryservice/swagger-ui.html#/file-event-controller/)

    * [https://forensicsearch-default.gov.code42.com/forensic-search/queryservice/swagger-ui.html#/file-event-controller](https://forensicsearch-default.gov.code42.com/forensic-search/queryservice/swagger-ui.html#/file-event-controller) (Code42 federal environment only)

* Ireland: [https://forensicsearch-default.ie.code42.com/forensic-search/queryservice/swagger-ui.html#/file-event-controller](https://forensicsearch-default.ie.code42.com/forensic-search/queryservice/swagger-ui.html#/file-event-controller)

<aside class="notice">

**API limits**

* **Request rate:** To ensure optimal performance throughout your Code42 environment, Code42 limits API requests to 120 per minute. Requests that exceed this limit are blocked and do not return results.

* **Result set:**
   * `fileevent` results are limited to 10,000 events per request. Requesting a page number that exceeds these limits returns an error (for example, a `fileevent` query with a `pgSize` of 10,000 cannot display `pgNum` 2). To obtain more than 10,000 results, use the `pgToken` and `nextPgToken` request fields to submit multiple requests. (For `pgToken` implementation details: from the **Complete API documentation** links above, see the **Model** tab in the **SearchRequest** and **FileEventResponse** sections.)
   * `fileevent/export` queries are limited to 200,000 events. 
   * `fileevent/grouping` queries are limited to 1,000 groups.

</aside>

### Authentication

Authentication tokens are required in the header of all requests. To obtain an authentication token, use your Code42 administrator credentials to submit a `GET` request to:

* United States: 
    * If you sign in to the Code42 console at [https://console.us.code42.com/console](https://console.us.code42.com/console), use: 
`https://console.us.code42.com/c42api/v3/auth/jwt?useBody=true`
    * If you sign in to the Code42 console at [https://www.crashplan.com/console](https://www.crashplan.com/console), use: 
`https://www.crashplan.com/c42api/v3/auth/jwt?useBody=true`
    * If you sign in to the Code42 console for the Code42 federal environment at [https://console.gov.code42.com/console](https://console.gov.code42.com/console), use: 
`https://console.gov.code42.com/c42api/v3/auth/jwt?useBody=true`

* Ireland: `https://console.ie.code42.com/c42api/v3/auth/jwt?useBody=true`

For example:

```bash
curl -X GET -u "username" -H "Accept: application/json" "https://console.us.code42.com/c42api/v3/auth/jwt?useBody=true"
```

If your organization uses [two-factor authentication for local users](https://support.code42.com/Administrator/Cloud/Configuring/Two-factor_authentication_for_local_users), you must also include a `totp-auth` header value containing the Time-based One-Time Password (TOTP) supplied by the Google Authenticator mobile app. The example below includes a TOTP value of 424242.

```bash
curl -X GET -u "username" -H "totp-auth: 424242" "Accept: application/json" "https://console.us.code42.com/c42api/v3/auth/jwt?useBody=true"
```

A successful request returns an authentication token. For example:

```json
{
    "v3_user_token": "eyJjdHkiOiJKV1QiLCJlbmMiOiJBMTI4R0NNIiwiZXhwIjoiMjAxOC0wNC0zMFQyMTo0MDoyNy4xMDZaIiwiYWxnIjoiUlNBLU9BRVAtMjU2In0.0H-4bl43zA3cIE5D3o_8vZzJIUgtJt64mZbimNa2TNha761RgVBFaTfttMODXF1ntLUTHl-rD0JuHEAMrIxjpnaODictPizrDVeTA1PgkPrsKot9jp6D7uTEC1Y56qHS1qjP6WHQBpv6ADBfrAfePX3NnwkA5a1I8pB88kSWc1MXZ4uMt-rFcNtlLLPVfwtEXHyNG_bxYJOOn28y2ysJGSBD_Xx1-uK4zKvjWwXfVQG581TntFPy0LamJfJ7IM4wOIG-QrKeV796fJAaHBxNfOe4UWC8WeNcDEvgNZvOPchWTHY4l66OaOjHNeEkoKkxvc35j4V_QpYxe6GXRYK4NA.TJXe9M6goiZbw-tr.y0lUTHHkHU5tRS7bWI8jntMLcxv0HajXTXquV62IG4400i7wi0YSX-6vpsXVgivzztxnPaukgUsLavhZ8-wCiMdEkut4GfijTlDAM_tfmJyZG6Cn5GKIJgSCENrR1JTxvC6dhTvHc41p6T3jXqBWikoJwD9z9Ec3u-OhM3gotQZUfCq0rR8T043RZSN9-0TpxhpPUEUAS6rkAI07QP08l_nUqdQTsNF0Tafe1yfPTYJabkslHhYMlLRYuXwhWr_39h5BY89ud0cW_OyUtjzz83m9iGxv6sba9VBIb2Y95ipXLu6Ie-5wz8zivfjizX6ZQatp5Ep4UZxzsMdqD9j0BFXkXQZuITJLtKfmUX-FZYR8utNrbwtt8u2tvNUK8Ix4Fwa3bWPxlkwrhOdz70M-mxluxpR6EKSrf8xwHagMcahzVPcW5NVL2khr4MwMUKyRV69dAdGiaTKh2rd52znA0aE3OCtelnBrBn4rls0KX71_qZEAdPaLyyqZ4VaurWUfl35zSi2LW_a3-TebgIebHZxC-MxvFEH4DQq6gJDdoX92_YEYEn4tO_dhUTlD0CZ9HhT39XFrO9MBe4DoDzG-Iql_A-nhmCyOrRmQvUlR72XpHVFQQx3X6tqdPxFocgDh5z03-kLB4SjznQSlzJNbzl_knXTBGopoFLn3WHvjX8q327Vmwx1hjrQnO8Eg5rJMoXTJCMEEOkMyjkbFeEzEhTf2jcvvAlnNnxdtjb1Zo05RWwMsPwwHAgGr-0mm-ungNjIGW0MyMTZtK0StP1uRqfI1Q6ghqnGZxEZN_0fvsVlsz4u9A1eBYRE0xzg8p-0g62nAQ8GftpYaUoymgqbL2WCL15r38emLklXSruztosGU4Dtusg4JHEhYPxO4ieqeBu6FLX9fPSA_y3zmd_AEjW40-_6zC3quPYJwytaEIwVH6phtfa2phsOLLw-U-b2QY09-d27YirIjgNRZ7rO4GF3iX8hW3LfFIWj0WKA5HGtGHg.JzHVCE8zfy1qRBf__rhchA"
}
```

**Token considerations** 

* Use this authentication token in your search requests (see examples below).
* Authentication tokens expire after one hour.
* You must have credentials for a Code42 user with either the [Customer Cloud Admin](https://support.code42.com/Administrator/Cloud/Monitoring_and_managing/Roles_reference#Customer_Cloud_Admin) or [Security Center User](https://support.code42.com/Administrator/Cloud/Monitoring_and_managing/Roles_reference#Security_Center_User) role.
* The example above only applies to users who authenticate locally with Code42. Single sign-on (SSO) users must also complete SAML authentication with their SSO provider. If you need assistance with this process, contact your SSO provider.
* The URL to obtain the authentication token is different than the URL used to query file event data.


### Groups and filters 

Forensic Search API queries are organized by **groups of filters**. This structure facilitates complicated requests with-application-files-in-unexpected-locations) in the next section searches for files matching any one of 11 different file extensions that also exist in any one of nine different locations. Search queries are limited to a total of 1,024 criteria per request.

For example, the JSON below uses two groups of filters:

* The first group uses a `filterClause` value of `OR`, which returns results if **any** of the four MD5 values are found (db349b97c37d22f5ea1d1841e3c89eb4 or 84c82835a5d21bbcf75a61706d8ab549 or f351e1fcca0c4ea05fc44d15a17f8b36 or 7bf2b57f2a205768755c07f238fb32cc).
* The second group uses a `filterClause` value of `AND`, which returns results only if **all** criteria in the filter are met (in this example, on or after 2018-02-01 **and** on or before 2018-02-07).
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

This simple example demonstrates a search for all files on all devices with the file extension .docx that exist anywhere **except** the file path `C:/Users`. For more complicated examples with multiple groups and additional filters, see the [sample use cases](#sample-use-cases) in the next section. Use this simple example as a starting point for your own searches and replace the content of the `-d` section with your specific search criteria.

```bash
curl -X POST  https://forensicsearch-east.us.code42.com/forensic-search/queryservice/api/v1/fileevent \
-H 'content-type: application/json' \
-H "authorization: v3_user_token <authentication token goes here (without the angle brackets)>" \
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
<aside class="success">

**Format results as CSV**

To receive results in CSV format instead of JSON, use the `fileevent/export` resource instead of `fileevent`. 
For example: 
`https://forensicsearch-east.us.code42.com/forensic-search/queryservice/api/v1/fileevent/export`
</aside>

## Sample Use Cases 

### Use case 1: Search for application files in unexpected locations 

The sample JSON below shows how to search for files with any of these extensions (.action, .app, .bat, .bin, .cmd, .com, .command, .cpl, .exe, .msc, .osx) that exist outside these locations:

* C:\Program Files
* /Applications
* /Library
* /User/*/Applications
* /User/*/Library
* /usr/bin
* /usr/local/bin
* /sbin
* /bin

#### Sample JSON search query for application files in specific locations 

Modify this sample to fit your environment and then include it in a request (as shown in the [Sample request](#sample-request) section above).

```bash
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
          "value": "C:\Program Files*"
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

<aside class="notice">

**The Code42 API also supports SHA256 searches**

To search for SHA256 hash values instead of MD5, replace `md5Checksum` with `sha256Checksum` in the sample JSON below.

</aside>

#### Sample JSON search query for MD5 values between two dates 

Modify this sample to fit your environment and then include it in a request (as shown in the [Sample request](#sample-request) section above).

```bash
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
            "domainName": 192.0.2.0,
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
            "domainName": 192.0.4.0,
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

The sample JSON below shows how to use the `fileevent/grouping` resource to find an approximate count of **Synced to cloud service** file events for a specific user for each cloud service. This sample groups by the `syncDestination` value, but you can choose any `groupingTerm` listed in the [Code42 API documentation viewer](https://forensicsearch-east.us.code42.com/forensic-search/queryservice/swagger-ui.html#/file-event-controller/groupingUsingPOST) in your requests.

#### Sample JSON search query for cloud service file event counts 

Modify this sample to fit your environment and then include it in a request (as shown in the [Sample request](#sample-request) section above). For grouping queries, you must use the `fileevent/grouping` resource.

```bash
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

<aside class="notice">

**Missing or unknown values**

Some file events may not capture all metadata. Reasons for omitted metadata can include:
* The file did not exist on disk long enough for Code42 to capture all the metadata.
* Several values, including `deviceUserName` and `userUid`, are captured and reported from the Code42 cloud instead of directly from the user device. If those values haven't been reported yet, they may be blank or may display as UNKNOWN or NAME_NOT_AVAILABLE. In those cases, you can use the `deviceUid` to get details via the [Computer API resource](https://console.us.code42.com/apidocviewer/#Computer-get).

</aside>

## External resources 

Curl: [Command line tool and library reference](https://curl.se/)