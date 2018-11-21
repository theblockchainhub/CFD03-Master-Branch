# CFD03 Project - Smartsign

Smartsign is a small prototype for the issuance of stamps of digital authenticity issued by the state Courts of Justice to be used in the notaries to guarantee the authenticity of documents. This project has no connection with the governmental organizations cited here, restricting only as a case study for learning Hyperledger technology.

## Team Builder
Paulo Corcino

## Network Diagram
<span style="display:block;text-align:center">![Network Diagram](/smartsign/images/network.png)</span>
* Generate Certificates for peers
* Build Docker images for network
* Start the Smartsign network

## Prerequisites

* [Docker](https://www.docker.com/products/overview) - v1.13 or higher
* [Docker Compose](https://docs.docker.com/compose/overview/) - v1.8 or higher
* [NPM](https://www.npmjs.com/get-npm) - v5.6.0 or higher
* [nvm]() - v8.11.3 (use to download and set what node version you are using)
* [Node.js](https://nodejs.org/en/download/) - node v8.11.3 ** don't install in SUDO mode
* [Git client](https://git-scm.com/downloads) - v 2.9.x or higher

## Setup

1. Download Hyperledger fabric-sample

```
curl -sSL https://goo.gl/6wtTN5 | bash -s 1.3.0
```
This will create a bin folder in the current location, which contains the tools for the corresponding operations.

After that download all files for use the Hyperledger, acesse the new folder.

```
cd fabric-samples/
```

```
git clone -b Group-PauloCorcino --single-branch https://github.com/theblockchainhub/CFD03-Master-Branch.git tmp
mv ./tmp/smartsign ./smartsign
rm -rf tmp
cd smartsign/
```

Create certificate

```
./netup.sh generateCA
```

Create Channel Files

```
./netup.sh generateTX
```

 Start Network

```
./netup.sh up
```

 Start Channel 

```
./netup.sh startCH
```

  Stop Network

```
./netup.sh down
```

## Chaincode
In develepoment...

## Webservices
In develepoment...



