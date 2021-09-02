require('dotenv').config()
const Web3 = require('web3')
const ethers = require('ethers')

const tokenABI = require('./PledgeToken.json')
const tokenAddress = '0xAFF09f554936ce8B2fE5Cd179CfC0AeCae386356'

const gasLimit = "0x4C4B40"
const gasPrice = "0x4A817C800"

var web3
var tokenContract

async function initializeWeb3(endpoint) {
  web3 = new Web3(endpoint)

  let acc = web3.eth.accounts.privateKeyToAccount(process.env.OWNER_KEY)
  web3.eth.accounts.wallet.add(acc)

  acc = web3.eth.accounts.privateKeyToAccount(process.env.TEST_KEY1)
  web3.eth.accounts.wallet.add(acc)

  acc = web3.eth.accounts.privateKeyToAccount(process.env.TEST_KEY2)
  web3.eth.accounts.wallet.add(acc)
}

async function initializeContract() {
  tokenContract = new web3.eth.Contract(tokenABI.abi, tokenAddress)
}

async function approve(spender, amount, opts) {
  await tokenContract.methods.approve(spender, amount).send(opts).on(
    'receipt', function(receipt) {
      console.log('Approve successful')
    }
  ).on(
    'error', function(error, receipt) {
      console.log('Approve failed')
    }
  )
}

async function mint(amount, opts) {
  await tokenContract.methods.mint(amount).send(opts).on(
    'receipt', function(receipt) {
      console.log('Mint successful')
    }
  ).on(
    'error', function(error, receipt) {
      console.log('Mint failed')
      console.log(error)
    }
  )
}

async function burn(amount, opts) {
  await tokenContract.methods.burn(amount).send(opts).on(
    'receipt', function(receipt) {
      console.log('Burn successful')
    }
  ).on(
    'error', function(error, receipt) {
      console.log('Burn failed')
      console.log(error)
    }
  )
}

async function transfer(to, amount, opts) {
  await tokenContract.methods.transfer(to, amount).send(opts).on(
    'receipt', function(receipt) {
      console.log('Transfer successful')
    }
  ).on(
    'error', function(error, receipt) {
      console.log('Transfer failed')
      console.log(error)
    }
  )
}

async function transferFrom(to, from, amount, opts) {
  await tokenContract.methods.transferFrom(from, to, amount).send(opts).on(
    'receipt', function(receipt) {
      console.log('Transfer successful')
    }
  ).on(
    'error', function(error, receipt) {
      console.log('Transfer failed')
      console.log(error)
    }
  )
}

async function pause(opts) {
  await tokenContract.methods.pause().send(opts).on(
    'receipt', function(receipt) {
      console.log('Pause successful')
    }
  ).on(
    'error', function(error, receipt) {
      console.log('Pause failed')
      console.log(error)
    }
  )
}

async function unpause(opts) {
  await tokenContract.methods.unpause().send(opts).on(
    'receipt', function(receipt) {
      console.log("Unpause successful")
    }
  ).on(
    'error', function(error, receipt) {
      console.log('Unpause failed')
    }
  )
}

async function transferOwnership(address, opts) {
  await tokenContract.methods.transferOwnership(address).send(opts).on(
    'receipt', function(receipt) {
      console.log("Transfer ownership initiated successfully")
    }
  ).on(
    'error', function(error, receipt) {
      console.log('Transfer ownership failed')
    }
  )
}

async function acceptOwnership(opts) {
  await tokenContract.methods.acceptOwnership().send(opts).on(
    'receipt', function(receipt) {
      console.log("Approve ownership success")
    }
  ).on(
    'error', function(error, receipt) {
      console.log('Approve ownership failed')
    }
  )
}

async function getBalance(address) {
  let bal = await tokenContract.methods.balanceOf(address).call()

  console.log(address + " balance: " + bal)
}

async function getStatus() {
  let status = await tokenContract.methods.isPaused().call()

  if (status) {
    console.log('Contract paused (' + status + ')')
  } else {
    console.log('Contract not paused (' + status + ')')
  }
}

async function getInfo() {
  let symbol = await tokenContract.methods.symbol().call()
  let name = await tokenContract.methods.name().call()
  let decimals = await tokenContract.methods.decimals().call()

  console.log(name + " (" + symbol + ")")
  console.log("Decimals: " + decimals)
}

async function getSupply() {
  let supply = await tokenContract.methods.totalSupply().call()

  console.log("Total Supply: " + supply)
}

async function getOwner() {
  let owner = await tokenContract.methods.getOwner().call()

  console.log("Owner: " + owner)
}

async function getAllowance(account, spender) {
  let allowance = await tokenContract.methods.allowance(account, spender).call()

  console.log("Allowance: " + allowance)
}

async function getPendingStatus(opts) {
  let status = await tokenContract.methods.pendingTransfer().call()

  if (status) {
    console.log('Ownership transfer pending')
  } else {
    console.log('No pending ownership transfer')
  }
}

async function getTransferCount() {
  let count = await tokenContract.methods.getTransferCount().call()

  console.log('Ownership transfer counts: ' + count)
}

function getOpts(account) {
  opts = {
    from: account,
    gasLimit: gasLimit,
    gasPrice: gasPrice,
  }

  return opts
}

async function testMint() {
  console.log('Test: Mint')
  let ownerOpts = getOpts(web3.eth.accounts.wallet[0].address)
  let otherOpts = getOpts(web3.eth.accounts.wallet[1].address)

  /*
  await getSupply()

  console.log('-- Mint')
  await mint(ethers.BigNumber.from("3000000000000000000000000000"), ownerOpts)
  await getSupply()

  console.log('-- Mint over total max supply')
  await mint(ethers.BigNumber.from("1000000000000000000000000000"), ownerOpts)
  await getSupply()
  */

  console.log('-- Non-owner')
  await mint(ethers.BigNumber.from("3000000000000000000000000000"), otherOpts)
  await getSupply()
}

async function testBurn() {
  console.log('Test: Burn')
  let ownerOpts = getOpts(web3.eth.accounts.wallet[0].address)
  let otherOpts = getOpts(web3.eth.accounts.wallet[1].address)

  /*
  await getSupply()
  await getBalance(web3.eth.accounts.wallet[0].address)

  console.log('-- Burn')
  await burn(ethers.BigNumber.from("1000000000000000000000000000"), ownerOpts)
  await getSupply()
  await getBalance(web3.eth.accounts.wallet[0].address)

  console.log('-- Burn more than owner wallet contains')
  await burn(ethers.BigNumber.from("4000000000000000000000000000"), ownerOpts)
  */

  console.log('-- Non-owner')
  await burn(ethers.BigNumber.from("1000000000000000000000000000"), otherOpts)
}

async function testPause() {
  console.log('Test: Pause')
  let ownerOpts = getOpts(web3.eth.accounts.wallet[0].address)
  let otherOpts = getOpts(web3.eth.accounts.wallet[1].address)

  await getStatus()

  console.log('-- Pause')
  await pause(ownerOpts)
  await getStatus()

  console.log('-- -- Transfer while paused')
  await transfer(web3.eth.accounts.wallet[1].address, ethers.BigNumber.from("1000000000000"), ownerOpts)

  console.log('-- Unpause')
  await unpause(ownerOpts)
  await getStatus()

  console.log('-- Non-owner')
  await pause(otherOpts)
}

async function testOwnerTransfer() {
  console.log('Test: Owner Transfer')
  let ownerOpts = getOpts(web3.eth.accounts.wallet[0].address)
  let otherOpts = getOpts(web3.eth.accounts.wallet[1].address)

  await getTransferCount()
  await getOwner()

  console.log('-- Initiate transfer')
  await transferOwnership(web3.eth.accounts.wallet[1].address, ownerOpts)
  await getPendingStatus(ownerOpts)
  await getPendingStatus(otherOpts)

  console.log('-- Approve transfer')
  await acceptOwnership(otherOpts)
  await getOwner()
  await getTransferCount()
}

async function testTransfer() {
  console.log('Test: Token transfer')
  let ownerOpts = getOpts(web3.eth.accounts.wallet[0].address)
  let otherOpts = getOpts(web3.eth.accounts.wallet[1].address)

  await getBalance(web3.eth.accounts.wallet[0].address)
  await getBalance(web3.eth.accounts.wallet[1].address)
  console.log('-- Send')
  await transfer(web3.eth.accounts.wallet[1].address, ethers.BigNumber.from("1000000000000"), ownerOpts)
  await getBalance(web3.eth.accounts.wallet[0].address)
  await getBalance(web3.eth.accounts.wallet[1].address)
}

async function testDataFetch() {
  console.log('Test: Data')
  let ownerOpts = getOpts(web3.eth.accounts.wallet[0].address)
  let otherOpts = getOpts(web3.eth.accounts.wallet[1].address)

  await getInfo()
  await getStatus()
  await getPendingStatus(otherOpts)
  await getOwner()
}

initializeWeb3('https://data-seed-prebsc-1-s3.binance.org:8545/').then(
  initializeContract().then(
    testOwnerTransfer().then()
  )
)
