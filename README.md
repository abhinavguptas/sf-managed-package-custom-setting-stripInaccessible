# Salesforce Managed Package - Protected Custom Settings Issue with Security.stripInaccessible()
This managed package source code demonstrates the issue of Protected Custom Settings bug with Security.stripInaccessible() method. Here is quick summary of the issue:

* Create Protected Custom setting either of Hierarchy or List Type
* As part of Security Review Compliance, one will either check for CRUD/FLS via Apex Describe Calls, or can use the newly released Security.stripInaccessible() Apex utility. 
* Add a class lets say Foo.cls, that uses Security.stripInaccessible() to verify Custom Setting access in any Aura, LWC, Batch or other Apex code. 
* Do a managed release or beta package upload i.e. with a package prefix
* Install the managed package in a client org.
* In the client org, invoke Foo.cls and you will get a FALSE Exception from Security.stripInaccessible() despite having READ/WRITE access on the protected custom settings. 

