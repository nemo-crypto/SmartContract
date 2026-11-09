import { readFileSync } from 'node:fs';
import solc from 'solc';
import { workflowTests } from './workflow.mjs';
const source = readFileSync(new URL('../solidity/contracts/DeliveryEscrow.sol', import.meta.url), 'utf8');
const output = JSON.parse(solc.compile(JSON.stringify({ language: 'Solidity', sources: { 'DeliveryEscrow.sol': { content: source } }, settings: { evmVersion: 'shanghai', outputSelection: { '*': { '*': ['abi', 'evm.bytecode.object'] } } } })));
const errors = (output.errors ?? []).filter(x => x.severity === 'error');
if (errors.length) throw new Error(errors.map(x => x.formattedMessage).join('\n'));
const contract = output.contracts['DeliveryEscrow.sol'].DeliveryEscrow;
workflowTests('Solidity', { abi: contract.abi, bytecode: '0x' + contract.evm.bytecode.object });
