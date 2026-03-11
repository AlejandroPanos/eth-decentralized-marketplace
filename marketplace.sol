// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Marketplace {

    // Initial statements
    struct Client {
        string name;
        string email;
        uint256 age;
    }

    uint256 private listingIdCounter = 0;
    struct Listing {
        uint256 id;
        address seller;
        string name;
        string description;
        uint256 price;
        uint256 qty;
        bool isActive;
    }

    struct Review {
        address buyer;
        uint256 stars;
        string comment;
        uint256 itemId;
    }

    mapping (string => Client) public clientData;
    mapping (uint256 => Listing) public listingData;
    mapping (uint256 => Review[]) public listingReviews;
    mapping (address => mapping (uint256 => bool)) public hasPurchased;
    mapping (address => mapping (uint256 => bool)) public hasReviewed;
    mapping (address => uint256) public sellerStars;
    mapping (address => uint256) public sellerReviews;

    // These arrays are for pure development purposes
    // In reality they would increase gas cost as they grow
    Client[] public listofClients;
    Listing[] public listOfListings;
    Review[] public listOfReviews;

    // Create modifiers
    modifier OnlyListingOwner(uint256 _itemId) {
        require(listingData[_itemId].seller == msg.sender, "You cannot run this function");
        _;
    }

    modifier CheckActive(uint256 _itemId) {
        require(listingData[_itemId].isActive == true, "Listing is not active. Cannot buy");
        _;
    }

    modifier OnlyBuyer(uint256 _itemId) {
        require(hasPurchased[msg.sender][_itemId] == true, "Must buy before leaving a review");
        _;
    }

    // Create events
    event ClientAdded(string);
    event ListingAdded(uint256, string);
    event UpdatedListing(uint256);
    event DeletedListing(uint256);
    event NewPurchase(uint256);

    // Function to create and save a client
    function addClient(string memory _name, string memory _email, uint256 _age) external {
        Client memory newClient = Client({
            name: _name, 
            email: _email, 
            age: _age
        });

        clientData[_email] = newClient;
        listofClients.push(newClient);

        emit ClientAdded(_name);
    }

    // Function to add a listing
    function addListing(string memory _name, string memory _description, uint256 _price, uint256 _qty) external {
        listingIdCounter++;

        Listing memory newListing = Listing({
            id: listingIdCounter,
            seller: msg.sender,
            name: _name,
            description: _description,
            price: _price,
            qty: _qty,
            isActive: true
        });

        listingData[listingIdCounter] = newListing;
        listOfListings.push(newListing);

        emit ListingAdded(listingIdCounter, _name);
    }

    // Function to update listing
    function updateListing(uint256 _itemId, string memory _newName, uint256 _newPrice, uint256 _newQty) external OnlyListingOwner(_itemId) returns(bool){
        listingData[_itemId].name = _newName;
        listingData[_itemId].price = _newPrice;
        listingData[_itemId].qty = _newQty;
        
        emit UpdatedListing(_itemId);

        return true;
    }

    // Function to remove listing
    function removeListing(uint256 _itemId) external OnlyListingOwner(_itemId) returns(bool){
        listingData[_itemId].isActive = false;

        emit DeletedListing(_itemId);

        return true;
    }

    // Function to buy item
    function buyListing(uint256 _itemId) external payable CheckActive(_itemId) returns(bool) {
        require(msg.sender != listingData[_itemId].seller, "Can't buy your own listings");
        require(listingData[_itemId].qty > 0, "No items left in stock");

        uint256 price = listingData[_itemId].price;
        require(msg.value == price, "Must send exact amount");

        (bool success, ) = payable(listingData[_itemId].seller).call{value: msg.value}('');
        require(success, "ETH transfer not done correctly");

        listingData[_itemId].qty--;

        if (listingData[_itemId].qty == 0) {
            listingData[_itemId].isActive = false;
        }

        hasPurchased[msg.sender][_itemId] = true;

        emit NewPurchase(_itemId);

        return true;
    }

    // Function to leave review
    function leaveReview(uint256 _itemId, uint256 _stars, string memory _comment) external OnlyBuyer(_itemId) returns(bool) {
        require(_stars > 0 && _stars <= 5, "Stars must be between 0 and 5");
        require(!hasReviewed[msg.sender][_itemId], "Already reviewed this item");
        hasReviewed[msg.sender][_itemId] = true;

        Review memory newReview = Review({
            buyer: msg.sender,
            stars: _stars,
            comment: _comment,
            itemId: _itemId
        });
        listingReviews[_itemId].push(newReview);
        address seller = listingData[_itemId].seller;
        sellerStars[seller] += _stars;
        sellerReviews[seller] ++;
        return true;
    }

    // Function to calculate average rating
    function averageRating(address _seller) public view returns(uint256) {
        if (sellerStars[_seller] == 0) {
            return 0;
        }
        uint256 avgRating = sellerStars[_seller] / sellerReviews[_seller];
        return avgRating;
    }   
}