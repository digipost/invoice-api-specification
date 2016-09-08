# User documents API

This API makes it possible for third parties (*sender*) to access and perform certain operations on a *user's* documents in Digipost. The *user* grants the *sender* access to documents through an *agreement*. The *agreement* governs which documents the *sender* can access and what operations it can perform. For example, the agreement type `INVOICE_BANK` allows a *sender* to retrieve a *user's* invoices and update their payment status.

## Table of contents

* [Organisation account](#organisation-account)
* [API technical](#api-technical)
* [Identify Digipost user](#identify-digipost-user)
* [Agreements](#agreements)
    * [Create or update agreement](#create-or-update-agreement)
    * [Read user agreement](#read-user-agreement)
    * [Get all agreements for a specific user](#get-all-agreements-for-a-specific-user)
    * [Delete agreement](#delete-agreement)
* [Documents](#documents)
    * [Get all documents for a given user and agreement](#get-all-documents-for-a-given-user-and-agreement)
    * [Get document count for a user](#get-document-count-for-a-user)
    * [Get single document by ID](#get-single-document-by-id)
    * [Update document, set status of invoice](#update-document-set-status-of-invoice)
    * [Get document content (pdf/html)](#get-document-content-pdfhtml)
* [Error handling](#error-handling)
* [Security](#security)
* [Miscellaneous](#miscellaneous)
* [Java Client Library](#java-client-library)

## Organisation account

Before an organisation can access the API it must be registered in Digipost and it must be granted access to one or more agreement types that governs which operations it can perform on behalf of users.

### Broker

The broker is the organisation and system integrating with the API. A broker can access the API on behalf of itself or on behalf of other organisations called senders. A broker uses a `brokerId` and certificate to authenticate with the API.

### Sender

The sender is the organization that wants access to user data. Every sender has a `senderId` which is a mandatory parameter to all API-requests. If the organisation has its own integration with the API, the `senderId` will be the same ID as the `brokerId`.

## API technical

* Type: XML over HTTP RESTful API
* Media type for XML: `application/vnd.digipost.user-v1+xml`
* [Java client library available](#java-client-library)

## Identify Digipost user

Operation: `IdentifyUser`

#### Java

```java
IdentificationResult identificationResult = client.identifyUser(senderId, userId);
```

#### Request

```xml
POST /api/identification
Accept: application/vnd.digipost.user-v1+xml
Content-Type: application/vnd.digipost.user-v1+xml

<identification>
  <personal-identification-number>01018012345</personal-identification-number>
</identification>
```

#### Response

```xml
HTTP/1.1 200 Ok

<identification-result>
  <result>DIGIPOST</result>
</identification-result>
```

#### Valid result codes

* `DIGIPOST` - registered user in Digipost
* `UNIDENTIFIED` - could not be identified by Digipost

## Agreements

An agreement between the *sender* and the *user* must be created before the sender's system can access any of the user's data. Different types of agreements exists and they define what data the *sender* will be granted access to.

### Create or update agreement

Operation: `CreateOrReplaceAgreement`

For some agreement types the *user* can accept the agreement from the site of the *sender*. The *sender* will then use this API to create the agreement in Digipost.

#### Java

```java
client.createOrReplaceAgreement(senderId, new Agreement(INVOICE_BANK, userId));
```

#### Request

```xml
POST /api/<sender-id>/user-agreements
Accept: application/vnd.digipost.user-v1+xml
Content-Type: application/vnd.digipost.user-v1+xml

<agreement>
  <type>invoice-bank</type>
  <user-id>01018012345<user-id>
  <attributes>
    <attribute><key>sms-notification</key><value>true</value></attribute>
  </attributes>
</agreement>
```

#### Response

```
HTTP/1.1 201 Created
Location: https://api.digipost.no/api/<sender-id>/user-agreements/<id>
```

To update an existing agreement simply post a new agreement of the same type for the same user and it will replace the existing.

### Read user agreement

Operation: GetAgreement

#### Java

```java
GetAgreementResult agreement = client.getAgreement(senderId, INVOICE_BANK, userId);
```

#### Request

```
GET /api/<sender-id>/user-agreements?user-id=12345678901&agreement-type=invoice-bank
Accept: application/vnd.digipost.user-v1+xml
```

#### Response

```xml
HTTP/1.1 200 Ok

<agreement href="/api/user-agreements/xyz123">
  <type>invoice-bank</type>
  <user-id>01018012345<user-id>
  <attributes>
    <attribute><key>sms-notification</key><value>true</value></attribute>
  </attributes>
</agreement>
```

#### Expected error responses:

* `HTTP 404 + UNKNOWN_USER`: No agrement found because the userId is not a Digipost user
* `HTTP 404 + NO_AGREEMENT`: The userId is a Digipost user but no agreement exists
* `HTTP 404 + AGREEMENT_DELETED`: The userId is a Digipost user with no currently active agreement. The user has previously deleted an agreement of the same type.

### Get all agreements for a specific user

Only agreements that the *sender* have access to will be returned.

Operation: `GetAgreements`

#### Java

```java
List<Agreement> agreements = client.getAgreements(senderId, userId);
```

#### Request

```
GET /api/<sender-id>/user-agreements?user-id=01018012345
Accept: application/vnd.digipost.user-v1+xml
```

#### Response

```xml
HTTP/1.1 200 Ok

<agreements>
  <agreement href="/api/<sender-id>/user-agreements/xyz123">
    <type>invoice-bank</type>
    <user-id>01018012345<user-id>
    <attributes>
      <attribute><key>sms-notification</key><value>true</value></attribute>
    </attributes>
  </agreement>
<agreements>
```

### Delete agreement

Operation: `DeleteAgreement`

#### Java

```java
client.deleteAgreement(senderId, INVOICE_BANK, userId);
```

#### Request

```
DELETE /api/<sender-id>/user-agreements?user-id=12345678901&agreement-type=invoice-bank
```

#### Response

```
HTTP/1.1 204 No Content
```

Operation: `DeleteAgreementById`

#### Request:

```
DELETE /api/<sender-id>/user-agreements/<id>
```

#### Response:

```
HTTP/1.1 204 No Content
```

## Documents

A document consists of some commons fields like id, subject, sender etc. and optionally some metadata fields that extends the documents semantics i.e. invoice, signature, insurance, etc.

### Get all documents for a given user and agreement

Operation: `GetDocuments`

#### Java

```java
List<Document> documents = client.getDocuments(senderId, INVOICE_BANK, userId, InvoiceStatus.UNPAID);
```

#### Request

```
GET /api/<sender-id>/user-documents?user-id=01018012345&agreement-type=invoice-bank&invoice-status=unpaid&invoice-due-date-from=20150101
Accept: application/vnd.digipost.user-v1+xml
```

#### Response

```xml
HTTP/1.1 200 Ok

<documents>
  <document href="/api/<sender-id>/user-documents/1234-xyz-000">
    <id>1234-xyz-000</id>
    <sender>Hafslund</sender>
    <invoice>
      <kid>00034558237213812</kid>
      <account>12345678909</account>
      <dueDate>2016-10-14</dueDate>
      <amount>299.40</amount>
      <status>unpaid</status>
    </invoice>
    <document-content-url>/api/1111/user-document-content/1234-xyz-000</document-content-url>
  </document>
</document>
```

### Get document count for a user

Operation: `GetDocumentCount`

#### Java

```java
long documentCount = client.getDocumentCount(senderId, INVOICE_BANK, userId, InvoiceStatus.UNPAID);
```

#### Request

```
GET /api/<sender-id>/user-documents/count?user-id=01018012345&agreement-type=invoice-dnb&invoice-status=unpaid&invoice-due-date-from=20150101
Accept: text/plain
Accept: application/vnd.digipost.user-v1+xml
```

#### Response

```
HTTP/1.1 200 Ok

5
```

Or if Accept: application/vnd.digipost.user-v1+xml

```xml
<document-count>
  <count>5</count>
</document-count>
```

### Get single document by ID

Operation: `GetDocument`

#### Request:

```
GET /api/<sender-id>/user-documents/<id>?agreement-type=invoice-bank
Accept: application/vnd.digipost.user-v1+xml
```

#### Response:

```xml
HTTP/1.1 200 Ok

<document href="/api/<sender-id>/user-documents/1234-xyz-000">
  <id>1234-xyz-000</id>
  <sender>Hafslund</sender>
  <invoice>
    <kid>00034558237213812</kid>
    <account>12345678909</account>
    <dueDate>2016-10-14</dueDate>
    <amount>299.40</amount>
    <status>unpaid</status>
    <update-invoice>/api/<sender-id>/user-documents/1234-xyz-000/invoice<update-invoice>
  </invoice>
  <document-content-url>/api/<sender-id>/user-documents/1234-xyz-000/content</document-content-url>
</document>
```

### Update document, set status of invoice

Operation: `UpdateInvoice`

#### Request:

```xml
POST /api/<sender-id>/user-documents/<id>/invoice
Content-Type: application/vnd.digipost.user-v1+xml

<invoice-update>
  <status>PAID</status>
  <payment-id>123456787654321</payment-id>
  <from-account>10001012345</from-account>
</invoice-update>
```

or 

```xml
POST /api/<sender-id>/user-documents/<id>/invoice
Content-Type: application/vnd.digipost.user-v1+xml

<invoice-update>
  <status>DELETED</status>
</invoice-update>
```

#### Response:

```
HTTP/1.1 204 No Content
```

After successful update the entire document state can be refreshed from the url in the Location-header.


### Get document content (pdf/html)

Operation: GetDocumentContent

Perform a GET against <document-content-url> and redirect the user’s browser to the url in the response Location header.

#### Request:

```
GET /api/<sender-id>/user-documents/1234-xyz-000/content
Accept: application/vnd.digipost.user-v1+xml
```

#### Response:

```xml
HTTP/1.1 200 Ok

<document-content>
  <content-type>application/pdf</content-type>
  <url>https://www.digipostdata.no/documents/34303129?token=30a6648a2cb1ce05d31dd6188135d7107c87d353dfe60f7720a598c4d6a95c2e4cf05f3ab63e52d734d745c2bf5084d37347f58aeca9da743235cf37cdca0ecb&download=false</url>
</document-content>
```

## Error handling

The API uses standard HTTP response codes to signal different types of error and a generic error response xml for details when applicable.

#### Response types

* `HTTP 2xx` Success response. 200 OK when response contains a body and 204 No Content for empty responses.
* `HTTP 3xx` Success responses directing the client to fetch the resource from another url.
* `HTTP 4xx` Client errors and malformed requests. Includes invalid xml and other validation errors.
* `HTTP 5xx` Server errors including unexpected server faults and service unavailble.

#### Response XML

```xml
<error>
  <code>UNKNOWN_AGREEMENT_TYPE</code>
  <message>Could not create agreement of unknown type</message>
<error>
```

## Security

The API employs both transport layer security (SSL/TLS) and message level digital signature to protect confidentiality, integrity and nonrepudiation.

### Transport security (SSL/TLS)

API endpoints are only available through HTTPS using secure versions of TLS.

### Message signatures

Every request issued by the client and every response from the server must contain a digital signature over selected header values including request method and path, client ID, timestamp and a SHA256 hash of the entire message body.

#### X509 Certificate

Third party systems must register a public X509 certificate of type “virksomhetssertifikat” with Digipost. This certificate will be used to verify the signature in each request.

#### Headers

The following example shows the mandatory security related headers:

```
Date: Wed, 29 Jun 2016 14:58:11 GMT
X-Digipost-UserId: 9999
X-Content-SHA256: q1MKE+RZFJgrefm34/uplM/R8/si9xzqGvvwK0YMbR0=
X-Digipost-Signature: BHvtgDTKz490iMbYZsOf5+FvWCsWDt5oJgyTvXlLiNrWgUu/fhuY8AJYBoH8g+0t46slsmJqQxNlsa6u+cF1aE921cZy7ISSeRLl/z6WlwCtTGu9fFH9X4Kr+2ffwPqzCTRPD4D5jHrbudmSGZJIq3ImAKU250t6SCJ//aiAKMg=
```

#### Signature

The signature is computed using the `SHA256WithRSAEncryption` algorithm over canonical string as shown below:

POST

```
POST
/messages
date: Wed, 29 Jun 2016 14:58:11 GMT
x-content-sha256: q1MKE+RZFJgrefm34/uplM/R8/si9xzqGvvwK0YMbR0=
x-digipost-userid: 9999
parameter1=58&parameter2=test
```

GET

```
GET
/
date: Wed, 29 Jun 2016 14:58:11 GMT
x-digipost-userid: 9999
parameter1=58&parameter2=test
```

Pseudo code for generating the signature

```java
String stringToSign = uppercase(verb) + "\n" +
                      lowercase(path) + "\n" +
                      "date: " + datoHeader + "\n" +
                      "x-content-sha256: " + sha256Header + "\n" +
                      "x-digipost-userid: " + virksomhetsId + "\n" +
                      lowercase(urlencode(requestparametre)) + "\n";

String signature =    base64(sign(stringToSign));
```

#### Reference

https://digipost.no/plattform/api/v5/sikkerhet

## Miscellaneous

### Request tracing

The API supports a HTTP-header with a unique ID to allow tracking each pair of HTTP-requests. When a request is sent with the header X-Digipost-Request-ID, the corresponding response will contain the exact same header.

## Java Client Library

For easy integration with Digipost Document API we provide a Java client library with a high level API. The client is a simple jar with a minimum set of dependencies. Using the client library gives the following advantages:

* Ready to use high level Java API
* Correct implementation of security mechanisms
* Easy to upgrade to new versions of the API (available from maven central)
* Continuously developed and tested

### Work in progress implementation

https://github.com/digipost/digipost-api-client-java/tree/user-documents

### Code example

```java
final FileInputStream key = new FileInputStream("digipost.p12");
final BrokerId brokerId = new BrokerId(111);
final SenderId senderId = new SenderId(222);

final DigipostUserDocumentClient client = new DigipostUserDocumentClient.Builder(brokerId, key, "password").build();

client.createOrReplaceAgreement(senderId, Agreement.createInvoiceBankAgreement(userId, false), requestTrackingId);

final List<Document> documents = client.getDocuments(senderId, AgreementType.INVOICE_BANK, userId, InvoiceStatus.UNPAID, null);
```
