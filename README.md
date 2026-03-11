# Decentralized Marketplace

A smart contract-based marketplace built with Solidity that enables secure peer-to-peer transactions on the Ethereum blockchain.

## Overview

This project implements a fully functional decentralized marketplace where users can list items for sale, purchase from other sellers, and leave reviews. All transactions are handled trustlessly through smart contract logic with payments in ETH.

## Features

### Core Functionality

- **Item Listings**: Sellers can create listings with name, description, price, and quantity
- **Purchase System**: Buyers can purchase items with exact ETH payment
- **Inventory Management**: Automatic quantity tracking and sold-out detection
- **Listing Management**: Sellers can update or remove their own listings
- **Access Control**: Modifier-based permissions to prevent unauthorized actions

### Review System

- Buyers can leave reviews (1-5 stars with comments) after purchase
- One review per buyer per item to prevent spam
- Automatic seller rating calculation based on all received reviews
- Average rating available for any seller address

### Security Features

- Prevent self-purchases
- Exact payment validation
- Ownership verification for listing modifications
- Purchase history tracking
- Active/inactive listing status

## Technical Details

### Smart Contract Structure

**Structs:**

- `Listing`: Stores item information (id, seller, name, description, price, quantity, status)
- `Review`: Stores review data (buyer, stars, comment, itemId)
- `Client`: Optional user profile data

**Key Mappings:**

- `listingData`: Maps listing ID to Listing struct
- `listingReviews`: Maps listing ID to array of reviews
- `hasPurchased`: Tracks purchase history per user per item
- `hasReviewed`: Prevents duplicate reviews
- `sellerStars`: Running total of stars for each seller
- `sellerReviews`: Count of reviews for each seller

**Modifiers:**

- `OnlyListingOwner`: Restricts function access to listing creator
- `CheckActive`: Ensures listing is active before purchase
- `OnlyBuyer`: Ensures user purchased item before reviewing

### Main Functions

```solidity
addListing(string _name, string _description, uint256 _price, uint256 _qty)
updateListing(uint256 _itemId, string _newName, uint256 _newPrice, uint256 _newQty)
removeListing(uint256 _itemId)
buyListing(uint256 _itemId) payable
leaveReview(uint256 _itemId, uint256 _stars, string _comment)
averageRating(address _seller) view returns(uint256)
```

## Usage

### Deployment

1. Compile with Solidity compiler version ^0.8.0
2. Deploy to your preferred network (testnet recommended for testing)
3. No constructor parameters required

### Creating a Listing

```solidity
addListing("Laptop", "Used MacBook Pro 2020", 1000000000000000000, 1); // 1 ETH in wei
```

### Purchasing an Item

```solidity
buyListing(1); // Send exact ETH amount as msg.value
```

### Leaving a Review

```solidity
leaveReview(1, 5, "Great seller, fast delivery!");
```

### Checking Seller Rating

```solidity
uint256 rating = averageRating(0x123...); // Returns average (e.g., 4 for 4.66 rounded down)
```

## Events

The contract emits the following events for off-chain tracking:

- `ListingAdded(uint256 itemId, string name)`
- `UpdatedListing(uint256 itemId)`
- `DeletedListing(uint256 itemId)`
- `NewPurchase(uint256 itemId)`
- `ClientAdded(string name)`

## Testing Scenarios

1. **Create and Update Listing**: Verify only owner can modify
2. **Purchase Flow**: Test exact payment, quantity decrement, sold-out status
3. **Review System**: Confirm one review per purchase, rating calculation
4. **Access Control**: Attempt unauthorized modifications
5. **Edge Cases**: Self-purchase prevention, out-of-stock handling

## Limitations and Considerations

- Integer division for ratings means decimals are truncated (4.66 becomes 4)
- Direct ETH transfers to sellers (consider withdrawal pattern for production)
- Arrays grow unbounded (gas optimization needed for production scale)
- Client struct is optional and not used in core marketplace logic

## Development Environment

- **Language**: Solidity ^0.8.0
- **License**: MIT
- **Recommended IDE**: Remix IDE for quick testing
- **Testing Network**: Ethereum testnets (Sepolia, Goerli)
