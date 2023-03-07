// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

interface ICrowdsaleStat {
    /// @notice amount of funds collected in wei
    function getWeiCollected() public view returns (uint256);

    /// @notice amount of tokens minted (NOT equal to totalSupply() in case token is reused!)
    function getTokenMinted() public view returns (uint256);
}

interface IInvestmentsWalletConnector {
    /// @dev process and forward investment
    function storeInvestment(address investor, uint256 payment) external;
    /// @dev total investments amount stored using storeInvestment()
    function getTotalInvestmentsStored() internal view returns (uint256);
    /// @dev called in case crowdsale succeeded
    function wcOnCrowdsaleSuccess() internal;
    /// @dev called in case crowdsale failed
    function wcOnCrowdsaleFailure() internal;
}


contract ISimpleCrowdsaleBase {
    /// @dev says if crowdsale time bounds must be checked
    function mustApplyTimeCheck(
        address /*investor*/,
        uint256 /*payment*/
    ) internal view returns (bool);

    /// @notice whether to apply hard cap check logic via getMaximumFunds() method
    function hasHardCap() internal view returns (bool);

    /// @notice maximum investments to be accepted during pre-ICO
    function getMaximumFunds() internal view returns (uint256);

    /// @notice minimum amount of funding to consider crowdsale as successful
    function getMinimumFunds() internal view returns (uint256);

    /// @notice start time of the pre-ICO
    function getStartTime() internal view returns (uint256);

    /// @notice end time of the pre-ICO
    function getEndTime() internal view returns (uint256);

    /// @notice minimal amount of investment
    function getMinInvestment() public view returns (uint256);

    /// @dev calculates token amount for given investment
    function calculateTokens(
        address investor,
        uint256 payment,
        uint256 extraBonuses
    ) internal view returns (uint256);
}

/// @title Base contract for simple crowdsales
contract SimpleCrowdsaleBase is
    ReentrancyGuard,
    IInvestmentsWalletConnector,
    ISimpleCrowdsaleBase
{
    using SafeMath for uint256;

    event FundTransfer(address backer, uint256 amount, bool isContribution);

    modifier validAddress(address addr) {
        require(addr != address(0));
        _;
    }

    constructor(address token) public validAddress(token) {
        m_token = IERC20(token);
    }

    // PUBLIC interface: payments

    // fallback function as a shortcut
    fallback() external {
        require(0 == msg.data.length);
        buy(); // only internal call here!
    }

    /// @notice crowdsale participation
    function buy() public payable {
        // dont mark as external!
        buyInternal(msg.sender, msg.value, 0);
    }

    // INTERNAL

    /// @dev payment processing
    function buyInternal(
        address investor,
        uint256 payment,
        uint256 extraBonuses
    ) internal nonReentrant {
        require(payment >= getMinInvestment()); // 1
        require(
            getCurrentTime() >= getStartTime() ||
                !mustApplyTimeCheck(investor, payment) /* for final check */
        );
        if (getCurrentTime() >= getEndTime()) finish();

        if (m_finished) {
            // saving provided gas
            investor.transfer(payment);
            return;
        }

        uint256 startingWeiCollected = getWeiCollected();
        uint256 startingInvariant = address(this).balance.add(
            startingWeiCollected
        );

        uint256 change;
        if (hasHardCap()) { 10000 = 9999 = 100 - 100000
            // return or update payment if needed
            uint256 paymentAllowed = getMaximumFunds().sub(getWeiCollected());
            assert(0 != paymentAllowed);

            if (paymentAllowed < payment) {
                change = payment.sub(paymentAllowed); 99
                payment = paymentAllowed;
            }
        }

        // issue tokens
        uint256 tokens = calculateTokens(investor, payment, extraBonuses); // 1 ether 
        m_token.mint(investor, tokens);
        m_tokensMinted += tokens;

        // record payment
        storeInvestment(investor, payment);
        assert(
            (!hasHardCap() || getWeiCollected() <= getMaximumFunds()) &&
                getWeiCollected() > startingWeiCollected
        );
        emit FundTransfer(investor, payment, true);

        if (hasHardCap() && getWeiCollected() == getMaximumFunds()) finish();

        if (change > 0) investor.transfer(change);

        assert(
            startingInvariant ==
                address(this).balance.add(getWeiCollected()).add(change)
        );
    }

    function finish() internal {
        if (m_finished) return;

        if (getWeiCollected() >= getMinimumFunds()) wcOnCrowdsaleSuccess();
        else wcOnCrowdsaleFailure();

        m_finished = true;
    }

    // Other pluggables

    /// @dev says if crowdsale time bounds must be checked
    function mustApplyTimeCheck(
        address /*investor*/,
        uint256 /*payment*/
    ) internal view returns (bool) {
        return true;
    }

    /// @notice whether to apply hard cap check logic via getMaximumFunds() method
    function hasHardCap() internal view returns (bool) {
        return getMaximumFunds() != 0;
    }

    /// @dev to be overridden in tests
    function getCurrentTime() internal view returns (uint256) {
        return now;
    }

    /// @notice minimal amount of investment
    function getMinInvestment() public view returns (uint256) {
        uint256 fin = 10000000000000000;
        return fin;
    }

    // ICrowdsaleStat

    function getWeiCollected() public view returns (uint256) {
        return getTotalInvestmentsStored();
    }

    /// @notice amount of tokens minted (NOT equal to totalSupply() in case token is reused!)
    function getTokenMinted() public view returns (uint256) {
        return m_tokensMinted;
    }

    // FIELDS

    /// @dev contract responsible for token accounting
    MintableToken public m_token;

    uint256 m_tokensMinted;

    bool m_finished = false;
}

/// @title StandardToken which can be minted by another contract.
contract MintableToken {
    event Mint(address indexed to, uint256 amount);

    /// @dev mints new tokens
    function mint(address _to, uint256 _amount) public;
}
