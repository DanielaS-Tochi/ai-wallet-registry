// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract WalletRegistry {
    struct WalletInfo {
        address owner;
        string nickname;
        string tag;
        uint256 createdAt;
    }

    // mapping from stored wallet address => info
    mapping(address => WalletInfo) public wallets;
    // list of registered wallets (for enumeration)
    address[] public walletList;

    event WalletAdded(address indexed wallet, address indexed by, string nickname, string tag);
    event WalletUpdated(address indexed wallet, address indexed by, string nickname, string tag);
    event WalletRemoved(address indexed wallet, address indexed by);

    function addWallet(address _wallet, string calldata _nickname, string calldata _tag) external {
        require(_wallet != address(0), "Zero address");
        require(wallets[_wallet].owner == address(0), "Already registered");

        wallets[_wallet] = WalletInfo({
            owner: msg.sender,
            nickname: _nickname,
            tag: _tag,
            createdAt: block.timestamp
        });

        walletList.push(_wallet);
        emit WalletAdded(_wallet, msg.sender, _nickname, _tag);
    }

    function updateWallet(address _wallet, string calldata _nickname, string calldata _tag) external {
        WalletInfo storage info = wallets[_wallet];
        require(info.owner != address(0), "Not registered");
        require(info.owner == msg.sender, "Not owner");

        info.nickname = _nickname;
        info.tag = _tag;

        emit WalletUpdated(_wallet, msg.sender, _nickname, _tag);
    }

    function removeWallet(address _wallet) external {
        WalletInfo storage info = wallets[_wallet];
        require(info.owner != address(0), "Not registered");
        require(info.owner == msg.sender, "Not owner");

        // delete mapping entry
        delete wallets[_wallet];

        // remove from walletList (gas-inefficient but fine for small lists in demo)
        for (uint i = 0; i < walletList.length; i++) {
            if (walletList[i] == _wallet) {
                walletList[i] = walletList[walletList.length - 1];
                walletList.pop();
                break;
            }
        }

        emit WalletRemoved(_wallet, msg.sender);
    }

    function getWallets() external view returns (address[] memory) {
        return walletList;
    }

    function getWalletInfo(address _wallet) external view returns (WalletInfo memory) {
        return wallets[_wallet];
    }

    // convenience: count of wallets
    function totalWallets() external view returns (uint256) {
        return walletList.length;
    }
}
