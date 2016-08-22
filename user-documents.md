# User documents API

This API makes it possible for third parties (*sender*) to access and perform certain operations on a *user's* documents in Digipost. The *user* grants the *sender* access to documents through an *agreement*. The *agreement* governs which documents the *sender* can access and what operations it can perform. For example, the agreement type `INVOICE_BANK` allows a *sender* to retrieve a *user's* invoices and update their payment status.

## System account

Before a system can access the API it must be registered in Digipost and it must be granted access to one or more agreement types that governs which operations it can perform on behalf of users.

### Broker

The broker is the organisation and system integrating with the API. A broker can access the API on behalf of itself or on behalf of other organisations called senders. A broker uses a `brokerId` and certificate to authenticate with the API.

### Sender

The sender is the organization that wants access to user data. Every sender has a `senderId` which is a mandatory parameter to all API-requests. If the organisation has its own integration with the API, the `senderId` will be the same ID as the `brokerId`.
