from service import Web3Client

API_KEY = 'xxx'
# URL = 'https://mainnet.infura.io/v3/' + API_KEY # 主鏈
# URL = 'https://ropsten.infura.io/v3/' + API_KEY # 測試鏈
CONTRACT_ADDRESS = '0x123'
ADDRESS1 = '0x123'


def play_eth():
    web3 = Web3Client.get_web3_client(URL)

    print(f'first block:{web3.eth.getBlock(0).hash.hex()}')

    print(f'地址{ADDRESS1}的ETH餘額:')
    print(f'{web3.eth.getBalance(ADDRESS1)} ETH')


ABI_PATH = 'usdt_abi.json'


def play_usdt():
    web3 = Web3Client.get_web3_client(URL)

    contract = Web3Client.get_contract(web3, CONTRACT_ADDRESS, ABI_PATH)

    print(f'USDt functions:')
    print(Web3Client.get_functions(contract))

    contract_decimals = Web3Client.get_decimals(contract)
    contract_balance = Web3Client.get_balance(web3, contract, ADDRESS1)
    usdt_balance = contract_balance / (10 ** contract_decimals)
    print(f'USDt餘額:{usdt_balance}')

    # # 執行交易
    # from_pri_key = '413AE44638D2CECC9B5137EC4A9657083C2DF0BBDD1E1105574A3F8EB75F0C81'
    # print(f'地址{ADDRESS1}給地址{account_info["address"]}, 1塊')
    # Web3Client.transfer(web3, contract, ADDRESS1,
    #                     account_info["address"], 1, from_pri_key)
    # print(f'地址{ADDRESS1}餘額:')
    # print(Web3Client.get_balance(web3, contract, ADDRESS1))
    # print(f'地址{account_info["address"]}餘額:')
    # print(Web3Client.get_balance(web3, contract, account_info["address"]))


def create_account():
    default_password = 'asdn1ind8n102d912nd90n'
    # 新增帳戶
    account = Web3Client.create_account(default_password)

    # 取得帳戶資訊
    print(f'新建立帳戶資訊:')
    account_info = Web3Client.get_account_info(account)
    print(account_info)


DEPLOY_SOL_PATH = 'WToken.sol'


def deploy():
    web3 = Web3Client.get_web3_client(URL)
    Web3Client.deploy_contract(web3, DEPLOY_SOL_PATH, ADDRESS1)


if __name__ == "__main__":
    play_eth()
    # play_usdt()
    # create_account()
    # deploy()
