#!/bin/bash
#set -e

export PATH=${PWD}/../bin:${PWD}:$PATH
export FABRIC_CFG_PATH=${PWD}
export VERBOSE=false

# ###############################################################################
# VARIABLES 
# ###############################################################################

PROJPATH=${PWD}
ARTIFPATH=$PROJPATH/artifacts
CHNPATH=$ARTIFPATH/channel-artifacts
CAPATH=$ARTIFPATH/crypto-config


GENESIS_PROFILE_NAME="OrdererGenesis"
GLOBAL_PROFILE_NAME="STJChannel"
TJSE_PROFILE_NAME="TJSEChannel"
TJBA_PROFILE_NAME="TJBAChannel"
TJSP_PROFILE_NAME="TJSPChannel"

GENESIS_CHANNEL_NAME="$(echo $GENESIS_PROFILE_NAME | tr '[A-Z]' '[a-z]')"
GLOBAL_CHANNEL_NAME="$(echo $GLOBAL_PROFILE_NAME | tr '[A-Z]' '[a-z]')"
TJSE_CHANNEL_NAME="$(echo $TJSE_PROFILE_NAME | tr '[A-Z]' '[a-z]')"
TJBA_CHANNEL_NAME="$(echo $TJBA_PROFILE_NAME | tr '[A-Z]' '[a-z]')"
TJSP_CHANNEL_NAME="$(echo $TJSP_PROFILE_NAME | tr '[A-Z]' '[a-z]')"


ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/smartsign.app/orderers/orderer.smartsign.app/msp/tlscacerts/tlsca.smartsign.app-cert.pem
PEER0_STJ_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/stj.smartsign.app/peers/peer0.stj.smartsign.app/tls/ca.crt
PEER0_TJSE_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/tjse.smartsign.app/peers/peer0.tj-se.smartsign.app/tls/ca.crt
PEER0_TJSP_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/tjsp.smartsign.app/peers/peer0.tj-sp.smartsign.app/tls/ca.crt
PEER0_TJBA_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/tjba.smartsign.app/peers/peer0.tj-ba.smartsign.app/tls/ca.crt

# ##############################################################################

# Ask user for confirmation to proceed
function askProceed() {
  read -p "Continue? [Y/n] " ans
  case "$ans" in
  y | Y | "")
    echo "proceeding ..."
    ;;
  n | N)
    echo "exiting..."
    exit 1
    ;;
  *)
    echo "invalid response"
    askProceed
    ;;
  esac
}

function networkUp() {

echo
echo "#################################################################"
echo "#######                  Start SmartSign               ##########"
echo "#################################################################"

    # delete all docker running
    docker rm -f $(docker ps -aq) 2>&1

    # delete all network
    docker network prune -f 2>&1

    # start smartsign network
    docker-compose -f docker-compose.yaml -f docker-compose-couch.yaml up -d
    #docker-compose -f docker-compose.yaml -f docker-compose-couch.yaml up
}

function networkDown() {

echo
echo "#################################################################"
echo "#######                  Stop SmartSign                ##########"
echo "#################################################################"

    # stop smartsign network
    docker-compose -f docker-compose.yaml -f docker-compose-couch.yaml down --volumes --remove-orphans 
    #docker-compose -f docker-compose.yaml down --volumes --remove-orphans 

    # clear networks
    docker network prune -f 2>&1
}

function startChannel(){

    DCK_ARTIFACTS=/opt/gopath/src/github.com/hyperledger/fabric/peer/channel-artifacts/

    # # Creating STJChannel as peer0.stj.smartsign.app cli default
    docker exec cli peer channel create -o orderer.smartsign.app:7050 -c $GLOBAL_CHANNEL_NAME -f $DCK_ARTIFACTS/${GLOBAL_CHANNEL_NAME}.tx --tls --cafile $ORDERER_CA
   
    sleep 20s

    # # Join the STJChannel as peer0.stj.smartsign.app cli default
    docker exec cli peer channel join -b ${GLOBAL_CHANNEL_NAME}.block --tls --cafile $ORDERER_CA

    # # Join the Channel STJChannel
    docker exec -e "CORE_PEER_LOCALMSPID=TJSEOrgMSP" -e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/tj-se.smartsign.app/peers/peer0.tj-se.smartsign.app/tls/ca.crt" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/tj-se.smartsign.app/users/Admin@tj-se.smartsign.app/msp" -e "CORE_PEER_ADDRESS=peer0.tj-se.smartsign.app:7051" cli peer channel join -b ${GLOBAL_CHANNEL_NAME}.block --tls --cafile $ORDERER_CA
    docker exec -e "CORE_PEER_LOCALMSPID=TJSPOrgMSP" -e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/tj-sp.smartsign.app/peers/peer0.tj-sp.smartsign.app/tls/ca.crt" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/tj-sp.smartsign.app/users/Admin@tj-sp.smartsign.app/msp" -e "CORE_PEER_ADDRESS=peer0.tj-sp.smartsign.app:7051" cli peer channel join -b ${GLOBAL_CHANNEL_NAME}.block --tls --cafile $ORDERER_CA
    docker exec -e "CORE_PEER_LOCALMSPID=TJBAOrgMSP" -e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/tj-ba.smartsign.app/peers/peer0.tj-ba.smartsign.app/tls/ca.crt" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/tj-ba.smartsign.app/users/Admin@tj-ba.smartsign.app/msp" -e "CORE_PEER_ADDRESS=peer0.tj-ba.smartsign.app:7051" cli peer channel join -b ${GLOBAL_CHANNEL_NAME}.block --tls --cafile $ORDERER_CA

    # # Update the Anchor Peers in Channel One
    docker exec cli peer channel update -o orderer.smartsign.app:7050 -c $GLOBAL_CHANNEL_NAME -f $DCK_ARTIFACTS/STJOrgMSPAnchors_${GLOBAL_CHANNEL_NAME}.tx --tls --cafile $ORDERER_CA    
    docker exec -e "CORE_PEER_LOCALMSPID=TJSEOrgMSP" -e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/tj-se.smartsign.app/peers/peer0.tj-se.smartsign.app/tls/ca.crt" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/tj-se.smartsign.app/users/Admin@tj-se.smartsign.app/msp" -e "CORE_PEER_ADDRESS=peer0.tj-se.smartsign.app:7051" cli peer channel update -o orderer.smartsign.app:7050 -c $GLOBAL_CHANNEL_NAME -f $DCK_ARTIFACTS/TJSEOrgMSPAnchors_${GLOBAL_CHANNEL_NAME}.tx --tls --cafile $ORDERER_CA
    docker exec -e "CORE_PEER_LOCALMSPID=TJSPOrgMSP" -e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/tj-sp.smartsign.app/peers/peer0.tj-sp.smartsign.app/tls/ca.crt" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/tj-sp.smartsign.app/users/Admin@tj-sp.smartsign.app/msp" -e "CORE_PEER_ADDRESS=peer0.tj-sp.smartsign.app:7051" cli peer channel update -o orderer.smartsign.app:7050 -c $GLOBAL_CHANNEL_NAME -f $DCK_ARTIFACTS/TJSPOrgMSPAnchors_${GLOBAL_CHANNEL_NAME}.tx --tls --cafile $ORDERER_CA
    docker exec -e "CORE_PEER_LOCALMSPID=TJBAOrgMSP" -e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/tj-ba.smartsign.app/peers/peer0.tj-ba.smartsign.app/tls/ca.crt" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/tj-ba.smartsign.app/users/Admin@tj-ba.smartsign.app/msp" -e "CORE_PEER_ADDRESS=peer0.tj-ba.smartsign.app:7051" cli peer channel update -o orderer.smartsign.app:7050 -c $GLOBAL_CHANNEL_NAME -f $DCK_ARTIFACTS/TJBAOrgMSPAnchors_${GLOBAL_CHANNEL_NAME}.tx --tls --cafile $ORDERER_CA
    
    # # Creating TJSEOrgMSP as peer1.tj-se.smartsign.app cli default #########################################
    docker exec -e "CORE_PEER_LOCALMSPID=TJSEOrgMSP" -e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/tj-se.smartsign.app/peers/peer1.tj-se.smartsign.app/tls/ca.crt" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/tj-se.smartsign.app/users/Admin@tj-se.smartsign.app/msp" -e "CORE_PEER_ADDRESS=peer1.tj-se.smartsign.app:7051" cli peer channel create -o orderer.smartsign.app:7050 -c $TJSE_CHANNEL_NAME -f $DCK_ARTIFACTS/${TJSE_CHANNEL_NAME}.tx --tls --cafile $ORDERER_CA

    sleep 20s

    # # Join the STJChannel as peer0.stj.smartsign.app cli default
    docker exec -e "CORE_PEER_LOCALMSPID=TJSEOrgMSP" -e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/tj-se.smartsign.app/peers/peer1.tj-se.smartsign.app/tls/ca.crt" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/tj-se.smartsign.app/users/Admin@tj-se.smartsign.app/msp" -e "CORE_PEER_ADDRESS=peer1.tj-se.smartsign.app:7051" cli peer channel join -b ${TJSE_CHANNEL_NAME}.block --tls --cafile $ORDERER_CA

    # # Join the Channel STJChannel
    docker exec -e "CORE_PEER_LOCALMSPID=TJSEOrgMSP" -e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/tj-se.smartsign.app/peers/peer0.tj-se.smartsign.app/tls/ca.crt" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/tj-se.smartsign.app/users/Admin@tj-se.smartsign.app/msp" -e "CORE_PEER_ADDRESS=peer0.tj-se.smartsign.app:7051" cli peer channel join -b ${TJSE_CHANNEL_NAME}.block --tls --cafile $ORDERER_CA
    docker exec cli peer channel join -b ${TJSE_CHANNEL_NAME}.block --tls --cafile $ORDERER_CA

    # # Update the Anchor Peers in Channel One
    docker exec cli peer channel update -o orderer.smartsign.app:7050 -c $TJSE_CHANNEL_NAME -f $DCK_ARTIFACTS/STJOrgMSPAnchors_${TJSE_CHANNEL_NAME}.tx --tls --cafile $ORDERER_CA    
    docker exec -e "CORE_PEER_LOCALMSPID=TJSEOrgMSP" -e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/tj-se.smartsign.app/peers/peer0.tj-se.smartsign.app/tls/ca.crt" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/tj-se.smartsign.app/users/Admin@tj-se.smartsign.app/msp" -e "CORE_PEER_ADDRESS=peer0.tj-se.smartsign.app:7051" cli peer channel update -o orderer.smartsign.app:7050 -c $TJSE_CHANNEL_NAME -f $DCK_ARTIFACTS/TJSEOrgMSPAnchors_${TJSE_CHANNEL_NAME}.tx --tls --cafile $ORDERER_CA

    # # Creating TJBAOrgMSP as peer1.tj-ba.smartsign.app cli default #########################################
    docker exec -e "CORE_PEER_LOCALMSPID=TJBAOrgMSP" -e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/tj-ba.smartsign.app/peers/peer1.tj-ba.smartsign.app/tls/ca.crt" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/tj-ba.smartsign.app/users/Admin@tj-ba.smartsign.app/msp" -e "CORE_PEER_ADDRESS=peer1.tj-ba.smartsign.app:7051" cli peer channel create -o orderer.smartsign.app:7050 -c $TJBA_CHANNEL_NAME -f $DCK_ARTIFACTS/${TJBA_CHANNEL_NAME}.tx --tls --cafile $ORDERER_CA

    sleep 20s

    # # Join the STJChannel as peer0.stj.smartsign.app cli default
    docker exec -e "CORE_PEER_LOCALMSPID=TJBAOrgMSP" -e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/tj-ba.smartsign.app/peers/peer1.tj-ba.smartsign.app/tls/ca.crt" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/tj-ba.smartsign.app/users/Admin@tj-ba.smartsign.app/msp" -e "CORE_PEER_ADDRESS=peer1.tj-ba.smartsign.app:7051" cli peer channel join -b ${TJBA_CHANNEL_NAME}.block --tls --cafile $ORDERER_CA

    # # Join the Channel STJChannel
    docker exec -e "CORE_PEER_LOCALMSPID=TJBAOrgMSP" -e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/tj-ba.smartsign.app/peers/peer0.tj-ba.smartsign.app/tls/ca.crt" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/tj-ba.smartsign.app/users/Admin@tj-ba.smartsign.app/msp" -e "CORE_PEER_ADDRESS=peer0.tj-ba.smartsign.app:7051" cli peer channel join -b ${TJBA_CHANNEL_NAME}.block --tls --cafile $ORDERER_CA
    docker exec cli peer channel join -b ${TJBA_CHANNEL_NAME}.block --tls --cafile $ORDERER_CA

    # # Update the Anchor Peers in Channel One
    docker exec cli peer channel update -o orderer.smartsign.app:7050 -c $TJBA_CHANNEL_NAME -f $DCK_ARTIFACTS/STJOrgMSPAnchors_${TJBA_CHANNEL_NAME}.tx --tls --cafile $ORDERER_CA    
    docker exec -e "CORE_PEER_LOCALMSPID=TJBAOrgMSP" -e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/tj-ba.smartsign.app/peers/peer0.tj-ba.smartsign.app/tls/ca.crt" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/tj-ba.smartsign.app/users/Admin@tj-ba.smartsign.app/msp" -e "CORE_PEER_ADDRESS=peer0.tj-ba.smartsign.app:7051" cli peer channel update -o orderer.smartsign.app:7050 -c $TJBA_CHANNEL_NAME -f $DCK_ARTIFACTS/TJBAOrgMSPAnchors_${TJBA_CHANNEL_NAME}.tx --tls --cafile $ORDERER_CA

    # # Creating TJSPOrgMSP as peer1.tj-sp.smartsign.app cli default ########################################
    docker exec -e "CORE_PEER_LOCALMSPID=TJSPOrgMSP" -e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/tj-sp.smartsign.app/peers/peer1.tj-sp.smartsign.app/tls/ca.crt" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/tj-sp.smartsign.app/users/Admin@tj-sp.smartsign.app/msp" -e "CORE_PEER_ADDRESS=peer1.tj-sp.smartsign.app:7051" cli peer channel create -o orderer.smartsign.app:7050 -c $TJSP_CHANNEL_NAME -f $DCK_ARTIFACTS/${TJSP_CHANNEL_NAME}.tx --tls --cafile $ORDERER_CA

    sleep 20s

    # # Join the STJChannel as peer0.stj.smartsign.app cli default
    docker exec -e "CORE_PEER_LOCALMSPID=TJSPOrgMSP" -e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/tj-sp.smartsign.app/peers/peer1.tj-sp.smartsign.app/tls/ca.crt" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/tj-sp.smartsign.app/users/Admin@tj-sp.smartsign.app/msp" -e "CORE_PEER_ADDRESS=peer1.tj-sp.smartsign.app:7051" cli peer channel join -b ${TJSP_CHANNEL_NAME}.block --tls --cafile $ORDERER_CA

    # # Join the Channel STJChannel
    docker exec -e "CORE_PEER_LOCALMSPID=TJSPOrgMSP" -e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/tj-sp.smartsign.app/peers/peer0.tj-sp.smartsign.app/tls/ca.crt" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/tj-sp.smartsign.app/users/Admin@tj-sp.smartsign.app/msp" -e "CORE_PEER_ADDRESS=peer0.tj-sp.smartsign.app:7051" cli peer channel join -b ${TJSP_CHANNEL_NAME}.block --tls --cafile $ORDERER_CA
    docker exec cli peer channel join -b ${TJSP_CHANNEL_NAME}.block --tls --cafile $ORDERER_CA

    # # Update the Anchor Peers in Channel One
    docker exec cli peer channel update -o orderer.smartsign.app:7050 -c $TJSP_CHANNEL_NAME -f $DCK_ARTIFACTS/STJOrgMSPAnchors_${TJSP_CHANNEL_NAME}.tx --tls --cafile $ORDERER_CA    
    docker exec -e "CORE_PEER_LOCALMSPID=TJSPOrgMSP" -e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/tj-sp.smartsign.app/peers/peer0.tj-sp.smartsign.app/tls/ca.crt" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/tj-sp.smartsign.app/users/Admin@tj-sp.smartsign.app/msp" -e "CORE_PEER_ADDRESS=peer0.tj-sp.smartsign.app:7051" cli peer channel update -o orderer.smartsign.app:7050 -c $TJSP_CHANNEL_NAME -f $DCK_ARTIFACTS/TJSPOrgMSPAnchors_${TJSP_CHANNEL_NAME}.tx --tls --cafile $ORDERER_CA

}

function generateCa {

    echo "This process will delete all certificate there are in Hyperledger. Would you like to contninue this process?"
    askProceed

    echo
    echo "#################################################################"
    echo "#######        Generating cryptographic material       ##########"
    echo "#################################################################"

    # remove all certificates
    rm -rf $CAPATH

    cryptogen generate --config=$ARTIFPATH/crypto-config.yaml --output=$CAPATH
}

function createChannel(){

    # Create new channel 

    mkdir -p $CHNPATH

    echo
    echo "##########################################################"
    echo "#########  Generating Orderer Genesis block ##############"
    echo "##########################################################"
    configtxgen -configPath $ARTIFPATH -profile $GENESIS_PROFILE_NAME -outputBlock $CHNPATH/genesis.block -channelID $GENESIS_CHANNEL_NAME

    echo
    echo "#################################################################"
    echo "### Generating channel configuration transaction 'channel.tx' ###"
    echo "#################################################################"
    configtxgen -configPath $ARTIFPATH -profile $GLOBAL_PROFILE_NAME -outputCreateChannelTx $CHNPATH/$GLOBAL_CHANNEL_NAME.tx -channelID $GLOBAL_CHANNEL_NAME
    configtxgen -configPath $ARTIFPATH -profile $TJSE_PROFILE_NAME -outputCreateChannelTx $CHNPATH/$TJSE_CHANNEL_NAME.tx -channelID $TJSE_CHANNEL_NAME
    configtxgen -configPath $ARTIFPATH -profile $TJBA_PROFILE_NAME -outputCreateChannelTx $CHNPATH/$TJBA_CHANNEL_NAME.tx -channelID $TJBA_CHANNEL_NAME
    configtxgen -configPath $ARTIFPATH -profile $TJSP_PROFILE_NAME -outputCreateChannelTx $CHNPATH/$TJSP_CHANNEL_NAME.tx -channelID $TJSP_CHANNEL_NAME

    #cp $CLIPATH/channel.tx $PROJPATH/web
    echo
    echo "#################################################################"
    echo "####### Generating anchor peer update for STJOrgMSP ##########"
    echo "#################################################################"
    configtxgen -configPath $ARTIFPATH -profile $GLOBAL_PROFILE_NAME -outputAnchorPeersUpdate $CHNPATH/STJOrgMSPAnchors_$GLOBAL_CHANNEL_NAME.tx -channelID $GLOBAL_CHANNEL_NAME -asOrg STJOrgMSP
    configtxgen -configPath $ARTIFPATH -profile $TJSE_PROFILE_NAME -outputAnchorPeersUpdate $CHNPATH/STJOrgMSPAnchors_$TJSE_CHANNEL_NAME.tx -channelID $TJSE_CHANNEL_NAME -asOrg STJOrgMSP
    configtxgen -configPath $ARTIFPATH -profile $TJBA_PROFILE_NAME -outputAnchorPeersUpdate $CHNPATH/STJOrgMSPAnchors_$TJBA_CHANNEL_NAME.tx -channelID $TJBA_CHANNEL_NAME -asOrg STJOrgMSP
    configtxgen -configPath $ARTIFPATH -profile $TJSP_PROFILE_NAME -outputAnchorPeersUpdate $CHNPATH/STJOrgMSPAnchors_$TJSP_CHANNEL_NAME.tx -channelID $TJSP_CHANNEL_NAME -asOrg STJOrgMSP

    echo
    echo "#################################################################"
    echo "#######    Generating anchor peer update for TJSEOrgMSP   ##########"
    echo "#################################################################"
    configtxgen -configPath $ARTIFPATH -profile $GLOBAL_PROFILE_NAME -outputAnchorPeersUpdate $CHNPATH/TJSEOrgMSPAnchors_$GLOBAL_CHANNEL_NAME.tx -channelID $GLOBAL_CHANNEL_NAME -asOrg TJSEOrgMSP
    configtxgen -configPath $ARTIFPATH -profile $TJSE_PROFILE_NAME -outputAnchorPeersUpdate $CHNPATH/TJSEOrgMSPAnchors_$TJSE_CHANNEL_NAME.tx -channelID $TJSE_CHANNEL_NAME -asOrg TJSEOrgMSP

    echo
    echo "##################################################################"
    echo "####### Generating anchor peer update for TJSPOrgMSP ##########"
    echo "##################################################################"
    configtxgen -configPath $ARTIFPATH -profile $GLOBAL_PROFILE_NAME -outputAnchorPeersUpdate $CHNPATH/TJSPOrgMSPAnchors_$GLOBAL_CHANNEL_NAME.tx -channelID $GLOBAL_CHANNEL_NAME -asOrg TJSPOrgMSP
    configtxgen -configPath $ARTIFPATH -profile $TJSP_PROFILE_NAME -outputAnchorPeersUpdate $CHNPATH/TJSPOrgMSPAnchors_$TJSP_CHANNEL_NAME.tx -channelID $TJSP_CHANNEL_NAME -asOrg TJSPOrgMSP

    echo
    echo "##################################################################"
    echo "#######   Generating anchor peer update for TJBAOrgMSP   ##########"
    echo "##################################################################"
    configtxgen -configPath $ARTIFPATH -profile $GLOBAL_PROFILE_NAME -outputAnchorPeersUpdate $CHNPATH/TJBAOrgMSPAnchors_$GLOBAL_CHANNEL_NAME.tx -channelID $GLOBAL_CHANNEL_NAME -asOrg TJBAOrgMSP
    configtxgen -configPath $ARTIFPATH -profile $TJBA_PROFILE_NAME -outputAnchorPeersUpdate $CHNPATH/TJBAOrgMSPAnchors_$TJBA_CHANNEL_NAME.tx -channelID $TJBA_CHANNEL_NAME -asOrg TJBAOrgMSP

}

case $1 in
   "up") 
        networkUp
        ;;
   "down") 
        networkDown
        ;;
    "startCH")
        startChannel
        ;;
   "generateTX") 
        createChannel
        ;;
   "generateCA") 
        generateCa
        ;;
   *) echo "Invalid argument!"
      exit 1
      ;;
esac
