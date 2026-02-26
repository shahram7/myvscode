// extensions/my-defaults/src/extension.ts
import * as vscode from 'vscode';

export async function activate() {
  const cfg = vscode.workspace.getConfiguration();
  // Force user setting so it shows in settings.json and overrides any prior value
  await cfg.update('window.menuBarVisibility', 'classic', vscode.ConfigurationTarget.Global);
}
