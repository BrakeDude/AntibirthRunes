local prizeVariant = {
    [1] = PickupVariant.PICKUP_HEART,
    [2] = PickupVariant.PICKUP_HEART,
    [3] = PickupVariant.PICKUP_HEART,
    [4] = "Fly",
    [5] = "Fly",
    [6] = "Spider",
    [7] = "Spider",
    [8] = "Fart",
    [9] = "Fart",
    [10] = PickupVariant.PICKUP_COLLECTIBLE, 
    [11] = PickupVariant.PICKUP_TRINKET, 
}

local trinkets = {
    TrinketType.TRINKET_FISH_HEAD,
    TrinketType.TRINKET_FISH_TAIL,
    TrinketType.TRINKET_ROTTEN_PENNY,
    TrinketType.TRINKET_BOBS_BLADDER,
}

AntibirthRunes.CallOnNewRun[#AntibirthRunes.CallOnNewRun + 1] = function()
    prizeVariant = {
        [1] = PickupVariant.PICKUP_HEART,
        [2] = PickupVariant.PICKUP_HEART,
        [3] = "Fly",
        [4] = "Spider",
        [5] = "Fart",
        [6] = PickupVariant.PICKUP_COLLECTIBLE, 
        [7] = PickupVariant.PICKUP_TRINKET, 
    }
    
    trinkets = {
        TrinketType.TRINKET_FISH_HEAD,
        TrinketType.TRINKET_FISH_TAIL,
        TrinketType.TRINKET_ROTTEN_PENNY,
        TrinketType.TRINKET_BOBS_BLADDER,
    }
end

AntibirthRunes.CallOnContinue[#AntibirthRunes.CallOnContinue + 1] = function(data)
    if data["RottenBum"] then
        prizeVariant = data["RottenBum"].Prize
        trinkets = data["RottenBum"].Trinkets
    end
end

AntibirthRunes.CallOnSave[#AntibirthRunes.CallOnSave + 1] = function()
    return "RottenBum", {Prize = prizeVariant, Trinkets = trinkets}, true
end

local function SpawnPrize(type, variant, subtype, pos, rng)
    local x,y = AntibirthRunes:GetRandomNumber(-4, 4, rng), AntibirthRunes:GetRandomNumber(2,4, rng)
    if x < 0 then x = math.min(x,-1) elseif x > 0 then x = math.max(x,1) end
    Isaac.Spawn(type, variant, subtype, pos, Vector(x,y), nil)
end

local function Beggar(slot, player, uses, rng)
    if uses > 0 or uses == -1 then
        local sprite = slot:GetSprite()
        if sprite:IsPlaying("Idle") then
            SFXManager():Play(SoundEffect.SOUND_SCAMPER, 1, 0, false)
            if rng:RandomFloat() <= 0.3 then
                sprite:Play("PayPrize", true)
            else
                sprite:Play("PayNothing", true)
            end
        end
        if sprite:IsFinished("PayNothing") then
            sprite:Play("Idle", true)
            uses = uses - 1
        end
        if sprite:IsFinished("PayPrize") then
            sprite:Play("Prize", true)
        end
        if sprite:IsFinished("Prize") then
            if AntibirthRunes:GetData(slot).Teleport then
                sprite:Play("Teleport", true)
            else
                sprite:Play("Idle", true)
                uses = uses - 1
            end
        end
        if sprite:IsEventTriggered("Prize") then
            local var = prizeVariant[rng:RandomInt(#prizeVariant)+1]
            if var ~= "Fart" then SFXManager():Play(SoundEffect.SOUND_SLOTSPAWN, 1, 0, false) end
            if var == PickupVariant.PICKUP_COLLECTIBLE then
                local itemPool = Game():GetItemPool()
                local poolItem = itemPool:GetCollectible(ItemPoolType.POOL_ROTTEN_BEGGAR, true, slot.DropSeed)
                Isaac.Spawn(EntityType.ENTITY_PICKUP, var, poolItem, Game():GetRoom():FindFreePickupSpawnPosition(slot.Position + Vector(0, 40)), Vector.Zero, nil)
                AntibirthRunes:GetData(slot).Teleport = true
            elseif var == PickupVariant.PICKUP_TRINKET then
                local i = rng:RandomInt(#trinkets) + 1
                SpawnPrize(EntityType.ENTITY_PICKUP, var, trinkets[i], slot.Position, rng)
                Game():GetItemPool():RemoveTrinket(trinkets[i])
                table.remove(trinkets, i)
                if #trinkets == 0 then
                    table.remove(prizeVariant, #prizeVariant)
                end
            elseif var == "Fly" then
                player:AddBlueFlies(rng:RandomInt(3)+1, slot.Position, nil)
            elseif var == "Spider" then
                for i = 1, rng:RandomInt(3) + 1 do
                    player:ThrowBlueSpider(slot.Position, slot.Position + Vector(AntibirthRunes:GetRandomNumber(-60, 60, rng), AntibirthRunes:GetRandomNumber(20, 70, rng)))
                end
            elseif var == "Fart" then
                Game():Fart(slot.Position, 0)
            else
                local heart = {HeartSubType.HEART_ROTTEN, HeartSubType.HEART_BONE}
                SpawnPrize(EntityType.ENTITY_PICKUP, var, heart[rng:RandomInt(2) + 1], slot.Position, rng)
            end
        end
        if sprite:IsFinished("Teleport") then
            slot:Remove()
            return true
        end
    end
    return uses
end

Gebo.AddMachineBeggar(18, Beggar, 6)