#!/bin/bash
# set -e

#CHANNEL_NAME="default"
PROJPATH=${PWD}
ARTIFPATH=$PROJPATH/artifacts
CHNPATH=$ARTIFPATH/channel-artifacts

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