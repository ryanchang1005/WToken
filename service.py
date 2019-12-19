import os
import json
from web3 import (
    HTTPProvider,
    Web3,
)
from eth_account import Account
from utils.file_utils import read_file_content, get_file_name


class Web3Client:

    @staticmethod
    def get_web3_client(url):
        return Web3(HTTPProvider(url))

    @staticmethod
    def get_contract(web3, contract_address_str, abi_path):
        with open(abi_path) as f:
            my_abi = json.load(f)
        contract_address = web3.toChecksumAddress(contract_address_str)
        return web3.eth.contract(address=contract_address, abi=my_abi)

    @staticmethod
    def get_functions(contract):
        result = []
        for func in contract.all_functions():
            result.append(func)
        return result

    @staticmethod
    def get_decimals(contract):
        return contract.functions.decimals().call()

    @staticmethod
    def get_balance(web3, contract, address):
        return contract.functions.balanceOf(address).call()

    @staticmethod
    def create_account(password):
        return Account.create(password)

    @staticmethod
    def get_account_info(account):
        return {
            'address': account.address,
            'private_key': account.key.hex()
        }

    @staticmethod
    def transfer(web3, contract, addr_from, addr_to, amount, private_key):
        web3.eth.defaultAccount = addr_from

        transaction = contract.functions.transfer(addr_to, amount).buildTransaction(
            {
                'gasPrice': web3.toWei('1', 'gwei'),
                'from': addr_from,
                'nonce': web3.eth.getTransactionCount(addr_from)
            }
        )

        signed_txn = web3.eth.account.signTransaction(transaction, private_key=private_key)
        web3.eth.sendRawTransaction(signed_txn.rawTransaction)

    @staticmethod
    def deploy_contract(web3, sol_path, address):
        from solc import compile_standard
        file_name = get_file_name(sol_path)
        clz_name = file_name.replace('.sol', '')
        sol_content = read_file_content(sol_path)

        # 編譯
        compiled_sol = compile_standard({
            'language': 'Solidity',
            'sources': {
                file_name: {
                    'content': sol_content
                }
            },
            'settings': {
                'outputSelection': {
                    "*": {
                        "*": [
                            "metadata", "evm.bytecode"
                            , "evm.bytecode.sourceMap"
                        ]
                    }
                }
            }
        })

        bytecode = compiled_sol['contracts'][file_name][clz_name]['evm']['bytecode']['object']

        abi = json.loads(compiled_sol['contracts'][file_name][clz_name]['metadata'])['output']['abi']
        #
        # pre_contract = web3.eth.contract(abi=abi, bytecode=bytecode)
        #
        # # 設定部署的帳號
        # pri_key = '413AE44638D2CECC9B5137EC4A9657083C2DF0BBDD1E1105574A3F8EB75F0C81'
        # account = web3.eth.account.privateKeyToAccount(pri_key)
        #
        # # 傳遞建構式參數
        # transaction = pre_contract.constructor(10000, 'WToken3', 'WToken3').buildTransaction(
        #     {
        #         'gasPrice': web3.toWei('10', 'gwei'),
        #         'from': account.address,
        #         'nonce': web3.eth.getTransactionCount(account.address)
        #     }
        # )
        #
        # signed_txn = web3.eth.account.signTransaction(transaction, private_key=pri_key)
        # data = web3.eth.sendRawTransaction(signed_txn.rawTransaction)
        #
        # print(data)
        # print(data.hex())

        contract = web3.eth.contract(address='890e85693d7060d7277bb51facb2d2b69311198e3d5157db59cfc0f8e210c426', abi=abi)

        functions = Web3Client.get_functions(contract)
        print(functions)
        pass
