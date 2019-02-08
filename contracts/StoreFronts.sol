pragma solidity ^0.4.23;
import './roles.sol';

contract Pausable is DSRoles {
    bool isRunning = true;

    modifier onlyWhenRunning {
        require(isRunning, "contract is stopped, no transactions possible");
        _;
    }

    function startContract() auth public {
        isRunning = true;
    }

    function stopContract() auth public {
        isRunning = false;
    }
}

contract StoreFronts is Pausable {
    uint16 higestStoreId;
    address storeOwner;
    mapping(uint16 => mapping(uint => Item)) itemsAtStore;
    mapping(uint16 => uint) highestSKUAtStore;
    mapping(uint16 => uint[]) freeSKUsAtStore;

    struct Item {
        string name;
        uint sku;
        uint32 price;
        uint64 inventory;
        address seller;
    }

    event Sold(uint16 storeID, uint sku, uint amount);
    event InStockAgain(uint16 storeID, uint sku);
    event OutOfStock(uint16 storeID, uint sku);

    constructor(address _storeOwner) public {
        storeOwner = _storeOwner;
    }

    function gethighestSKUAtStore(uint16 storeID)
    public
    view
    returns (uint)
    {
        return highestSKUAtStore[storeID];
    }

    function getHighestStoreID()
    public
    view
    returns(uint16)
    {
        return higestStoreId;
    }

    function retrieveFunds(uint256 amount)
    public
    auth
    {
        require(address(this).balance >= amount, "requested amount is higher than contract balance");
        storeOwner.transfer(amount);
    }

    function addStore()
    public
    onlyWhenRunning
    auth
    {
        higestStoreId++;
    }

    function getitemsAtStore(uint16 storeID, uint _sku)
    public
    view
    returns(string memory name, uint sku, uint price, uint inventory, address seller)
    {
        require(bytes(itemsAtStore[storeID][_sku].name).length != 0,"item is removed");
        return (
        itemsAtStore[storeID][_sku].name,
        itemsAtStore[storeID][_sku].sku,
        itemsAtStore[storeID][_sku].price,
        itemsAtStore[storeID][_sku].inventory,
        itemsAtStore[storeID][_sku].seller
        );
    }

    function setitemsAtStore(uint16 storeID, string memory _name, uint32 _price)
    public
    onlyWhenRunning
    auth
    returns(uint) {
        require(bytes(_name).length != 0, "name must be non-empty");
        require(storeID <= higestStoreId, "store does not exist yet, call addStore first");
        uint assignedSKU;
        if (freeSKUsAtStore[storeID].length == 0) {
            assignedSKU = ++highestSKUAtStore[storeID];
        } else {
            assignedSKU = freeSKUsAtStore[storeID][freeSKUsAtStore[storeID].length -1];
            delete freeSKUsAtStore[storeID][freeSKUsAtStore[storeID].length -1];
            freeSKUsAtStore[storeID].length--;
        }
        itemsAtStore[storeID][assignedSKU] = Item({name: _name, sku: assignedSKU, price: _price, inventory: 1, seller: msg.sender});
        return assignedSKU;
    }

    function updateInventory(uint16 storeID, uint _sku, uint64 newValue)
    public
    onlyWhenRunning
    auth
    returns(uint) {
        uint oldValue = itemsAtStore[storeID][_sku].inventory;
        itemsAtStore[storeID][_sku].inventory = newValue;
        if (oldValue == 0 && newValue != 0) emit InStockAgain(storeID, _sku);
        return itemsAtStore[storeID][_sku].inventory;
    }

    function updatePrice(uint16 storeID, uint _sku, uint32 newValue)
    public
    onlyWhenRunning
    auth
    returns(uint) {
        itemsAtStore[storeID][_sku].price = newValue;
        return itemsAtStore[storeID][_sku].price;
    }

    function deleteItemsAtStore(uint16 storeID, uint _sku)
    public
    onlyWhenRunning
    auth
    returns(bool success) {
        delete itemsAtStore[storeID][_sku];
        freeSKUsAtStore[storeID].push(_sku);
        return true;
    }

    function buyItem(uint16 storeID, uint _sku, uint32 amount)
    public
    onlyWhenRunning
    payable
    {
        uint32 totalPrice = itemsAtStore[storeID][_sku].price * amount;
        require(itemsAtStore[storeID][_sku].inventory >= amount);
        require(msg.value >= totalPrice);
        itemsAtStore[storeID][_sku].inventory -= amount;
        uint amountToRefund = msg.value - totalPrice;
        if (amountToRefund > 0) { msg.sender.transfer(amountToRefund); }
        if (itemsAtStore[storeID][_sku].inventory == 0) {emit OutOfStock(storeID, _sku);}
        emit Sold(storeID, _sku, amount);
    }
}



