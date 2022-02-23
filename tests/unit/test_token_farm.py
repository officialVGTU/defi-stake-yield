import pytest
from brownie import network, exceptions
from scripts.helpful_scripts import get_account, get_contract
from scripts.helpful_scripts import LOCAL_BLOCKCHAIN_ENVIRONMENTS, INITIAL_PRICE_FEED_VALUE
from scripts.deploy import deploy_token_farm_and_dapp_token

def test_set_price_feed_contract():
    if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        pytest.skip('Only for local testing!')
    account = get_account()
    non_owner = get_account(index=1)
    token_farm, dapp_token = deploy_token_farm_and_dapp_token()

    price_feed_address = get_contract('eth_usd_price_feed')
    token_farm.setPriceFeedContract(dapp_token, price_feed_address, {'from': account})

    assert token_farm.tokenPriceFeedMapping(dapp_token.address) == price_feed_address
    with pytest.raises(exceptions.VirtualMachineError):
        token_farm.setPriceFeedContract(dapp_token, price_feed_address, {'from': non_owner})

def test_stake_tokens(amount_staked):
    if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        pytest.skip('Only for local testing!')
    account = get_account()
    token_farm, dapp_token = deploy_token_farm_and_dapp_token()

    dapp_token.approve(token_farm.address, amount_staked, {'from': account})
    token_farm.stakeTokens(amount_staked, dapp_token.address, {'from': account})

    assert token_farm.stakingBalance(dapp_token.address, account.address) == amount_staked
    assert token_farm.uniqueTokensStaked(account.address) == 1
    assert token_farm.stakers(0) == account.address
    return token_farm, dapp_token

def test_issue_tokens(amount_staked):
    if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        pytest.skip('Only for local testing!')
    account = get_account()
    token_farm, dapp_token = test_stake_tokens(amount_staked)
    starting_balance = dapp_token.balanceOf(account.address)

    token_farm.issueTokens({'from': account})

    assert dapp_token.balanceOf(account.address) == starting_balance + INITIAL_PRICE_FEED_VALUE