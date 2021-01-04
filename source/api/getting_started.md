# Getting started

---
**Considerations**

* For assistance with using the Code42 API, contact your Customer Success Manager (CSM) to engage the Code42 Professional Services team. Or, [post your question to the Code42 community](https://success.code42.com/home) to get advice from fellow Code42 administrators.

* API resources themselves only work for you under these conditions:
  * You have a [product plan](https://support.code42.com/Terms_and_conditions/Code42_customer_support_resources/Code42_product_plans) that includes access to the Code42 API.
  * Your credentials rely on local authentication. SSO or authentication through any third-party provider will not work.
  * Your [role provides permission](https://support.code42.com/Administrator/Cloud/Monitoring_and_managing/Manage_user_roles) to access the data necessary to a given API resource. If your API calls fail because you do not have permission to use them, you will see reply messages like these: `HTTP 401 Unauthorized`, `HTTP 401 Could not authenticate user`, `Your Code42 product plan does not permit use of the Code42 API`.
  * The examples in the articles here use curl.

---

## Request URLs

Following are the request URLs for the APIs shown in this documentation.

* United States:

  * If you sign in to the Code42 console at [https://www.crashplan.com/console](https://www.crashplan.com/console), use `https://api.prod.ffs.us2.code42.com/<resource>`.

  * If you sign in to the Code42 console at [https://console.us.code42.com/console](https://console.us.code42.com/console), use `https://api.us.code42.com/<resource>`.

* Ireland: If you sign in to the Code42 console at [https://console.ie.code42.com/console](https://console.ie.code42.com/console), use `https://api.ie.code42/<resource>`.

## Resources

Combine the [request URL](#request-urls) with the resource to get the full URL for the API. The path of the resource is shown for each API listed in the [Code42 API Documentation](/api/).

For example, the [Auth API documentation](/api/#tag/Auth) shows the resource as `/v1/auth/`. To run the Auth API, combine the request URL with the resource in the API call:

```bash
curl -X GET -u "username" -H "Accept: application/json" "https://api.us.code42.com/v1/auth/"
```

## Authentication

Most API calls require an [authentication token](https://support.code42.com/Administrator/Cloud/Monitoring_and_managing/Code42_API_resources/Code42_API_authentication_methods#Use_token_authentication) in the header of the request. To obtain an authentication token, use your Code42 administrator credentials to submit a `GET` request to the `/v1/auth/` API. (For details, see the [Auth API documentation](/api/#tag/Auth).)

In the following example, replace `<Code42Username>` with a Code42 administrator username, and replace `<RequestURL>` with the [request URL](#request-urls) of your Code42 cloud instance:

```bash
curl -X GET -u "<Code42Username>" -H "Accept: application/json" "https://<RequestURL>/v1/auth/"
```

If your organization uses [two-factor authentication for local users](https://support.code42.com/Administrator/Cloud/Configuring/Two-factor_authentication_for_local_users), you must also include a `totp-auth` header value containing the Time-based One-Time Password (TOTP) supplied by the Google Authenticator mobile app. The example below includes a TOTP value of 424242.

```bash
curl -X GET -u "<Code42Username>" -H "totp-auth: 424242" "Accept: application/json" "https://<RequestURL>/v1/auth/"
```

A successful request returns an authentication token. For example:

```bash
{"bearerToken": "eyJjdHkiO_bxYJOOn28y...5HGtGHgJzHVCE8zfy1qRBf_rhchA"}
```

### Token considerations

* Authentication tokens expire after 30 minutes.
* The user account making the authentication API request must have the [Customer Cloud Admin](https://support.code42.com/Administrator/Cloud/Monitoring_and_managing/Roles_reference#Customer_Cloud_Admin) role.

## Get a tenant ID

Some APIs require that you provide the unique ID of your organization (or tenant) in the Code42 cloud. To obtain the tenant ID, use your Code42 administrator credentials to submit a `GET` request to the [`/v1/customer` API](/api/#tag/Customer).

In the following example, replace `<AuthToken>` with the [authentication token](#authentication) and replace `<RequestURL>` with the [request URL](#request-urls) of your Code42 cloud instance:

```bash
curl -X GET -H "Authorization: Bearer <AuthToken>" 'https://<RequestURL>/v1/customer'
```

A successful response returns the tenantUid:

```json
{
  "data": {
    "name": "My Org",
    "registrationKey": "4s42ukut7pwpwr4c",
    "deploymentModel": "PUBLIC",
    "maintenanceMode": false,
    "tenantUid": "42b42dfe-4242-4242-428a-8a1dfd352f2f",
    "masterServicesAgreement": {
      "accepted": true,
      "acceptanceRequired": false
    }
  },
  "error": null,
  "warnings": null
}
```

## Get userUIDs

Some APIs require that you provide a user's UID. Each user in Code42 is uniquely identified by a userUID value.

You can locate userUIDs directly in the Code42 console:

* Export a [list of Code42 users to a CSV file](https://support.code42.com/Administrator/Cloud/Code42_console_reference/Users_reference#CSV_export). The file includes each user's userUID.
* View userUIDs in the [User Backup report](https://support.code42.com/Administrator/Cloud/Code42_console_reference/User_Backup_report_reference#User_Backup_report) and [Device Status report](https://support.code42.com/Administrator/Cloud/Code42_console_reference/Device_Status_report_reference#Device_Status_report).

You can also submit a `GET` request to the `/v1/User` API to get a userUID (see the [User API documentation](/api/#tag/User)).

In the following example, replace `<RequestURL>` with the [request URL](#request-urls) of your Code42 cloud instance, replace `<Code42Username>` with the Code42 username of the user whose userUID value you want to view, and replace `<AuthToken>` with the [authentication token](#authentication):

```bash
curl -X GET 'https://<RequestURL>/v1/users?username=<Code42Username>' -H 'Authorization: Bearer <AuthToken>'
```

A successful response lists information about that user, including the `userUID`.

```json
{
  "metadata": {
    "timestamp": "2020-06-12T19:45:41.962Z",
    "params": {
      "q": "astrid.ludwig@example.com",
      "active": "true"
    }
  },
  "data": {
    "totalCount": 1,
    "users": [
      {
        "userId": 199520,
        "userUid": "933431721358889954",
        "status": "Active",
        "username": "astrid.ludwig@example.com",
        "email": "astrid.ludwig@example.com",
        "firstName": "Astrid",
        "lastName": "Ludwig",
        "quotaInBytes": -1,
        "orgId": 4203,
        "orgUid": "933427843360873352",
        "orgName": "OktaOrg",
        "userExtRef": null,
        "notes": null,
        "active": true,
        "blocked": false,
        "emailPromo": true,
        "invited": false,
        "orgType": "ENTERPRISE",
        "usernameIsAnEmail": true,
        "creationDate": "2019-12-23T15:51:01.871Z",
        "modificationDate": "2019-12-23T15:51:02.057Z",
        "passwordReset": false,
        "localAuthenticationOnly": false,
        "licenses": [
          "admin.securityTools"
        ]
      }
    ]
  }
}
```

---
