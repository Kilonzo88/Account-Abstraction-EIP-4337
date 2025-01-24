// SPDX-License-Identifier: MIT

pragma solidity ^0.8.21;

import {Script} from "forge-std/Script.sol";
import {MinimalAccount} from "src/ethereum/MinimalAccount.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {console} from "forge-std/Test.sol";

contract DeployMinimal is Script, HelperConfig {
    function run() public {
        deployMinimalAccount();
    }
        

    function deployMinimalAccount() public returns(HelperConfig, MinimalAccount) {
        HelperConfig helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();

        address deployerAddress;

        if(block.chainid == LOCAL_CHAIN_ID) {
            deployerAddress = ANVIL_DEFAULT_ACCOUNT;
        } else {
            deployerAddress = BURNER_WALLET;
        }
        
        vm.startBroadcast(deployerAddress);
        MinimalAccount minimalAccount = new MinimalAccount(config.entryPoint);
        minimalAccount.transferOwnership(config.account);
        vm.stopBroadcast();

        console.log("HelperConfig",address(helperConfig));
        console.log("MinimalAccount",address(minimalAccount));

        return (helperConfig, minimalAccount);
    } 
}