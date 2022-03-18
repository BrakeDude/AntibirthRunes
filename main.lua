AntibirthRunes = RegisterMod("Antibirth Runes", 1)
local mod = AntibirthRunes

local GeboID = Isaac.GetCardIdByName("Gebo")
local KenazID = Isaac.GetCardIdByName("Kenaz")
local FehuID = Isaac.GetCardIdByName("Fehu")
local OthalaID = Isaac.GetCardIdByName("Othala")
local SowiloID = Isaac.GetCardIdByName("Sowilo")
local IngwazID = Isaac.GetCardIdByName("Ingwaz")

local GeboSFX = Isaac.GetSoundIdByName("Gebo")
local KenazSFX = Isaac.GetSoundIdByName("Kenaz")
local FehuSFX = Isaac.GetSoundIdByName("Fehu")
local OthalaSFX = Isaac.GetSoundIdByName("Othala")
local SowiloSFX = Isaac.GetSoundIdByName("Sowilo")
local IngwazSFX = Isaac.GetSoundIdByName("Ingwaz")

local EIDGeboRu = "Создает машину для пожертвований"
local EIDKenazRu = "Отравляет всех врагов в комнате"
local EIDFehuRu = "Превращает артефакты и предметы в монеты по их обычной цене в магазине"
local EIDOthalaRu = "Дает ещё одну копию случайного имеющегося артефакта"
local EIDSowiloRu = "Восстанавливает ранее убитых врагов в комнате#Позволяет повторно получить награду за зачистку комнаты#!!! Если использовать в борьбе с жадностью, можно превратить комнату в магазин"
local EIDIngwazRu = "Открывает все сундуки в комнате"


if EID then
	EID:addCard(GeboID, "Spawns a donation machine", "Gebo", "en_us")
	EID:addCard(KenazID, "Poisons all enemies in the room", "Kenaz", "en_us")
	EID:addCard(FehuID, "Turns pickups and items in the room into coins#Coin values are equal to their shop value", "Fehu", "en_us")
	EID:addCard(OthalaID, "Gives another copy of a random item that you already have", "Othala", "en_us")
	EID:addCard(SowiloID, "Respawn all enemies of the room#Allows you to farm room clear rewards#!!! If used in a greed fight, it can reroll the room into a Shop", "Sowilo", "en_us")
	EID:addCard(IngwazID, "Unlocks every chest in the room", "Ingwaz", "en_us")
	EID:addCard(GeboID, "Aparece una máquina de donación", "Gebo", "spa")
	EID:addCard(KenazID, "Envenena a todos los enemigos en la sala", "Kenaz", "spa")
	EID:addCard(FehuID, "Convierte todos los recolectables y objetos en monedas#El valor de las monedas es igual al valor en las tiendas", "Fehu", "spa")
	EID:addCard(OthalaID, "Te da una copia de un objeto ya existente en tu inventario", "Othala", "spa")
	EID:addCard(SowiloID, "Revive a los enemigos de una sala limpia#Permite conseguir más recompensas#!!! Si se usa en una pelea contra Greed, puede cambiar la sala a una tienda", "Sowilo", "spa")
	EID:addCard(IngwazID, "Abre todos los cofres de una sala", "Ingwaz", "spa")
	EID:addCard(GeboID, EIDGeboRu,"Гебо","ru")
	EID:addCard(KenazID, EIDKenazRu,"Кеназ","ru")
	EID:addCard(FehuID, EIDFehuRu,"Феху","ru")
	EID:addCard(OthalaID, EIDOthalaRu,"Отала","ru")
	EID:addCard(SowiloID, EIDSowiloRu,"Совило","ru")
	EID:addCard(IngwazID, EIDIngwazRu,"Ингваз","ru")
end


local function magicchalk_3f(player)
  local magicchalk = Isaac.GetItemIdByName("Magic Chalk")
  return player:HasCollectible(magicchalk)
end

function mod:UseGebo(gebo, player, useflags)
	DoBigbook("gfx/ui/giantbook/Gebo.png", GeboSFX, nil, nil, true)
	local slot = Isaac.Spawn(EntityType.ENTITY_SLOT, 8, -1, Game():GetRoom():FindFreePickupSpawnPosition(player.Position, 0, true), Vector.Zero, player)
	Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, -1, slot.Position, slot.Velocity, slot)
	if magicchalk_3f(player) then
		local restock = Isaac.Spawn(EntityType.ENTITY_SLOT, 10, -1, Game():GetRoom():FindFreePickupSpawnPosition(player.Position, 0, true), Vector.Zero, player)
		Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, -1, restock.Position, restock.Velocity, restock)
	end
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.UseGebo, GeboID)

function mod:UseKenaz(kenaz, player, useflags)
	DoBigbook("gfx/ui/giantbook/Kenaz.png", KenazSFX, nil, nil, true)
	player:AddCollectible(CollectibleType.COLLECTIBLE_TOXIC_SHOCK)
	player:RemoveCollectible(CollectibleType.COLLECTIBLE_TOXIC_SHOCK) --this method actually works lol
	if magicchalk_3f(player) then
		player:UseActiveItem(CollectibleType.COLLECTIBLE_MEGA_BEAN, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
	end
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.UseKenaz, KenazID)

function mod:KenazPoison(entity)
	local player = Isaac.GetPlayer(0)
	if entity:GetData()["Poison"] then
		if entity:GetData()["Poison"] > 0 then
			local ranDamage = GetRandomFloat(1.0, 3.5, player:GetCardRNG(KenazID))
			entity:AddPoison(EntityRef(player), 22, ranDamage)
			entity:GetData()["Poison"] = entity:GetData()["Poison"] - 1
			print("poison")
		else 
			entity:GetData()["Poison"] = nil
		end
	end
end
--mod:AddCallback(ModCallbacks.MC_PRE_NPC_UPDATE, mod.KenazPoison)

function mod:UseFehu(fehu, player, useflags)
	DoBigbook("gfx/ui/giantbook/Fehu.png", FehuSFX, nil, nil, true)
	player:UseCard(Card.CARD_REVERSE_HERMIT, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
	if magicchalk_3f(player) then
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_PENNY, Game():GetRoom():FindFreePickupSpawnPosition(player.Position, 0, true), Vector.Zero, player)
	end
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.UseFehu, FehuID)

function mod:UseOthala(othala, player, useflags)
	DoBigbook("gfx/ui/giantbook/Othala.png", OthalaSFX, nil, nil, true)
	if player:GetCollectibleCount() > 0 then
		local playersItems = {}
		for item = 1,GetMaxCollectibleID() do
			local itemConf = Isaac.GetItemConfig():GetCollectible(item)
			if player:HasCollectible(item) and itemConf.Type ~= ItemType.ITEM_ACTIVE 
			and (itemConf.Tags & ItemConfig.TAG_QUEST ~= ItemConfig.TAG_QUEST)
			then
				for i = 1, player:GetCollectibleNum(item,true) do
					table.insert(playersItems,item)
				end
			end
		end
		playersItems = Shuffle(playersItems)
		if #playersItems > 0 then
			local randomItem = player:GetCardRNG(OthalaID):RandomInt(#playersItems)+1
			player:AddCollectible(playersItems[randomItem])
			
		end
		if magicchalk_3f(player) then
			if #playersItems > 0 then
				local randomItem = player:GetCardRNG(OthalaID):RandomInt(#playersItems)+1
				player:AddCollectible(playersItems[randomItem])
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.UseOthala, OthalaID)

function mod:UseSowilo(sowilo, player, useflags)
	DoBigbook("gfx/ui/giantbook/Sowilo.png", SowiloSFX, nil, nil, true)
	
	if magicchalk_3f(player) then
		player:UseActiveItem(CollectibleType.COLLECTIBLE_FORGET_ME_NOW, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
	else
		player:UseActiveItem(CollectibleType.COLLECTIBLE_D7, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
	end
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.UseSowilo, SowiloID)

function mod:UseIngwaz(ingwaz, player, useflags)
	local entities = Isaac:GetRoomEntities()
	DoBigbook("gfx/ui/giantbook/Ingwaz.png", IngwazSFX, nil, nil, true)
	for i=1, #entities do
		if entities[i]:ToPickup() then
			if (entities[i].Variant >= 50 and 60 >= entities[i].Variant) or entities[i].Variant == PickupVariant.PICKUP_REDCHEST or entities[i].Variant == PickupVariant.PICKUP_MOMSCHEST then
				entities[i]:ToPickup():TryOpenChest(player)
			end
		end
	end
	
	if magicchalk_3f(player) then
		player:UseActiveItem(CollectibleType.COLLECTIBLE_DADS_KEY, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
	end
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.UseIngwaz, IngwazID)

function GetRandomNumber(numMin, numMax, rng)
	if not numMax then
		numMax = numMin
		numMin = nil
	end
	
	rng = rng or RNG()
	if type(rng) == "number" then
		local seed = rng
		rng = RNG()
		rng:SetSeed(seed, 1)
	end
	
	if numMin and numMax then
		return rng:Next() % (numMax - numMin + 1) + numMin
	elseif numMax then
		return rng:Next() % numMax
	end
	return rng:Next()
end

function GetRandomFloat(numMin, numMax, rng)
    return numMin + rng:RandomFloat() * (numMax - numMin);
end

function GetMaxCollectibleID()
    return Isaac.GetItemConfig():GetCollectibles().Size -1
end

function GetMaxTrinketID()
    return Isaac.GetItemConfig():GetTrinkets().Size -1
end

function Shuffle(list)
	local size, shuffled  = #list, list
    for i = size, 2, -1 do
		local j = math.random(i)
		shuffled[i], shuffled[j] = shuffled[j], shuffled[i]
	end
    return shuffled
end
--------------------------
--start of bigbook stuff--
--------------------------
OnRenderCounter = 0
IsEvenRender = true
mod:AddCallback(ModCallbacks.MC_POST_RENDER, function()
	OnRenderCounter = OnRenderCounter + 1
	
	IsEvenRender = false
	if Isaac.GetFrameCount()%2 == 0 then
		IsEvenRender = true
	end
end)

--ripairs stuff from revel
function ripairs_it(t,i)
	i=i-1
	local v=t[i]
	if v==nil then return v end
	return i,v
end
function ripairs(t)
	return ripairs_it, t, #t+1
end

--delayed functions
DelayedFunctions = {}

function DelayFunction(func, delay, args, removeOnNewRoom, useRender)
	local delayFunctionData = {
		Function = func,
		Delay = delay,
		Args = args,
		RemoveOnNewRoom = removeOnNewRoom,
		OnRender = useRender
	}
	table.insert(DelayedFunctions, delayFunctionData)
end

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
	for i, delayFunctionData in ripairs(DelayedFunctions) do
		if delayFunctionData.RemoveOnNewRoom then
			table.remove(DelayedFunctions, i)
		end
	end
end)

local function delayFunctionHandling(onRender)
	if #DelayedFunctions ~= 0 then
		for i, delayFunctionData in ripairs(DelayedFunctions) do
			if (delayFunctionData.OnRender and onRender) or (not delayFunctionData.OnRender and not onRender) then
				if delayFunctionData.Delay <= 0 then
					if delayFunctionData.Function then
						if delayFunctionData.Args then
							delayFunctionData.Function(table.unpack(delayFunctionData.Args))
						else
							delayFunctionData.Function()
						end
					end
					table.remove(DelayedFunctions, i)
				else
					delayFunctionData.Delay = delayFunctionData.Delay - 1
				end
			end
		end
	end
end

mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
	delayFunctionHandling(false)
end)

mod:AddCallback(ModCallbacks.MC_POST_RENDER, function()
	delayFunctionHandling(true)
end)

mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function()
	DelayedFunctions = {}
end)

--bigbook pausing
local hideBerkano = false
function DoBigbookPause()
	local player = Isaac.GetPlayer(0)
	
	local sfx = SFXManager()
	
	hideBerkano = true
	player:UseCard(Card.RUNE_BERKANO, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER) --we undo berkano's effects later, this is done purely for the bigbook which our housing mod should have made blank if we got here
	
	--remove the blue flies and spiders that just spawned
	for _, bluefly in pairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLUE_FLY, -1, false, false)) do
		if bluefly:Exists() and bluefly.FrameCount <= 0 then
			bluefly:Remove()
		end
	end
	for _, bluespider in pairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLUE_SPIDER, -1, false, false)) do
		if bluespider:Exists() and bluespider.FrameCount <= 0 then
			bluespider:Remove()
		end
	end
end

local isPausingGame = false
local isPausingGameTimer = 0
function KeepPaused()
	isPausingGame = true
	isPausingGameTimer = 0
end

function StopPausing()
	isPausingGame = false
	isPausingGameTimer = 0
end

mod:AddCallback(ModCallbacks.MC_POST_RENDER, function()
	if isPausingGame then
		isPausingGameTimer = isPausingGameTimer - 1
		if isPausingGameTimer <= 0 then
			isPausingGameTimer = 30
			DoBigbookPause()
		end
	end
end)

mod:AddCallback(ModCallbacks.MC_USE_CARD, function()
	if not hideBerkano then
		DelayFunction(function()
			local stuffWasSpawned = false
			
			for _, bluefly in pairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLUE_FLY, -1, false, false)) do
				if bluefly:Exists() and bluefly.FrameCount <= 1 then
					stuffWasSpawned = true
					break
				end
			end
			
			for _, bluespider in pairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLUE_SPIDER, -1, false, false)) do
				if bluespider:Exists() and bluespider.FrameCount <= 1 then
					stuffWasSpawned = true
					break
				end
			end
			
			if stuffWasSpawned then
				DoBigbook("gfx/ui/giantbook/rune_07_berkano.png", nil, nil, nil, false)
			end
		end, 1, nil, false, true)
	end
	hideBerkano = false
end, Card.RUNE_BERKANO)

--giantbook overlays
local shouldRenderGiantbook = false
local giantbookUI = Sprite()
giantbookUI:Load("gfx/ui/giantbook/giantbook.anm2", true)
local giantbookAnimation = "Appear"
function DoBigbook(spritesheet, sound, animationToPlay, animationFile, doPause)

	if doPause == nil then
		doPause = true
	end
	if doPause then
		DoBigbookPause()
	end
	
	if not animationToPlay then
		animationToPlay = "Appear"
	end
	
	if not animationFile then
		animationFile = "gfx/ui/giantbook/giantbook.anm2"
		if animationToPlay == "Appear" or animationToPlay == "Shake" then
			animationFile = "gfx/ui/giantbook/giantbook.anm2"
		elseif animationToPlay == "Static" then
			animationToPlay = "Effect"
			animationFile = "gfx/ui/giantbook/giantbook_clicker.anm2"
		elseif animationToPlay == "Flash" then
			animationToPlay = "Idle"
			animationFile = "gfx/ui/giantbook/giantbook_mama_mega.anm2"
		elseif animationToPlay == "Sleep" then
			animationToPlay = "Idle"
			animationFile = "gfx/ui/giantbook/giantbook_sleep.anm2"
		elseif animationToPlay == "AppearBig" or animationToPlay == "ShakeBig" then
			if animationToPlay == "AppearBig" then
				animationToPlay = "Appear"
			elseif animationToPlay == "ShakeBig" then
				animationToPlay = "Shake"
			end
			animationFile = "gfx/ui/giantbook/giantbookbig.anm2"
		end
	end
	
	giantbookAnimation = animationToPlay
	giantbookUI:Load(animationFile, true)
	if spritesheet then
		giantbookUI:ReplaceSpritesheet(0, spritesheet)
		giantbookUI:LoadGraphics()
	end
	giantbookUI:Play(animationToPlay, true)
	shouldRenderGiantbook = true
	
	if sound then
		local sfx = SFXManager()
		sfx:Play(sound, 1, 0, false, 1)
	end
	
end
mod:AddCallback(ModCallbacks.MC_POST_RENDER, function()
	if ShouldRender() then
		local centerPos = GetScreenCenterPosition()
		
		if IsEvenRender then
			giantbookUI:Update()
			if giantbookUI:IsFinished(giantbookAnimation) then
				shouldRenderGiantbook = false
			end
		end
		
		if shouldRenderGiantbook then
			giantbookUI:Render(centerPos, Vector.Zero, Vector.Zero)
		end
	end
end)
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function()
	shouldRenderGiantbook = false
end)

function ShouldRender(ignoreMusic, ignoreNoHud)

	local music = MusicManager()
	local currentMusic = music:GetCurrentMusicID()
	
	local game = Game()
	local seeds = game:GetSeeds()

	if (ignoreMusic or (currentMusic ~= Music.MUSIC_JINGLE_BOSS and currentMusic ~= Music.MUSIC_JINGLE_NIGHTMARE)) and (ignoreNoHud or not seeds:HasSeedEffect(SeedEffect.SEED_NO_HUD)) then
		return true
	end
	
	return false
end

function GetScreenCenterPosition()

	local game = Game()
	local room = game:GetRoom()

	local shape = room:GetRoomShape()
	local centerOffset = (room:GetCenterPos()) - room:GetTopLeftPos()
	local pos = room:GetCenterPos()
	
	if centerOffset.X > 260 then
		pos.X = pos.X - 260
	end
	if shape == RoomShape.ROOMSHAPE_LBL or shape == RoomShape.ROOMSHAPE_LTL then
		pos.X = pos.X - 260
	end
	if centerOffset.Y > 140 then
		pos.Y = pos.Y - 140
	end
	if shape == RoomShape.ROOMSHAPE_LTR or shape == RoomShape.ROOMSHAPE_LTL then
		pos.Y = pos.Y - 140
	end
	
	return Isaac.WorldToRenderPosition(pos, false)
	
end