// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {WalletRegistry} from "../src/WalletRegistry.sol";

contract WalletRegistryTest is Test {
    WalletRegistry reg;

    address alice = address(0x1);
    address bob = address(0x2);

    function setUp() public {
        reg = new WalletRegistry();
    }

    function testAddAndGetWallet() public {
        reg.addWallet(alice, "alice", "DeFi");

        address[] memory list = reg.getWallets();
        assertEq(list.length, 1);

        // getWalletInfo returns a struct WalletInfo memory (assumed).
        WalletRegistry.WalletInfo memory info = reg.getWalletInfo(alice);

        // owner is the test contract (msg.sender)
        assertEq(info.owner, address(this));
        assertEq(info.nickname, "alice");
        assertEq(info.tag, "DeFi");
        assertTrue(info.createdAt > 0);
    }

    function testCannotAddTwice() public {
        reg.addWallet(alice, "alice", "DeFi");
        vm.expectRevert(bytes("Already registered"));
        reg.addWallet(alice, "alice2", "Other");
    }

    function testUpdateAndRemove() public {
        reg.addWallet(bob, "bob", "NFT");

        WalletRegistry.WalletInfo memory infoBefore = reg.getWalletInfo(bob);
        assertEq(infoBefore.owner, address(this));

        reg.updateWallet(bob, "bob2", "Trader");

        WalletRegistry.WalletInfo memory infoAfter = reg.getWalletInfo(bob);
        assertEq(infoAfter.nickname, "bob2");
        assertEq(infoAfter.tag, "Trader");

        reg.removeWallet(bob);

        address[] memory list = reg.getWallets();
        assertEq(list.length, 0);
    }

    function testOnlyOwnerCanUpdateOrRemove() public {
        reg.addWallet(alice, "alice", "DeFi");

        // simulate different sender
        vm.prank(address(0x999));
        vm.expectRevert(bytes("Not owner"));
        reg.updateWallet(alice, "x", "y");

        vm.prank(address(0x999));
        vm.expectRevert(bytes("Not owner"));
        reg.removeWallet(alice);
    }
}
