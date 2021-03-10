#!/bin/bash


# Once this script has been ran, please return any remaining fauct funds to this address: 
# addr_test1qqr585tvlc7ylnqvz8pyqwauzrdu0mxag3m7q56grgmgu7sxu2hyfhlkwuxupa9d5085eunq2qywy7hvmvej456flknswgndm3


# SETUP GUIDE
# 1. Run node and wallet 
# 1.1:
#       $ git clone https://github.com/input-output-hk/cardano-node && cd cardano-node
#       $ nix-build default.nix -A scripts.testnet.node -o launch-testnet-node
#       $ ./launch-testnet-node
#       $ export CARDANO_NODE_SOCKET_PATH=<PATH_TO_NODE_SOCKET>
# 1.2:
#       $ git clone https://github.com/input-output-hk/cardano-wallet && cd cardano-wallet
#       $ curl -OL https://raw.githubusercontent.com/input-output-hk/iohk-nix/master/cardano-lib/testnet-byron-genesis.json
#       $ nix-build default.nix -A cardano-wallet -o cardano-wallet
#       $ ./cardano-wallet/bin/cardano-wallet serve --listen-address 127.0.0.1 --port 8090 --testnet ./testnet-byron-genesis.json --node-socket $CARDANO_NODE_SOCKET_PATH --database ./testnet-db
# 2. Run ikar 
# 2.1:
#       $ git clone https://github.com/piotr-iohk/ikar && cd ikar
#       $ docker run --network=host --rm piotrstachyra/icarus:latest
# 3. Use ikar (localhost:4444) to create a wallet and update `Wallet Variables`
# 4. Update the API Key to withdraw funds from the testnet faucet
# 5. ./frag-test.py

setup_variables ()
{
    # Faucet API KEY
    # https://developers.cardano.org/en/testnets/cardano/about/the-testnet-faucet/
    export APIKEY=<APIKEY_HERE>

    # Test Constants
    export UTXO_OUTPUTS=50
    export LOVELACE=$((1 * 1000000)) # 1 ADA

    # Wallet Variables
    export WALLET_PATH_TO_MNEMONICS_FILE=./mnemonic.txt
    export WALLET_WALLETID=0d5744ed252d063967e972fb5c5294fe35e9607f
    export WALLET_PATH_TO_PASS_FILE=./passphrase.txt
    export WALLET_PATH_TO_WALLET_DB=../../cardano-wallet/testnet-db/rnd.0d5744ed252d063967e972fb5c5294fe35e9607f.sqlite

    # Frag Variables
    export FRAG_WALLET="--mnemonics $WALLET_PATH_TO_MNEMONICS_FILE --wid $WALLET_WALLETID --wpass $WALLET_PATH_TO_PASS_FILE --wdb $WALLET_PATH_TO_WALLET_DB --outputs $UTXO_OUTPUTS --total $LOVELACE --testnet --bootstrap"

    # Defrag Variables
    export DEFRAG_WALLET="--mnemonics $WALLET_PATH_TO_MNEMONICS_FILE --wid $WALLET_WALLETID --wpass $WALLET_PATH_TO_PASS_FILE --wdb $WALLET_PATH_TO_WALLET_DB --testnet"

    # Bootstrap Addresses
    export BOOTSTRAP_ADDRESS=$(./frag-ops.py print-bootstrap-address --mnemonics ./mnemonic.txt --testnet --raw)
}

# Needs API key to run this, I used the faucet here https://developers.cardano.org/en/testnets/cardano/tools/faucet/
request_funds_from_faucet () 
{
    curl -v -XPOST "https://faucet.cardano-testnet.iohkdev.io/send-money/$BOOTSTRAP_ADDRESS?apiKey=$APIKEY"
    sleep 3m # Wait for faucet funds
}

frag_wallets ()
{
    ./frag-ops.py frag $FRAG_WALLET
}

defrag_wallets ()
{
    ./frag-ops.py defrag $DEFRAG_WALLET
}

main()
{
    setup_variables
    request_funds_from_faucet
    frag_wallets
    defrag_wallets
}

main

exit $?
