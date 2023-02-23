# SophosPartnerCustomerIDs


This script serves an important purpose: in the event that a user accidentally installs Sophos on a client machine using the wrong installer, it can be difficult to determine which customer tenant the machine has been installed to. 

However, by searching the registry at:

[HKEY_LOCAL_MACHINE\SOFTWARE\Sophos\Management\Policy\Authority\20211208113420922375], 

You can retrieve the "TenantID" and use this script to easily locate which of your customers the machine has been installed into.

This script/exe will ask if you are running it on the affected machine, if you are it will search for the relevant registry key. 
If you are not, then it will prompt you to enter the TenantID found at the above registry location

You will need to create a new Sophos Partner API credential to run this script. You will need a "Client ID" and a "Client Secret". More info on how to get this here: https://developer.sophos.com/getting-started

Client ID = Sophos API Client ID <br>
Client Secret = Sophos API Client Secret <br>
Tenant ID = The TenantID taken from the registry above (must be in GUID format) (example = 123456a7-123b-12c3-a1d2-a6e1c71a1f5a)
