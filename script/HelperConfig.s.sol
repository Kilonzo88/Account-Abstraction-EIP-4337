// SPDX-License-Identifier: MIT

pragma solidity ^0.8.21;

import {Script, console} from "forge-std/Script.sol";
import {EntryPoint} from "lib/account-abstraction/contracts/core/EntryPoint.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";

contract HelperConfig is Script {
    ERC20Mock public usdc;

    error HelperConfig__InvalidChainId();
    error HelperConfig__NotLocalChainId();
    error HelperConfig__NotArbitrumChainId();

    struct NetworkConfig {
        address entryPoint;
        address account;
        address usdc;
    }

    /*//////////////////////////////////////////////////////////////
                            STATE VARIABLES
    //////////////////////////////////////////////////////////////*/
    uint256 constant ETH_SEPOLIA_CHAIN_ID = 11155111;
    uint256 constant ARBITRUM_SEPOLIA_CHAIN_ID = 421614;
    uint256 constant ZK_SYNC_SEPOLIA_CHAIN_ID = 300;
    uint256 constant LOCAL_CHAIN_ID = 31337;
    address constant BURNER_WALLET = 0x605990a6bE9D8DB8C076Ea2357E593c6384C44E9;
    address constant ANVIL_DEFAULT_ACCOUNT = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266; //Default foundry default wallet is found at base.sol

    NetworkConfig public localNetworkConfig;
    mapping(uint256 chainId => NetworkConfig) public networkConfigs;

    /*//////////////////////////////////////////////////////////////
                               FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    constructor(){
        networkConfigs[ETH_SEPOLIA_CHAIN_ID] = getSepoliaEthConfig();
        networkConfigs[ZK_SYNC_SEPOLIA_CHAIN_ID] = getZkSyncSepoliaConfig();
        networkConfigs[ARBITRUM_SEPOLIA_CHAIN_ID] = getArbitrumSepoliaConfig();
    }

    function getConfig() public returns(NetworkConfig memory) {
        return _getConfigByChainId(block.chainid);
    }

    function _getConfigByChainId(uint256 chainId) internal returns(NetworkConfig memory) {
        console.log("Current chainId:", chainId);
        if(chainId == LOCAL_CHAIN_ID) {
            return getOrCreateAnvilConfig();
        } else if(networkConfigs[chainId].account != address(0)) {
            return networkConfigs[chainId];
        } else {
            revert HelperConfig__InvalidChainId();
        }
    }

    /*//////////////////////////////////////////////////////////////
                            GETTERS
    //////////////////////////////////////////////////////////////*/

    function getSepoliaEthConfig() public view returns(NetworkConfig memory) {
         if(block.chainid != ARBITRUM_SEPOLIA_CHAIN_ID) {
            revert HelperConfig__NotArbitrumChainId();
        } else
        
        return NetworkConfig({
            entryPoint: address(0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789),
            account:BURNER_WALLET,
            usdc: address(usdc)
            }
        );
    }

    function getArbitrumSepoliaConfig() public view returns(NetworkConfig memory) {
        if(block.chainid != ARBITRUM_SEPOLIA_CHAIN_ID) {
            revert HelperConfig__NotArbitrumChainId();
        } else 
        
        return NetworkConfig({
            entryPoint: address(0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789),
            account:BURNER_WALLET,
            usdc: address(0x75faf114eafb1BDbe2F0316DF893fd58CE46AA4d)});
    }

    function getZkSyncSepoliaConfig() public pure returns(NetworkConfig memory) {
        return NetworkConfig({
            entryPoint: address(0),
            account:BURNER_WALLET,
            usdc: address(0x5A7d6b2F92C77FAD6CCaBd7EE0624E64907Eaf3E)});
    }

    function getOrCreateAnvilConfig() public returns(NetworkConfig memory) {
        if(localNetworkConfig.account != address(0)) {
            return localNetworkConfig;
        }

        //deploy EntryPointMock
        console.log("Deploying EntryPointMock");
        vm.startBroadcast(ANVIL_DEFAULT_ACCOUNT);
        EntryPoint entryPoint = new EntryPoint();
        vm.stopBroadcast();

        localNetworkConfig = NetworkConfig({
            entryPoint: address(entryPoint),
            account: ANVIL_DEFAULT_ACCOUNT,
            usdc: address(usdc)});

        return localNetworkConfig;
    }  
}