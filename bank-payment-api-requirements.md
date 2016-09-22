# Requirements for bank provided payment APIs

This document describes the general requirements for the API that a bank provides to Digipost to allow customers/users to pay invoices directly from Digipost.

## Table of contents

* [CreateAgreement](#createagreement)
* [GetAccountList](#getaccountlist)
* [CreatePayment](#createpayment)
* [Security](#security)

## CreateAgreement

If required by the bank Digipost will send a CreateAgreement request to signal that the user has accepted (in Digipost) the general terms for the service and agrees that Digipost can retrieve account numbers and create payments on behalf of the user. The request may contain an agreement digitally signed (BankId) by the user.

The bank stores the agreement and uses it to authorize subsequent payments for the same customer.

## Request

* bank-identifier (if multiple banks use the same platform)
* personal-identification-number (fødselsnummer)
* signed-agreement (if required)

## GetAccountList

Digipost retrieves the account list and presents it to the user which chooses which accounts they will pay invoices from. The chosen accounts are stored on the user's profile in Digipost. Only account that can be used for payment should be returned.

### Request

* bank-identifier
* personal-identification-number (fødselsnummer)

### Response

* List of accounts with
  - account number
  - account alias

## CreatePayment

When the user receives an invoice they can chose which account to pay from and then submit the payment with one click.

After successful response it is expected that the invoice has been added to pending payments in the bank and that it will automatically be paid on the due date unless manually stopped by the user (or due to insufficient funds).

### Request

* bank-identifier
* personal-identification-number (fødselsnummer)
* from account number (chosen previously)
* to account number
* CID/KID (optional for certain credit card invoices)
* amount
* due date
* invoice issuer name (optional)

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
