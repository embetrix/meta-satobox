# Usage


## Wallets

### Create a Wallet with passphrase and loadable on startup

```
bitcoin-cli -named createwallet wallet_name="Wallet-01" passphrase="passphrase"  load_on_startup=true
```


### Change Wallet passphrase

```
bitcoin-cli -rpcwallet="Wallet-01" walletpassphrasechange "passphrase" "newpassphrase"
```

### Check Wallet

```
bitcoin-cli -rpcwallet="Wallet-01" getwalletinfo
```

### Backing Up the Wallet

```
bitcoin-cli -rpcwallet="Wallet-01" backupwallet /var/run/bitcoin/Wallet-01_Backup.dat
```

### List Wallets

```
bitcoin-cli listwallets
```

### Load Wallet after reboot (and make it automatically loaded upon startup)

```
bitcoin-cli loadwallet "Wallet-01"  true
```

## Transactions

### Create an Addresse

```
bitcoin-cli -rpcwallet=Wallet-01 getnewaddress "someaddress" "bech32"
```

```
bitcoin-cli -rpcwallet=Wallet-02 getnewaddress "someaddress2" "bech32"
```

### Get an Addresse

```
bitcoin-cli -rpcwallet="Wallet-01" getaddressesbylabel "someaddress"
```

```
bitcoin-cli -rpcwallet="Wallet-02" getaddressesbylabel "someaddress2"
```

### Get Balance

```
bitcoin-cli -rpcwallet="Wallet-01" getbalance
```

### Send to address

```
bitcoin-cli -rpcwallet="Wallet-01" walletpassphrase "passphrase" 60

bitcoin-cli -rpcwallet="Wallet-01" sendtoaddress "tb1qcvc44x08p7ey5alewx64z6wm9f67fp9kayjx7s" 0.00010068

```

### List transactions

```
bitcoin-cli -rpcwallet="Wallet-01" listtransactions
```
