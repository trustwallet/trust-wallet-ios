const Web3 = require('web3')
const ProviderEngine = require('web3-provider-engine')
const HookedWalletSubprovider = require('web3-provider-engine/subproviders/hooked-wallet.js')
const FilterSubprovider = require('web3-provider-engine/subproviders/filters.js')
const Web3Subprovider = require("web3-provider-engine/subproviders/web3.js")

const context = window || global

context.chrome = { webstore: true }
context.Web3 = Web3

let callbacks = {}
let hookedSubProvider

const Trust = {
  init (rpcUrl, options) { 
    const engine = new ProviderEngine()
    const web3 = new Web3(engine)
    context.web3 = web3

    engine.addProvider(hookedSubProvider = new HookedWalletSubprovider(options))
    engine.addProvider(new FilterSubprovider())
    engine.addProvider(new Web3Subprovider(new Web3.providers.HttpProvider(rpcUrl)))

    engine.on('error', err => console.error(err.stack))
    engine.isTrust = true
    engine.start()

    return engine
  },
  addCallback (id, cb, isRPC) {
    cb.isRPC = isRPC
    callbacks[id] = cb
  },
  executeCallback (id, error, value) {
    console.log(`executing callback: \nid: ${id}\nvalue: ${value}\nerror: ${error}\n`)

    let callback = callbacks[id]

    if (callback.isRPC) {
        const response = {'id': id, jsonrpc: '2.0', result: value, error: {message: error} }

      if (error) {
        callback(response, null)
      } else {
        callback(null, response)
      }
    } else {
      callback(error, value)
    }
    delete callbacks[id]
  }
}

if (typeof context.Trust === 'undefined') {
  context.Trust = Trust
}

module.exports = Trust

