# OnChain Weather Insurance with Identity Verification

This project demonstrates a weather insurance smart contract using Chainlink Price Feeds and Sign Protocol for identity verification. It allows verified users to purchase insurance and claim payouts based on temperature data provided by Chainlink oracles.

## Features

- User identity verification using Sign Protocol
- Weather insurance purchase for verified users
- Automatic payouts based on Chainlink temperature data

## Technology Stack & Tools

- Solidity (Writing Smart Contracts)
- [Foundry](https://getfoundry.sh/) (Development Framework)
- [Chainlink](https://chain.link/) (Price Feeds)
- [Sign Protocol](https://docs.sign.global/) (Identity Verification)

...

## How it works

1. Users first verify their identity using Sign Protocol.
2. Verified users can purchase weather insurance by paying a premium.
3. The contract uses Chainlink Price Feeds to check the current temperature.
4. If the temperature exceeds the threshold, insured users can claim their payout.

...