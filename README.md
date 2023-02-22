# SophosPartnerCustomerIDs
Connects to Sophos Central Partner to get Tenant IDs

This script serves an important purpose: in the event that a user accidentally installs Sophos on a client machine using the wrong installer, it can be difficult to determine which customer tenant the machine has been installed to. 

However, by searching the registry at:

[HKEY_LOCAL_MACHINE\SOFTWARE\Sophos\Management\Policy\Authority\20211208113420922375], 

You can retrieve the "TenantID" and use this script to easily locate which of your customers the machine has been installed into.

You will need to create a new Sophos Partner API credential to run this script. You will need a "Client ID" and a "Client Secret". More info on how to get this here: https://developer.sophos.com/getting-started
