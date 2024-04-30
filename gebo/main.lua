local majorversion = 1
local minorversion = 0
local APIFolder = "gebo"

local function Init()
    Gebo = RegisterMod("Gebo API", 1)
    Gebo.MajorVersion = majorversion
    Gebo.MinorVersion = minorversion
    Gebo.SaveData = {}
    local DefaultSaveData = {}
    if not GeboSlots then
        GeboSlots = {}
    end

    function Gebo.GetData(entity)
        if entity and entity.GetData then
            local data = entity:GetData()
            if not data.GeboData then
                data.GeboData = {}
            end
            return data.GeboData
        end
        return nil
    end

    function Gebo.IsGeboSlot(_slot)
        for _,slot in ipairs(GeboSlots) do
            if slot.Type == _slot.Type and slot.Variant == _slot.Variant and (slot.SubType == _slot.SubType or slot.SubType == -1) then
                return true
            end
        end
        return false
    end
    
    function Gebo.GetGeboSlot(_slot)
        for _,slot in ipairs(GeboSlots) do
            if slot.Type == _slot.Type and slot.Variant == _slot.Variant and (slot.SubType == _slot.SubType or slot.SubType == -1) then
                return slot
            end
        end
    end
    
    function Gebo.AddMachineBeggar(variant, func, plays, _type, subtype)
        _type = _type or 6
        subtype = subtype or 0
        plays = plays or 5
        table.insert(GeboSlots, {Type = _type, Variant = variant, SubType = subtype, Function = func, Plays = plays})
    end
    
    function Gebo.ChangeRepentogonTag(variant, add, _type, subtype)
        _type = _type or 6
        subtype = subtype or 0
        for key,slot in ipairs(GeboSlots) do
            if slot.Type == _type and slot.Variant == variant and slot.SubType == subtype then
                GeboSlots[key].REPENTOGON = add
            end
        end
    end
    
    function Gebo.UpdateMachineBeggar(variant, func, plays, _type, subtype)
        if type(variant) ~= "number" then return end
        _type = _type or 6
        subtype = subtype or 0
        plays = plays or 5
        for key,slot in ipairs(GeboSlots) do
            if slot.Type == _type and slot.Variant == variant and slot.SubType == subtype then
                GeboSlots[key].Type = _type
                GeboSlots[key].Variant = variant
                GeboSlots[key].SubType = subtype
                GeboSlots[key].Plays = plays
                if func ~= nil and type(func) == "function" then
                    GeboSlots[key].Function = func
                end
            end
        end
    end

    function Gebo.AddSaveData(name, data, overwriteDefault)
        Gebo.SaveData[name] = data
        if not DefaultSaveData[name] or overwriteDefault then
            DefaultSaveData[name] = data
        end
    end

    function Gebo.GetSaveData()
        return Gebo.SaveData
    end

    function Gebo.LoadSaveData(data, overwriteDefaul)
        Gebo.SaveData = data
        if overwriteDefaul then
            DefaultSaveData = data
        end
    end

    function Gebo.ResetSaveData()
        Gebo.SaveData = DefaultSaveData
    end

    function Gebo.ResetSaveDataByKey(key)
        Gebo.SaveData[key] = DefaultSaveData[key]
    end

    function Gebo.GetSaveDataByKey(key)
        return Gebo.SaveData[key]
    end

    function Gebo.SetSaveDataByKey(key, data)
        Gebo.SaveData[key] = data
    end
    
    local geboVanillaSlotScripts =
    {
        "crane",
        "fortune",
        "slot",
        "blood",
        "confessional",
        "restock",
        "beggar",
        "devil_beggar",
        "key_master",
        "bomb_bum",
        "battery_bum",
        "rotten_bum",
        "repentogon"
    }
    
    local geboModdedSlotScripts =
    {
        "retribution.swine_beggar",
        "retribution.apon_machine",
        "fiendfolio.cosplay_beggar",
        "fiendfolio.evil_beggar",
        "fiendfolio.robot_fortune_teller",
        "fiendfolio.zodiac_beggar",
        "fiendfolio.golden_slot",
        "fiendfolio.vending",
        "fiendfolio.grid_restock",
        "fiendfolio.fake_beggar",
        "andromeda.cosmic_beggar",
        "repentanceplus.stargazer",
        "epiphany.dice_machine",
        "epiphany.glitch_slot",
        "epiphany.gold_restock",
        "epiphany.pain-o-matic",
    }
    
    do
        for _,script in pairs(geboVanillaSlotScripts) do
            include(APIFolder..".vanilla."..script)
        end
        for _,script in pairs(geboModdedSlotScripts) do
            include(APIFolder.."."..script)
        end
    end

    local function GeboEffect()
        for _,slot in ipairs(Isaac.GetRoomEntities()) do
            if Gebo.IsGeboSlot(slot) then
                local data = Gebo.GetData(slot)
                local slotData = Gebo.GetGeboSlot(slot)
                if data.Gebo ~= nil then
                    if type(slotData.Function) == "function" then
                        if not data.PrevCollide then
                            data.PrevCollide = slot.EntityCollisionClass
                            slot.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ENEMIES
                        end
                        local dead = slotData.Function(slot, data.Gebo.Player, data.Gebo.Uses, data.Gebo.rng)
                        
                        if dead == nil or type(dead) == "boolean" and dead == true or type(dead) == "number" and dead <= 0 then
                            data.Gebo = nil
                        elseif type(dead) == "number" and dead > 0 then
                            data.Gebo.Uses = dead	
                        end
                    end
                elseif data.PrevCollide then
                    slot.EntityCollisionClass = data.PrevCollide
                    data.PrevCollide = nil
                end
            end
        end
    end
    Gebo:AddCallback(ModCallbacks.MC_POST_UPDATE, GeboEffect)

    print("["..Gebo.Name.."] V"..Gebo.MajorVersion.."."..Gebo.MinorVersion.." successfully loaded.")
end

if Gebo and (Gebo.MajorVersion < majorversion or Gebo.MajorVersion == majorversion and Gebo.MinorVersion < minorversion) then
    print("Newer version of ["..Gebo.Name.."] was found. Updating V"..Gebo.MajorVersion.."."..Gebo.MinorVersion.." to V"..majorversion.."."..minorversion.."...")
    local data = Gebo.GetSaveData()
    Gebo = nil
    Init()
    Gebo.LoadSaveData(data, true)
    print("["..Gebo.Name.."] was successfully updated.")
elseif not Gebo then
    Init()
end