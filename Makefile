NETWORK_URL := http://127.0.0.1:8545

build:
	forge build

# Short command to deploy to your local Anvil chain
deploy:
	forge script script/DeployFundMe.s.sol --rpc-url $(NETWORK_URL) --broadcast