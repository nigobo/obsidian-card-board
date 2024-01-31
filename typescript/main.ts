import {
  App,
  Modal,
  Notice,
  Plugin,
  PluginSettingTab,
  Setting,
  TFile,
  addIcon,
  moment,
  normalizePath } from 'obsidian';
import { CardBoardView, VIEW_TYPE_CARD_BOARD } from './view';
import { CardBoardPluginSettings, CardBoardPluginSettingsPostV11 } from './types';
import { Elm, ElmApp, Flags } from '../src/Worker';
import { FileFilter } from './fileFilter'
import { getDateFromFile, IPeriodicNoteSettings } from 'obsidian-daily-notes-interface';

export default class CardBoardPlugin extends Plugin {
  private commandIds: string[] = [];
  private worker:     ElmApp;
  private fileFilter: FileFilter;
  settings:           CardBoardPluginSettings;

  async onload() {
    console.log('loading CardBoard plugin');

    await this.loadSettings();

    const globalSettings : any = this.settings?.data.globalSettings;

    if ((!(globalSettings === undefined)) && globalSettings.hasOwnProperty('filters')) {
      this.fileFilter = new FileFilter(globalSettings.filters);
    } else {
      this.fileFilter = new FileFilter([]);
    }

    this.app.workspace.onLayoutReady(this.onLayoutReady.bind(this));
  }

  async onLayoutReady() {
    // @ts-ignore
    const dataviewSettings = this.app.plugins.getPlugin("dataview")?.settings

    const workerFlags:Flags = {
      uniqueId:           "random",
      now:                Date.now(),
      zone:               new Date().getTimezoneOffset(),
      firstDayOfWeek:     moment.localeData().firstDayOfWeek(),
      settings:           this.settings,
      rightToLeft:        (this.app.vault as any).getConfig("rightToLeft"),
      dataviewTaskCompletion:   {
        taskCompletionTracking:           dataviewSettings  === undefined ? true          : dataviewSettings['taskCompletionTracking'],
        taskCompletionUseEmojiShorthand:  dataviewSettings  === undefined ? false         : dataviewSettings['taskCompletionUseEmojiShorthand'],
        taskCompletionText:               dataviewSettings  === undefined ? "completion"  : dataviewSettings['taskCompletionText']
      }
    };

    // @ts-ignore
    this.worker = Elm.Worker.init({
      flags: workerFlags
    });

    const that = this;

    this.worker.ports.interopFromElm.subscribe((fromElm) => {
      switch (fromElm.tag) {
        case "allTasksLoaded":
          that.handleAllTasksLoaded();
          break;
      }
    });

    const markdownFiles = this.app.vault.getMarkdownFiles();
    const filteredFiles = markdownFiles.filter((file) => this.fileFilter.isAllowed(file.path));

    for (const file of filteredFiles) {
      const fileDate      = this.formattedFileDate(file);
      const fileContents  = await this.app.vault.cachedRead(file);

      this.worker.ports.interopToElm.send({
        tag: "fileAdded",
        data: {
          filePath:     file.path,
          fileDate:     fileDate,
          fileContents: fileContents
        }
      });
    }

    this.worker.ports.interopToElm.send({
      tag: "allMarkdownLoaded",
      data: { }
    });
  }


  async handleAllTasksLoaded() {
    console.log("All tasks loaded");

    this.registerView(
      VIEW_TYPE_CARD_BOARD,
      (leaf) => new CardBoardView(this, leaf)
    );

    addIcon("card-board",
      '<rect x="2" y="2" width="96" height="96" rx="12" ry="12" fill="none" stroke="currentColor" stroke-width="5"></rect>' +
      '<rect x="28" y="28" width="12" height="46" fill="none" stroke="currentColor" stroke-width="5"></rect>' +
      '<rect x="56" y="28" width="12" height="30" fill="none" stroke="currentColor" stroke-width="5"></rect>');

    this.addRibbonIcon('card-board', 'CardBoard', async () => {
      this.activateView(0);
    });

    this.addCommands();
  }

  onunload() {
    console.log('unloading CardBoard plugin');
    this.app.workspace.detachLeavesOfType(VIEW_TYPE_CARD_BOARD);
  }


  addCommands() {
    this.settings?.data?.boardConfigs?.forEach((boardConfig, index) => {
      const config : any = boardConfig;
      var boardName : string;

      if (config.hasOwnProperty('data')) {
        boardName = config.data.title;
      } else {
        boardName = config.name;
      }

      const command = this.addCommand({
        id: "open-card-board-plugin-" + index,
        name: "Open " + boardName,
        callback: async () => {
          this.activateView(index);
        },
      });

      this.commandIds.push(command.id);
    });
  }


  removeCommands() {
    for (const commandId of this.commandIds) {
      // @ts-ignore
      this.app.commands.removeCommand(commandId);
    }
    this.commandIds = [];
  }

  async activateView(index: number) {
    this.app.workspace.detachLeavesOfType(VIEW_TYPE_CARD_BOARD);

    await this.app.workspace.getLeaf(true).setViewState({
      type: VIEW_TYPE_CARD_BOARD,
      active: true,
    });

    const leaf = this.app.workspace.getLeavesOfType(VIEW_TYPE_CARD_BOARD)[0];

    if (leaf.view instanceof CardBoardView) {
      leaf.view.currentBoardIndex(index);
    }

    this.app.workspace.revealLeaf(leaf);
  }

  async deactivateView() {
    this.app.workspace.detachLeavesOfType(VIEW_TYPE_CARD_BOARD);
  }

  async loadSettings() {
    this.settings = await this.loadData();
  }

  async saveSettings( newSettings: CardBoardPluginSettingsPostV11) {
    await this.backupOldVersion(this.settings?.version, newSettings.version);

    this.removeCommands();
    this.addCommands();
    this.settings = newSettings;
    await this.saveData(newSettings);
  }

  async backupOldVersion(oldVersion: string | null, newVersion: string) {
    if (oldVersion && (oldVersion != newVersion)) {
      const pathToSettings = normalizePath(this.app.vault.configDir + "/plugins/card-board/data.json");
      const pathToSavedSettings = normalizePath(this.app.vault.configDir + "/plugins/card-board/data." + oldVersion + ".json");

      if (await this.app.vault.adapter.exists(pathToSavedSettings)) {
        await this.app.vault.adapter.remove(pathToSavedSettings);
      }
      this.app.vault.adapter.copy(pathToSettings, pathToSavedSettings);
    }
  }

  // HELPERS

  formattedFileDate(
    file: TFile
  ): string | null {
    return getDateFromFile(file, "day")?.format('YYYY-MM-DD') || null;
  }
}
