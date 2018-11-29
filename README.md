# Use Case
This hyperledger fabric application serves as a POC for the ethical trade of diamonds. By ensuring only those with permission (i.e. legal diamond mining, cutting, and retail entities) are able to transact on the blockchain network increases transparency into the origins of the diamonds. As consumers are becoming increasingly aware of issues surrounding conflict diamonds, this application would give reassurance that certified diamonds are ethically sourced and produced.

# Set up the environment (optional)
If required, run the following commands to tear down any existing networks, kill any stale or active containers, clear any cached networks, and delete any underlying chaincode image:

`./byfn.sh down`

`docker rm -f $(docker ps -aq)`

`docker network prune`

`docker rmi dev-peer0.org1.example.com-fabcar-1.0-5c906e402ed29f20260ae42283216aa75549c571e2e380f3615826365d8269ba`

# Install the clients & launch the network
From fabric-samples/fabcar run the following commands to launch the network and smart contract container for chaincode written in node:

`./startFarbic.sh node`

`npm install`

# Enrolling the Admin User
Send an enroll call to the CA server and retrieve the enrollment certificate (created on network launch) for the admin user:

`node enrollAdmin.js`

# Register & Enroll
Send the register and enroll call for a new user (user1):

`node registerUser.js`

# Interacting with the Ledger
The following functions query, write, and update data on the ledger using the second identity (user1) as the signing entity:

To query all diamonds on the ledger:

`node queryDiamonds.js`

To query a specific diamond on the ledger (this script takes a diamond key as an argument):

`node queryDiamond.js DIAMOND3`

To mine (create) a diamond on the ledger (this script takes the colour, clarity, country of origin, and owner/mining company as arguments)

`node mineDiamond.js Yellow SI Russia Mirny_Mine`

To transact a diamond (change owners) on the ledger (this script takes the diamond key and new owner as arguments)

`node transactDiamond.js DIAMOND2 John_Doe`
