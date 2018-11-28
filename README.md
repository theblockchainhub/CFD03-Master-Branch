[//]: # (SPDX-License-Identifier: CC-BY-4.0)

# CFDev Capstone Project: CREDO

Please consult the CFDEv_Capstone_Project_CREDO_01_5.PDF file in the same folder with README.MD

The CREDO Project uses  Hyperledger Fabric to manage user claims between users and organizations. Some of the user cases are:

1. As organizations, they can create user claims, so that other organization can verify
2. As users, they can sign claims submitted by an organization, so that the claims are ready for other orgnanzation to verify
3. As organizations, they can verify user claims that are submitted by other organizations

# Setup

Make sure the Docker/Docker-Compose, Go v1.10.x, Node.js 8.9.x are installed.

Run `bootstrap.sh` script to preload all of the requisite docker images for Hyperledger Fabric and the necessary tools.

```bash
./scripts/bootstrap.sh
```

Run 'byfn.sh' to setup the fabric infrastructure. It creates 2 organizations and each has 2 peers.

```bash
cd fabric
./byfn.sh up -c mychannel -l node
```

Note: To clean up the system, run: `./byfn.sh down`

## Chaincode

The chaincode are written in node.js and are located in the chaincode\credo\node folder.  

# Manage claims

To manage claims, create a bash session to the 'cli' container.

```bash
docker exec -it cli bash
```
There are some help shell scripts to help append, sign, verify and query claims. 

NOTE: Due to the limitation of arguments parsing, it will not allow the each argument to contain spaces inside.

## Append a new claim
### To create a new claim:

```bash
appendClaim <userID> <claimType> <claimValue> <submitOrganization> <expirationDate>
```

```bash
./scripts/appendClaim.sh "user2", "0", "1", "Northwest Hospital", "2020-10-30"
```

* userID: the claim userID
* claimType: type of claim

    0:TRANSCRIPT, 1:MASK_FITTING, 2:FLU_SHOT

* claimValue: value of the claim. It depends on the type of the claim
* submitOrganization: the name of the organization that submit this new claim
* expirationDate: the date the claim expires

### To sign claim

```bash
./scripts/signClaim.sh <userID> <claimType>
```

```bash
./scripts/signClaim.sh user2 1
```

* userID: the user ID that the claim belongs
* claimType: the type of claim

    0:TRANSCRIPT, 1:MASK_FITTING, 2:FLU_SHOT

### To verify claim

```bash
./scripts/verifyClaim.sh <userID> <claimType>
```

```bash
./scripts/verifyClaim.sh user2 1
```

* userID: the user ID of the claim the orgainization want to verify
* claimType: the type of claim

    0:TRANSCRIPT, 1:MASK_FITTING, 2:FLU_SHOT

### To query all claims
For testing purpose, run the following command to query all the claims.

```bash
./scripts/queryAllClaims.sh
```
