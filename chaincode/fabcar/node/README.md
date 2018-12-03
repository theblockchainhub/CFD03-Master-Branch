

#Functions Breakdown
-----
### InitLedger

Adds 4 merchants to the ledger. Each merchant has a key (iterated from 0->3) and 5 fields. Fields are as follows: names (name of merchant), money (amount of money merchant possesses), fruitType (the fruit that the merchant sells), fruitAmount(amount of the fruit which is held by the merchant), fruitPrice (the current market valuation of the price of the fruit), and initial amount (initial amount of fruit possessed  used later for re-valuation of fruit).


-----

## Query

### queryMerchant
#Arguments: 1 /
Argument Type: Merchant key 

Allows one key argument to be passed in (e.g. ‘MERCHANT1’) 
Gets state for merchant and ensures that state is not blank, then returns state value. 

### queryMerchantByName
#Arguments: 1 /
Argument Type : Merchant.names value 

Allows one value argument to be passed in, which will be name value (e.g. ‘Hank’)
Loops through all states to see how many valid states exist in ledger currently (see queryAllMerchants). 
During loop compares name argument to name value of Merchant from JSON-parsed format. 
If the name value matches, then returns the merchant corresponding to current merchant key.

### queryAllMerchants
#Arguments: 0

Iterates through all Merchant keys, parses the values of each, adds to new JSON and pushes them to an array ‘allResults’. The array is converted to Buffer and returned. 

-----
## Invoke 

### addNewMerchant
#Arguments: 5 /
Argument Type: Merchant.names value,  Merchant.money value, Merchant.fruitType value, Merchant.fruitAmount value, Merchant.fruitPrice value

Loops through all iterations of valid merchant states and adds them to list of total merchants. The length of the list is then appended to string ‘MERCHANT’ which is used as a key for the values of the merchant passed in as arguments.

### sellOneFruit
#Arguments: 1 /
Argument Type : Merchant key

Gets merchant state from passed in key and parses into JSON format. Checks if merchant has enough fruit to sell, otherwise throws error. If fruit quantity is sufficient, removes 1 from fruitAmount and adds to money based on value of fruit sold.  If the amount of fruit reaches half of initialAmount, then initialAmount changes to current fruitAmount and fruitPrice increases by 1. This last functionality is to model the addition of value to resources as they become scarce in the marketplace.

### sellMultipleFruits
#Arguments: 2 /
Argument Type: Merchant key, amount of fruit to be sold 

Similar to sellOneFruit, obtains merchant state and parses into JSON. After checking for sufficient quantity, subtracts from fruitAmount the argument of fruit sold. Adds to money the product of fruitPrice and amount sold. After transaction, checks if fruitAmount falls beneath half of initialAmount. If so, changes initialAmount to fruitAmount and adds 1 to fruitPrice.

###  changeStallOwner
#Arguments: 2 /
Argument Type: Merchant key, name of new stall owner

Gets state of merchant based on key and changes Merchant.names value to what name argument is passed in along with key.
