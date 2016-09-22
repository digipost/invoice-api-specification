# Requirements for bank payment API

This document describes the general requirements for the API that a bank provides to Digipost to allow customers/users to pay invoices directly from Digipost.

When the customer receives an invoice in Digipost they will be prompted the option to set up 'one click payment' to their bank. They will then go through the following steps:

1. Accept the terms of the service and allow Digipost to retrieve their account list and create payments on their behalf. Digipost will optionally invoke the API-function [CreateAgreement](#createagreement)
2. Select one or more accounts that will be used to pay invoices from. Digipost will invoke the API-function [GetAccountList](#getaccountlist)
3. Pay invoices directly from Digipost from one of the accounts selected above. Digipost will invoke the API-function [CreatePayment](#createpayment)


## Table of contents

* [CreateAgreement](#createagreement)
* [GetAccountList](#getaccountlist)
* [CreatePayment](#createpayment)
* [Security](#security)

## CreateAgreement

If required by the bank, Digipost will send a CreateAgreement request to signal that the user has accepted (in Digipost) the general terms for the service and agrees that Digipost can retrieve account numbers and create payments on behalf of the user. The request may contain an agreement digitally signed (BankId) by the user.

The bank stores the agreement and uses it to authorize subsequent payments for the same customer.

## Request (parameters)

* bank-identifier (if multiple banks use the same platform)
* personal-identification-number (fødselsnummer)
* signed-agreement (if required)

## GetAccountList

Digipost retrieves the account list and presents it to the user which chooses which accounts they will pay invoices from. The chosen accounts are stored on the user's profile in Digipost. Only accounts that can be used for payment should be returned.

### Request (parameters)

* bank-identifier
* personal-identification-number (fødselsnummer)

### Response

* List of accounts with
  - account number
  - account alias

## CreatePayment

When the user receives an invoice they can choose which account to pay from and then submit the payment with one click.

After successful response it is expected that the invoice has been added to pending payments in the bank and that it will automatically be paid on the due date unless manually stopped by the user (or due to insufficient funds).

### Request (parameters)

* bank-identifier
* personal-identification-number (fødselsnummer)
* from account number (chosen previously)
* to account number
* CID/KID (optional for certain credit card invoices)
* amount
* due date
* invoice issuer name (optional)
* Digipost invoice id (optional, can be used to retrieve invoice specification pdf/html)

### Response

* payment identifier (to be able to trace back to the payment if neccessary)

## API type

Preferably http based (REST or SOAP) with XML or JSON message format.

## Security

* Encrypted transport (TLS for HTTPS)
* Session based or pr. message authentication
  - Each message can be digitally signed for stateless authentication
  - Digitally signed authentication with subsequent session identitier is also possible
* Identification using X509 certificates
