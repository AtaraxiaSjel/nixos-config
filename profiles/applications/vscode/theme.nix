{ mainuser, linkFarm }:
{ base00-hex, base01-hex, base02-hex, base03-hex, base04-hex, base05-hex, base06-hex, base07-hex, base08-hex, base09-hex
, base0A-hex, base0B-hex, base0C-hex, base0D-hex, base0E-hex, base0F-hex, ... }:
let
  theme = {
    "theme/generated.json" = __toJSON {
      "$schema" = "vscode://schemas/color-theme";
      colors = {
        "activityBar.activeBackground" = "#${base00-hex}";
        "activityBar.background" = "#${base00-hex}";
        "activityBar.dropBackground" = "#${base07-hex}";
        "activityBar.foreground" = "#${base05-hex}";
        "activityBar.inactiveForeground" = "#${base03-hex}";
        "activityBarBadge.background" = "#${base0D-hex}";
        "activityBarBadge.foreground" = "#${base07-hex}";
        "badge.background" = "#${base00-hex}";
        "badge.foreground" = "#${base05-hex}";
        "breadcrumb.activeSelectionForeground" = "#${base07-hex}";
        "breadcrumb.background" = "#${base00-hex}";
        "breadcrumb.focusForeground" = "#${base06-hex}";
        "breadcrumb.foreground" = "#${base05-hex}";
        "breadcrumbPicker.background" = "#${base00-hex}";
        "button.background" = "#${base00-hex}";
        "button.foreground" = "#${base07-hex}";
        "button.hoverBackground" = "#${base04-hex}";
        "button.secondaryBackground" = "#${base0E-hex}";
        "button.secondaryForeground" = "#${base07-hex}";
        "button.secondaryHoverBackground" = "#${base04-hex}";
        "charts.blue" = "#${base0D-hex}";
        "charts.foreground" = "#${base05-hex}";
        "charts.green" = "#${base0B-hex}";
        "charts.lines" = "#${base05-hex}";
        "charts.orange" = "#${base09-hex}";
        "charts.purple" = "#${base0E-hex}";
        "charts.red" = "#${base08-hex}";
        "charts.yellow" = "#${base0A-hex}";
        "checkbox.background" = "#${base01-hex}";
        "checkbox.foreground" = "#${base05-hex}";
        "debugConsole.errorForeground" = "#${base08-hex}";
        "debugConsole.infoForeground" = "#${base05-hex}";
        "debugConsole.sourceForeground" = "#${base05-hex}";
        "debugConsole.warningForeground" = "#${base0A-hex}";
        "debugConsoleInputIcon.foreground" = "#${base05-hex}";
        "debugExceptionWidget.background" = "#${base00-hex}";
        "debugIcon.breakpointCurrentStackframeForeground" = "#${base0A-hex}";
        "debugIcon.breakpointDisabledForeground" = "#${base04-hex}";
        "debugIcon.breakpointForeground" = "#${base08-hex}";
        "debugIcon.breakpointStackframeForeground" = "#${base0F-hex}";
        "debugIcon.breakpointUnverifiedForeground" = "#${base02-hex}";
        "debugIcon.continueForeground" = "#${base0B-hex}";
        "debugIcon.disconnectForeground" = "#${base08-hex}";
        "debugIcon.pauseForeground" = "#${base0D-hex}";
        "debugIcon.restartForeground" = "#${base0B-hex}";
        "debugIcon.startForeground" = "#${base0B-hex}";
        "debugIcon.stepBackForeground" = "#${base0F-hex}";
        "debugIcon.stepIntoForeground" = "#${base0C-hex}";
        "debugIcon.stepOutForeground" = "#${base0E-hex}";
        "debugIcon.stepOverForeground" = "#${base0D-hex}";
        "debugIcon.stopForeground" = "#${base08-hex}";
        "debugTokenExpression.boolean" = "#${base09-hex}";
        "debugTokenExpression.error" = "#${base08-hex}";
        "debugTokenExpression.name" = "#${base0E-hex}";
        "debugTokenExpression.number" = "#${base09-hex}";
        "debugTokenExpression.string" = "#${base0B-hex}";
        "debugTokenExpression.value" = "#${base05-hex}";
        "debugToolBar.background" = "#${base00-hex}";
        "debugView.stateLabelBackground" = "#${base0D-hex}";
        "debugView.stateLabelForeground" = "#${base07-hex}";
        "debugView.valueChangedHighlight" = "#${base0D-hex}";
        descriptionForeground = "#${base03-hex}";
        "diffEditor.diagonalFill" = "#${base02-hex}";
        "diffEditor.insertedTextBackground" = "#${base0B-hex}20";
        "diffEditor.removedTextBackground" = "#${base08-hex}20";
        "dropdown.background" = "#${base00-hex}";
        "dropdown.foreground" = "#${base05-hex}";
        "dropdown.listBackground" = "#${base00-hex}";
        "editor.background" = "#${base00-hex}";
        "editor.findMatchBackground" = "#${base0A-hex}6f";
        "editor.findMatchHighlightBackground" = "#${base09-hex}6f";
        "editor.findRangeHighlightBackground" = "#${base00-hex}6f";
        "editor.foreground" = "#${base05-hex}";
        "editor.hoverHighlightBackground" = "#${base02-hex}6f";
        "editor.inactiveSelectionBackground" = "#${base02-hex}";
        "editor.lineHighlightBackground" = "#${base00-hex}";
        "editor.rangeHighlightBackground" = "#${base00-hex}6f";
        "editor.selectionBackground" = "#${base01-hex}";
        "editor.selectionHighlightBackground" = "#${base00-hex}";
        "editor.snippetFinalTabstopHighlightBackground" = "#${base03-hex}";
        "editor.snippetTabstopHighlightBackground" = "#${base02-hex}";
        "editor.wordHighlightBackground" = "#${base02-hex}6f";
        "editor.wordHighlightStrongBackground" = "#${base03-hex}6f";
        "editorBracketMatch.background" = "#${base02-hex}";
        "editorCodeLens.foreground" = "#${base02-hex}";
        "editorCursor.foreground" = "#${base05-hex}";
        "editorError.foreground" = "#${base08-hex}";
        "editorGroup.background" = "#${base00-hex}";
        "editorGroup.dropBackground" = "#${base02-hex}6f";
        "editorGroup.emptyBackground" = "#${base00-hex}";
        "editorGroupHeader.noTabsBackground" = "#${base00-hex}";
        "editorGroupHeader.tabsBackground" = "#${base00-hex}";
        "editorGutter.addedBackground" = "#${base0B-hex}";
        "editorGutter.background" = "#${base00-hex}";
        "editorGutter.commentRangeForeground" = "#${base04-hex}";
        "editorGutter.deletedBackground" = "#${base08-hex}";
        "editorGutter.foldingControlForeground" = "#${base05-hex}";
        "editorGutter.modifiedBackground" = "#${base0E-hex}";
        "editorHint.foreground" = "#${base0D-hex}";
        "editorHoverWidget.background" = "#${base00-hex}";
        "editorHoverWidget.foreground" = "#${base05-hex}";
        "editorIndentGuide.activeBackground" = "#${base04-hex}";
        "editorIndentGuide.background" = "#${base03-hex}";
        "editorInfo.foreground" = "#${base0C-hex}";
        "editorLightBulb.foreground" = "#${base0A-hex}";
        "editorLightBulbAutoFix.foreground" = "#${base0D-hex}";
        "editorLineNumber.activeForeground" = "#${base04-hex}";
        "editorLineNumber.foreground" = "#${base03-hex}";
        "editorLink.activeForeground" = "#${base0D-hex}";
        "editorMarkerNavigation.background" = "#${base00-hex}";
        "editorMarkerNavigationError.background" = "#${base08-hex}";
        "editorMarkerNavigationInfo.background" = "#${base0D-hex}";
        "editorMarkerNavigationWarning.background" = "#${base0A-hex}";
        "editorOverviewRuler.addedForeground" = "#${base0B-hex}";
        "editorOverviewRuler.bracketMatchForeground" = "#${base06-hex}";
        "editorOverviewRuler.commonContentForeground" = "#${base0F-hex}";
        "editorOverviewRuler.currentContentForeground" = "#${base0D-hex}";
        "editorOverviewRuler.deletedForeground" = "#${base08-hex}";
        "editorOverviewRuler.errorForeground" = "#${base08-hex}";
        "editorOverviewRuler.findMatchForeground" = "#${base0A-hex}6f";
        "editorOverviewRuler.incomingContentForeground" = "#${base0B-hex}";
        "editorOverviewRuler.infoForeground" = "#${base0C-hex}";
        "editorOverviewRuler.modifiedForeground" = "#${base0E-hex}";
        "editorOverviewRuler.rangeHighlightForeground" = "#${base03-hex}6f";
        "editorOverviewRuler.selectionHighlightForeground" = "#${base02-hex}6f";
        "editorOverviewRuler.warningForeground" = "#${base0A-hex}";
        "editorOverviewRuler.wordHighlightForeground" = "#${base07-hex}6f";
        "editorOverviewRuler.wordHighlightStrongForeground" = "#${base0D-hex}6f";
        "editorPane.background" = "#${base00-hex}";
        "editorRuler.foreground" = "#${base03-hex}";
        "editorSuggestWidget.background" = "#${base00-hex}";
        "editorSuggestWidget.foreground" = "#${base05-hex}";
        "editorSuggestWidget.highlightForeground" = "#${base0D-hex}";
        "editorSuggestWidget.selectedBackground" = "#${base02-hex}";
        "editorWarning.foreground" = "#${base0A-hex}";
        "editorWhitespace.foreground" = "#${base03-hex}";
        "editorWidget.background" = "#${base00-hex}";
        "editorWidget.foreground" = "#${base05-hex}";
        errorForeground = "#${base08-hex}";
        "extensionBadge.remoteBackground" = "#${base09-hex}";
        "extensionBadge.remoteForeground" = "#${base07-hex}";
        "extensionButton.prominentBackground" = "#${base0B-hex}";
        "extensionButton.prominentForeground" = "#${base07-hex}";
        "extensionButton.prominentHoverBackground" = "#${base02-hex}";
        foreground = "#${base05-hex}";
        "gitDecoration.addedResourceForeground" = "#${base0B-hex}";
        "gitDecoration.conflictingResourceForeground" = "#${base09-hex}";
        "gitDecoration.deletedResourceForeground" = "#${base08-hex}";
        "gitDecoration.ignoredResourceForeground" = "#${base03-hex}";
        "gitDecoration.modifiedResourceForeground" = "#${base0A-hex}";
        "gitDecoration.stageDeletedResourceForeground" = "#${base0C-hex}";
        "gitDecoration.stageModifiedResourceForeground" = "#${base0C-hex}";
        "gitDecoration.submoduleResourceForeground" = "#${base0F-hex}";
        "gitDecoration.untrackedResourceForeground" = "#${base0E-hex}";
        "icon.foreground" = "#${base04-hex}";
        "input.background" = "#${base00-hex}";
        "input.foreground" = "#${base05-hex}";
        "input.placeholderForeground" = "#${base03-hex}";
        "inputOption.activeBackground" = "#${base02-hex}";
        "inputOption.activeBorder" = "#${base09-hex}";
        "inputOption.activeForeground" = "#${base05-hex}";
        "inputValidation.errorBackground" = "#${base08-hex}";
        "inputValidation.errorBorder" = "#${base08-hex}";
        "inputValidation.errorForeground" = "#${base05-hex}";
        "inputValidation.infoBackground" = "#${base0D-hex}";
        "inputValidation.infoBorder" = "#${base0D-hex}";
        "inputValidation.infoForeground" = "#${base05-hex}";
        "inputValidation.warningBackground" = "#${base0A-hex}";
        "inputValidation.warningBorder" = "#${base0A-hex}";
        "inputValidation.warningForeground" = "#${base05-hex}";
        "list.activeSelectionBackground" = "#${base01-hex}";
        "list.activeSelectionForeground" = "#${base05-hex}";
        "list.dropBackground" = "#${base07-hex}";
        "list.errorForeground" = "#${base08-hex}";
        "list.filterMatchBackground" = "#${base02-hex}";
        "list.focusBackground" = "#${base02-hex}";
        "list.focusForeground" = "#${base05-hex}";
        "list.highlightForeground" = "#${base07-hex}";
        "list.hoverBackground" = "#${base03-hex}";
        "list.hoverForeground" = "#${base05-hex}";
        "list.inactiveFocusBackground" = "#${base02-hex}";
        "list.inactiveSelectionBackground" = "#${base02-hex}";
        "list.inactiveSelectionForeground" = "#${base05-hex}";
        "list.invalidItemForeground" = "#${base08-hex}";
        "list.warningForeground" = "#${base0A-hex}";
        "listFilterWidget.background" = "#${base00-hex}";
        "listFilterWidget.noMatchesOutline" = "#${base08-hex}";
        "menu.background" = "#${base00-hex}";
        "menu.foreground" = "#${base05-hex}";
        "menu.selectionBackground" = "#${base02-hex}";
        "menu.selectionForeground" = "#${base05-hex}";
        "menu.separatorBackground" = "#${base07-hex}";
        "menubar.selectionBackground" = "#${base00-hex}";
        "menubar.selectionForeground" = "#${base05-hex}";
        "merge.currentContentBackground" = "#${base0D-hex}40";
        "merge.currentHeaderBackground" = "#${base0D-hex}40";
        "merge.incomingContentBackground" = "#${base0B-hex}60";
        "merge.incomingHeaderBackground" = "#${base0B-hex}60";
        "minimap.background" = "#${base00-hex}";
        "minimap.errorHighlight" = "#${base08-hex}";
        "minimap.findMatchHighlight" = "#${base0A-hex}6f";
        "minimap.selectionHighlight" = "#${base02-hex}6f";
        "minimap.warningHighlight" = "#${base0A-hex}";
        "minimapGutter.addedBackground" = "#${base0B-hex}";
        "minimapGutter.deletedBackground" = "#${base08-hex}";
        "minimapGutter.modifiedBackground" = "#${base0E-hex}";
        "notebook.rowHoverBackground" = "#${base00-hex}";
        "notification.background" = "#${base02-hex}";
        "notification.buttonBackground" = "#${base0D-hex}";
        "notification.buttonForeground" = "#${base07-hex}";
        "notification.buttonHoverBackground" = "#${base02-hex}";
        "notification.errorBackground" = "#${base08-hex}";
        "notification.errorForeground" = "#${base07-hex}";
        "notification.foreground" = "#${base05-hex}";
        "notification.infoBackground" = "#${base0C-hex}";
        "notification.infoForeground" = "#${base07-hex}";
        "notification.warningBackground" = "#${base0A-hex}";
        "notification.warningForeground" = "#${base07-hex}";
        "notificationCenterHeader.background" = "#${base00-hex}";
        "notificationCenterHeader.foreground" = "#${base05-hex}";
        "notificationLink.foreground" = "#${base0D-hex}";
        "notifications.background" = "#${base02-hex}";
        "notifications.foreground" = "#${base05-hex}";
        "notificationsErrorIcon.foreground" = "#${base08-hex}";
        "notificationsInfoIcon.foreground" = "#${base0D-hex}";
        "notificationsWarningIcon.foreground" = "#${base0A-hex}";
        "panel.background" = "#${base00-hex}";
        "panel.dropBackground" = "#${base00-hex}6f";
        "panelTitle.activeForeground" = "#${base05-hex}";
        "panelTitle.inactiveForeground" = "#${base03-hex}";
        "peekViewEditor.background" = "#${base00-hex}";
        "peekViewEditor.matchHighlightBackground" = "#${base09-hex}6f";
        "peekViewEditorGutter.background" = "#${base00-hex}";
        "peekViewResult.background" = "#${base00-hex}";
        "peekViewResult.fileForeground" = "#${base05-hex}";
        "peekViewResult.lineForeground" = "#${base03-hex}";
        "peekViewResult.matchHighlightBackground" = "#${base09-hex}6f";
        "peekViewResult.selectionBackground" = "#${base02-hex}";
        "peekViewResult.selectionForeground" = "#${base05-hex}";
        "peekViewTitle.background" = "#${base02-hex}";
        "peekViewTitleDescription.foreground" = "#${base03-hex}";
        "peekViewTitleLabel.foreground" = "#${base05-hex}";
        "pickerGroup.foreground" = "#${base03-hex}";
        "problemsErrorIcon.foreground" = "#${base08-hex}";
        "problemsInfoIcon.foreground" = "#${base0C-hex}";
        "problemsWarningIcon.foreground" = "#${base0A-hex}";
        "progressBar.background" = "#${base03-hex}";
        "quickInput.background" = "#${base00-hex}";
        "quickInput.foreground" = "#${base05-hex}";
        "scrollbar.shadow" = "#${base00-hex}";
        "scrollbarSlider.activeBackground" = "#${base04-hex}6f";
        "scrollbarSlider.background" = "#${base02-hex}6f";
        "scrollbarSlider.hoverBackground" = "#${base03-hex}6f";
        "selection.background" = "#${base01-hex}";
        "settings.checkboxBackground" = "#${base01-hex}";
        "settings.checkboxForeground" = "#${base05-hex}";
        "settings.dropdownBackground" = "#${base01-hex}";
        "settings.dropdownForeground" = "#${base05-hex}";
        "settings.focusedRowBackground" = "#${base02-hex}";
        "settings.headerForeground" = "#${base05-hex}";
        "settings.modifiedItemForeground" = "#${base0D-hex}";
        "settings.modifiedItemIndicator" = "#${base0D-hex}";
        "settings.numberInputBackground" = "#${base00-hex}";
        "settings.numberInputForeground" = "#${base05-hex}";
        "settings.textInputBackground" = "#${base01-hex}";
        "settings.textInputForeground" = "#${base05-hex}";
        "sideBar.background" = "#${base00-hex}";
        "sideBar.dropBackground" = "#${base01-hex}6f";
        "sideBar.foreground" = "#${base05-hex}";
        "sideBarSectionHeader.background" = "#${base00-hex}";
        "sideBarSectionHeader.foreground" = "#${base05-hex}";
        "sideBarTitle.foreground" = "#${base05-hex}";
        "statusBar.background" = "#${base0D-hex}";
        "statusBar.debuggingBackground" = "#${base09-hex}";
        "statusBar.debuggingForeground" = "#${base07-hex}";
        "statusBar.foreground" = "#${base07-hex}";
        "statusBar.noFolderBackground" = "#${base0E-hex}";
        "statusBar.noFolderForeground" = "#${base07-hex}";
        "statusBarItem.activeBackground" = "#${base03-hex}";
        "statusBarItem.errorBackground" = "#${base08-hex}";
        "statusBarItem.errorForeground" = "#${base07-hex}";
        "statusBarItem.hoverBackground" = "#${base02-hex}";
        "statusBarItem.prominentBackground" = "#${base0E-hex}";
        "statusBarItem.prominentForeground" = "#${base07-hex}";
        "statusBarItem.prominentHoverBackground" = "#${base08-hex}";
        "statusBarItem.remoteBackground" = "#${base0B-hex}";
        "statusBarItem.remoteForeground" = "#${base07-hex}";
        "symbolIcon.arrayForeground" = "#${base05-hex}";
        "symbolIcon.booleanForeground" = "#${base09-hex}";
        "symbolIcon.classForeground" = "#${base0A-hex}";
        "symbolIcon.colorForeground" = "#f0f";
        "symbolIcon.constantForeground" = "#${base09-hex}";
        "symbolIcon.constructorForeground" = "#${base0D-hex}";
        "symbolIcon.enumeratorForeground" = "#${base09-hex}";
        "symbolIcon.enumeratorMemberForeground" = "#${base0D-hex}";
        "symbolIcon.eventForeground" = "#${base0A-hex}";
        "symbolIcon.fieldForeground" = "#${base08-hex}";
        "symbolIcon.fileForeground" = "#${base05-hex}";
        "symbolIcon.folderForeground" = "#${base05-hex}";
        "symbolIcon.functionForeground" = "#${base0D-hex}";
        "symbolIcon.interfaceForeground" = "#${base0D-hex}";
        "symbolIcon.keyForeground" = "#f0f";
        "symbolIcon.keywordForeground" = "#${base0E-hex}";
        "symbolIcon.methodForeground" = "#${base0D-hex}";
        "symbolIcon.moduleForeground" = "#${base05-hex}";
        "symbolIcon.namespaceForeground" = "#${base05-hex}";
        "symbolIcon.nullForeground" = "#${base0F-hex}";
        "symbolIcon.numberForeground" = "#${base09-hex}";
        "symbolIcon.objectForeground" = "#f0f";
        "symbolIcon.operatorForeground" = "#f0f";
        "symbolIcon.packageForeground" = "#f0f";
        "symbolIcon.propertyForeground" = "#${base05-hex}";
        "symbolIcon.referenceForeground" = "#f0f";
        "symbolIcon.snippetForeground" = "#${base05-hex}";
        "symbolIcon.stringForeground" = "#${base0B-hex}";
        "symbolIcon.structForeground" = "#${base0A-hex}";
        "symbolIcon.textForeground" = "#${base05-hex}";
        "symbolIcon.typeParameterForeground" = "#f0f";
        "symbolIcon.unitForeground" = "#f0f";
        "symbolIcon.variableForeground" = "#${base08-hex}";
        "tab.activeBackground" = "#${base01-hex}";
        "tab.activeForeground" = "#${base05-hex}";
        "tab.activeModifiedBorder" = "#${base0D-hex}";
        "tab.hoverBackground" = "#${base02-hex}";
        "tab.inactiveBackground" = "#${base00-hex}";
        "tab.inactiveForeground" = "#${base03-hex}";
        "tab.inactiveModifiedBorder" = "#${base0D-hex}";
        "tab.unfocusedActiveBackground" = "#${base00-hex}";
        "tab.unfocusedActiveForeground" = "#${base04-hex}";
        "tab.unfocusedActiveModifiedBorder" = "#${base0D-hex}";
        "tab.unfocusedHoverBackground" = "#${base02-hex}";
        "tab.unfocusedInactiveForeground" = "#${base03-hex}";
        "tab.unfocusedInactiveModifiedBorder" = "#${base0D-hex}";
        "terminal.ansiBlack" = "#${base00-hex}";
        "terminal.ansiBlue" = "#${base0D-hex}";
        "terminal.ansiBrightBlack" = "#${base03-hex}";
        "terminal.ansiBrightBlue" = "#${base0D-hex}";
        "terminal.ansiBrightCyan" = "#${base0C-hex}";
        "terminal.ansiBrightGreen" = "#${base0B-hex}";
        "terminal.ansiBrightMagenta" = "#${base0E-hex}";
        "terminal.ansiBrightRed" = "#${base08-hex}";
        "terminal.ansiBrightWhite" = "#${base07-hex}";
        "terminal.ansiBrightYellow" = "#${base0A-hex}";
        "terminal.ansiCyan" = "#${base0C-hex}";
        "terminal.ansiGreen" = "#${base0B-hex}";
        "terminal.ansiMagenta" = "#${base0E-hex}";
        "terminal.ansiRed" = "#${base08-hex}";
        "terminal.ansiWhite" = "#${base05-hex}";
        "terminal.ansiYellow" = "#${base0A-hex}";
        "terminal.background" = "#${base00-hex}";
        "terminal.foreground" = "#${base05-hex}";
        "terminalCursor.foreground" = "#${base05-hex}";
        "textBlockQuote.background" = "#${base00-hex}";
        "textBlockQuote.border" = "#${base0D-hex}";
        "textCodeBlock.background" = "#${base00-hex}";
        "textLink.activeForeground" = "#${base0C-hex}";
        "textLink.foreground" = "#${base0D-hex}";
        "textPreformat.foreground" = "#${base0D-hex}";
        "textSeparator.foreground" = "#f0f";
        "titleBar.activeBackground" = "#${base01-hex}";
        "titleBar.activeForeground" = "#${base05-hex}";
        "titleBar.inactiveBackground" = "#${base00-hex}";
        "titleBar.inactiveForeground" = "#${base03-hex}";
        "tree.indentGuidesStroke" = "#${base05-hex}";
        "walkThrough.embeddedEditorBackground" = "#${base00-hex}";
        "welcomePage.background" = "#${base00-hex}";
        "welcomePage.buttonBackground" = "#${base00-hex}";
        "welcomePage.buttonHoverBackground" = "#${base02-hex}";
        "widget.shadow" = "#${base00-hex}";
      };
      name = "Generated theme";
      tokenColors = [
        {
          name = "Comment";
          scope = [ "comment" "punctuation.definition.comment" ];
          settings = {
            fontStyle = "italic";
            foreground = "#${base03-hex}";
          };
        }
        {
          name = "Variables, Parameters";
          scope = [
            "variable"
            "string constant.other.placeholder"
            "entity.name.variable.parameter"
            "entity.name.variable.local"
            "variable.parameter"
          ];
          settings = { foreground = "#${base05-hex}"; };
        }
        {
          name = "Properties";
          scope = [ "variable.other.object.property" ];
          settings = { foreground = "#${base0D-hex}"; };
        }
        {
          name = "Colors";
          scope = [ "constant.other.color" ];
          settings = { foreground = "#${base0B-hex}"; };
        }
        {
          name = "Invalid";
          scope = [ "invalid" "invalid.illegal" ];
          settings = { foreground = "#${base08-hex}"; };
        }
        {
          name = "Invalid - Deprecated";
          scope = [ "invalid.deprecated" ];
          settings = { foreground = "#${base0F-hex}"; };
        }
        {
          name = "Keyword, Storage";
          scope = [ "keyword" "storage.modifier" ];
          settings = { foreground = "#${base0E-hex}"; };
        }
        {
          name = "Keyword Control";
          scope = [
            "keyword.control"
            "keyword.control.flow"
            "keyword.control.from"
            "keyword.control.import"
            "keyword.control.as"
          ];
          settings = { foreground = "#${base0E-hex}"; };
        }
        {
          name = "Keyword";
          scope = [
            "keyword.other.using"
            "keyword.other.namespace"
            "keyword.other.class"
            "keyword.other.new"
            "keyword.other.event"
            "keyword.other.this"
            "keyword.other.await"
            "keyword.other.var"
            "keyword.other.package"
            "keyword.other.import"
            "variable.language.this"
            "storage.type.ts"
          ];
          settings = { foreground = "#${base0E-hex}"; };
        }
        {
          name = "Types, Primitives";
          scope = [ "keyword.type" "storage.type.primitive" ];
          settings = { foreground = "#${base0C-hex}"; };
        }
        {
          name = "Function";
          scope = [ "storage.type.function" ];
          settings = { foreground = "#${base0D-hex}"; };
        }
        {
          name = "Operator, Misc";
          scope = [
            "constant.other.color"
            "punctuation"
            "punctuation.section.class.end"
            "meta.tag"
            "punctuation.definition.tag"
            "punctuation.separator.inheritance.php"
            "punctuation.definition.tag.html"
            "punctuation.definition.tag.begin.html"
            "punctuation.definition.tag.end.html"
            "keyword.other.template"
            "keyword.other.substitution"
          ];
          settings = { foreground = "#${base04-hex}"; };
        }
        {
          name = "Embedded";
          scope = [ "punctuation.section.embedded" "variable.interpolation" ];
          settings = { foreground = "#${base0C-hex}"; };
        }
        {
          name = "Tag";
          scope =
            [ "entity.name.tag" "meta.tag.sgml" "markup.deleted.git_gutter" ];
          settings = { foreground = "#${base08-hex}"; };
        }
        {
          name = "Function, Special Method";
          scope = [
            "entity.name.function"
            "meta.function-call"
            "variable.function"
            "support.function"
            "keyword.other.special-method"
          ];
          settings = { foreground = "#${base0D-hex}"; };
        }
        {
          name = "Block Level Variables";
          scope = [ "meta.block variable.other" ];
          settings = { foreground = "#${base08-hex}"; };
        }
        {
          name = "Other Variable, String Link";
          scope = [ "support.other.variable" "string.other.link" ];
          settings = { foreground = "#${base08-hex}"; };
        }
        {
          name = "Number, Constant, Function Argument, Tag Attribute, Embedded";
          scope = [
            "constant.numeric"
            "constant.language"
            "support.constant"
            "constant.character"
            "constant.escape"
            "keyword.other.unit"
            "keyword.other"
          ];
          settings = { foreground = "#${base09-hex}"; };
        }
        {
          name = "String, Symbols, Inherited Class, Markup Heading";
          scope = [
            "string"
            "constant.other.symbol"
            "constant.other.key"
            "entity.other.inherited-class"
            "markup.heading"
            "markup.inserted.git_gutter"
            "meta.group.braces.curly constant.other.object.key.js string.unquoted.label.js"
          ];
          settings = {
            fontStyle = "";
            foreground = "#${base0B-hex}";
          };
        }
        {
          name = "Class, Support";
          scope = [
            "entity.name"
            "support.type"
            "support.class"
            "support.other.namespace.use.php"
            "meta.use.php"
            "support.other.namespace.php"
            "markup.changed.git_gutter"
            "support.type.sys-types"
          ];
          settings = { foreground = "#${base0A-hex}"; };
        }
        {
          name = "Storage Type, Import Class";
          scope = [
            "storage.type"
            "storage.modifier.package"
            "storage.modifier.import"
          ];
          settings = { foreground = "#${base0A-hex}"; };
        }
        {
          name = "Fields";
          scope = [ "entity.name.variable.field" ];
          settings = { foreground = "#${base0D-hex}"; };
        }
        {
          name = "Entity Types";
          scope = [ "support.type" ];
          settings = { foreground = "#${base0C-hex}"; };
        }
        {
          name = "CSS Class and Support";
          scope = [
            "source.css support.type.property-name"
            "source.sass support.type.property-name"
            "source.scss support.type.property-name"
            "source.less support.type.property-name"
            "source.stylus support.type.property-name"
            "source.postcss support.type.property-name"
          ];
          settings = { foreground = "#${base0C-hex}"; };
        }
        {
          name = "Sub-methods";
          scope = [
            "entity.name.module.js"
            "variable.import.parameter.js"
            "variable.other.class.js"
          ];
          settings = { foreground = "#${base08-hex}"; };
        }
        {
          name = "Language methods";
          scope = [ "variable.language" ];
          settings = {
            fontStyle = "italic";
            foreground = "#${base08-hex}";
          };
        }
        {
          name = "entity.name.method.js";
          scope = [ "entity.name.method.js" ];
          settings = {
            fontStyle = "italic";
            foreground = "#${base0D-hex}";
          };
        }
        {
          name = "meta.method.js";
          scope = [
            "meta.class-method.js entity.name.function.js"
            "variable.function.constructor"
          ];
          settings = { foreground = "#${base0D-hex}"; };
        }
        {
          name = "Attributes";
          scope = [ "entity.other.attribute-name" ];
          settings = { foreground = "#${base0D-hex}"; };
        }
        {
          name = "HTML Attributes";
          scope = [
            "text.html.basic entity.other.attribute-name.html"
            "text.html.basic entity.other.attribute-name"
          ];
          settings = {
            fontStyle = "italic";
            foreground = "#${base0A-hex}";
          };
        }
        {
          name = "CSS Classes";
          scope = [ "entity.other.attribute-name.class" ];
          settings = { foreground = "#${base0A-hex}"; };
        }
        {
          name = "CSS ID's";
          scope = [ "source.sass keyword.control" ];
          settings = { foreground = "#${base0D-hex}"; };
        }
        {
          name = "Inserted";
          scope = [ "markup.inserted" ];
          settings = { foreground = "#${base0B-hex}"; };
        }
        {
          name = "Deleted";
          scope = [ "markup.deleted" ];
          settings = { foreground = "#${base08-hex}"; };
        }
        {
          name = "Changed";
          scope = [ "markup.changed" ];
          settings = { foreground = "#${base0E-hex}"; };
        }
        {
          name = "Regular Expressions";
          scope = [ "string.regexp" ];
          settings = { foreground = "#${base0C-hex}"; };
        }
        {
          name = "Escape Characters";
          scope = [ "constant.character.escape" ];
          settings = { foreground = "#${base0C-hex}"; };
        }
        {
          name = "URL";
          scope = [ "*url*" "*link*" "*uri*" ];
          settings = { fontStyle = "underline"; };
        }
        {
          name = "Decorators";
          scope = [
            "tag.decorator.js entity.name.tag.js"
            "tag.decorator.js punctuation.definition.tag.js"
          ];
          settings = {
            fontStyle = "italic";
            foreground = "#${base0D-hex}";
          };
        }
        {
          name = "ES7 Bind Operator";
          scope = [
            "source.js constant.other.object.key.js string.unquoted.label.js"
          ];
          settings = {
            fontStyle = "italic";
            foreground = "#${base0E-hex}";
          };
        }
        {
          name = "JSON Key - Level 0";
          scope = [
            "source.json meta.structure.dictionary.json support.type.property-name.json"
          ];
          settings = { foreground = "#${base0D-hex}"; };
        }
        {
          name = "JSON Key - Level 1";
          scope = [
            "source.json meta.structure.dictionary.json meta.structure.dictionary.value.json meta.structure.dictionary.json support.type.property-name.json"
          ];
          settings = { foreground = "#${base0D-hex}"; };
        }
        {
          name = "JSON Key - Level 2";
          scope = [
            "source.json meta.structure.dictionary.json meta.structure.dictionary.value.json meta.structure.dictionary.json meta.structure.dictionary.value.json meta.structure.dictionary.json support.type.property-name.json"
          ];
          settings = { foreground = "#${base0D-hex}"; };
        }
        {
          name = "JSON Key - Level 3";
          scope = [
            "source.json meta.structure.dictionary.json meta.structure.dictionary.value.json meta.structure.dictionary.json meta.structure.dictionary.value.json meta.structure.dictionary.json meta.structure.dictionary.value.json meta.structure.dictionary.json support.type.property-name.json"
          ];
          settings = { foreground = "#${base0D-hex}"; };
        }
        {
          name = "JSON Key - Level 4";
          scope = [
            "source.json meta.structure.dictionary.json meta.structure.dictionary.value.json meta.structure.dictionary.json meta.structure.dictionary.value.json meta.structure.dictionary.json meta.structure.dictionary.value.json meta.structure.dictionary.json meta.structure.dictionary.value.json meta.structure.dictionary.json support.type.property-name.json"
          ];
          settings = { foreground = "#${base0D-hex}"; };
        }
        {
          name = "JSON Key - Level 5";
          scope = [
            "source.json meta.structure.dictionary.json meta.structure.dictionary.value.json meta.structure.dictionary.json meta.structure.dictionary.value.json meta.structure.dictionary.json meta.structure.dictionary.value.json meta.structure.dictionary.json meta.structure.dictionary.value.json meta.structure.dictionary.json meta.structure.dictionary.value.json meta.structure.dictionary.json support.type.property-name.json"
          ];
          settings = { foreground = "#${base0D-hex}"; };
        }
        {
          name = "JSON Key - Level 6";
          scope = [
            "source.json meta.structure.dictionary.json meta.structure.dictionary.value.json meta.structure.dictionary.json meta.structure.dictionary.value.json meta.structure.dictionary.json meta.structure.dictionary.value.json meta.structure.dictionary.json meta.structure.dictionary.value.json meta.structure.dictionary.json meta.structure.dictionary.value.json meta.structure.dictionary.json meta.structure.dictionary.value.json meta.structure.dictionary.json support.type.property-name.json"
          ];
          settings = { foreground = "#${base0D-hex}"; };
        }
        {
          name = "JSON Key - Level 7";
          scope = [
            "source.json meta.structure.dictionary.json meta.structure.dictionary.value.json meta.structure.dictionary.json meta.structure.dictionary.value.json meta.structure.dictionary.json meta.structure.dictionary.value.json meta.structure.dictionary.json meta.structure.dictionary.value.json meta.structure.dictionary.json meta.structure.dictionary.value.json meta.structure.dictionary.json meta.structure.dictionary.value.json meta.structure.dictionary.json meta.structure.dictionary.value.json meta.structure.dictionary.json support.type.property-name.json"
          ];
          settings = { foreground = "#${base0D-hex}"; };
        }
        {
          name = "JSON Key - Level 8";
          scope = [
            "source.json meta.structure.dictionary.json meta.structure.dictionary.value.json meta.structure.dictionary.json meta.structure.dictionary.value.json meta.structure.dictionary.json meta.structure.dictionary.value.json meta.structure.dictionary.json meta.structure.dictionary.value.json meta.structure.dictionary.json meta.structure.dictionary.value.json meta.structure.dictionary.json meta.structure.dictionary.value.json meta.structure.dictionary.json meta.structure.dictionary.value.json meta.structure.dictionary.json meta.structure.dictionary.value.json meta.structure.dictionary.json support.type.property-name.json"
          ];
          settings = { foreground = "#${base0D-hex}"; };
        }
        {
          name = "Markdown - Plain";
          scope = [
            "text.html.markdown"
            "punctuation.definition.list_item.markdown"
          ];
          settings = { foreground = "#${base05-hex}"; };
        }
        {
          name = "Markdown - Markup Raw Inline";
          scope = [ "text.html.markdown markup.inline.raw.markdown" ];
          settings = { foreground = "#${base0E-hex}"; };
        }
        {
          name = "Markdown - Markup Raw Inline Punctuation";
          scope = [
            "text.html.markdown markup.inline.raw.markdown punctuation.definition.raw.markdown"
          ];
          settings = { foreground = "#${base0C-hex}"; };
        }
        {
          name = "Markdown - Line Break";
          scope = [ "text.html.markdown meta.dummy.line-break" ];
          settings = { foreground = "#${base03-hex}"; };
        }
        {
          name = "Markdown - Heading";
          scope = [
            "markdown.heading"
            "markup.heading | markup.heading entity.name"
            "markup.heading.markdown punctuation.definition.heading.markdown"
          ];
          settings = { foreground = "#${base0D-hex}"; };
        }
        {
          name = "Markup - Italic";
          scope = [ "markup.italic" ];
          settings = {
            fontStyle = "italic";
            foreground = "#${base08-hex}";
          };
        }
        {
          name = "Markup - Bold";
          scope = [ "markup.bold" "markup.bold string" ];
          settings = {
            fontStyle = "bold";
            foreground = "#${base08-hex}";
          };
        }
        {
          name = "Markup - Bold-Italic";
          scope = [
            "markup.bold markup.italic"
            "markup.italic markup.bold"
            "markup.quote markup.bold"
            "markup.bold markup.italic string"
            "markup.italic markup.bold string"
            "markup.quote markup.bold string"
          ];
          settings = {
            fontStyle = "bold";
            foreground = "#${base08-hex}";
          };
        }
        {
          name = "Markup - Underline";
          scope = [ "markup.underline" ];
          settings = {
            fontStyle = "underline";
            foreground = "#${base09-hex}";
          };
        }
        {
          name = "Markdown - Blockquote";
          scope = [ "markup.quote punctuation.definition.blockquote.markdown" ];
          settings = { foreground = "#${base0C-hex}"; };
        }
        {
          name = "Markup - Quote";
          scope = [ "markup.quote" ];
          settings = { fontStyle = "italic"; };
        }
        {
          name = "Markdown - Link";
          scope = [ "string.other.link.title.markdown" ];
          settings = { foreground = "#${base0D-hex}"; };
        }
        {
          name = "Markdown - Link Description";
          scope = [ "string.other.link.description.title.markdown" ];
          settings = { foreground = "#${base0E-hex}"; };
        }
        {
          name = "Markdown - Link Anchor";
          scope = [ "constant.other.reference.link.markdown" ];
          settings = { foreground = "#${base0A-hex}"; };
        }
        {
          name = "Markup - Raw Block";
          scope = [ "markup.raw.block" ];
          settings = { foreground = "#${base0E-hex}"; };
        }
        {
          name = "Markdown - Raw Block Fenced";
          scope = [ "markup.raw.block.fenced.markdown" ];
          settings = { foreground = "#00000050"; };
        }
        {
          name = "Markdown - Fenced Bode Block";
          scope = [ "punctuation.definition.fenced.markdown" ];
          settings = { foreground = "#00000050"; };
        }
        {
          name = "Markdown - Fenced Code Block Variable";
          scope = [
            "markup.raw.block.fenced.markdown"
            "variable.language.fenced.markdown"
          ];
          settings = { foreground = "#${base0E-hex}"; };
        }
        {
          name = "Markdown - Fenced Language";
          scope = [ "variable.language.fenced.markdown" ];
          settings = { foreground = "#${base08-hex}"; };
        }
        {
          name = "Markdown - Separator";
          scope = [ "meta.separator" ];
          settings = {
            fontStyle = "bold";
            foreground = "#${base0C-hex}";
          };
        }
        {
          name = "Markup - Table";
          scope = [ "markup.table" ];
          settings = { foreground = "#${base0E-hex}"; };
        }
        {
          scope = "token.info-token";
          settings = { foreground = "#${base0D-hex}"; };
        }
        {
          scope = "token.warn-token";
          settings = { foreground = "#${base0A-hex}"; };
        }
        {
          scope = "token.error-token";
          settings = { foreground = "#${base08-hex}"; };
        }
        {
          scope = "token.debug-token";
          settings = { foreground = "#${base0E-hex}"; };
        }
      ];
      type = "dark";
    };
    "package.json" = __toJSON {
      name = "theme";
      displayName = "Generated theme";
      version = "0.0.0";
      publisher = mainuser;
      engines.vscode = "^1.22.0";
      contributes.themes = [{
        label = "Generated theme";
        uiTheme = "vs-dark";
        path = "./theme/generated.json";
      }];
      capabilities = {
        untrustedWorkspaces.supported = true;
        virtualWorkspaces = true;
      };
    };
  };
in with builtins;
linkFarm "${mainuser}.theme" (attrValues (mapAttrs (name: value: {
  name = "share/vscode/extensions/${mainuser}.theme/${name}";
  path = toFile (baseNameOf name) value;
}) theme))
