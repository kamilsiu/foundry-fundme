-include .env

build:
	forge build

deploy-sepolia:
	forge script script/DeployFundMe.s.sol \
		--rpc-url $(SEPOLIA_RPC_URL) \
		--private-key $(PRIVATE_KEY) \
		--broadcast \
		--verify \
		--etherscan-api-key $(ETHERSCAN_API_KEY) \
		-vvvv
format:;forge fmt
clean:;forge clean
test:;forge test
snapshot:;forge snapshot
coverage:;forge coverage