import { execFileSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import { workflowTests } from './workflow.mjs';
const compiler = process.env.VYPER_BIN || 'vyper';
const source = fileURLToPath(new URL('../vyper/contracts/delivery_escrow.vy', import.meta.url));
const result = JSON.parse(execFileSync(compiler, ['--evm-version', 'shanghai', '-f', 'combined_json', source], { encoding: 'utf8' }));
const artifact = Object.values(result).find(x => x && typeof x === 'object' && x.abi && x.bytecode);
if (!artifact) throw new Error('Vyper 未生成 ABI / bytecode');
workflowTests('Vyper', artifact);
