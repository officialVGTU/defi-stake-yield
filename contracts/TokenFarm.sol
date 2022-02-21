// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@chainlink/contracts/src/interfaces/AggregatorV3Interface.sol";

contract TokenFarm is Ownable {
    address[] public allowedTokens;
    address[] public stakers;
//    mapping token address => staker address => amount
    mapping(address => mapping(address => uint256)) public stakingBalance;
    mapping(address => uint256) public uniqueTokensStaked;
    mapping(address => address) public tokenPriceFeedMapping;
    IERC20 public dappToken;

    constructor(address _dappTokenAddress) public {
        dappToken = IERC20(_dappTokenAddress);
    }

    function setPriceFeedContract(address _token, address _priceFeed) public onlyOwner {
        tokenPriceFeedMapping[_token] = _priceFeed;
    }

    function issueTokens() public onlyOwner {
        for (uint256 stakersIndex=0; stakersIndex < stakers.lenght; stakersIndex++){
            address recipient = stakers[stakersIndex];
            uint256 userTotalValue = getUserTotalValue(recipient);
            dappToken.transfer(recipient, &&&);
        }
    }

    function getUserTotalValue(address _user) public view returns (uint256){
        uint256 totalValue = 0;
        require(uniqueTokensStaked[_user] > 0, 'No token staked!');
        for (uint256 allowedTokenIndex=0; allowedTokenIndex < allowedToken.lenght; allowedTokenIndex++){
            totalValue = totalValue + getUserSingleTokenValue(_user, allowedToken[allowedTokenIndex]);
        }
    }

    function getUserSingleTokenValue(address _user, address _token) public view returns (uint256){
        if (uniqueTokensStaked[_user] <= 0){
            return 0;
        }
//        price of the token * stakingBalance[_token][_user]
        getTokenValue(_token);
    }

    function getTokenValue(address _token) public view returns (uint256) {
        // priceFeedAddress
        address priceFeedAddress = tokenPriceFeedMapping[_token];

    }

    function stakeTokens(uint256 _amount, address _token) public {
        require(_amount > 0, 'Amount must be more that 0');
        require(tokenIsAllowed(_token), 'Token is currently no allowed');
        IERC20(_token).transferFrom(msg.sender, address(this), _amount);
        updateUniqueTokensStaked(msg.sender, _token);
        stakingBalance[_token][msg.sender] = stakingBalance[_token][msg.sender] + _amount;
        if (uniqueTokensStaked[msg.sender] == 1) {
            stakers.push(msg.sender);
        }
    }

    function updateUniqueTokensStaked(address _user, address _token) internal {
        if (stakingBalance[_token][_user] <= 0){
            uniqueTokensStaked[_user] = uniqueTokensStaked[_user] + 1;
        }
    }

    function addAllowedTokens(address _token) public onlyOwner {
        allowedTokens.push(_token);
    }

    function tokenIsAllowed(address _token) public returns (bool) {
        for (uint256 allowedTokensIndex=0; allowedTokensIndex < allowedTokens.length; allowedTokensIndex++){
            if (allowedTokens[allowedTokensIndex] == _token){
                return true;
            }
        }
        return false;
    }
}
