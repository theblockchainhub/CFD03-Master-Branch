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
    console.log('=========== Init chaincode ===========');
    return shim.success();
  }

  // The Invoke method is called as a result of an application request to run the Smart Contract
  // 'fabcar'. The calling application program has also specified the particular smart contract
  // function to be called, with arguments
  async Invoke(stub) {
    console.log('============= Invoke chaincode =============');
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

    let diamonds = [];
    diamonds.push({
      colour: 'Pink',
      clarity: 'IF',
      countryOfOrigin: 'Australia',
      owner: 'Argyle Diamond Mine'
    });

    for (let i = 0; i < diamonds.length; i++) {
      diamonds[i].docType = 'diamond';
      await stub.putState('DIAMOND' + i, Buffer.from(JSON.stringify(diamonds[i])));
      console.info('Added <--> ', diamonds[i]);
    }
    console.log('============= END : Initialize Ledger ===========');
  }

  async mineDiamond(stub, args) {
    console.log('============= START : Mine Diamond ===========');
    if (args.length != 4) {
      throw new Error('Incorrect number of arguments. Expecting 4');
    }

    let startKey = 'DIAMOND0';
    let endKey = 'DIAMOND999';
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
        } catch (err) {
          console.log(err);
          jsonRes.Record = res.value.value.toString('utf8');
        }
        allResults.push(jsonRes);
      }
      if (res.done) {
        console.log('end of data');
        await iterator.close();

        let newDiamond = {
          docType: 'diamond',
          colour: args[0],
          clarity: args[1],
          countryOfOrigin: args[2],
          owner: args[3]
        };

        let index = allResults.length;
        await stub.putState('DIAMOND' + index, Buffer.from(JSON.stringify(newDiamond)));

        return Buffer.from(JSON.stringify(newDiamond));
      }
    }
  }
  
  async changeDiamondOwner(stub, args) {
    console.log('============= START : Change Diamond Owner ===========');
    if (args.length != 2) {
      throw new Error('Incorrect number of arguments. Expecting 2');
    }

    let diamondAsBytes = await stub.getState(args[0]);
    let diamond = JSON.parse(diamondAsBytes);
    diamond.owner = args[1];

    await stub.putState(args[0], Buffer.from(JSON.stringify(diamond)));
    console.log('============= END : Change Diamond Owner ===========');
  }

  async queryAllDiamonds(stub, args) {
    console.log('============= START : Query All Diamonds =============');
    let startKey = 'DIAMOND0';
    let endKey = 'DIAMOND999';
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

  async queryDiamond(stub, args) {
    if (args.length != 1) {
      throw new Error('Incorrect number of arguments. Expecting DiamondNumber ex: DIAMOND01');
    }
    let diamondNumber = args[0];
    let diamondAsBytes = await stub.getState(diamondNumber); //get the diamond from chaincode state
    if (!diamondAsBytes || diamondAsBytes.toString().length <= 0) {
      throw new Error(diamondNumber + ' does not exist: ');
    }
    console.log(diamondAsBytes.toString());
    return diamondAsBytes;
  }

};

shim.start(new Chaincode());