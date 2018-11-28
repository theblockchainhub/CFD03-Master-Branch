'use strict';

const shim = require('fabric-shim');
const util = require('util');

const ClaimType = {
	TRANSCRIPT : 0,
	MASK_FITTING : 1,
	FLU_SHOT: 2
}

const ClaimStatus = {
	SUBMITED: 0,			// Submitted by Authority, pending signature of user
	ACTIVE: 1,				// Signed by User, available for verify
	EXPIRED: 2				// Claim has expired
}

let Chaincode = class {

 async Init(stub) {
		console.info('=========== chaincode: Instantiated ===========');
		
    return shim.success();
  }

  async Invoke(stub) {
		console.info('=========== chaincode: Invoke ===========');

    let ret = stub.getFunctionAndParameters();
    console.info(ret);

    let method = this[ret.fcn];
    if (!method) {
      console.error('No function of name:' + ret.fcn + ' found');
      throw new Error('Received unknown function ' + ret.fcn + ' invocation');
    }

    try {
      let payload = await method(stub, ret.params);
      return shim.success(payload);
		} 
		catch (err) {
      console.log(err);
      return shim.error(err);
    }
  }

	async initLedger(stub, args) {
    console.info('============= START : Initialize Ledger ===========');

   	let claims = [];
   	claims.push({
			userID: "user1",
			type: ClaimType.MASK_FITTING,
			value: "1",
			issuingAuthority: "General Hospital",
			expDate: new Date("2018-10-30"),
			status: ClaimStatus.SUBMITED
	  });

    claims.push({
			userID: "user2",
			type: ClaimType.FLU_SHOT,
			value: "1",
			issuingAuthority: "Northwest Hospital",
			expDate: new Date("2018-10-30"),
			status: ClaimStatus.SUBMITED
    });

    for (let i = 0; i < claims.length; i++) {
			await stub.putState(claims[i].userID + '/' + claims[i].type, Buffer.from(JSON.stringify(claims[i])));
			console.log('Added claim', coffees[i]);
    }

    console.info('============= END : Initialize Ledger ===========');
  }

	// Call this method to verify a user claim
	async verifyClaim(stub, args){
		console.info('============= START : Verify Claim ===========');

		if (args.length != 2) {
		  throw new Error('Incorrect number of arguments. Expecting 2');
		}
		let claimID = args[0]+ "/" + args[1];
		console.log('claimID:' + claimID);
		let claimBytes = await stub.getState(claimID);
		console.log('claimBytes:' + claimBytes);
	  let claim = JSON.parse(claimBytes);

		var verifyStatus = {
			userID: args[0],
			type: parseInt(args[1]),
			verified: (claim.status == ClaimStatus.ACTIVE),
		};

		return Buffer.from(JSON.stringify(verifyStatus));

		console.info('============= End : Verify Claim ===========');

	}

	async signClaim(stub, args) {
		console.info('============= START : Sign Claim ===========');

		if (args.length != 2) {
		  throw new Error('Incorrect number of arguments. Expecting 2');
		}
		let claimID = args[0]+"/" + args[1];
		console.log('claimID:' + claimID);
		let claimBytes = await stub.getState(claimID);
		console.log('claimBytes:' + claimBytes);

	  let claim = JSON.parse(claimBytes);
	  claim.status = ClaimStatus.ACTIVE;

	  await stub.putState(claimID, Buffer.from(JSON.stringify(claim)));
		console.info('============= End : Sign Claim ===========');
	}

  async queryAllClaims(stub, args) {
    console.info('============= START : Query All claims ===========');

		let startKey = '';
		let endKey = '';
		let iterator = await stub.getStateByRange(startKey, endKey);
	
		let allResults = [];
		while(true){
			let res = await iterator.next();
			let jsonRes = {};
			if (res.value && res.value.value.toString()) {
				jsonRes.Key = res.value.key;
				try {
					jsonRes.Record = JSON.parse(res.value.value.toString('utf8'))
				}
				catch(err) {
					console.log(err);
					jsonRes.Record = res.value.value.toString('utf8');
				}			
			}
			allResults.push(jsonRes);
			if (res.done) {
				console.log('end of data from ledger');
				await iterator.close();
				console.log(allResults);
				return Buffer.from(JSON.stringify(allResults));
			}
		}

		console.info('============= END : Query All claims ===========');	
  }

  async queryZKPAllClaims(stub, args) {
    console.info('============= START : Query ZKP All claims ===========');

    // Using Args in Querry, ZKP criteria will be that the date of the claim is not displayed

	  var ZKPclaimResult = {
			userID: args[0],
			type: parseInt(args[1]),
			value: args[2],
			issuingAuthority: args[3],
		//	expDate: new Date(args[4]),
			status: ClaimStatus.SUBMITED
		};
		var claimID = args[0] + '/' + args[1];
		await stub.putState(claimID, Buffer.from(JSON.stringify(ZKPclaimResult)));
	} 

    // End of Args in Querry 
		let startKey = '';
		let endKey = '';
		let iterator = await stub.getStateByRange(startKey, endKey);
	
		let allResults = [];
		while(true){
			let res = await iterator.next();
			let jsonRes = {};
			if (res.value && res.value.value.toString()) {
				jsonRes.Key = res.value.key;
				try {
					jsonRes.Record = JSON.parse(res.value.value.toString('utf8'))
				}
				catch(err) {
					console.log(err);
					jsonRes.Record = res.value.value.toString('utf8');
				}			
			}
			allResults.push(jsonRes);
			if (res.done) {
				console.log('end of data from ledger');
                await iterator.close();
                // Display only ZKP Claims 
				console.log(allResults);
				return Buffer.from(JSON.stringify(allResults));
			}
		}

		console.info('============= END : Query ZKP All claims ===========');	
  }
	async appendClaim(stub, args) {
		console.info('============= START : Append Claim ===========');

		if (args.length != 5) {
			throw new Error('Incorrect number of arguments. Expecting 5');
		}

	  var claim = {
			userID: args[0],
			type: parseInt(args[1]),
			value: args[2],
			issuingAuthority: args[3],
			expDate: new Date(args[4]),
			status: ClaimStatus.SUBMITED
		};
		var claimID = args[0] + '/' + args[1];

		await stub.putState(claimID, Buffer.from(JSON.stringify(claim)));

		console.log('Appended claim', claim);

		console.info('============= END : Append Claim ===========');
	} 

};

shim.start(new Chaincode());
