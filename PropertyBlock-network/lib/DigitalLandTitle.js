/*
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/* global getAssetRegistry */

'use strict';
/**
 * Process a property that is held for sale
 * @param {net.biz.digitalPropertyNetwork.RegisterPropertyForSale} propertyForSale the property to be sold
 * @transaction
 */
 
// Function to register a new property on the network.
async function RegisterNewProperty(newProperty){
	// Function changes the value of propertyList key of the SalesAgreement asset.
	// Which is essentially stores a properties on network for sale. 
    SalesAgreement.propertyList.push(newProperty);
    console.log('### New property added ###');
}
// Function puts new property for sale on the network.
async function onRegisterPropertyForSale(propertyForSale) {   // eslint-disable-line no-unused-vars
    console.log('### onRegisterPropertyForSale ' + propertyForSale.toString());
	// Change in the asset state.
    propertyForSale.title.forSale = true;
     
    const registry = await getAssetRegistry('net.biz.digitalPropertyNetwork.LandTitle');
    await registry.update(propertyForSale.title);
}

// Function to transfer the ownership of property.
async function makeAgreement(property,owner,newOwner){
	// Change in asset state.
  RegisterPropertyForSale.seller=owner;
  RegisterPropertyForSale.title=property; 
  console.log('### '+RegisterPropertyForSale.title.toString()+' from owner '+RegisterPropertyForSale.person.toString()+' ###');
  SalesAgreement.LandTitle=property;
  // Ownership transfered.
  SalesAgreement.buyer=newOwner;
  SalesAgreement.seller=owner;
}
// Function to add the info to the LanTitle information asset.
async function addInfo(info){
  LandTitle.info=info;
}

// Function loops through all theproperties registered on the network and refrain it from getting sold on the network identified by propertyId.
async function blocklistProperty(propertyId){
  for(var i=0;i<SalesAgreement.propertyList.length;i++){
    if(SalesAgreement.propertyList[i].titleId===propertyId){
		// Change in asset state.
      SalesAgreement.propertyList[i].blacklisted=true;
      BlockedProperty.title=SalesAgreement.propertyList[i].title;
      BlockedProperty.title=SalesAgreement.propertyList[i].title;
    }
  }
  console.log('### Property '+propertyId+' blacklisted ###');
}
// Function loops through all the properties registered on the network and allows it to sale on the network identified by propertyId.
async function unblocklistProperty(propertyId){
  for(var i=0;i<SalesAgreement.propertyList.length;i++){
    if(SalesAgreement.propertyList[i].titleId===propertyId){
      SalesAgreement.propertyList[i].blacklisted=false; 
      UnBlockedProperty.title=SalesAgreement.propertyList[i].title;
    }
  }
  console.log('### Property '+propertyId+' blacklisted ###');
}

