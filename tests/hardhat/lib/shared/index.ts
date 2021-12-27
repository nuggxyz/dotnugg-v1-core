import { Signer, Contract } from 'ethers';
import { ethers } from 'hardhat';
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/dist/src/signers';
import { DeployOptions } from 'hardhat-deploy/dist/types';

import { MinEthersFactory, GetContractTypeFromFactory, GetARGsTypeFromFactory } from '../../../../typechain/common';

import { getHRE } from './deployment';

const nameofFactory =
    <T>() =>
    (name: keyof T) =>
        name;
export const deployContract = async <CF extends MinEthersFactory<GetContractTypeFromFactory<CF>, any>>({
    factory,
    args,
    from,
}: {
    factory: string;
    args: GetARGsTypeFromFactory<CF>;
    from: Signer | SignerWithAddress;
}): Promise<GetContractTypeFromFactory<CF>> => {
    const signedFactory = (await ethers.getContractFactory(factory)).connect(from);
    const contract = (await signedFactory.deploy(...(Object.values(args) || []))) as Contract;
    const result = (await contract.deployed()) as GetContractTypeFromFactory<CF>;
    return result;
};

export const deployContractWithSalt = async <CF extends MinEthersFactory<GetContractTypeFromFactory<CF>, any>>({
    factory,
    args,
    from,
    salt = '',
    ...options
}: {
    factory: string;
    args: GetARGsTypeFromFactory<CF>;
    from: string;
    salt?: string;
} & DeployOptions): Promise<GetContractTypeFromFactory<CF>> => {
    const deployment = await getHRE().deployments.deploy(factory, {
        from,
        log: true,
        args,
        deterministicDeployment: salt,
        ...options,
    });

    const result = await getHRE().ethers.getContractAt<GetContractTypeFromFactory<CF>>(factory, deployment.address);
    console.log(factory, 'deployed at: ', deployment.address);
    return result;
};

export function encodeParameters(types: any, values: any) {
    const abi = new ethers.utils.AbiCoder();
    return abi.encode(types, values);
}

export async function prepareAccountsWithContext(mochaContext: Mocha.Context) {
    mochaContext.signers = await ethers.getSigners();
    mochaContext.accounts = await ethers.getNamedSigners();
    mochaContext.contracts = {};

    return mochaContext.accounts;
}

export async function prepareAccounts() {
    const res = await ethers.getNamedSigners();
    const hre = getHRE();
    Object.keys(res).forEach((k) => {
        hre.tracer.nameTags[res[k].address] = k;
    });
    return res;
    // return ;
}
