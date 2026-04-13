local internal = RunDirectorBoonBans_Internal
local uiData = internal.ui

function uiData.GetBoonText(boon)
    return boon.Name or boon.Key or ""
end

function uiData.GetNormalizedBanFilterMode(uiState)
    local mode = tostring(uiState and uiState.view and uiState.view[uiData.BAN_FILTER_MODE_ALIAS] or "all")
    if uiData.BAN_FILTER_MODE_SET[mode] == true then
        return mode
    end
    return "all"
end

function uiData.GetVisibleBanCount(scopeKey, uiState)
    if type(scopeKey) ~= "string" or scopeKey == "" then
        return 0
    end

    local currentBans = internal.GetBanConfig(scopeKey, uiState) or 0
    local filterText = tostring(uiState and uiState.view and uiState.view[uiData.BAN_FILTER_TEXT_ALIAS] or ""):lower()
    local filterMode = uiData.GetNormalizedBanFilterMode(uiState)
    local visibleCount = 0

    for _, boon in ipairs(uiData.GetScopeBoons(scopeKey)) do
        local boonText = (boon.NameLower or string.lower(uiData.GetBoonText(boon)))
        local isBanned = bit32.band(currentBans, boon.Mask) ~= 0
        local matchesText = filterText == "" or boonText:find(filterText, 1, true) ~= nil
        local matchesMode = filterMode == "all"
            or (filterMode == "checked" and isBanned)
            or (filterMode == "unchecked" and not isBanned)
        if matchesText and matchesMode then
            visibleCount = visibleCount + 1
        end
    end

    return visibleCount
end

function uiData.BuildRarityRows(root)
    local rows = {}
    for _, boon in ipairs(uiData.GetScopeBoons(root.primaryScopeKey)) do
        if uiData.IsRarityEligibleBoon(boon) then
            table.insert(rows, {
                key = boon.Key,
                name = uiData.GetBoonText(boon),
                alias = internal.GetRarityAlias(root.primaryScopeKey, boon.Key),
            })
        end
    end
    return rows
end

function uiData.GetRarityRows(root)
    local rows = uiData.rarityRowsByRoot[root.id]
    if not rows then
        rows = uiData.BuildRarityRows(root)
        uiData.rarityRowsByRoot[root.id] = rows
    end
    return rows
end
