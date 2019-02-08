pragma solidity ^0.4.23;

import './roles.sol';
import './StoreFronts.sol';

contract Admin is DSRoles {
    StoreFronts[256] contractsOwned;
    mapping(address => uint8) IdOwnedByAddress;
    address ownerAtIDZero;
    bool storesOwnersMaxed = false;
    uint8 highestAvailableOwnerID;
    uint8[] removedOwnerRoles;
    event StoreFrontDeployed(address);

    function getStoreFrontsandStoreIDs()
    public
    view
    returns(address[], uint[])
    {
        uint maxiter = 256 - removedOwnerRoles.length;
        address[] memory contracts = new address[](maxiter);
        uint[] memory maxStoreID = new uint[](maxiter);
        for(uint8 i=0; i < maxiter; i++) {
            contracts[i] = (address(contractsOwned[i]));
            maxStoreID[i] = contractsOwned[i].getHighestStoreID();
        }
        return (contracts, maxStoreID);
    }

    function highestID ()
    public
    view
    returns(uint8)
    {
        return highestAvailableOwnerID;
    }

    function getIdForAddress(address storesOwner)
    public
    view
    returns(uint8)
    {
        require(storesOwner == ownerAtIDZero || IdOwnedByAddress[storesOwner] != 0, "this address does not own a store");
        return IdOwnedByAddress[storesOwner];
    }

    function getContractAtID (uint8 ownerID)
    public
    view
    returns(address)
    {
        return contractsOwned[ownerID];
    }

    function addAdmin(address[] addresses)
    public
    auth
    {
        for (uint8 i = 0; i < addresses.length; i++) {
            setRootUser(addresses[i], true);
        }
    }

    function enableContract(address storesOwner)
    public
    auth
    {
        uint8 role = IdOwnedByAddress[storesOwner];
        address code = getContractAtID(role);
        setRoleCapability(role, code, bytes4(keccak256("retrieveFunds()")), true);
        setRoleCapability(role, code, bytes4(keccak256("addStore()")), true);
        setRoleCapability(role, code, bytes4(keccak256("getitemsAtStore()")), true);
        setRoleCapability(role, code, bytes4(keccak256("setitemsAtStore()")), true);
        setRoleCapability(role, code, bytes4(keccak256("updateInventory()")), true);
        setRoleCapability(role, code, bytes4(keccak256("updatePrice()")), true);
        setRoleCapability(role, code, bytes4(keccak256("deleteItemsAtStore()")), true);
        setRoleCapability(role, code, bytes4(keccak256("buyItem()")), true);
    }

    function addStoresOwner(address storesOwner)
    public
    auth
    returns(uint8)
    {
        require(!storesOwnersMaxed || removedOwnerRoles.length != 0, "no store slots left. remove a store to make space");
        if (!storesOwnersMaxed) {
            StoreFronts s = new StoreFronts(storesOwner);
            contractsOwned[highestAvailableOwnerID] = s;
            setUserRole(storesOwner, highestAvailableOwnerID, true);
            if (highestAvailableOwnerID == 255) {
                storesOwnersMaxed = true;
            } else {
                highestAvailableOwnerID++;
            }
            IdOwnedByAddress[storesOwner] = highestAvailableOwnerID;
            emit StoreFrontDeployed(storesOwner);
            return highestAvailableOwnerID;
        } else {
            uint8 ownerID = removedOwnerRoles[removedOwnerRoles.length-1];
            contractsOwned[ownerID] = s;
            setUserRole(storesOwner, ownerID, true);
            delete removedOwnerRoles[removedOwnerRoles.length-1];
            removedOwnerRoles.length -= 1;
            IdOwnedByAddress[storesOwner] = ownerID;
            if (ownerID == 0) { ownerAtIDZero = storesOwner; }
            emit StoreFrontDeployed(storesOwner);
            return ownerID;
        }
    }

    function removeStoresOwner(address storesOwner)
    public
    auth
    {
        require(storesOwner == ownerAtIDZero || IdOwnedByAddress[storesOwner] != 0, "this address does not own a store");
        setUserRole(storesOwner, IdOwnedByAddress[storesOwner], false);
        StoreFronts contractToRemove = contractsOwned[IdOwnedByAddress[storesOwner]];
        contractToRemove.stopContract();
        contractToRemove.retrieveFunds(address(contractToRemove).balance);
        uint8 removedID = IdOwnedByAddress[storesOwner];
        if (storesOwner == ownerAtIDZero) {
            ownerAtIDZero=address(0);
        }
        if (removedID == 255) {
            highestAvailableOwnerID--;
            IdOwnedByAddress[storesOwner] = 0;
        }
        delete contractsOwned[removedID];
        removedOwnerRoles.push(removedID);
        IdOwnedByAddress[storesOwner] = 0;
        return;
    }

}



