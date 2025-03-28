import * as vscode from 'vscode';

const TerminalLabel = 'Tarantool';
const Tt = 'tt';

function selectTerminal(): Thenable<vscode.Terminal | undefined> {
	interface TerminalQuickPickItem extends vscode.QuickPickItem {
		terminal: vscode.Terminal;
	}
	const terminals = vscode.window.terminals;
	const items: TerminalQuickPickItem[] = terminals.map(t => {
		return {
			label: `name: ${t.name}`,
			terminal: t
		};
	});
	return vscode.window.showQuickPick(items).then(item => {
		return item ? item.terminal : undefined;
	});
}

function getTerminal(): vscode.Terminal {
	const terminal = vscode.window.terminals.find(t => t.name === TerminalLabel) ||
		vscode.window.createTerminal(TerminalLabel);
	terminal.show(true);
	return terminal;
}

function isTerminalRunning(): boolean {
	const terminals = vscode.window.terminals;
	return terminals.find(t => t.name === TerminalLabel) !== undefined;
}

export function init() {
	const t = getTerminal();
	t.sendText('tt init');
}

export function start() {
	const t = getTerminal();
	t.sendText('tt start -i &');
}

export function stop() {
	const t = getTerminal();
	t.sendText('tt stop -y');
}
