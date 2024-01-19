--Amazing save manager
local json = require("json")

AntibirthRunes.CallOnContinue = {}
AntibirthRunes.CallOnNewRun = {}
AntibirthRunes.CallOnSave = {}
AntibirthRunes.CallOnSettings = {}

local continue = false
local function IsContinue()
    local totPlayers = #Isaac.FindByType(EntityType.ENTITY_PLAYER)

    if totPlayers == 0 then
        if Game():GetFrameCount() == 0 then
            continue = false
        else
            local room = Game():GetRoom()
            local desc = Game():GetLevel():GetCurrentRoomDesc()

            if desc.SafeGridIndex == GridRooms.ROOM_GENESIS_IDX then
                if not room:IsFirstVisit() then
                    continue = true
                else
                    continue = false
                end
            else
                continue = true
            end
        end
    end
    return continue
end


AntibirthRunes:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, function ()
    if #Isaac.FindByType(EntityType.ENTITY_PLAYER) ~= 0 then return end

    Isaac.ExecuteCommand("reloadshaders")

    local isContinue = IsContinue()

    if isContinue and AntibirthRunes:HasData() then
        local loadedData = json.decode(AntibirthRunes:LoadData())
        for _, funct in ipairs(AntibirthRunes.CallOnSettings) do
            funct(loadedData)
        end
        for _, funct in ipairs(AntibirthRunes.CallOnContinue) do
            funct(loadedData)
        end
    else
        if AntibirthRunes:HasData() then
            local loadedData = json.decode(AntibirthRunes:LoadData())
            for _, funct in ipairs(AntibirthRunes.CallOnSettings) do
                funct(loadedData)
            end
        end
        
        for _, funct in ipairs(AntibirthRunes.CallOnNewRun) do
            funct()
        end
    end
end)

AntibirthRunes:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, function(isSaving)
    local saveData = {}
    saveData["Settings"] = {}
    for _, funct in ipairs(AntibirthRunes.CallOnSave) do
        local key, data, onSave = funct()
        if onSave == nil or onSave == true and isSaving then
            saveData[key] = data
        end
    end
    AntibirthRunes:SaveData(json.encode(saveData))
end)