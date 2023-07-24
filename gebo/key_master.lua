local prizeVariant = {
    [1] = PickupVariant.PICKUP_CHEST,
    [2] = PickupVariant.PICKUP_LOCKEDCHEST,
    [3] = PickupVariant.PICKUP_REDCHEST,
    [4] = PickupVariant.PICKUP_BOMBCHEST,
    [5] = PickupVariant.PICKUP_MIMICCHEST,
    [6] = PickupVariant.PICKUP_HAUNTEDCHEST,
    [7] = PickupVariant.PICKUP_SPIKEDCHEST,
    [8] = PickupVariant.PICKUP_WOODENCHEST,
    [9] = PickupVariant.PICKUP_ETERNALCHEST,
    [10] = PickupVariant.PICKUP_COLLECTIBLE,
    [11] = PickupVariant.PICKUP_TRINKET,
}

AntibirthRunes.CallOnNewRun[#AntibirthRunes.CallOnNewRun + 1] = function()
    prizeVariant = {
        [1] = PickupVariant.PICKUP_CHEST,
        [2] = PickupVariant.PICKUP_LOCKEDCHEST,
        [3] = PickupVariant.PICKUP_REDCHEST,
        [4] = PickupVariant.PICKUP_BOMBCHEST,
        [5] = PickupVariant.PICKUP_MIMICCHEST,
        [6] = PickupVariant.PICKUP_HAUNTEDCHEST,
        [7] = PickupVariant.PICKUP_SPIKEDCHEST,
        [8] = PickupVariant.PICKUP_WOODENCHEST,
        [9] = PickupVariant.PICKUP_ETERNALCHEST,
        [10] = PickupVariant.PICKUP_COLLECTIBLE,
        [11] = PickupVariant.PICKUP_TRINKET,
    }
end

AntibirthRunes.CallOnContinue[#AntibirthRunes.CallOnContinue + 1] = function(data)
    prizeVariant = data["KeyMaster"]
end

AntibirthRunes.CallOnSave[#AntibirthRunes.CallOnSave + 1] = function()
    return "KeyMaster", prizeVariant, true
end

local function SpawnPrize(type, variant, subtype, pos, rng)
    local isTrinket = variant == PickupVariant.PICKUP_TRINKET
    local xvel = isTrinket and 4 or 15
    local yvel = isTrinket and 4 or 10
    local x,y = AntibirthRunes:GetRandomNumber(-xvel , xvel, rng), AntibirthRunes:GetRandomNumber(1 * yvel, 1.5 * yvel, rng)
    if x < 0 then x = math.min(x,-1) elseif x > 0 then x = math.max(x,1) end
    Isaac.Spawn(type, variant, subtype, pos, Vector(x,y), nil)
end

local function Beggar(slot, player, uses, rng)
    if uses > 0 or uses == -1 then
        local sprite = slot:GetSprite()
        if sprite:IsPlaying("Idle") then
            SFXManager():Play(SoundEffect.SOUND_KEY_DROP0, 1, 0, false)
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
            SFXManager():Play(SoundEffect.SOUND_SLOTSPAWN, 1, 0, false)
            local var = prizeVariant[rng:RandomInt(#prizeVariant)+1]
            if var == PickupVariant.PICKUP_COLLECTIBLE then
                local itemPool = Game():GetItemPool()
                local poolItem = itemPool:GetCollectible(ItemPoolType.POOL_KEY_MASTER, true, slot.DropSeed)
                Isaac.Spawn(EntityType.ENTITY_PICKUP, var, poolItem, Game():GetRoom():FindFreePickupSpawnPosition(slot.Position + Vector(0, 40)), Vector.Zero, nil)
                AntibirthRunes:GetData(slot).Teleport = true
            elseif var == PickupVariant.PICKUP_TRINKET then
                SpawnPrize(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, TrinketType.TRINKET_PAPER_CLIP, slot.Position, rng)
                AntibirthRunes:GetData(slot).Teleport = true
                table.remove(prizeVariant, 11)
            else
                SpawnPrize(EntityType.ENTITY_PICKUP, var, 0, slot.Position, rng)
            end
        end
        if sprite:IsFinished("Teleport") then
            slot:Remove()
            return true
        end
    end
    return uses
end

Gebo.AddMachineBeggar(7, Beggar, 6)