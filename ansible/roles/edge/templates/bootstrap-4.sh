#!/bin/bash -x

main() {
    if [[ -d "/var/lib/bootstrap" ]]; then
        echo "It appears this network has already been boot strapped"
        exit
    fi
    mkdir /var/lib/bootstrap
    pushd /var/lib/bootstrap

    polygon-edge polybft-secrets --data-dir validator-0 --json --insecure > validator-0.json
    polygon-edge polybft-secrets --data-dir validator-3 --json --insecure > validator-3.json
    polygon-edge polybft-secrets --data-dir validator-1 --json --insecure > validator-1.json
    polygon-edge polybft-secrets --data-dir validator-2 --json --insecure > validator-2.json

    apt update
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
    apt-get install -y nodejs

    pushd /opt/polygon-edge/
    make compile-core-contracts
    cp -r /opt/polygon-edge/core-contracts /var/lib/bootstrap/core-contracts/
    popd

    BURN_CONTRACT_ADDRESS=0x0000000000000000000000000000000000000000
    BALANCE=0x0

    polycli wallet create --words 12 --language english | jq '.Addresses[0]' > rootchain-wallet.json

    # Should the deployer be funded from an unlocked L1 chain or from a prefunded account on L1
    COINBASE_ADDRESS=$(cast rpc --rpc-url http://gp23-poc3-devnet-geth-0.c.polygon-060623.internal:8545 eth_coinbase | sed 's/"//g')
    cast send --rpc-url http://gp23-poc3-devnet-geth-0.c.polygon-060623.internal:8545 --from $COINBASE_ADDRESS --value 10000000ether $(cat rootchain-wallet.json | jq -r '.ETHAddress') --unlocked
    # cast send --rpc-url http://gp23-poc3-devnet-geth-0.c.polygon-060623.internal:8545 --from 0xC7FDEe289150041f2c4AAEF095e8a6715223663C --value 10000000ether $(cat rootchain-wallet.json | jq -r '.ETHAddress') --private-key 0xc0ffec0ffec0ffec0ffec0ffec0ffec0ffec0ffec0ffec0ffec0ffec0ffeDEAD

    polygon-edge genesis \
                 --consensus polybft \
                 --chain-id 100 \
                 --bootnode /dns4/validator-0/tcp/10001/p2p/$(cat validator-0.json | jq -r '.[0].node_id')  --bootnode /dns4/validator-3/tcp/10001/p2p/$(cat validator-3.json | jq -r '.[0].node_id')  --bootnode /dns4/validator-1/tcp/10001/p2p/$(cat validator-1.json | jq -r '.[0].node_id')  --bootnode /dns4/validator-2/tcp/10001/p2p/$(cat validator-2.json | jq -r '.[0].node_id')  \
                 --premine $(cat validator-0.json | jq -r '.[0].address'):1000000000000000000000000  --premine $(cat validator-3.json | jq -r '.[0].address'):1000000000000000000000000  --premine $(cat validator-1.json | jq -r '.[0].address'):1000000000000000000000000  --premine $(cat validator-2.json | jq -r '.[0].address'):1000000000000000000000000  \
                 --premine 0x85da99c8a7c2c95964c8efd687e95e632fc533d6:1000000000000000000000000000 \
                 --premine $BURN_CONTRACT_ADDRESS \
                 --reward-wallet 0x0101010101010101010101010101010101010101:1000000000000000000000000000 \
                 --block-gas-limit 50000000 \
                 --block-time 5s \
                 --validators /dns4/validator-0/tcp/10001/p2p/$(cat validator-0.json | jq -r '.[0].node_id'):$(cat validator-0.json | jq -r '.[0].address' | sed 's/^0x//'):$(cat validator-0.json | jq -r '.[0].bls_pubkey')  --validators /dns4/validator-3/tcp/10001/p2p/$(cat validator-3.json | jq -r '.[0].node_id'):$(cat validator-3.json | jq -r '.[0].address' | sed 's/^0x//'):$(cat validator-3.json | jq -r '.[0].bls_pubkey')  --validators /dns4/validator-1/tcp/10001/p2p/$(cat validator-1.json | jq -r '.[0].node_id'):$(cat validator-1.json | jq -r '.[0].address' | sed 's/^0x//'):$(cat validator-1.json | jq -r '.[0].bls_pubkey')  --validators /dns4/validator-2/tcp/10001/p2p/$(cat validator-2.json | jq -r '.[0].node_id'):$(cat validator-2.json | jq -r '.[0].address' | sed 's/^0x//'):$(cat validator-2.json | jq -r '.[0].bls_pubkey')  \
                 --epoch-size 10 \
                 --native-token-config MyToken:MTK:18:true:$(cat rootchain-wallet.json | jq -r '.ETHAddress')
    polygon-edge polybft stake-manager-deploy \
        --jsonrpc http://gp23-poc3-devnet-geth-0.c.polygon-060623.internal:8545 \
        --test

    #    --private-key $(cat rootchain-wallet.json | jq -r '.HexPrivateKey')

    polygon-edge rootchain deploy \
                 --stake-manager $(cat genesis.json | jq -r '.params.engine.polybft.bridge.stakeManagerAddr') \
                 --stake-token $(cat genesis.json | jq -r '.params.engine.polybft.bridge.stakeTokenAddr') \
                 --json-rpc http://gp23-poc3-devnet-geth-0.c.polygon-060623.internal:8545 \
                 --test

    #             --deployer-key $(cat rootchain-wallet.json | jq -r '.HexPrivateKey') \

    polygon-edge rootchain fund \
                --stake-token $(cat genesis.json | jq -r '.params.engine.polybft.bridge.stakeTokenAddr') \
                --mint \
                --addresses $(cat validator-*.json | jq -r ".[].address" | paste -sd "," - | tr -d '\n') \
                --amounts $(for f in validator-*.json; do echo -n "1000000000000000000000000,"; done | sed 's/,$//') \
                --json-rpc http://gp23-poc3-devnet-geth-0.c.polygon-060623.internal:8545

    #            --private-key $(cat rootchain-wallet.json | jq -r '.HexPrivateKey')

     polygon-edge polybft whitelist-validators \
                  --private-key aa75e9a7d427efc732f8e4f1a5b7646adcc61fd5bae40f80d13c8419c9f43d6d \
                  --addresses $(cat validator-*.json | jq -r ".[].address" | paste -sd "," - | tr -d '\n') \
                  --supernet-manager $(cat genesis.json | jq -r '.params.engine.polybft.bridge.customSupernetManagerAddr') \
                  --jsonrpc http://gp23-poc3-devnet-geth-0.c.polygon-060623.internal:8545

    #              --private-key $(cat rootchain-wallet.json | jq -r '.HexPrivateKey') \

    counter=1
    echo "Registering validator: ${counter}"

    polygon-edge polybft register-validator \
                 --data-dir validator-0 \
                 --supernet-manager $(cat genesis.json | jq -r '.params.engine.polybft.bridge.customSupernetManagerAddr') \
                 --jsonrpc http://gp23-poc3-devnet-geth-0.c.polygon-060623.internal:8545

    polygon-edge polybft stake \
                 --data-dir validator-0 \
                 --amount 1000000000000000000000000 \
                 --supernet-id $(cat genesis.json | jq -r '.params.engine.polybft.supernetID') \
                 --stake-manager $(cat genesis.json | jq -r '.params.engine.polybft.bridge.stakeManagerAddr') \
                 --stake-token $(cat genesis.json | jq -r '.params.engine.polybft.bridge.stakeTokenAddr') \
                 --jsonrpc http://gp23-poc3-devnet-geth-0.c.polygon-060623.internal:8545

    ((counter++))
    echo "Registering validator: ${counter}"

    polygon-edge polybft register-validator \
                 --data-dir validator-3 \
                 --supernet-manager $(cat genesis.json | jq -r '.params.engine.polybft.bridge.customSupernetManagerAddr') \
                 --jsonrpc http://gp23-poc3-devnet-geth-0.c.polygon-060623.internal:8545

    polygon-edge polybft stake \
                 --data-dir validator-3 \
                 --amount 1000000000000000000000000 \
                 --supernet-id $(cat genesis.json | jq -r '.params.engine.polybft.supernetID') \
                 --stake-manager $(cat genesis.json | jq -r '.params.engine.polybft.bridge.stakeManagerAddr') \
                 --stake-token $(cat genesis.json | jq -r '.params.engine.polybft.bridge.stakeTokenAddr') \
                 --jsonrpc http://gp23-poc3-devnet-geth-0.c.polygon-060623.internal:8545

    ((counter++))
    echo "Registering validator: ${counter}"

    polygon-edge polybft register-validator \
                 --data-dir validator-1 \
                 --supernet-manager $(cat genesis.json | jq -r '.params.engine.polybft.bridge.customSupernetManagerAddr') \
                 --jsonrpc http://gp23-poc3-devnet-geth-0.c.polygon-060623.internal:8545

    polygon-edge polybft stake \
                 --data-dir validator-1 \
                 --amount 1000000000000000000000000 \
                 --supernet-id $(cat genesis.json | jq -r '.params.engine.polybft.supernetID') \
                 --stake-manager $(cat genesis.json | jq -r '.params.engine.polybft.bridge.stakeManagerAddr') \
                 --stake-token $(cat genesis.json | jq -r '.params.engine.polybft.bridge.stakeTokenAddr') \
                 --jsonrpc http://gp23-poc3-devnet-geth-0.c.polygon-060623.internal:8545

    ((counter++))
    echo "Registering validator: ${counter}"

    polygon-edge polybft register-validator \
                 --data-dir validator-2 \
                 --supernet-manager $(cat genesis.json | jq -r '.params.engine.polybft.bridge.customSupernetManagerAddr') \
                 --jsonrpc http://gp23-poc3-devnet-geth-0.c.polygon-060623.internal:8545

    polygon-edge polybft stake \
                 --data-dir validator-2 \
                 --amount 1000000000000000000000000 \
                 --supernet-id $(cat genesis.json | jq -r '.params.engine.polybft.supernetID') \
                 --stake-manager $(cat genesis.json | jq -r '.params.engine.polybft.bridge.stakeManagerAddr') \
                 --stake-token $(cat genesis.json | jq -r '.params.engine.polybft.bridge.stakeTokenAddr') \
                 --jsonrpc http://gp23-poc3-devnet-geth-0.c.polygon-060623.internal:8545

    ((counter++))


    polygon-edge polybft supernet \
                 --private-key aa75e9a7d427efc732f8e4f1a5b7646adcc61fd5bae40f80d13c8419c9f43d6d \
                 --supernet-manager $(cat genesis.json | jq -r '.params.engine.polybft.bridge.customSupernetManagerAddr') \
                 --stake-manager $(cat genesis.json | jq -r '.params.engine.polybft.bridge.stakeManagerAddr') \
                 --finalize-genesis-set \
                 --enable-staking \
                 --jsonrpc http://gp23-poc3-devnet-geth-0.c.polygon-060623.internal:8545

    #             --private-key $(cat rootchain-wallet.json | jq -r '.HexPrivateKey') \

    tar czf gp23-poc3.edge.polygon.private.tar.gz *.json validator* core-contracts
    popd
}

main