from brownie import FundMe, accounts, network, config, MockV3Aggregator
from web3 import Web3
import os


def deploy_fundMe():
    # First and formost, we need to get the accounts
    account = get_accounts()
    # Now we can deploy the contract
    # check if we are in a development network

    
    if (network.show_active() != "development"):
        price_feed_address = config["networks"][network.show_active()]["eth_price_feed"]
    else:
        # we need to check the number of contracts we have already deployed
        if len(MockV3Aggregator) <= 0:
            MockV3Aggregator.deploy(18, Web3.toWei(2000, "ether"), {"from": account})

        price_feed_address = MockV3Aggregator[-1].address # Get the address of the last deployed contract
    fundMe = FundMe.deploy(price_feed_address, {'from': account}, publish_source=config["networks"][network.show_active()].get("verify"))
    # And we can print the address
    print("FundMe contract address:", fundMe.address)

    # get the contract address
    transaction = fundMe.fund({'from': account, 'value': 100})

    # get the transaction hash
    transaction.wait(1)

    # antother transaction
    transaction = fundMe.getConversionRate(2200, {'from': account})


def get_accounts():
    if (network.show_active() == "development"):
        return accounts[0]
    else:
        return accounts.add(config["wallets"]["from_key"])

def main():
    deploy_fundMe()