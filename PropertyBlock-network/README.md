# Digital Property Network

Contributors:

Michael Lusignan
Pratik Patil
Sandip Prashar

> This is a project for CFDev 03 at The Blockchain Hub, at York University Lassonde Professional Development, Lassonde School of Engineering.
> Digital Property Network is a platform for users to digital exchange the property ownership over a Hyperledger smart contract network.
> This Defines a business network where house sellers can list their properties for sale.

This business network defines:

**Participant**
`Person`

**Assets**
`LandTitle` `SalesAgreement`

**Transaction**
`RegisterPropertyForSale`
'BlockedProperty'
'UnBlockedProperty'
A `Person` is responsible for a `LandTitle`. By creating a `SalesAgreement` between two `Person` participants you are then able to submit a `RegisterPropertyForSale` transaction.

To test this Business Network Definition in the **Test** tab:

Create two `Person` participants:

```
{
  "$class": "net.biz.digitalPropertyNetwork.Person",
  "personId": "personId:Billy",
  "firstName": "Billy",
  "lastName": "Thompson"
}
```

```
{
  "$class": "net.biz.digitalPropertyNetwork.Person",
  "personId": "personId:Jenny",
  "firstName": "Jenny",
  "lastName": "Jones"
}
```

Create a `LandTitle` asset:

```
{
  "$class": "net.biz.digitalPropertyNetwork.LandTitle",
  "titleId": "titleId:ABCD",
  "owner": "resource:net.biz.digitalPropertyNetwork.Person#personId:Billy",
  "information": "Detached House"
}
```

Create a `SalesAgreement` asset:

```
{
  "$class": "net.biz.digitalPropertyNetwork.SalesAgreement",
  "salesId": "salesId:1234",
  "buyer": "resource:net.biz.digitalPropertyNetwork.Person#personId:Jenny",
  "seller": "resource:net.biz.digitalPropertyNetwork.Person#personId:Billy",
  "title": "resource:net.biz.digitalPropertyNetwork.LandTitle#titleId:ABCD"
}
```

Submit a `RegisterPropertyForSale` transaction:

```
{
  "$class": "net.biz.digitalPropertyNetwork.RegisterPropertyForSale",
  "seller": "resource:net.biz.digitalPropertyNetwork.Person#personId:Billy",
  "title": "resource:net.biz.digitalPropertyNetwork.LandTitle#titleId:ABCD"
}
```

This `RegisterPropertyForSale` transaction will update `titleId:ABCD` `LandTitle` asset to `forSale`.

Congratulations!

## License <a name="license"></a>
Hyperledger Project source code files are made available under the Apache License, Version 2.0 (Apache-2.0), located in the LICENSE file. Hyperledger Project documentation files are made available under the Creative Commons Attribution 4.0 International License (CC-BY-4.0), available at http://creativecommons.org/licenses/by/4.0/.
