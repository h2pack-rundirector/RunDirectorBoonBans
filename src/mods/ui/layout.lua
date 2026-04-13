local internal = RunDirectorBoonBans_Internal
local uiData = internal.ui

function uiData.DrawMainContent(ui, uiState)
    local mainTabsNode = uiData.GetMainTabsNode(uiState)
    if mainTabsNode then
        local changed = lib.drawUiNode(ui, mainTabsNode, uiState, nil, internal.definition.customTypes)
        local activeTabName = mainTabsNode._activeTabKey
        local tabState = nil
        if type(activeTabName) == "string" and mainTabsNode._tabStateByKey then
            tabState = mainTabsNode._tabStateByKey[activeTabName]
        end
        local activeRootAlias = type(activeTabName) == "string" and uiData.GetSelectedRootAlias(activeTabName) or nil
        local activeRootId = activeRootAlias and uiState.get(activeRootAlias) or nil
        local selectedRoot = (type(activeRootId) == "string" and activeRootId ~= "")
            and uiData.GetRootById(activeRootId)
            or (tabState and tabState.selectedRoot or nil)

        if selectedRoot and type(activeTabName) == "string" then
            if uiData.banFilterState.rootId ~= selectedRoot.id then
                uiData.ResetBanFilter(selectedRoot.id, uiState)
            end
            if selectedRoot.id == "Hera" and uiData.activeBridalGlowRootId ~= selectedRoot.id then
                uiData.InvalidateBridalGlowRootCache()
                uiData.activeBridalGlowRootId = selectedRoot.id
            end
        end

        if changed and selectedRoot then
            for _, scope in ipairs(selectedRoot.scopes or uiData.EMPTY_LIST) do
                internal.UpdateGodStats(scope.key, uiState)
            end
        end
    end
end

function internal.DrawTab(ui, uiState)
    uiData.RefreshFrameState(uiState)
    uiData.DrawMainContent(ui, uiState)
end

function internal.DrawQuickContent(ui, uiState, theme)
    local colors = uiData.GetThemeColors(theme)
    local totalBans = internal.GetTotalBansConfigured()
    local customizedRoots = uiData.GetCustomizedRootCount(uiState)
    uiData.DrawColoredText(ui, colors.info, "Boon Bans")
    ui.Text(string.format("%d total bans configured", totalBans))
    ui.Text(string.format("%d roots customized", customizedRoots))
    local padVal, padChanged = ui.Checkbox("Padding Enabled##QuickBoonBans", uiState.view.EnablePadding == true)
    if padChanged then
        uiState.set("EnablePadding", padVal)
    end
    lib.drawUiNode(ui, uiData.GetQuickResetNode(), uiState, nil, internal.definition.customTypes)
end
