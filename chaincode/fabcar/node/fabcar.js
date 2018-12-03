/*
# Copyright IBM Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
*/

'use strict';
const shim = require('fabric-shim');
const util = require('util');

let Chaincode = class {

  // The Init method is called when the Smart Contract 'fabcar' is instantiated by the blockchain network
  // Best practice is to have any Ledger initialization in separate function -- see initLedger()
  async Init(stub) {
    console.info('=========== Instantiated fabcar chaincode ===========');
    return shim.success();
  }

  // The Invoke method is called as a result of an application request to run the Smart Contract
  // 'fabcar'. The calling application program has also specified the particular smart contract
  // function to be called, with arguments
  async Invoke(stub) {
    let ret = stub.getFunctionAndParameters();
    console.info(ret);

    let method = this[ret.fcn];
    if (!method) {
      console.error('no function of name:' + ret.fcn + ' found');
      throw new Error('Received unknown function ' + ret.fcn + ' invocation');
    }
    try {
      let payload = await method(stub, ret.params);
      return shim.success(payload);
    } catch (err) {
      console.log(err);
      return shim.error(err);
    }
  }

  async initLedger(stub, args) {
    console.info('============= START : Initialize Ledger ===========');
    let merchants = [];
    merchants.push({
      names: 'Brock',
      money: '80',
      fruitType: 'Apples',
      fruitAmount: '36',
      fruitPrice: '5', 
      initialAmount: '36'
    });
    merchants.push({
      names: 'Hank',
      money: '51',
      fruitType: 'Cherries',
      fruitAmount: '104',
      fruitPrice: '2', 
      initialAmount: '104'
    });
    merchants.push({
      names: 'Dean',
      money: '23',
      fruitType: 'Lemons',
      fruitAmount: '4',
      fruitPrice: '4',
      initialAmount: '4'
    });
    merchants.push({
      names: 'Doc',
      money: '2',
      fruitType: 'Bananas',
      fruitAmount: '24',
      fruitPrice : '8',
      initialAmount: '24'
    });

    for (let i = 0; i < merchants.length; i++) {
      merchants[i].docType = 'merchant';
      await stub.putState('MERCHANT' + i, Buffer.from(JSON.stringify(merchants[i])));
      console.info('Added <--> ', merchants[i]);
    }
    console.info('============= END : Initialize Ledger ===========');
  }


//----------------------START OF QUERY CODE-----------------//
  async queryMerchant(stub, args) {
    if (args.length != 1) {
      throw new Error ('Incorrect number of arguments. Expecting Merchant # ex: MERCHANT01');
    }
    let merchantNumber = args[0];

    let merchantAsBytes = await stub.getState(merchantNumber); //get the merchant from chaincode state
    if (!merchantAsBytes || merchantAsBytes.toString().length <=0){
      throw new Error (merchantNumber + ' does not exist ');
    }
    console.log(merchantAsBytes.toString());
    return merchantAsBytes;
  }

    async queryAllMerchants(stub, args) {

    let startKey = 'MERCHANT0';
    let endKey = 'MERCHANT999';

    let iterator = await stub.getStateByRange(startKey, endKey);

    let allResults = [];
    while (true) {
      let res = await iterator.next();

      if (res.value && res.value.value.toString()) {
        let jsonRes = {};
        console.log(res.value.value.toString('utf8'));

        jsonRes.Key = res.value.key;
        try {
          jsonRes.Record = JSON.parse(res.value.value.toString('utf8'));
          jsonRes.Record = JSON.parse(res.value.value);
        } catch (err) {
          console.log(err);
          jsonRes.Record = res.value.value.toString('utf8');
        }
        allResults.push(jsonRes);
      }
      if (res.done) {
        console.log('end of data');
        await iterator.close();
        console.info(allResults);
        return Buffer.from(JSON.stringify(allResults));
      }
    }
  }

  async queryMerchantByName (stub, args){
    if (args.length != 1) {
      throw new Error ('Incorrect number of arguments. Expecting Merchant name ex: "Hank"');
    }
    let merchantName = args[0];
    let realMerchN;
    let merchantNum;
    let merchantAsBytes;
    let merchant;
    let iterator = await stub.getStateByRange('MERCHANT0', 'MERCHANT999');

    let allResults = [];
    while (true) {
      let res = await iterator.next();

      if (res.value && res.value.value.toString()) {
        let jsonRes = {};
        jsonRes.Key = res.value.key;
        allResults.push(jsonRes);
      }
      if (res.done) {
        await iterator.close();
       let totalMerchants = allResults.length;
    }

    for (var i=0; i<totalMerchants; i++){
      merchantNum = "MERCHANT" + String(i);
      merchantAsBytes = await stub.getState(merchantNum);
      merchant = JSON.parse(merchantAsBytes);

      if (merchant.names == merchantName){
        realMerchN = merchantNum;
      }
    }

    let realMerchant = await stub.getState(realMerchN);
    if (!realMerchant || realMerchant.toString().length <=0){
      throw new Error (realMerchN + ' does not exist ');
    }

    console.log(realMerchant.toString());
    return realMerchant;
  }
}

  
//--------------END OF QUERY CODE--------------------------//



//---------------------START OF INVOKE CODE--------------------//
  async addNewMerchant(stub, args) {
    console.info('============= START : START OF ADD MERCHANT ===========');
    if (args.length != 5) {
      throw new Error('Incorrect number of arguments. Expecting 5');
    }

    let iterator = await stub.getStateByRange('MERCHANT0', 'MERCHANT999');

    let allResults = [];
    while (true) {
      let res = await iterator.next();

      if (res.value && res.value.value.toString()) {
        let jsonRes = {};
        console.log(res.value.value.toString('utf8'));

        jsonRes.Key = res.value.key;
        try {
          jsonRes.Record = JSON.parse(res.value.value.toString('utf8'));
        } catch (err) {
          console.log(err);
          jsonRes.Record = res.value.value.toString('utf8');
        }
        allResults.push(jsonRes);
      }
      if (res.done) {
        await iterator.close();

        var merchant = {
          docType: 'merchants',
          names: args[0],
          money: args[1],
          fruitType: args[2],
          fruitAmount: args[3],
          fruitPrice: args[4], 
          initialAmount: args[3]
       };

       let totalMerchants = allResults.length;
       await stub.putState('MERCHANT' + totalMerchants, Buffer.from(JSON.stringify(merchant)));
       console.info('============= END : Create Merchant ===========');
      }
    }
  }

  async sellOneFruit(stub, args) {
    console.info('============= START : sellOneFruit ===========');
    if (args.length != 1) {
       throw new Error('Incorrect number of arguments. Expecting 1');
    }

    let merchantAsBytes = await stub.getState(args[0]);
    let merchant = JSON.parse(merchantAsBytes);

    if (merchant.fruitAmount == "0"){
        throw new Error ("Cannot sell fruit. 0 Fruit owned");
    }
    else{
      merchant.fruitAmount = String(parseInt(merchant.fruitAmount) -1);
      merchant.money = String(parseInt(merchant.money) + parseInt(merchant.fruitPrice));
    }

    if (parseInt(merchant.initialAmount) - parseInt(merchant.fruitAmount) == 0.5*parseInt(merchant.initialAmount)){
      merchant.initialAmount = String(parseInt(merchant.fruitAmount));
      merchant.fruitPrice = String(parseInt(merchant.fruitPrice) + 1);
    }

    await stub.putState(args[0], Buffer.from(JSON.stringify(merchant)));
    console.info('============= END : sellOneFruit ===========');
  }

  async sellMultipleFruits(stub, args) {
    console.info('============= START : sellMultipleFruits ===========');
    if (args.length != 2) {
       throw new Error('Incorrect number of arguments. Expecting 2');
    }

    let merchantAsBytes = await stub.getState(args[0]);
    let merchant = JSON.parse(merchantAsBytes);

    let numberSold = args[1];

    if (merchant.fruitAmount <= String(numbersold-1)){
        throw new Error ("Cannot sell this amount of fruit. Not enough fruit owned.");
    }
    else{
      merchant.fruitAmount = String(parseInt(merchant.fruitAmount) -numberSold);
      merchant.money = String(parseInt(merchant.money) + (parseInt(merchant.fruitPrice)*numberSold));
    }

    if (parseInt(merchant.initialAmount) - parseInt(merchant.fruitAmount) < 0.5* parseInt(merchant.initialAmount)){
      merchant.initialAmount = String(parseInt(merchant.fruitAmount));
      merchant.fruitPrice = String(parseInt(merchant.fruitPrice) + 1);
    }

    await stub.putState(args[0], Buffer.from(JSON.stringify(merchant)));
    console.info('============= END : sellMultipleFruits ===========');
  }  

  async changeStallOwner(stub, args){

    console.info('============= START : changeCarOwner ===========');
    if (args.length != 2) {
      throw new Error('Incorrect number of arguments. Expecting 2');
    }

    let merchantAsBytes = await stub.getState(args[0]);
    let merchant = JSON.parse(merchantAsBytes);
    merchant.names = args[1];
   
    await stub.putState(args[0], Buffer.from(JSON.stringify(merchant)));
    console.info('============= END : changeCarOwner ===========');

  }

  //-----------------End of Invoke Code ---------------------//

};

shim.start(new Chaincode());
