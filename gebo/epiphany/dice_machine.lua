local function Machine(slot, player, uses, rng)
    local DICE_MACHINE = Epiphany.Slot.DICE_MACHINE
    local sprite = slot:GetSprite()
    if sprite:IsPlaying("OutOfPrizes") or DICE_MACHINE:isDead(sprite) then
        return true
    end
    if sprite:IsPlaying("Wiggle") and sprite:GetFrame() == 28 then
        uses = uses - 1
    end
    if not DICE_MACHINE:isSpriteBusy(sprite) then
        sprite:PlayOverlay("CoinInsert", true)
	    SFXManager():Play(SoundEffect.SOUND_COIN_SLOT)
	end
    return uses
end

AntibirthRunes:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
	if Epiphany then
        if not Gebo.IsGeboSlot({Type = 6, Variant = Epiphany.Slot.DICE_MACHINE.ID, SubType = -1}) then
		    Gebo.AddMachineBeggar(Epiphany.Slot.DICE_MACHINE.ID, Machine, nil, 6, -1)
        end
	end
end)