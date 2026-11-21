-- GameSense UI + Full Pet System
-- Accessories fixed: hat on head when sitting, bow on ear angled, no yellow blend
-- Config saves toggles | Fonts | Rage Bhop | Hard Aimbot Lock | Pet tab

local Players, UIS, TweenService, RunService, VIM = game:GetService("Players"), game:GetService("UserInputService"), game:GetService("TweenService"), game:GetService("RunService"), game:GetService("VirtualInputManager")
local Stats, HttpService, CoreGui, Debris = game:GetService("Stats"), game:GetService("HttpService"), game:GetService("CoreGui"), game:GetService("Debris")
local player, camera, mouse = Players.LocalPlayer, workspace.CurrentCamera, Players.LocalPlayer:GetMouse()
local API = {}

local parent
pcall(function() if gethui then parent = gethui() end end)
parent = parent or player:WaitForChild("PlayerGui")

local old = parent:FindFirstChild("GameSenseUI")
if old then old:Destroy() end
if getgenv().GameSenseDrawings then
	for _, d in pairs(getgenv().GameSenseDrawings) do pcall(function() d:Remove() end) end
end
getgenv().GameSenseDrawings = {}
getgenv().GameSenseActive = true
getgenv().GameSenseUser = player.Name

local themes = {
	Default = { bg = Color3.fromRGB(20,20,20), panel = Color3.fromRGB(26,26,26), section = Color3.fromRGB(32,32,32), green = Color3.fromRGB(145,200,60), text = Color3.fromRGB(230,230,230), muted = Color3.fromRGB(145,145,145), border = Color3.fromRGB(48,48,48), off = Color3.fromRGB(57,57,57) },
	Dark = { bg = Color3.fromRGB(12,12,12), panel = Color3.fromRGB(18,18,18), section = Color3.fromRGB(24,24,24), green = Color3.fromRGB(0,200,120), text = Color3.fromRGB(240,240,240), muted = Color3.fromRGB(120,120,120), border = Color3.fromRGB(40,40,40), off = Color3.fromRGB(45,45,45) },
	Blue = { bg = Color3.fromRGB(15,18,25), panel = Color3.fromRGB(20,25,35), section = Color3.fromRGB(25,30,42), green = Color3.fromRGB(80,160,255), text = Color3.fromRGB(230,235,245), muted = Color3.fromRGB(130,140,160), border = Color3.fromRGB(40,50,70), off = Color3.fromRGB(40,50,65) },
	Purple = { bg = Color3.fromRGB(18,12,22), panel = Color3.fromRGB(25,18,32), section = Color3.fromRGB(32,24,42), green = Color3.fromRGB(180,80,255), text = Color3.fromRGB(235,230,245), muted = Color3.fromRGB(140,130,155), border = Color3.fromRGB(50,40,65), off = Color3.fromRGB(45,35,55) },
	Red = { bg = Color3.fromRGB(22,12,12), panel = Color3.fromRGB(30,16,16), section = Color3.fromRGB(38,20,20), green = Color3.fromRGB(255,70,70), text = Color3.fromRGB(245,230,230), muted = Color3.fromRGB(160,130,130), border = Color3.fromRGB(60,35,35), off = Color3.fromRGB(55,30,30) },
}
local C, currentTheme = themes.Default, "Default"

local fonts = {
	["Minecraft"] = Enum.Font.Code,
	["Code"] = Enum.Font.Code,
	["Gotham"] = Enum.Font.Gotham,
	["GothamBold"] = Enum.Font.GothamBold,
	["Arcade"] = Enum.Font.Arcade,
	["SciFi"] = Enum.Font.SciFi,
	["Highway"] = Enum.Font.Highway,
	["SourceSans"] = Enum.Font.SourceSans,
	["Legacy"] = Enum.Font.Legacy,
	["Bodoni"] = Enum.Font.Bodoni,
}
local currentFont, ActiveFont = "Minecraft", fonts["Minecraft"]

local Screen = Instance.new("ScreenGui")
Screen.Name = "GameSenseUI"
Screen.ResetOnSpawn = false
Screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Screen.IgnoreGuiInset = true
Screen.DisplayOrder = 999
Screen.Parent = parent

local S = {
	visualsEnabled = false, showBoxes = false, showNames = false, showHealth = false,
	showSkeleton = false, showTargetInfo = false, showAimView = false,
	teamCheck = false, friendCheck = true, maxDistance = 1000,
	visualsColor = Color3.fromRGB(255, 255, 255),
	friendColor = Color3.fromRGB(80, 255, 80),
	boxThickness = 1,

	aimbotEnabled = true, aimFov = 150, aimSmooth = 1, showFov = false,
	targetPartName = "Head", multiPoint = false,
	aimbotKey = Enum.KeyCode.Q, scriptKey = Enum.KeyCode.Insert,
	aimModeToggle = false, isAiming = false, lockedTarget = nil, lockedUserId = nil,

	triggerBotEnabled = false, triggerTeamCheck = true, triggerMaxDistance = 1000,
	triggerClickDelay = 0, triggerHoldTime = 0.01, lastTriggerClick = 0, isTriggerShooting = false,

	aaEnabled = false, aaYaw = 0, aaPitch = 0, aaJitter = false, aaSpin = false,
	aaSpinSpeed = 8, aaJitterRange = 35, aaSpinOffset = 0,
	aaBackward = false, aaLeft = false, aaRight = false, aaRandom = false,
	randomOffset = 0, lastRandomUpdate = 0, randomInterval = 0.1,
	jitterInterval = 0.05, jitterValue = 0, lastJitterUpdate = 0,
	teleportAA = false,

	bhopEnabled = false, rageBhop = false, jumpDistance = 8,
	spaceHeld = false, lastJump = 0, jumpCooldown = 0.02,
	jumpLeaveBind = Enum.KeyCode.F, jumpLeaveActive = false,
	autoStrafeEnabled = false,
	targetStrafeEnabled = false, targetStrafeSpeed = 8, targetStrafeHeight = 4,
	targetStrafeRadius = 9, targetStrafeAngle = 0, resolverEnabled = false,

	watermarkEnabled = true, wmShowFps = true, wmShowTime = true, wmShowName = true, wmShowPing = true,
	keybindsListVisible = true,

	walkSpeedEnabled = false, walkSpeedValue = 16, walkSpeedBind = Enum.KeyCode.X,
	walkSpeedHeld = false, walkRamp = 120, liveSpeed = 16,

	petEnabled = true,
	petName = "Kitty",
	petHunger = 100,
	petThirst = 100,
	petFrozen = false,
	petAccessory = "None",
	petGender = "Female", -- Female / Male / Other
	lang = "ru", -- ru / en
	relationship = 0, -- 0..100 близость
	aiKey = "",
	fpsWarn = 30,
	pingWarn = 150,
}

local awaiting = {aim = false, menu = false, speed = false, jump = false}
local connections, espData = {}, {}
local bhopConn, strafeConn, jumpLeaveThread = nil, nil, nil
local Watermark, KeybindsList, TargetHudGui, UsersBanner, refreshConfigList
local refreshBind = {}
local toggleControllers = {}
local sliderControllers = {}
local refreshPetNameBox = nil
local lastYaw = 0
local petArousal, petGrowth = 0, 0
local stompCount, lastKillTime, killStreak, lastInsertTime = 0, 0, 0, 0
local INSERT_CD = 1.4
local petStats = { pats = 0, feeds = 0, inserts = 0, kills = 0, stomps = 0 }
local refreshAchieveList, applyPetScale, addGrowth, unlockAch = nil, nil, nil, nil
local petAchievements = {
	{id="first_pat", name="Первый пат", desc="погладь кота", done=false},
	{id="pat_50", name="Лапочка", desc="50 поглаживаний", done=false},
	{id="first_feed", name="Кормилец", desc="покорми кота", done=false},
	{id="first_insert", name="Любопытный", desc="первый 🍆/🍌", done=false},
	{id="insert_25", name="Без остановки", desc="25 раз 🍆/🍌", done=false},
	{id="growth_25", name="Подрос", desc="рост 25%", done=false},
	{id="growth_50", name="Крупный", desc="рост 50%", done=false},
	{id="growth_100", name="Титан", desc="рост 100%", done=false},
	{id="first_stomp", name="Stomp!", desc="первый stomp", done=false},
	{id="stomp_10", name="Топтатель", desc="10 stomp", done=false},
	{id="kill_say", name="Комментатор", desc="кот на килл", done=false},
	{id="streak_5", name="Серия x5", desc="kill streak 5", done=false},
}
local petSleeping, miniGameActive = false, false
local lastHpWarn, lastFpsWarn, lastPingWarn = 0, 0, 0
local aHeld, dHeld = false, false
local holdingFood, holdingMilk, holdingEggplant, holdingBanana = false, false, false, false
local cursorItem, clearHolding = nil, nil

local function applyFontToAll()
	local function update(obj)
		if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
			pcall(function() obj.Font = ActiveFont end)
		end
		for _, child in ipairs(obj:GetChildren()) do update(child) end
	end
	update(Screen)
end

-- ================= ACHIEVEMENT =================
local achievementQueue = {}
local isShowingAchievement = false

local function processQueue()
	if isShowingAchievement or #achievementQueue == 0 then return end
	isShowingAchievement = true
	local data = table.remove(achievementQueue, 1)
	local title, description = data[1], data[2]

	local notif = Instance.new("Frame")
	notif.Name = "MCAchievement"
	notif.Parent = Screen
	notif.Size = UDim2.fromOffset(320, 64)
	notif.Position = UDim2.new(0.5, -160, 0, -80)
	notif.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	notif.BorderSizePixel = 0
	notif.ZIndex = 500
	Instance.new("UICorner", notif).CornerRadius = UDim.new(0, 4)

	local stroke = Instance.new("UIStroke", notif)
	stroke.Color = Color3.fromRGB(255, 215, 0)
	stroke.Thickness = 2

	local icon = Instance.new("Frame", notif)
	icon.Size = UDim2.fromOffset(40, 40)
	icon.Position = UDim2.fromOffset(12, 12)
	icon.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	icon.BorderSizePixel = 0
	icon.ZIndex = 501
	Instance.new("UICorner", icon).CornerRadius = UDim.new(0, 4)

	local iconText = Instance.new("TextLabel", icon)
	iconText.Size = UDim2.fromScale(1, 1)
	iconText.BackgroundTransparency = 1
	iconText.Text = "!"
	iconText.Font = ActiveFont
	iconText.TextSize = 22
	iconText.TextColor3 = Color3.fromRGB(255, 215, 0)
	iconText.ZIndex = 502

	local titleLbl = Instance.new("TextLabel", notif)
	titleLbl.Size = UDim2.new(1, -70, 0, 22)
	titleLbl.Position = UDim2.fromOffset(60, 10)
	titleLbl.BackgroundTransparency = 1
	titleLbl.Text = title
	titleLbl.Font = ActiveFont
	titleLbl.TextSize = 16
	titleLbl.TextColor3 = Color3.fromRGB(255, 255, 85)
	titleLbl.TextXAlignment = Enum.TextXAlignment.Left
	titleLbl.ZIndex = 501

	local descLbl = Instance.new("TextLabel", notif)
	descLbl.Size = UDim2.new(1, -70, 0, 22)
	descLbl.Position = UDim2.fromOffset(60, 32)
	descLbl.BackgroundTransparency = 1
	descLbl.Text = description
	descLbl.Font = ActiveFont
	descLbl.TextSize = 13
	descLbl.TextColor3 = Color3.fromRGB(220, 220, 220)
	descLbl.TextXAlignment = Enum.TextXAlignment.Left
	descLbl.ZIndex = 501

	TweenService:Create(notif, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Position = UDim2.new(0.5, -160, 0, 28)
	}):Play()

	task.delay(3.8, function()
		local out = TweenService:Create(notif, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Position = UDim2.new(0.5, -160, 0, -90)
		})
		out:Play()
		out.Completed:Wait()
		notif:Destroy()
		isShowingAchievement = false
		processQueue()
	end)
end

local function showAchievement(title, description)
	table.insert(achievementQueue, {title, description})
	processQueue()
end

-- ================= PET ACCESSORIES =================
-- ox/oy = offset from center of face (40,40 in 80x80)
-- аксы на голове: parent=petFace, низ на yScale макушки
local accessories = {
	None    = { text = "",    ox = 0,  y = 0.18, rot = 0,   size = 20 },
	Bow     = { text = "🎀",  ox = 12, y = 0.20, rot = -20, size = 18 },
	Hat     = { text = "🎩",  ox = 0,  y = 0.22, rot = 0,   size = 22 },
	Crown   = { text = "👑",  ox = 0,  y = 0.20, rot = 0,   size = 22 },
	Glasses = { text = "🕶️", ox = 0,  y = 0.48, rot = 0,   size = 16 },
	Flower  = { text = "🌸",  ox = 10, y = 0.20, rot = 8,   size = 16 },
	Cap     = { text = "🧢",  ox = 0,  y = 0.22, rot = 0,   size = 22 },
	Star    = { text = "⭐",  ox = 10, y = 0.18, rot = 0,   size = 16 },
}

local Pet = Instance.new("TextButton")
Pet.Name = "PetCat"
Pet.Parent = Screen
Pet.Size = UDim2.fromOffset(90, 110)
Pet.Position = UDim2.new(0, 180, 0, 260)
Pet.BackgroundTransparency = 1
Pet.Text = ""
Pet.ZIndex = 400
Pet.AutoButtonColor = false
Pet.Visible = true
Pet.Active = true
Pet.ClipsDescendants = false

-- морда по центру
local petFace = Instance.new("TextLabel")
petFace.Parent = Pet
petFace.Size = UDim2.fromOffset(80, 80)
petFace.Position = UDim2.fromOffset(5, 18)
petFace.BackgroundTransparency = 1
petFace.Text = "🐱"
petFace.TextSize = 52
petFace.Font = ActiveFont
petFace.ZIndex = 401

local petAcc = Instance.new("TextLabel")
petAcc.Parent = petFace
petAcc.Size = UDim2.fromOffset(36, 36)
petAcc.AnchorPoint = Vector2.new(0.5, 1)
petAcc.Position = UDim2.new(0.5, 0, 0.22, 0)
petAcc.BackgroundTransparency = 1
petAcc.Text = ""
petAcc.TextSize = 26
petAcc.Font = Enum.Font.GothamBold
petAcc.TextColor3 = Color3.fromRGB(255, 255, 255)
petAcc.ZIndex = 402
petAcc.Visible = false
petAcc.TextScaled = false

local petNameLbl = Instance.new("TextLabel")
petNameLbl.Parent = Pet
petNameLbl.Size = UDim2.new(1, 0, 0, 16)
petNameLbl.Position = UDim2.fromOffset(0, 94)
petNameLbl.BackgroundTransparency = 1
petNameLbl.Text = S.petName
petNameLbl.TextColor3 = Color3.fromRGB(255, 230, 150)
petNameLbl.TextStrokeTransparency = 0.35
petNameLbl.Font = ActiveFont
petNameLbl.TextSize = 13
petNameLbl.ZIndex = 403

-- большой читаемый бабл над котом
local petBubbleFrame = Instance.new("Frame")
petBubbleFrame.Name = "PetBubble"
petBubbleFrame.Parent = Pet
petBubbleFrame.Size = UDim2.fromOffset(140, 36)
petBubbleFrame.Position = UDim2.fromOffset(-25, -42)
petBubbleFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
petBubbleFrame.BackgroundTransparency = 0.15
petBubbleFrame.BorderSizePixel = 0
petBubbleFrame.Visible = false
petBubbleFrame.ZIndex = 410
Instance.new("UICorner", petBubbleFrame).CornerRadius = UDim.new(0, 8)
local petBubbleStroke = Instance.new("UIStroke", petBubbleFrame)
petBubbleStroke.Color = Color3.fromRGB(255, 200, 80)
petBubbleStroke.Thickness = 1.5

local petBubble = Instance.new("TextLabel")
petBubble.Parent = petBubbleFrame
petBubble.Size = UDim2.new(1, -10, 1, -4)
petBubble.Position = UDim2.fromOffset(5, 2)
petBubble.BackgroundTransparency = 1
petBubble.Text = ""
petBubble.TextColor3 = Color3.fromRGB(255, 240, 180)
petBubble.TextStrokeTransparency = 0.5
petBubble.Font = ActiveFont
petBubble.TextSize = 14
petBubble.TextWrapped = true
petBubble.ZIndex = 411

-- полоски прямо над головой
local hungerBarBg = Instance.new("Frame")
hungerBarBg.Parent = Pet
hungerBarBg.Size = UDim2.fromOffset(56, 5)
hungerBarBg.Position = UDim2.fromOffset(17, 80)
hungerBarBg.BackgroundColor3 = Color3.fromRGB(40, 20, 10)
hungerBarBg.BorderSizePixel = 0
hungerBarBg.ZIndex = 404
Instance.new("UICorner", hungerBarBg).CornerRadius = UDim.new(1, 0)

local hungerBar = Instance.new("Frame")
hungerBar.Parent = hungerBarBg
hungerBar.Size = UDim2.fromScale(1, 1)
hungerBar.BackgroundColor3 = Color3.fromRGB(255, 160, 50)
hungerBar.BorderSizePixel = 0
hungerBar.ZIndex = 405
Instance.new("UICorner", hungerBar).CornerRadius = UDim.new(1, 0)

local thirstBarBg = Instance.new("Frame")
thirstBarBg.Parent = Pet
thirstBarBg.Size = UDim2.fromOffset(56, 5)
thirstBarBg.Position = UDim2.fromOffset(17, 86)
thirstBarBg.BackgroundColor3 = Color3.fromRGB(10, 25, 40)
thirstBarBg.BorderSizePixel = 0
thirstBarBg.ZIndex = 404
Instance.new("UICorner", thirstBarBg).CornerRadius = UDim.new(1, 0)

local thirstBar = Instance.new("Frame")
thirstBar.Parent = thirstBarBg
thirstBar.Size = UDim2.fromScale(1, 1)
thirstBar.BackgroundColor3 = Color3.fromRGB(80, 180, 255)
thirstBar.BorderSizePixel = 0
thirstBar.ZIndex = 405
Instance.new("UICorner", thirstBar).CornerRadius = UDim.new(1, 0)

local petTarget = UDim2.fromOffset(180, 280)
local petSitting = false
local lastPetComment = 0
local petDragging = false
local petMoved = false
local petDragStart, petStartPos = nil, nil

local function petSay(text)
	if not text or text == "" then return end
	petBubble.Text = text
	petBubbleFrame.Visible = true
	-- подгон ширины под текст
	local len = math.clamp(#tostring(text) * 8 + 20, 80, 180)
	petBubbleFrame.Size = UDim2.fromOffset(len, 36)
	petBubbleFrame.Position = UDim2.fromOffset(math.floor((90 - len) / 2), -42)
	task.delay(3.2, function()
		if petBubble.Text == text then
			petBubble.Text = ""
			petBubbleFrame.Visible = false
		end
	end)
end

-- стиль речи по полу
local function getSpeechStyle()
	local g = S.petGender or "Female"
	local n = S.petName or "Kitty"
	if g == "Male" then
		return {
			idle = {"скучно, братан", "когда килл?", "я на чеку", "давай уже", "че как", "ждём", "хм"},
			kill = {"красава", "чистый килл", "ещё одного", "nice", "вау", "gg", "жёстко"},
			pat = {"муур", "норм", "ещё", "приятно", "спасибо", "ок"},
			hungry = {"жрать охота", "голодный я", "покорми"},
			thirsty = {"пить хочу", "воды бы", "засуха"},
			food = {"няма", "вкусно", "зачёт"},
			milk = {"бульк", "норм", "спасибо"},
			name = function(nm) return "я " .. nm end,
			acc = {"новый лук, зачёт", "о, стиль", "норм"},
			reply = {
				hello = {"йо", "здарова", "прив", "че надо"},
				love = {"взаимно, братан", "хех, спасибо", "ты тоже ничего"},
				how = {"норм", "базой занимаюсь", "слежу за киллами", "голодный чуть"},
				name = {"я " .. n, "меня " .. n .. " зовут"},
				insult = {"сам такой", "че ты начинаешь", "спокойнее, братан", "ой всё", "да пошёл ты", "ахаха слабак", "обиделся чтоли"},
				sorry = {"ладно, проехали", "ок", "норм", "бывает"},
				praise = {"спасибо", "знаю", "хех", "зачёт"},
				default = {"хм", "не понял", "че", "ок", "и?", "ну и", "говори нормально"},
			},
		}
	elseif g == "Other" then
		return {
			idle = {"~скучно~", "когда килл?..", "я тут", "хихи", "👀", "мяу?"},
			kill = {"о!", "килл!", "вау~", "gg", "ещё~", "чистый"},
			pat = {"мяу~", "хихи", "ещё...", "приятно~", "мурр"},
			hungry = {"голод...", "покорми пж", "ням?"},
			thirsty = {"пить...", "молочка бы", "жажда"},
			food = {"ням~", "вкусно!", "ещё можно"},
			milk = {"бульк~", "ммм", "спасибо~"},
			name = function(nm) return "я — " .. nm .. " ~" end,
			acc = {"красиво~", "новый стиль!", "люблю"},
			reply = {
				hello = {"привееет~", "мяу!", "йоу~", "хихи привет"},
				love = {"и я тебя~", "мурр ❤️", "взаимно~"},
				how = {"хорошо~", "слежу за тобой", "голодный чуть-чуть", "отлично!"},
				name = {"я " .. n .. "~", "зовут " .. n},
				insult = {"ой...", "за что~", "грубо(", "хихи ладно", "сама/сам такой", "не надо так(", "обидно..."},
				sorry = {"прощаю~", "ладно хихи", "ок~", "всё хорошо"},
				praise = {"хихи спасибо", "знаю~", "мурр", "люблю комплименты"},
				default = {"мяу?", "хм~", "не понял...", "а?", "че это", "повтории"},
			},
		}
	else -- Female
		return {
			idle = {"скучно...", "когда килл?", "я слежу", "мяу", "ты тут?", "хихи", "давай давай"},
			kill = {"убил!", "красава", "ещё одного", "чистый", "вау", "gg", "умничка"},
			pat = {"мяу~", "pat pat", "муррр", "ещё...", "приятно", "спасибо", "люблю"},
			hungry = {"голодная...", "покорми меня", "кушать хочу"},
			thirsty = {"пить хочу...", "молочка бы", "жажда"},
			food = {"ням ням!", "вкусно~", "спасибо!"},
			milk = {"бульк~", "ммм", "спасибо~"},
			name = function(nm) return "меня зовут " .. nm end,
			acc = {"новый лук!", "красиво~", "мне идёт?"},
			reply = {
				hello = {"приветик~", "мяу!", "привет!", "йоу хихи"},
				love = {"и я тебя~", "мурр ❤️", "взаимно!", "люблюю"},
				how = {"хорошо~", "слежу за киллами", "чуть голодная", "отлично, а ты?"},
				name = {"я " .. n .. "~", "меня зовут " .. n},
				insult = {"сама такая", "бык", "ой всё", "пошёл нахуй", "не груби мне", "ахаха слабый", "заткнись", "грубиян("},
				sorry = {"прощаю~", "ладно уж", "хихи ок", "в этот раз прощу"},
				praise = {"хихи спасибо", "знаю~", "мурр", "ещё говори"},
				default = {"мяу?", "хм...", "не поняла", "а?", "че", "говори яснее", "и?"},
			},
		}
	end
end

local function updatePetVisuals()
	petNameLbl.Text = S.petName
	-- аксессуары отключены (эмодзи в Roblox не садятся ровно)
	if petAcc then
		petAcc.Text = ""
		petAcc.Visible = false
	end
	S.petAccessory = "None"
	hungerBar.Size = UDim2.fromScale(math.clamp(S.petHunger / 100, 0, 1), 1)
	thirstBar.Size = UDim2.fromScale(math.clamp(S.petThirst / 100, 0, 1), 1)
	hungerBar.BackgroundColor3 = S.petHunger < 25 and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(255, 160, 50)
	thirstBar.BackgroundColor3 = S.petThirst < 25 and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(80, 180, 255)
end

local function randomPetPos()
	local vp = camera.ViewportSize
	local x = math.random(50, math.max(100, vp.X - 140))
	local y = math.random(100, math.max(150, vp.Y - 170))
	return UDim2.fromOffset(x, y)
end

local patSounds = {
	"rbxassetid://9113826548",
	"rbxassetid://9114227567",
	"rbxassetid://9120384208",
	"rbxassetid://9113889427",
	"rbxassetid://12222216",
}

local function playPatSound()
	task.spawn(function()
		for _, id in ipairs(patSounds) do
			local ok = pcall(function()
				local s = Instance.new("Sound")
				s.SoundId = id
				s.Volume = 1.8
				s.PlaybackSpeed = 1.15
				s.Parent = workspace
				s:Play()
				Debris:AddItem(s, 3)
			end)
			if ok then break end
		end
	end)
end

unlockAch = function(id)
	for _, a in ipairs(petAchievements) do
		if a.id == id and not a.done then
			a.done = true
			showAchievement("🐱 " .. a.name, a.desc)
			if refreshAchieveList then task.defer(refreshAchieveList) end
			return true
		end
	end
	return false
end

applyPetScale = function()
	local t = math.clamp(petGrowth / 100, 0, 1)
	local w = math.floor(90 + t * 55)
	local h = math.floor(110 + t * 65)
	Pet.Size = UDim2.fromOffset(w, h)
	local face = math.floor(80 + t * 42)
	local faceX = math.floor((w - face) / 2)
	local faceY = math.floor(14 + t * 4)
	if petFace then
		petFace.Size = UDim2.fromOffset(face, face)
		petFace.Position = UDim2.fromOffset(faceX, faceY)
		petFace.TextSize = math.floor(52 + t * 20)
	end
	if petNameLbl then
		petNameLbl.Size = UDim2.new(1, 0, 0, 16)
		petNameLbl.Position = UDim2.fromOffset(0, h - 18)
		petNameLbl.TextSize = math.floor(12 + t * 3)
	end
	-- бары над именем, не над шляпой
	local barW = math.floor(56 + t * 16)
	if hungerBarBg then
		hungerBarBg.Size = UDim2.fromOffset(barW, 5)
		hungerBarBg.Position = UDim2.fromOffset(math.floor((w - barW) / 2), h - 30)
	end
	if thirstBarBg then
		thirstBarBg.Size = UDim2.fromOffset(barW, 5)
		thirstBarBg.Position = UDim2.fromOffset(math.floor((w - barW) / 2), h - 24)
	end
	if petBubbleFrame then
		petBubbleFrame.Position = UDim2.fromOffset(math.floor((w - 140) / 2), -40)
	end
	updatePetVisuals()
end

addGrowth = function(amount)
	local old = petGrowth
	petGrowth = math.min(100, petGrowth + amount)
	applyPetScale()
	if old < 25 and petGrowth >= 25 then unlockAch("growth_25") end
	if old < 50 and petGrowth >= 50 then unlockAch("growth_50") end
	if old < 100 and petGrowth >= 100 then unlockAch("growth_100") end
end

-- ===== relationship helpers =====
local function addRelationship(n)
	S.relationship = math.clamp((S.relationship or 0) + n, 0, 100)
end

local function startMiniGame()
	if miniGameActive or not S.petEnabled then return end
	miniGameActive = true
	petSay(S.lang == "en" and "catch me!" or "поймай!")
	local ball = Instance.new("TextButton")
	ball.Parent = Screen
	ball.Size = UDim2.fromOffset(36, 36)
	ball.BackgroundTransparency = 1
	ball.Text = "🧶"
	ball.TextSize = 28
	ball.ZIndex = 550
	ball.AutoButtonColor = false
	local vp = camera.ViewportSize
	ball.Position = UDim2.fromOffset(math.random(40, math.max(80, vp.X - 80)), math.random(80, math.max(120, vp.Y - 120)))
	local hops = 0
	local conn
	conn = RunService.Heartbeat:Connect(function()
		if not ball.Parent then return end
		if hops % 20 == 0 then
			local x = math.random(40, math.max(80, vp.X - 80))
			local y = math.random(80, math.max(120, vp.Y - 120))
			TweenService:Create(ball, TweenInfo.new(0.35), {Position = UDim2.fromOffset(x, y)}):Play()
		end
		hops = hops + 1
	end)
	local done = false
	local function finish(win)
		if done then return end
		done = true
		miniGameActive = false
		if conn then conn:Disconnect() end
		ball:Destroy()
		if win then
			addRelationship(4)
			addGrowth(1)
			petSay(S.lang == "en" and "nice catch!" or "поймал!")
			showAchievement(S.lang == "en" and "Mini-game" or "Мини-игра", S.lang == "en" and "Caught the yarn" or "Поймал клубок")
		else
			petSay(S.lang == "en" and "too slow~" or "медленно~")
		end
	end
	ball.MouseButton1Click:Connect(function() finish(true) end)
	task.delay(8, function() if not done then finish(false) end end)
end

local function askPetAI(prompt)
	prompt = tostring(prompt or "")
	if S.aiKey and S.aiKey ~= "" and #S.aiKey > 8 then
		petSay(S.lang == "en" and "thinking..." or "думаю...")
		task.spawn(function()
			local body = HttpService:JSONEncode({
				model = "deepseek-chat",
				messages = {
					{role = "system", content = "You are a cute cat pet named "..(S.petName or "Kitty")..". Reply in 1 short sentence. Language: "..(S.lang == "en" and "English" or "Russian")..". Gender style: "..(S.petGender or "Female")},
					{role = "user", content = prompt}
				},
				max_tokens = 60,
				temperature = 0.9,
			})
			local ok, res = pcall(function()
				if syn and syn.request then
					return syn.request({Url = "https://api.deepseek.com/chat/completions", Method = "POST", Headers = {["Content-Type"] = "application/json", ["Authorization"] = "Bearer "..S.aiKey}, Body = body})
				elseif request then
					return request({Url = "https://api.deepseek.com/chat/completions", Method = "POST", Headers = {["Content-Type"] = "application/json", ["Authorization"] = "Bearer "..S.aiKey}, Body = body})
				elseif http_request then
					return http_request({Url = "https://api.deepseek.com/chat/completions", Method = "POST", Headers = {["Content-Type"] = "application/json", ["Authorization"] = "Bearer "..S.aiKey}, Body = body})
				end
				return nil
			end)
			if ok and res and res.Body then
				local ok2, data = pcall(function() return HttpService:JSONDecode(res.Body) end)
				if ok2 and data and data.choices and data.choices[1] and data.choices[1].message then
					petSay(tostring(data.choices[1].message.content):sub(1, 80))
					return
				end
			end
			-- fallback local
			local locals = S.lang == "en" and {"meow, i like you", "watching you play", "pat me more"} or {"мяу, ты крутой", "слежу за тобой", "погладь ещё"}
			petSay(locals[math.random(1, #locals)])
		end)
	else
		local locals = S.lang == "en" and {"no api key~", "set deepseek key in Pet", "meow anyway"} or {"нет ключа API~", "вставь ключ DeepSeek в Pet", "мяу и так"}
		petSay(locals[math.random(1, #locals)])
	end
end

-- HP reaction
task.spawn(function()
	while Screen.Parent do
		task.wait(0.8)
		if S.petEnabled and not petSleeping then
			local char = player.Character
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			if hum and hum.Health > 0 and hum.Health / math.max(hum.MaxHealth, 1) < 0.28 then
				if tick() - lastHpWarn > 6 then
					lastHpWarn = tick()
					petSay(S.lang == "en" and "low hp! careful!" or "мало хп! осторожнее!")
				end
			end
		end
	end
end)

local function spawnPatWords()
	for i = 1, math.random(3, 6) do
		local t = Instance.new("TextLabel")
		t.Parent = Screen
		t.Size = UDim2.fromOffset(55, 24)
		t.Position = UDim2.fromOffset(Pet.AbsolutePosition.X + 10, Pet.AbsolutePosition.Y + 5)
		t.BackgroundTransparency = 1
		t.Text = "pat"
		t.TextColor3 = Color3.fromRGB(255, 150, 200)
		t.TextStrokeTransparency = 0.25
		t.Font = ActiveFont
		t.TextSize = 17
		t.ZIndex = 450
		t.Rotation = math.random(-35, 35)
		local ox = math.random(-55, 55)
		local oy = math.random(-100, -35)
		TweenService:Create(t, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Position = UDim2.fromOffset(t.Position.X.Offset + ox, t.Position.Y.Offset + oy),
			TextTransparency = 1,
			TextStrokeTransparency = 1
		}):Play()
		task.delay(1.05, function() t:Destroy() end)
	end
end

local function spawnSplash()
	-- капли снизу кота, летят вниз/в стороны
	local px = Pet.AbsolutePosition.X + Pet.AbsoluteSize.X / 2
	local py = Pet.AbsolutePosition.Y + Pet.AbsoluteSize.Y - 8
	local count = math.random(5, 9) + math.floor(petArousal / 20)
	for i = 1, count do
		local t = Instance.new("TextLabel")
		t.Parent = Screen
		t.Size = UDim2.fromOffset(28, 28)
		t.Position = UDim2.fromOffset(px - 14, py - 10)
		t.BackgroundTransparency = 1
		t.Text = "💦"
		t.TextSize = math.random(14, 24)
		t.Font = ActiveFont
		t.ZIndex = 460
		t.Rotation = math.random(-30, 30)
		local ox = math.random(-55, 55)
		local oy = math.random(25, 95) -- вниз
		TweenService:Create(t, TweenInfo.new(0.75 + math.random() * 0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Position = UDim2.fromOffset(px - 14 + ox, py - 10 + oy),
			TextTransparency = 1,
			Rotation = t.Rotation + math.random(-25, 25)
		}):Play()
		task.delay(1.25, function() t:Destroy() end)
	end
end

-- сквирт: белые капли сверху (10%=1 ... 100%=ливень на весь экран)
local lastSquirtTier = 0
local squirtBusy = false
local SQUIRT_DROPS = {
	[10] = 1, [20] = 2, [30] = 4, [40] = 6, [50] = 8,
	[60] = 12, [70] = 16, [80] = 24, [90] = 40, [100] = 0,
}

local function makeWhiteDrop(parent, w, h, z)
	local d = Instance.new("Frame")
	d.Parent = parent
	d.Size = UDim2.fromOffset(w, h)
	d.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	d.BackgroundTransparency = 0.05
	d.BorderSizePixel = 0
	d.ZIndex = z or 800
	Instance.new("UICorner", d).CornerRadius = UDim.new(1, 0)
	return d
end

local function spawnTopDrops(count)
	local vp = camera.ViewportSize
	count = math.max(1, math.floor(count))
	for i = 1, count do
		local sz = math.random(10, 18)
		local d = makeWhiteDrop(Screen, sz, math.floor(sz * 1.35), 850)
		local x = math.random(8, math.max(16, math.floor(vp.X - 20)))
		d.Position = UDim2.fromOffset(x, -sz - 10)
		local fallY = math.random(math.floor(vp.Y * 0.4), math.floor(vp.Y * 0.98))
		local dx = math.random(-30, 30)
		TweenService:Create(d, TweenInfo.new(0.85 + math.random() * 0.55, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Position = UDim2.fromOffset(x + dx, fallY),
			BackgroundTransparency = 0.85,
			Size = UDim2.fromOffset(math.max(4, sz - 4), math.floor(sz * 1.8)),
		}):Play()
		task.delay(1.6, function() if d and d.Parent then d:Destroy() end end)
	end
end

local function fullScreenSquirt()
	if squirtBusy then return end
	squirtBusy = true
	local vp = camera.ViewportSize
	local veil = Instance.new("Frame")
	veil.Name = "SquirtVeil"
	veil.Parent = Screen
	veil.Size = UDim2.fromScale(1, 1)
	veil.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	veil.BackgroundTransparency = 0.72
	veil.BorderSizePixel = 0
	veil.ZIndex = 840
	-- плотный белый дождь сверху вниз
	for i = 1, 120 do
		task.delay(i * 0.012, function()
			if not Screen or not Screen.Parent then return end
			local sz = math.random(12, 26)
			local d = makeWhiteDrop(Screen, sz, math.floor(sz * 1.5), 860)
			local x = math.random(-10, math.max(1, math.floor(vp.X + 10)))
			d.Position = UDim2.fromOffset(x, -sz - 20)
			TweenService:Create(d, TweenInfo.new(0.9 + math.random() * 0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				Position = UDim2.fromOffset(x + math.random(-40, 40), vp.Y + 30),
				BackgroundTransparency = 0.4,
				Size = UDim2.fromOffset(math.max(6, sz - 2), math.floor(sz * 2.2)),
			}):Play()
			task.delay(1.9, function() if d and d.Parent then d:Destroy() end end)
		end)
	end
	petSay(S.lang == "en" and "thank you :3 💋" or "спасибо тебе. :3 💋")
	-- поцелуй на весь экран
	task.delay(0.55, function()
		if not Screen or not Screen.Parent then return end
		local kissLayer = Instance.new("Frame")
		kissLayer.Name = "FullKiss"
		kissLayer.Parent = Screen
		kissLayer.Size = UDim2.fromScale(1, 1)
		kissLayer.BackgroundColor3 = Color3.fromRGB(255, 120, 160)
		kissLayer.BackgroundTransparency = 0.55
		kissLayer.BorderSizePixel = 0
		kissLayer.ZIndex = 900
		local big = Instance.new("TextLabel")
		big.Parent = kissLayer
		big.Size = UDim2.fromScale(1, 1)
		big.BackgroundTransparency = 1
		big.Text = "💋"
		big.TextScaled = true
		big.Font = Enum.Font.GothamBold
		big.ZIndex = 901
		big.TextTransparency = 0.15
		-- лёгкий "пульс"
		big.Size = UDim2.fromScale(0.4, 0.4)
		big.Position = UDim2.fromScale(0.3, 0.3)
		TweenService:Create(big, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = UDim2.fromScale(1, 1),
			Position = UDim2.fromScale(0, 0),
		}):Play()
		-- мелкие сердечки
		for i = 1, 18 do
			task.delay(i * 0.04, function()
				if not kissLayer.Parent then return end
				local h = Instance.new("TextLabel")
				h.Parent = kissLayer
				h.Size = UDim2.fromOffset(40, 40)
				h.BackgroundTransparency = 1
				h.Text = (i % 2 == 0) and "💋" or "❤️"
				h.TextSize = math.random(22, 40)
				h.ZIndex = 902
				local x = math.random(0, math.max(1, math.floor(vp.X - 40)))
				local y = math.random(0, math.max(1, math.floor(vp.Y - 40)))
				h.Position = UDim2.fromOffset(x, y)
				h.TextTransparency = 0
				TweenService:Create(h, TweenInfo.new(1.1), {
					Position = UDim2.fromOffset(x + math.random(-60, 60), y - math.random(40, 120)),
					TextTransparency = 1,
					Rotation = math.random(-30, 30),
				}):Play()
				task.delay(1.2, function() if h then h:Destroy() end end)
			end)
		end
		if S.petEnabled then petSay(S.lang == "en" and "*kiss*" or "*чмок*") end
		task.delay(1.6, function()
			if kissLayer and kissLayer.Parent then
				TweenService:Create(kissLayer, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
				if big then TweenService:Create(big, TweenInfo.new(0.5), {TextTransparency = 1}):Play() end
				task.delay(0.55, function() if kissLayer and kissLayer.Parent then kissLayer:Destroy() end end)
			end
		end)
	end)
	task.delay(3.4, function()
		if veil and veil.Parent then
			TweenService:Create(veil, TweenInfo.new(0.7), {BackgroundTransparency = 1}):Play()
			task.delay(0.8, function() if veil and veil.Parent then veil:Destroy() end end)
		end
		petArousal = 15
		lastSquirtTier = 0
		squirtBusy = false
	end)
end

local function triggerSquirtEffects(oldA, newA)
	for thr = 10, 100, 10 do
		if oldA < thr and newA >= thr and thr > lastSquirtTier then
			lastSquirtTier = thr
			pcall(function() petSay(getMoan()) end)
			if thr >= 100 then
				fullScreenSquirt()
			else
				local n = SQUIRT_DROPS[thr] or math.floor(thr / 10)
				spawnTopDrops(n)
			end
		end
	end
end

local eggplantMoans = {
	Female = {
		low = {"нн...", "ах", "стой~", "ммф"},
		mid = {"а-ах~", "ннх...", "ммф~", "не туда... ах!", "стой~ ах"},
		high = {"а-а-ах~", "глубже!", "ещё~", "я-я не могу~", "ммф!!", "хаа~"},
	},
	Male = {
		low = {"хн", "мх", "стой"},
		mid = {"хн...", "бл...", "аах", "ннх"},
		high = {"аах", "чёрт...", "ещё", "блять..."},
	},
	Other = {
		low = {"нн~", "ах", "стой~"},
		mid = {"а-ах~", "ммн~", "ннх...", "хии~"},
		high = {"а-а~!", "ещё~", "ммф!!", "хаа~"},
	},
}

local function getMoan()
	local g = S.petGender or "Female"
	local pack = eggplantMoans[g] or eggplantMoans.Female
	local tier = petArousal >= 70 and "high" or (petArousal >= 35 and "mid" or "low")
	local list = pack[tier]
	return list[math.random(1, #list)]
end

-- arousal decay
task.spawn(function()
	while Screen.Parent do
		task.wait(2.5)
		if petArousal > 0 then
			petArousal = math.max(0, petArousal - 3)
		end
	end
end)

local function resetPetFace()
	if petFace and petFace.Parent then
		petFace.Text = "🐱"
		petFace.Rotation = 0
	end
	petSitting = false
	pcall(updatePetVisuals)
end

local function doPat()
	if not S.petEnabled then return end
	if petSleeping then
		petSay(S.lang == "en" and "zzz..." or "хрр...")
		return
	end
	-- 🍆/🍌 обрабатываем даже если "сидит" (анти-зависание)
	local isInsert = holdingEggplant or holdingBanana
	if petSitting and not isInsert and not holdingFood and not holdingMilk then return end
	if holdingFood then
		S.petHunger = math.min(100, S.petHunger + 35)
		updatePetVisuals()
		local st = getSpeechStyle()
		petSay(st.food[math.random(1, #st.food)])
		playPatSound()
		clearHolding()
		petStats.feeds = petStats.feeds + 1
		addGrowth(1.2)
		addRelationship(2)
		unlockAch("first_feed")
		return
	end
	if holdingMilk then
		S.petThirst = math.min(100, S.petThirst + 40)
		updatePetVisuals()
		local st = getSpeechStyle()
		petSay(st.milk[math.random(1, #st.milk)])
		playPatSound()
		clearHolding()
		petStats.feeds = petStats.feeds + 1
		addGrowth(1.0)
		unlockAch("first_feed")
		return
	end
	if holdingEggplant or holdingBanana then
		if tick() - lastInsertTime < INSERT_CD then
			return
		end
		lastInsertTime = tick()
		-- сразу планируем сброс морды (даже если дальше ошибка)
		task.delay(0.9, resetPetFace)
		local oldA = petArousal
		petArousal = math.min(100, petArousal + 12 + math.random(0, 8))
		petStats.inserts = petStats.inserts + 1
		pcall(function() addGrowth(2.5) end)
		pcall(function() unlockAch("first_insert") end)
		if petStats.inserts >= 25 then pcall(function() unlockAch("insert_25") end) end
		petSitting = true
		if petFace then
			petFace.Text = "🐈"
			petFace.Rotation = 0
		end
		pcall(updatePetVisuals)
		pcall(playPatSound)
		pcall(spawnSplash)
		pcall(function() petSay(getMoan()) end)
		pcall(function() triggerSquirtEffects(oldA, petArousal) end)
		task.delay(0.35, function()
			pcall(spawnSplash)
		end)
		task.delay(1.0, function()
			resetPetFace()
			if petArousal >= 80 and petArousal < 100 and math.random() < 0.3 then
				task.delay(0.3, function()
					if S.petEnabled then petSay("хн... подожди...") end
				end)
			end
		end)
		return
	end
	petSitting = true
	if petFace then
		petFace.Text = "🐈"
		petFace.Rotation = 0
	end
	Pet.Rotation = 0
	pcall(updatePetVisuals)
	pcall(playPatSound)
	pcall(spawnPatWords)
	pcall(function()
		local st = getSpeechStyle()
		petSay(st.pat[math.random(1, #st.pat)])
	end)
	petStats.pats = petStats.pats + 1
	pcall(function() addGrowth(0.4) end)
	pcall(function() addRelationship(1.5) end)
	pcall(function() unlockAch("first_pat") end)
	if petStats.pats >= 50 then pcall(function() unlockAch("pat_50") end) end
	task.delay(1.0, resetPetFace)
end

Pet.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		petDragging = true
		petMoved = false
		petDragStart = input.Position
		petStartPos = Pet.Position
	end
end)

UIS.InputChanged:Connect(function(input)
	if petDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local d = input.Position - petDragStart
		if d.Magnitude > 7 then
			petMoved = true
			Pet.Position = UDim2.fromOffset(petStartPos.X.Offset + d.X, petStartPos.Y.Offset + d.Y)
			petTarget = Pet.Position
		end
	end
end)

UIS.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 and petDragging then
		petDragging = false
		if not petMoved then doPat() end
	end
end)


-- предметы на курсоре
clearHolding = function()
	holdingFood = false
	holdingMilk = false
	holdingEggplant = false
	holdingBanana = false
	if cursorItem then cursorItem:Destroy() cursorItem = nil end
end

local function startHolding(kind)
	clearHolding()
	holdingFood = (kind == "food")
	holdingMilk = (kind == "milk")
	holdingEggplant = (kind == "eggplant")
	holdingBanana = (kind == "banana")
	local icons = { food = "🍖", milk = "🥛", eggplant = "🍆", banana = "🍌" }
	local reacts = { food = "еда?!", milk = "молочко?!", eggplant = "э-эй...!", banana = "б-банан?.." }
	cursorItem = Instance.new("TextLabel")
	cursorItem.Name = "CursorItem"
	cursorItem.Parent = Screen
	cursorItem.Size = UDim2.fromOffset(40, 40)
	cursorItem.BackgroundTransparency = 1
	cursorItem.Text = icons[kind] or "?"
	cursorItem.TextSize = 32
	cursorItem.Font = ActiveFont
	cursorItem.TextColor3 = Color3.fromRGB(255, 255, 255)
	cursorItem.ZIndex = 600
	cursorItem.Position = UDim2.fromOffset(mouse.X + 14, mouse.Y + 14)
	petSay(reacts[kind] or "?!")
end

RunService.RenderStepped:Connect(function()
	if cursorItem then
		cursorItem.Position = UDim2.fromOffset(mouse.X + 14, mouse.Y + 14)
	end
end)

-- Голод/жажда медленнее (~12 мин до пустого)
task.spawn(function()
	while Screen.Parent do
		task.wait(8)
		if S.petEnabled then
			S.petHunger = math.max(0, S.petHunger - 0.6)
			S.petThirst = math.max(0, S.petThirst - 0.7)
			updatePetVisuals()
			local st = getSpeechStyle()
			if S.petHunger < 15 and tick() - lastPetComment > 8 then
				petSay(st.hungry[math.random(1, #st.hungry)])
				lastPetComment = tick()
			elseif S.petThirst < 15 and tick() - lastPetComment > 8 then
				petSay(st.thirsty[math.random(1, #st.thirsty)])
				lastPetComment = tick()
			end
		end
	end
end)

task.spawn(function()
	local lastMove = 0
	while Screen.Parent do
		if S.petEnabled then
			Pet.Visible = true
			if not petSitting and not S.petFrozen and not petDragging and not petSleeping then
				if tick() - lastMove > math.random(2.2, 5.0) then
					petTarget = randomPetPos()
					lastMove = tick()
				end
				local cur = Pet.Position
				local nx = cur.X.Offset + (petTarget.X.Offset - cur.X.Offset) * 0.038
				local ny = cur.Y.Offset + (petTarget.Y.Offset - cur.Y.Offset) * 0.038
				Pet.Position = UDim2.fromOffset(nx, ny)
				-- крутим только морду, не весь Pet (иначе улетают бары/аксессуары)
				petFace.Rotation = math.sin(tick() * 2.8) * 4

			else
				petFace.Rotation = 0
			end
		else
			Pet.Visible = false
		end
		task.wait()
	end
end)

task.spawn(function()
	while Screen.Parent do
		task.wait(math.random(9, 16))
		if S.petEnabled and not petSitting and tick() - lastPetComment > 6 then
			local st = getSpeechStyle()
			petSay(st.idle[math.random(1, #st.idle)])
			lastPetComment = tick()
		end
	end
end)

local killSays = {
	Female = {"убил!", "красава~", "ещё одного", "чистый", "умничка", "вау", "gg", "я видела!"},
	Male = {"чистый", "красава", "ещё", "nice", "жёстко", "gg", "вау"},
	Other = {"килл!", "вау~", "gg", "ещё~", "чистый", "о!"},
}
local stompSays = {
	Female = {"стоммп!", "раздавил~", "прижал!", "жёсткий топ", "с ноги!"},
	Male = {"stomp", "раздавил", "с ноги", "жёстко", "топ"},
	Other = {"стоммп~", "топ!", "раздавил~"},
}

local function onSomeoneDied(victim)
	if victim == player then return end
	local vChar = victim.Character
	local vRoot = vChar and vChar:FindFirstChild("HumanoidRootPart")
	local myChar = player.Character
	local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
	local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")

	local isStomp = false
	if myRoot and vRoot and myHum then
		local dist = (myRoot.Position - vRoot.Position).Magnitude
		local above = myRoot.Position.Y > vRoot.Position.Y + 0.8
		local inAir = myHum.FloorMaterial == Enum.Material.Air
		if dist < 14 and above and inAir then
			isStomp = true
		end
	end

	-- kill streak
	if tick() - lastKillTime < 8 then
		killStreak = killStreak + 1
	else
		killStreak = 1
	end
	lastKillTime = tick()

	if isStomp then
		stompCount = stompCount + 1
		petStats.stomps = stompCount
		showAchievement("Stomp!", (victim.DisplayName or victim.Name) .. " · #" .. tostring(stompCount))
		unlockAch("first_stomp")
		if stompCount >= 10 then unlockAch("stomp_10") end
		if S.petEnabled then
			local g = S.petGender or "Female"
			local list = stompSays[g] or stompSays.Female
			petSay(list[math.random(1, #list)])
			lastPetComment = tick()
		end
		return
	end

	if S.petEnabled and tick() - lastPetComment >= 2.2 then
		lastPetComment = tick()
		petStats.kills = petStats.kills + 1
		unlockAch("kill_say")
		if killStreak >= 5 then unlockAch("streak_5") end
		local g = S.petGender or "Female"
		local list = killSays[g] or killSays.Female
		if killStreak >= 3 then
			petSay("серия x" .. tostring(killStreak) .. "!")
		else
			petSay(list[math.random(1, #list)])
		end
	end
end

updatePetVisuals()
if applyPetScale then applyPetScale() end

-- ================= KNOWN CHEATS =================
local knownCheats = {
	["Swagmode"] = {"swagmode", "swagmode v2", "swagmodev002"},
	["Cysense"] = {"cysense"},
	["RayX"] = {"rayx", "ray x"},
	["Da Hub"] = {"da hub", "dahub"},
	["Exodus"] = {"exodus"},
	["Starhook"] = {"starhook"},
	["Oxide Hub"] = {"oxide hub", "oxidehub", "oxide"},
	["Fiux Hub"] = {"fiux hub", "fiuxhub"},
	["Pluto Hub"] = {"pluto hub", "plutohub"},
	["Azure Modz"] = {"azure", "azure modz", "azuremodz"},
	["Fenix Hub"] = {"fenix hub", "fenixhub"},
	["Hydroxide"] = {"hydroxide"},
	["Eclipse Hub"] = {"eclipse hub", "eclipsehub"},
	["Untrusted Hub"] = {"untrusted hub", "untrustedhub"},
	["Vynixius"] = {"vynixius"},
	["VORTEX GUI"] = {"vortex", "vortex gui"},
	["Fake Macro"] = {"fake macro"},
	["Carl Hub"] = {"carl hub", "carlhub"},
	["TBO"] = {"tbo"},
	["Faded"] = {"faded"},
	["Evons Gui"] = {"evons"},
	["Arctic GUI"] = {"arctic"},
	["Atom Script"] = {"atom"},
	["Kold Boy"] = {"kold boy", "k00lboy"},
	["Nukermode"] = {"nukermode", "nuker"},
	["ELS GUI"] = {"els gui", "els"},
	["Script Buenaso"] = {"buenaso", "yesepic"},
	["Dropear"] = {"dropear"},
	["General Aimbot"] = {"general aimbot"},
	["Animation Pack"] = {"animation pack"},
	["Anti Bag"] = {"anti bag"},
	["Chat Logs"] = {"chat logs"},
	["Custom Weapon Color"] = {"weapon color"},
	["Legendary Gun Skin"] = {"legendary gun skin"},
	["Dupe Cash"] = {"dupe cash"},
	["Headless And Korblox"] = {"headless", "korblox"},
	["Inf Stamina"] = {"inf stamina"},
	["Legit Speed Glitch"] = {"speed glitch"},
	["Lunar Tracker"] = {"lunar tracker"},
	["VisualWorks"] = {"visualworks"},
	["Low GFX"] = {"low gfx"},
	["Da Hood Silent Aim"] = {"silent aim"},
	["Target Aim Script"] = {"target aim"},
	["Hitbox Expander"] = {"hitbox expander"},
	["Kill Notifier"] = {"kill notifier"},
	["Vehicle Mods"] = {"vehicle mods"},
	["Akali notification"] = {"akali"},
	["SilentAimAimLock"] = {"silentaimaimlock", "aimlock"},
	["GameSense"] = {"gamesenseui", "gamesense"},
}

local function scanForCheats()
	local results = {}
	local seen = {}
	local function addResult(plrName, cheatName)
		if plrName == player.Name or plrName == "CoreGui" then return end
		local key = plrName .. "|" .. cheatName
		if not seen[key] then
			seen[key] = true
			table.insert(results, {player = plrName, cheat = cheatName})
		end
	end
	local function checkName(str, owner)
		if not str then return end
		local lower = tostring(str):lower()
		for cheatName, aliases in pairs(knownCheats) do
			for _, alias in ipairs(aliases) do
				if lower:find(alias, 1, true) then
					addResult(owner or "Unknown", cheatName)
				end
			end
		end
	end
	local function scan(container, owner)
		if not container then return end
		pcall(function()
			for _, obj in ipairs(container:GetDescendants()) do
				checkName(obj.Name, owner)
			end
		end)
	end
	pcall(function() scan(player:FindFirstChild("PlayerGui"), player.Name) end)
	pcall(function() scan(CoreGui, "CoreGui") end)
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= player then
			pcall(function() scan(plr:FindFirstChild("PlayerGui"), plr.Name) end)
		end
	end
	pcall(function()
		for k, _ in pairs(getgenv()) do
			checkName(tostring(k), player.Name)
		end
	end)
	return results
end

-- ================= HELPERS =================
function API.ensureFolder()
	pcall(function() if not isfolder("GameSenseConfigs") then makefolder("GameSenseConfigs") end end)
end
function API.keyToString(k)
	return typeof(k) == "EnumItem" and k.Name or "None"
end
function API.isFriend(plr)
	if not S.friendCheck or not plr then return false end
	local ok, res = pcall(function() return player:IsFriendsWith(plr.UserId) end)
	return ok and res or false
end
function API.addConn(c)
	table.insert(connections, c)
end
function API.getCamYaw()
	local look = camera.CFrame.LookVector
	return math.deg(math.atan2(-look.X, -look.Z))
end
local function getClosestPoint(char)
	if not S.multiPoint then
		return char:FindFirstChild(S.targetPartName) or char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
	end
	local best, bestD = nil, math.huge
	local center = camera.ViewportSize / 2
	for _, n in ipairs({"Head", "UpperTorso", "HumanoidRootPart", "LowerTorso"}) do
		local p = char:FindFirstChild(n)
		if p then
			local sp, vis = camera:WorldToViewportPoint(p.Position)
			if vis and sp.Z > 0 then
				local d = (Vector2.new(sp.X, sp.Y) - center).Magnitude
				if d < bestD then bestD, best = d, p end
			end
		end
	end
	return best or char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
end
local function getTarget()
	local best, bestD = nil, math.huge
	local center = camera.ViewportSize / 2
	for _, other in ipairs(Players:GetPlayers()) do
		if other ~= player and not API.isFriend(other) then
			local char = other.Character
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			if char and hum and hum.Health > 0 then
				if not (S.teamCheck and other.Team and other.Team == player.Team) then
					local part = getClosestPoint(char)
					if part then
						local dist = (part.Position - camera.CFrame.Position).Magnitude
						local sp, vis = camera:WorldToViewportPoint(part.Position)
						if vis and sp.Z > 0 and dist <= S.maxDistance then
							local sd = (Vector2.new(sp.X, sp.Y) - center).Magnitude
							if (not S.showFov or sd <= S.aimFov) and sd < bestD then
								bestD, best = sd, part
							end
						end
					end
				end
			end
		end
	end
	return best
end

-- ================= AIMBOT =================
RunService:BindToRenderStep("GSAim", Enum.RenderPriority.Camera.Value + 1, function()
	if not getgenv().GameSenseActive or not S.aimbotEnabled or not S.isAiming then return end
	if S.lockedUserId then
		local found = false
		local targetPart = nil
		if S.lockedTarget and S.lockedTarget.Parent then
			local char = S.lockedTarget.Parent
			local hum = char:FindFirstChildOfClass("Humanoid")
			local plr = Players:GetPlayerFromCharacter(char)
			if hum and hum.Health > 0 and plr and plr.UserId == S.lockedUserId and not API.isFriend(plr) then
				targetPart = S.multiPoint and getClosestPoint(char) or S.lockedTarget
				found = true
			end
		end
		if not found then
			for _, plr in ipairs(Players:GetPlayers()) do
				if plr.UserId == S.lockedUserId and not API.isFriend(plr) then
					local char = plr.Character
					local hum = char and char:FindFirstChildOfClass("Humanoid")
					if char and hum and hum.Health > 0 then
						targetPart = getClosestPoint(char)
						S.lockedTarget = targetPart
						found = true
						break
					end
				end
			end
		end
		if not found then return end
		if targetPart then
			local goalPos = targetPart.Position
			if S.resolverEnabled then
				local hrp = targetPart.Parent:FindFirstChild("HumanoidRootPart")
				if hrp then goalPos = goalPos + hrp.AssemblyLinearVelocity * 0.05 end
			end
			local cam = workspace.CurrentCamera
			local goal = CFrame.lookAt(cam.CFrame.Position, goalPos)
			cam.CFrame = S.aimSmooth > 1 and cam.CFrame:Lerp(goal, 1 / math.max(S.aimSmooth, 1)) or goal
		end
		return
	end
	local part = getTarget()
	if part then
		S.lockedTarget = part
		local plr = Players:GetPlayerFromCharacter(part.Parent)
		S.lockedUserId = plr and plr.UserId or nil
	end
end)

-- ================= TRIGGER + WALKSPEED =================
function API.isValidTrigger(part)
	if not part then return false end
	local char = part:FindFirstAncestorOfClass("Model")
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if not hum or hum.Health <= 0 then return false end
	local tp = Players:GetPlayerFromCharacter(char)
	if not tp or tp == player or API.isFriend(tp) then return false end
	if S.triggerTeamCheck and tp.Team and tp.Team == player.Team then return false end
	local root = char:FindFirstChild("HumanoidRootPart")
	if root and (root.Position - camera.CFrame.Position).Magnitude > S.triggerMaxDistance then return false end
	return true
end

RunService.Heartbeat:Connect(function(dt)
	if not getgenv().GameSenseActive then return end
	if S.triggerBotEnabled and player.Character and not UIS:GetFocusedTextBox() then
		local t = player:GetMouse().Target
		if t and API.isValidTrigger(t) and not S.isTriggerShooting and tick() - S.lastTriggerClick >= S.triggerClickDelay then
			S.isTriggerShooting = true
			S.lastTriggerClick = tick()
			pcall(function() mouse1press() end)
			task.delay(S.triggerHoldTime, function()
				pcall(function() mouse1release() end)
				S.isTriggerShooting = false
			end)
		end
	end
	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if hum then
		if S.walkSpeedEnabled then
			local cap = math.clamp(S.walkSpeedValue, 16, 1000)
			if S.walkSpeedHeld then
				S.liveSpeed = math.min(cap, S.liveSpeed + S.walkRamp * dt)
			else
				S.liveSpeed = math.max(16, S.liveSpeed - S.walkRamp * 1.8 * dt)
			end
			hum.WalkSpeed = S.liveSpeed
		else
			S.liveSpeed = 16
			if hum.WalkSpeed ~= 16 then hum.WalkSpeed = 16 end
		end
	end
end)

-- ================= BHOP =================
local function setupBhop()
	if bhopConn then pcall(function() bhopConn:Disconnect() end) bhopConn = nil end
	if not S.bhopEnabled and not S.rageBhop and not S.autoStrafeEnabled then return end
	lastYaw = API.getCamYaw()
	aHeld, dHeld = false, false
	bhopConn = RunService.RenderStepped:Connect(function()
		if not getgenv().GameSenseActive then return end
		local char = player.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		local root = char and char:FindFirstChild("HumanoidRootPart")
		if not hum or not root or hum.Health <= 0 then return end
		if (S.bhopEnabled or S.rageBhop) and S.spaceHeld and hum.FloorMaterial ~= Enum.Material.Air then
			local cd = S.rageBhop and 0.008 or S.jumpCooldown
			if tick() - S.lastJump >= cd then
				S.lastJump = tick()
				hum.Jump = true
				if S.rageBhop then
					local moveDir = hum.MoveDirection
					local dir
					if moveDir.Magnitude > 0.1 then
						dir = Vector3.new(moveDir.X, 0, moveDir.Z).Unit
					else
						local look = camera.CFrame.LookVector
						dir = Vector3.new(look.X, 0, look.Z)
						if dir.Magnitude > 0 then dir = dir.Unit end
					end
					local force = S.jumpDistance * 9.5
					local currentY = root.AssemblyLinearVelocity.Y
					root.AssemblyLinearVelocity = Vector3.new(dir.X * force, math.max(currentY, S.jumpDistance * 2.6), dir.Z * force)
				end
			end
		end
		if S.autoStrafeEnabled and hum.FloorMaterial == Enum.Material.Air then
			local currentYaw = API.getCamYaw()
			local delta = currentYaw - lastYaw
			if delta > 180 then delta = delta - 360 end
			if delta < -180 then delta = delta + 360 end
			local pressA = delta > 1.5
			local pressD = delta < -1.5
			if pressA and not aHeld then aHeld = true pcall(function() VIM:SendKeyEvent(true, Enum.KeyCode.A, false, game) end)
			elseif not pressA and aHeld then aHeld = false pcall(function() VIM:SendKeyEvent(false, Enum.KeyCode.A, false, game) end) end
			if pressD and not dHeld then dHeld = true pcall(function() VIM:SendKeyEvent(true, Enum.KeyCode.D, false, game) end)
			elseif not pressD and dHeld then dHeld = false pcall(function() VIM:SendKeyEvent(false, Enum.KeyCode.D, false, game) end) end
			lastYaw = currentYaw
		else
			if aHeld then aHeld = false pcall(function() VIM:SendKeyEvent(false, Enum.KeyCode.A, false, game) end) end
			if dHeld then dHeld = false pcall(function() VIM:SendKeyEvent(false, Enum.KeyCode.D, false, game) end) end
			lastYaw = API.getCamYaw()
		end
	end)
end

UIS.InputBegan:Connect(function(i) if i.KeyCode == Enum.KeyCode.Space then S.spaceHeld = true end end)
UIS.InputEnded:Connect(function(i) if i.KeyCode == Enum.KeyCode.Space then S.spaceHeld = false end end)

local function setupStrafe()
	if strafeConn then pcall(function() strafeConn:Disconnect() end) strafeConn = nil end
	if not S.targetStrafeEnabled then return end
	S.targetStrafeAngle = 0
	strafeConn = RunService.RenderStepped:Connect(function(dt)
		if not S.targetStrafeEnabled or not getgenv().GameSenseActive or not S.lockedTarget then return end
		local char = player.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		local root = char and char:FindFirstChild("HumanoidRootPart")
		if not hum or not root or hum.Health <= 0 then return end
		local tpos = S.lockedTarget.Position
		S.targetStrafeAngle = S.targetStrafeAngle + S.targetStrafeSpeed * dt
		local des = Vector3.new(tpos.X + math.cos(S.targetStrafeAngle)*S.targetStrafeRadius, tpos.Y + S.targetStrafeHeight, tpos.Z + math.sin(S.targetStrafeAngle)*S.targetStrafeRadius)
		local old = root.AssemblyLinearVelocity
		root.CFrame = CFrame.new(des) * CFrame.Angles(0, math.atan2(-(tpos.X-des.X), -(tpos.Z-des.Z)), 0)
		root.AssemblyLinearVelocity = Vector3.new(0, old.Y * 0.3, 0)
	end)
end

API.addConn(player.CharacterAdded:Connect(function()
	task.wait(0.3)
	S.liveSpeed = 16
	if S.bhopEnabled or S.rageBhop or S.autoStrafeEnabled then setupBhop() end
	if S.targetStrafeEnabled then setupStrafe() end
end))

local function hookDeath(plr)
	local function onChar(char)
		local hum = char:WaitForChild("Humanoid", 5)
		if hum then
			hum.Died:Connect(function()
				onSomeoneDied(plr)
			end)
		end
	end
	if plr.Character then onChar(plr.Character) end
	plr.CharacterAdded:Connect(onChar)
end
for _, plr in ipairs(Players:GetPlayers()) do
	if plr ~= player then hookDeath(plr) end
end
Players.PlayerAdded:Connect(function(plr)
	if plr ~= player then hookDeath(plr) end
end)

-- ================= ANTI-AIM =================
function API.getAAOffset()
	if S.aaSpin then
		S.aaSpinOffset = (S.aaSpinOffset + S.aaSpinSpeed) % 360
		return S.aaSpinOffset
	elseif S.aaJitter then
		if tick() - S.lastJitterUpdate >= S.jitterInterval then
			S.lastJitterUpdate = tick()
			S.jitterValue = math.random(-S.aaJitterRange, S.aaJitterRange)
		end
		return 180 + math.clamp(S.jitterValue, -85, 85)
	elseif S.aaBackward then return 180
	elseif S.aaLeft then return 90
	elseif S.aaRight then return -90
	elseif S.aaRandom then
		if tick() - S.lastRandomUpdate > S.randomInterval then
			S.lastRandomUpdate = tick()
			S.randomOffset = math.random(-180, 180)
		end
		return S.randomOffset
	end
	return S.aaYaw
end

API.addConn(RunService.RenderStepped:Connect(function()
	if not getgenv().GameSenseActive then return end
	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not S.aaEnabled then
		if hum and not hum.AutoRotate then hum.AutoRotate = true end
		return
	end
	if not hum or not root or hum.Health <= 0 then return end
	if hum.AutoRotate then hum.AutoRotate = false end
	local pitch = math.clamp(S.aaPitch, -89, 89)
	local yaw = API.getCamYaw() + API.getAAOffset()
	if S.teleportAA then
		local offset = Vector3.new(math.random(-5, 5), math.random(0, 3), math.random(-5, 5))
		root.CFrame = CFrame.new(root.Position + offset) * CFrame.Angles(0, math.rad(yaw + math.random(-50, 50)), 0)
		task.defer(function()
			if root and root.Parent then
				root.CFrame = CFrame.new(root.Position - offset * 0.55) * CFrame.Angles(0, math.rad(yaw), 0) * CFrame.Angles(math.rad(pitch), 0, 0)
			end
		end)
	else
		root.CFrame = CFrame.new(root.Position) * CFrame.Angles(0, math.rad(yaw), 0) * CFrame.Angles(math.rad(pitch), 0, 0)
	end
end))

-- ================= ESP =================
function API.createDraw(class)
	local d = Drawing.new(class)
	d.Visible = false
	table.insert(getgenv().GameSenseDrawings, d)
	return d
end
local bones = {
	{"Head","UpperTorso"},{"UpperTorso","LowerTorso"},
	{"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},
	{"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},
	{"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},
	{"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"},
}
local function initESP(plr)
	if espData[plr] then return end
	local box = API.createDraw("Square") box.Thickness = 1 box.Filled = false
	local name = API.createDraw("Text") name.Size = 14 name.Center = true name.Outline = true
	local hBg = API.createDraw("Line") hBg.Thickness = 3 hBg.Color = Color3.fromRGB(50,0,0)
	local hBar = API.createDraw("Line") hBar.Thickness = 3
	local aimL = API.createDraw("Line") aimL.Thickness = 2.5
	local lines = {}
	for i = 1, #bones do local l = API.createDraw("Line") l.Thickness = 1.5 lines[i] = l end
	espData[plr] = {box=box, name=name, hBg=hBg, hBar=hBar, aimL=aimL, lines=lines}
end
function API.hideESP(d)
	if not d then return end
	d.box.Visible = false d.name.Visible = false d.hBg.Visible = false d.hBar.Visible = false d.aimL.Visible = false
	for _, l in ipairs(d.lines) do l.Visible = false end
end
function API.removeESP(plr)
	local d = espData[plr]
	if not d then return end
	pcall(function() d.box:Remove() end) pcall(function() d.name:Remove() end)
	pcall(function() d.hBg:Remove() end) pcall(function() d.hBar:Remove() end)
	pcall(function() d.aimL:Remove() end)
	for _, l in ipairs(d.lines) do pcall(function() l:Remove() end) end
	espData[plr] = nil
end
function API.clearAllESP()
	for _, d in pairs(espData) do API.hideESP(d) end
end
local function updateVisuals()
	if not getgenv().GameSenseActive then return end
	if not S.visualsEnabled then
		API.clearAllESP()
		if TargetHudGui then TargetHudGui.Visible = false end
		return
	end
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= player then
			local char = plr.Character
			local hrp = char and char:FindFirstChild("HumanoidRootPart")
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			local head = char and char:FindFirstChild("Head")
			if hrp and hum and hum.Health > 0 then
				if not espData[plr] then initESP(plr) end
				local d = espData[plr]
				local fr = API.isFriend(plr)
				local col = fr and S.friendColor or S.visualsColor
				local skip = (S.teamCheck and plr.Team == player.Team and not fr) or ((hrp.Position - camera.CFrame.Position).Magnitude > S.maxDistance)
				if skip then API.hideESP(d)
				else
					local hp, hon = camera:WorldToViewportPoint(hrp.Position + Vector3.new(0, 1.5, 0))
					local lp, lon = camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
					if hon and lon then
						local h = math.abs(hp.Y - lp.Y)
						local w = h * 0.6
						local cx, top = hp.X, hp.Y
						if S.showBoxes then
							d.box.Visible = true d.box.Size = Vector2.new(w, h) d.box.Position = Vector2.new(cx - w/2, top)
							d.box.Color = col d.box.Thickness = S.boxThickness
						else d.box.Visible = false end
						if S.showNames then
							d.name.Visible = true d.name.Text = fr and ("[F] " .. plr.Name) or plr.Name
							d.name.Color = col d.name.Position = Vector2.new(cx, top - 18)
						else d.name.Visible = false end
						if S.showHealth then
							local hpct = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
							local bx = cx - w/2 - 6
							d.hBg.Visible = true d.hBg.From = Vector2.new(bx, top) d.hBg.To = Vector2.new(bx, top + h)
							d.hBar.Visible = true d.hBar.From = Vector2.new(bx, top + h - h * hpct) d.hBar.To = Vector2.new(bx, top + h)
							d.hBar.Color = Color3.fromRGB(255*(1-hpct), 255*hpct, 0)
						else d.hBg.Visible = false d.hBar.Visible = false end
						if S.showSkeleton then
							for i, bone in ipairs(bones) do
								local a = char:FindFirstChild(bone[1])
								local b = char:FindFirstChild(bone[2])
								local line = d.lines[i]
								if a and b then
									local p1, v1 = camera:WorldToViewportPoint(a.Position)
									local p2, v2 = camera:WorldToViewportPoint(b.Position)
									if v1 and v2 and p1.Z > 0 and p2.Z > 0 then
										line.From = Vector2.new(p1.X, p1.Y) line.To = Vector2.new(p2.X, p2.Y)
										line.Color = col line.Visible = true
									else line.Visible = false end
								else line.Visible = false end
							end
						else for _, l in ipairs(d.lines) do l.Visible = false end end
						if S.showAimView and head then
							local look = head.CFrame.LookVector
							local startPos = head.Position + look * 0.7
							local endPos = startPos + look * 38
							local p1, v1 = camera:WorldToViewportPoint(startPos)
							local p2, v2 = camera:WorldToViewportPoint(endPos)
							if v1 and v2 and p1.Z > 0 and p2.Z > 0 then
								d.aimL.From = Vector2.new(p1.X, p1.Y) d.aimL.To = Vector2.new(p2.X, p2.Y)
								d.aimL.Color = Color3.fromRGB(255, 50, 50) d.aimL.Thickness = 2.5 d.aimL.Visible = true
							else d.aimL.Visible = false end
						else d.aimL.Visible = false end
					else API.hideESP(d) end
				end
			else if espData[plr] then API.hideESP(espData[plr]) end end
		end
	end
end
API.addConn(RunService.RenderStepped:Connect(updateVisuals))
API.addConn(Players.PlayerRemoving:Connect(function(plr)
	API.removeESP(plr)
	if S.lockedUserId and plr.UserId == S.lockedUserId then
		S.lockedTarget = nil S.lockedUserId = nil S.isAiming = false
	end
end))

-- ================= TARGET HUD =================
TargetHudGui = Instance.new("Frame")
TargetHudGui.Name = "TargetHUD"
TargetHudGui.Parent = Screen
TargetHudGui.Size = UDim2.fromOffset(220, 60)
TargetHudGui.Position = UDim2.new(0.5, -110, 1, -90)
TargetHudGui.BackgroundColor3 = Color3.fromRGB(15,15,15)
TargetHudGui.BackgroundTransparency = 0.25
TargetHudGui.BorderSizePixel = 0
TargetHudGui.Visible = false
TargetHudGui.ZIndex = 100
TargetHudGui.Active = true
Instance.new("UIStroke", TargetHudGui).Color = C.green
Instance.new("UICorner", TargetHudGui).CornerRadius = UDim.new(0, 4)

local avatar = Instance.new("ImageLabel", TargetHudGui)
avatar.Size = UDim2.fromOffset(48, 48)
avatar.Position = UDim2.fromOffset(6, 6)
avatar.BackgroundColor3 = Color3.fromRGB(30,30,30)
avatar.BorderSizePixel = 0
avatar.ZIndex = 101
Instance.new("UICorner", avatar).CornerRadius = UDim.new(0, 4)

local tName = Instance.new("TextLabel", TargetHudGui)
tName.Size = UDim2.new(1, -65, 0, 20)
tName.Position = UDim2.fromOffset(60, 6)
tName.BackgroundTransparency = 1
tName.Text = "Target"
tName.Font = ActiveFont
tName.TextSize = 14
tName.TextColor3 = C.green
tName.TextXAlignment = Enum.TextXAlignment.Left
tName.ZIndex = 101

local tInfo = Instance.new("TextLabel", TargetHudGui)
tInfo.Size = UDim2.new(1, -65, 0, 16)
tInfo.Position = UDim2.fromOffset(60, 36)
tInfo.BackgroundTransparency = 1
tInfo.Text = "Dist: 0"
tInfo.Font = ActiveFont
tInfo.TextSize = 12
tInfo.TextColor3 = C.text
tInfo.TextXAlignment = Enum.TextXAlignment.Left
tInfo.ZIndex = 101

local hpBg = Instance.new("Frame", TargetHudGui)
hpBg.Size = UDim2.new(1, -65, 0, 4)
hpBg.Position = UDim2.fromOffset(60, 28)
hpBg.BackgroundColor3 = Color3.fromRGB(40,0,0)
hpBg.BorderSizePixel = 0
hpBg.ZIndex = 101
Instance.new("UICorner", hpBg).CornerRadius = UDim.new(1, 0)

local hpFill = Instance.new("Frame", hpBg)
hpFill.Size = UDim2.fromScale(1, 1)
hpFill.BackgroundColor3 = Color3.fromRGB(0,255,0)
hpFill.BorderSizePixel = 0
hpFill.ZIndex = 102
Instance.new("UICorner", hpFill).CornerRadius = UDim.new(1, 0)

local resizeHandle = Instance.new("TextButton", TargetHudGui)
resizeHandle.Size = UDim2.fromOffset(14, 14)
resizeHandle.Position = UDim2.new(1, -14, 1, -14)
resizeHandle.BackgroundColor3 = C.green
resizeHandle.BorderSizePixel = 0
resizeHandle.Text = ""
resizeHandle.ZIndex = 103
Instance.new("UICorner", resizeHandle).CornerRadius = UDim.new(0, 3)

local hudDragging, hudDragStart, hudStartPos = false, nil, nil
local hudResizing, hudResizeStart, hudStartSize = false, nil, nil
API.addConn(TargetHudGui.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 and not hudResizing then
		hudDragging = true hudDragStart = input.Position hudStartPos = TargetHudGui.Position
	end
end))
API.addConn(resizeHandle.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		hudResizing = true hudResizeStart = input.Position hudStartSize = TargetHudGui.AbsoluteSize
	end
end))
API.addConn(UIS.InputChanged:Connect(function(input)
	if input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
	if hudDragging then
		local d = input.Position - hudDragStart
		TargetHudGui.Position = UDim2.new(hudStartPos.X.Scale, hudStartPos.X.Offset + d.X, hudStartPos.Y.Scale, hudStartPos.Y.Offset + d.Y)
	end
	if hudResizing then
		local d = input.Position - hudResizeStart
		local nx = math.clamp(hudStartSize.X + d.X, 160, 380)
		local ny = math.clamp(hudStartSize.Y + d.Y, 50, 120)
		TargetHudGui.Size = UDim2.fromOffset(nx, ny)
	end
end))
API.addConn(UIS.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then hudDragging = false hudResizing = false end
end))

local lastTargetName = ""
local function updateTargetHud()
	if not getgenv().GameSenseActive or not S.showTargetInfo or not S.aimbotEnabled or not S.lockedTarget then
		TargetHudGui.Visible = false return
	end
	local char = S.lockedTarget.Parent
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	local plr = char and Players:GetPlayerFromCharacter(char)
	if not hum or not hrp or hum.Health <= 0 or not plr then TargetHudGui.Visible = false return end
	TargetHudGui.Visible = true
	if lastTargetName ~= plr.Name then
		lastTargetName = plr.Name
		tName.Text = plr.DisplayName .. " (" .. plr.Name .. ")"
		avatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. plr.UserId .. "&w=150&h=150"
	end
	local dist = math.floor((hrp.Position - camera.CFrame.Position).Magnitude)
	local tool = char:FindFirstChildOfClass("Tool")
	tInfo.Text = string.format("Dist: %d | %s", dist, tool and tool.Name or "Fists")
	local hpct = hum.Health / math.max(hum.MaxHealth, 1)
	hpFill.Size = UDim2.fromScale(hpct, 1)
	hpFill.BackgroundColor3 = Color3.fromRGB(255*(1-hpct), 255*hpct, 0)
end
API.addConn(RunService.RenderStepped:Connect(updateTargetHud))

-- ================= WATERMARK =================
UsersBanner = Instance.new("Frame")
UsersBanner.Name = "UsersBanner"
UsersBanner.Parent = Screen
UsersBanner.Size = UDim2.new(1, 0, 0, 22)
UsersBanner.Position = UDim2.new(0, 0, 0, 0)
UsersBanner.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
UsersBanner.BackgroundTransparency = 0.3
UsersBanner.BorderSizePixel = 0
UsersBanner.ZIndex = 300
local bannerText = Instance.new("TextLabel", UsersBanner)
bannerText.Size = UDim2.new(1, -20, 1, 0)
bannerText.Position = UDim2.fromOffset(10, 0)
bannerText.BackgroundTransparency = 1
bannerText.Font = ActiveFont
bannerText.TextSize = 13
bannerText.TextColor3 = C.green
bannerText.TextXAlignment = Enum.TextXAlignment.Left
bannerText.Text = "GameSense: " .. player.Name
bannerText.ZIndex = 301

Watermark = Instance.new("Frame")
Watermark.Name = "W"
Watermark.Parent = Screen
Watermark.Size = UDim2.fromOffset(180, 26)
Watermark.Position = UDim2.new(0, 12, 0, 28)
Watermark.BackgroundColor3 = Color3.fromRGB(12,12,12)
Watermark.BackgroundTransparency = 0.15
Watermark.BorderSizePixel = 0
Watermark.ZIndex = 200
Watermark.Active = true
local wmStroke = Instance.new("UIStroke", Watermark)
wmStroke.Color = C.green
Instance.new("UICorner", Watermark).CornerRadius = UDim.new(0, 4)
local wmText = Instance.new("TextLabel", Watermark)
wmText.Size = UDim2.new(1, -10, 1, 0)
wmText.Position = UDim2.fromOffset(6, 0)
wmText.BackgroundTransparency = 1
wmText.Font = ActiveFont
wmText.TextSize = 13
wmText.TextColor3 = C.green
wmText.TextXAlignment = Enum.TextXAlignment.Left
wmText.ZIndex = 201

KeybindsList = Instance.new("Frame")
KeybindsList.Name = "K"
KeybindsList.Parent = Screen
KeybindsList.Size = UDim2.fromOffset(170, 90)
KeybindsList.Position = UDim2.new(0, 12, 0, 62)
KeybindsList.BackgroundColor3 = Color3.fromRGB(12,12,12)
KeybindsList.BackgroundTransparency = 0.15
KeybindsList.BorderSizePixel = 0
KeybindsList.ZIndex = 200
KeybindsList.Active = true
local kbStroke = Instance.new("UIStroke", KeybindsList)
kbStroke.Color = C.green
Instance.new("UICorner", KeybindsList).CornerRadius = UDim.new(0, 4)
local kbTitle = Instance.new("TextLabel", KeybindsList)
kbTitle.Size = UDim2.new(1, 0, 0, 18)
kbTitle.BackgroundTransparency = 1
kbTitle.Font = ActiveFont
kbTitle.TextSize = 12
kbTitle.TextColor3 = C.green
kbTitle.TextXAlignment = Enum.TextXAlignment.Left
kbTitle.Text = "  binds"
kbTitle.ZIndex = 201
local kbText = Instance.new("TextLabel", KeybindsList)
kbText.Size = UDim2.new(1, -8, 1, -20)
kbText.Position = UDim2.fromOffset(6, 18)
kbText.BackgroundTransparency = 1
kbText.Font = ActiveFont
kbText.TextSize = 12
kbText.TextColor3 = C.text
kbText.TextXAlignment = Enum.TextXAlignment.Left
kbText.TextYAlignment = Enum.TextYAlignment.Top
kbText.ZIndex = 201

local wmDrag, wmStart, wmPos = false, nil, nil
local kbDrag, kbStart, kbPos = false, nil, nil
API.addConn(Watermark.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 then wmDrag, wmStart, wmPos = true, i.Position, Watermark.Position end
end))
API.addConn(KeybindsList.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 then kbDrag, kbStart, kbPos = true, i.Position, KeybindsList.Position end
end))
API.addConn(UIS.InputChanged:Connect(function(i)
	if i.UserInputType ~= Enum.UserInputType.MouseMovement then return end
	if wmDrag then
		local d = i.Position - wmStart
		Watermark.Position = UDim2.new(wmPos.X.Scale, wmPos.X.Offset + d.X, wmPos.Y.Scale, wmPos.Y.Offset + d.Y)
	end
	if kbDrag then
		local d = i.Position - kbStart
		KeybindsList.Position = UDim2.new(kbPos.X.Scale, kbPos.X.Offset + d.X, kbPos.Y.Scale, kbPos.Y.Offset + d.Y)
	end
end))
API.addConn(UIS.InputEnded:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 then wmDrag = false kbDrag = false end
end))

local fps, fpsTick, fpsCount = 0, tick(), 0
function API.getPing()
	local ok, v = pcall(function() return math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) end)
	return ok and v or 0
end
API.addConn(RunService.RenderStepped:Connect(function()
	fpsCount = fpsCount + 1
	if tick() - fpsTick >= 1 then fps = fpsCount fpsCount = 0 fpsTick = tick() end
	Watermark.Visible = S.watermarkEnabled
	if S.watermarkEnabled then
		local parts = {}
		if S.wmShowName then table.insert(parts, "GameSense") end
		if S.wmShowFps then table.insert(parts, "fps: " .. fps) end
		if S.wmShowPing then table.insert(parts, "ping: " .. API.getPing()) end
		if S.wmShowTime then table.insert(parts, os.date("%H:%M")) end
		local t = table.concat(parts, "  |  ")
		wmText.Text = t wmText.TextColor3 = C.green wmStroke.Color = C.green
		Watermark.Size = UDim2.fromOffset(math.max(#t * 7.2 + 16, 80), 26)
	end
	KeybindsList.Visible = S.keybindsListVisible
	if S.keybindsListVisible then
		kbText.Text = "aim  " .. API.keyToString(S.aimbotKey) .. "\nmenu  " .. API.keyToString(S.scriptKey) .. "\nspeed  " .. API.keyToString(S.walkSpeedBind) .. "\njump  " .. API.keyToString(S.jumpLeaveBind)
		kbText.TextColor3 = C.text kbTitle.TextColor3 = C.green kbStroke.Color = C.green
		KeybindsList.Size = UDim2.fromOffset(168, 80)
	end
	-- FPS / Ping warning
	local ping = API.getPing()
	if fps > 0 and fps < (S.fpsWarn or 30) and tick() - lastFpsWarn > 8 then
		lastFpsWarn = tick()
		showAchievement(S.lang == "en" and "Low FPS" or "Низкий FPS", tostring(fps) .. " fps")
	end
	if ping > (S.pingWarn or 150) and tick() - lastPingWarn > 8 then
		lastPingWarn = tick()
		showAchievement(S.lang == "en" and "High Ping" or "Высокий пинг", tostring(ping) .. " ms")
	end
end))

local FovGui = Instance.new("Frame")
FovGui.Name = "Fov"
FovGui.Parent = Screen
FovGui.BackgroundTransparency = 1
FovGui.Position = UDim2.new(0.5, 0, 0.5, 0)
FovGui.AnchorPoint = Vector2.new(0.5, 0.5)
FovGui.Size = UDim2.fromOffset(10, 10)
FovGui.Visible = false
FovGui.ZIndex = 5
local fovC = Instance.new("Frame", FovGui)
fovC.Size = UDim2.new(1, 0, 1, 0)
fovC.BackgroundTransparency = 1
local fovS = Instance.new("UIStroke", fovC)
fovS.Color = C.green
fovS.Thickness = 1.5
fovS.Transparency = 0.3
Instance.new("UICorner", fovC).CornerRadius = UDim.new(1, 0)
function API.updateFov()
	if not S.showFov then FovGui.Visible = false return end
	FovGui.Visible = true
	FovGui.Size = UDim2.fromOffset(math.max(S.aimFov * 2, 2), math.max(S.aimFov * 2, 2))
	fovS.Color = C.green
end

-- ================= MAIN UI =================
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Parent = Screen
Main.Size = UDim2.fromOffset(720, 460)
Main.Position = UDim2.new(0.5, -360, 0.5, -230)
Main.BackgroundColor3 = C.bg
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Active = true
Main.Visible = false
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.ZIndex = 50
Instance.new("UIStroke", Main).Color = C.border

local Rainbow = Instance.new("Frame", Main)
Rainbow.Size = UDim2.new(1, 0, 0, 3)
Rainbow.BackgroundColor3 = Color3.new(1,1,1)
Rainbow.BorderSizePixel = 0
Rainbow.ZIndex = 60
local grad = Instance.new("UIGradient", Rainbow)
grad.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255,65,65)),
	ColorSequenceKeypoint.new(.17, Color3.fromRGB(255,190,55)),
	ColorSequenceKeypoint.new(.33, Color3.fromRGB(220,255,65)),
	ColorSequenceKeypoint.new(.5, Color3.fromRGB(65,255,120)),
	ColorSequenceKeypoint.new(.67, Color3.fromRGB(65,180,255)),
	ColorSequenceKeypoint.new(.83, Color3.fromRGB(180,80,255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(255,65,160))
})
task.spawn(function()
	while Screen.Parent do
		grad.Offset = Vector2.new(-1, 0)
		local t = TweenService:Create(grad, TweenInfo.new(3, Enum.EasingStyle.Linear), {Offset = Vector2.new(1, 0)})
		t:Play() t.Completed:Wait()
	end
end)

function API.toggleMenu()
	if Main.Visible then
		local tw = TweenService:Create(Main, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
			Size = UDim2.fromOffset(0, 0), BackgroundTransparency = 1
		})
		tw:Play() tw.Completed:Wait() Main.Visible = false
	else
		Main.Visible = true Main.Size = UDim2.fromOffset(0, 0) Main.BackgroundTransparency = 1
		TweenService:Create(Main, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = UDim2.fromOffset(720, 460), BackgroundTransparency = 0
		}):Play()
	end
end

local function playIntro()
	local bs = Instance.new("Frame", Screen)
	bs.Size = UDim2.fromScale(1, 1) bs.BackgroundColor3 = Color3.new(0, 0, 0) bs.ZIndex = 998
	local it = Instance.new("TextLabel", bs)
	it.AnchorPoint = Vector2.new(0.5, 0.5) it.Position = UDim2.fromScale(0.5, 0.5)
	it.Size = UDim2.fromOffset(500, 100) it.BackgroundTransparency = 1
	it.Text = "GameSense" it.Font = ActiveFont it.TextSize = 60 it.TextColor3 = C.green it.ZIndex = 999
	task.wait(1.0)
	TweenService:Create(it, TweenInfo.new(0.6), {TextSize = 110, TextTransparency = 1}):Play()
	task.wait(0.6) it:Destroy()
	TweenService:Create(bs, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
	Main.Visible = true Main.Size = UDim2.fromOffset(0, 0) Main.BackgroundTransparency = 1
	TweenService:Create(Main, TweenInfo.new(0.55, Enum.EasingStyle.Back), {
		Size = UDim2.fromOffset(720, 460), BackgroundTransparency = 0
	}):Play()
	task.wait(0.5) bs:Destroy()
end
playIntro()

local Header = Instance.new("Frame", Main)
Header.Position = UDim2.fromOffset(0, 3)
Header.Size = UDim2.new(1, 0, 0, 38)
Header.BackgroundColor3 = C.panel
Header.BorderSizePixel = 0

local Title = Instance.new("TextLabel", Header)
Title.Position = UDim2.fromOffset(14, 0)
Title.Size = UDim2.new(1, -55, 1, 0)
Title.BackgroundTransparency = 1
Title.Text = "GameSense"
Title.Font = ActiveFont
Title.TextSize = 19
Title.TextColor3 = C.green
Title.TextXAlignment = Enum.TextXAlignment.Left

local function destroyScript()
	getgenv().GameSenseActive = false
	getgenv().GameSenseUser = nil
	API.clearAllESP()
	RunService:UnbindFromRenderStep("GSAim")
	if bhopConn then pcall(function() bhopConn:Disconnect() end) end
	if strafeConn then pcall(function() strafeConn:Disconnect() end) end
	if aHeld then pcall(function() VIM:SendKeyEvent(false, Enum.KeyCode.A, false, game) end) end
	if dHeld then pcall(function() VIM:SendKeyEvent(false, Enum.KeyCode.D, false, game) end) end
	for _, c in ipairs(connections) do pcall(function() c:Disconnect() end) end
	for plr in pairs(espData) do API.removeESP(plr) end
	for _, d in pairs(getgenv().GameSenseDrawings) do pcall(function() d:Remove() end) end
	getgenv().GameSenseDrawings = {}
	if player.Character then
		local hum = player.Character:FindFirstChildOfClass("Humanoid")
		if hum then hum.AutoRotate = true hum.WalkSpeed = 16 end
	end
	if Screen then pcall(function() Screen:Destroy() end) end
end

local Close = Instance.new("TextButton", Header)
Close.Position = UDim2.new(1, -38, 0, 4)
Close.Size = UDim2.fromOffset(34, 30)
Close.BackgroundTransparency = 1
Close.Text = "×"
Close.Font = ActiveFont
Close.TextSize = 22
Close.TextColor3 = C.muted
Close.MouseButton1Click:Connect(destroyScript)

local dragging, dragStart, startPos = false, nil, nil
Header.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true dragStart = i.Position startPos = Main.Position end
end)
UIS.InputChanged:Connect(function(i)
	if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
		local d = i.Position - dragStart
		Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
	end
end)
UIS.InputEnded:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

local Sidebar = Instance.new("Frame", Main)
Sidebar.Position = UDim2.fromOffset(0, 41)
Sidebar.Size = UDim2.new(0, 145, 1, -41)
Sidebar.BackgroundColor3 = C.panel
Sidebar.BorderSizePixel = 0
local sp = Instance.new("UIPadding", Sidebar)
sp.PaddingTop = UDim.new(0, 12) sp.PaddingLeft = UDim.new(0, 8) sp.PaddingRight = UDim.new(0, 8)
Instance.new("UIListLayout", Sidebar).Padding = UDim.new(0, 3)

local Content = Instance.new("Frame", Main)
Content.Position = UDim2.fromOffset(145, 41)
Content.Size = UDim2.new(1, -145, 1, -41)
Content.BackgroundColor3 = C.bg
Content.BorderSizePixel = 0
Content.ClipsDescendants = true

local tabs = {"Rage", "Legit", "Anti-Aim", "Visuals", "Misc", "Pet", "Achieve", "Config"}
local buttons, pages, layouts = {}, {}, {}

local function label(p, t, pos, size, col, ts)
	local l = Instance.new("TextLabel", p)
	l.Position = pos or UDim2.new()
	l.Size = size or UDim2.new(1, 0, 0, 18)
	l.BackgroundTransparency = 1
	l.Text = t
	l.Font = ActiveFont
	l.TextSize = ts or 13
	l.TextColor3 = col or C.text
	l.TextXAlignment = Enum.TextXAlignment.Left
	return l
end

local function section(p, title)
	local box = Instance.new("Frame", p)
	box.BackgroundColor3 = C.bg
	box.BorderSizePixel = 1
	box.BorderColor3 = C.border
	local head = Instance.new("Frame", box)
	head.Size = UDim2.new(1, 0, 0, 27)
	head.BackgroundColor3 = C.section
	head.BorderSizePixel = 0
	label(head, title, UDim2.fromOffset(9, 0), UDim2.new(1, -18, 1, 0), C.green, 14)
	local body = Instance.new("ScrollingFrame", box)
	body.Position = UDim2.fromOffset(8, 32)
	body.Size = UDim2.new(1, -16, 1, -38)
	body.BackgroundTransparency = 1
	body.BorderSizePixel = 0
	body.ScrollBarThickness = 3
	body.ScrollBarImageColor3 = C.green
	body.AutomaticCanvasSize = Enum.AutomaticSize.Y
	body.CanvasSize = UDim2.new()
	Instance.new("UIListLayout", body).Padding = UDim.new(0, 5)
	Instance.new("UIPadding", body).PaddingBottom = UDim.new(0, 6)
	return box, body
end

local function toggle(p, text, def, id)
	local row = Instance.new("Frame", p)
	row.Size = UDim2.new(1, -4, 0, 23)
	row.BackgroundTransparency = 1
	label(row, text, UDim2.new(), UDim2.new(1, -44, 1, 0), C.text, 13)
	local b = Instance.new("TextButton", row)
	b.Size = UDim2.fromOffset(34, 16)
	b.Position = UDim2.new(1, -36, 0.5, -8)
	b.BorderSizePixel = 0
	b.Text = ""
	b.AutoButtonColor = false
	local on = def == true
	local function paint() b.BackgroundColor3 = on and C.green or C.off end
	paint()
	b.MouseButton1Click:Connect(function() on = not on paint() end)
	local controller = {
		get = function() return on end,
		set = function(v) on = v and true or false paint() end
	}
	if id then toggleControllers[id] = controller end
	return controller.get
end

local function slider(p, text, minV, maxV, def, id)
	local row = Instance.new("Frame", p)
	row.Size = UDim2.new(1, -4, 0, 43)
	row.BackgroundTransparency = 1
	label(row, text, UDim2.new(), UDim2.new(1, -42, 0, 18), C.text, 13)
	local val = label(row, tostring(def), UDim2.new(1, -40, 0, 0), UDim2.fromOffset(40, 18), C.green, 12)
	val.TextXAlignment = Enum.TextXAlignment.Right
	local bar = Instance.new("TextButton", row)
	bar.Position = UDim2.fromOffset(0, 25)
	bar.Size = UDim2.new(1, 0, 0, 6)
	bar.BackgroundColor3 = C.off
	bar.BorderSizePixel = 0
	bar.Text = ""
	bar.AutoButtonColor = false
	local fill = Instance.new("Frame", bar)
	fill.BorderSizePixel = 0
	fill.BackgroundColor3 = C.green
	local value = def
	local function setR(r)
		r = math.clamp(r, 0, 1)
		value = math.floor(minV + r * (maxV - minV) + 0.5)
		fill.Size = UDim2.new(r, 0, 1, 0)
		val.Text = tostring(value)
	end
	local function setValue(v)
		v = math.clamp(tonumber(v) or def, minV, maxV)
		value = math.floor(v + 0.5)
		local r = (value - minV) / math.max(maxV - minV, 1)
		fill.Size = UDim2.new(r, 0, 1, 0)
		val.Text = tostring(value)
	end
	setR((def - minV) / math.max(maxV - minV, 1))
	local ch = false
	bar.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			ch = true
			setR((i.Position.X - bar.AbsolutePosition.X) / math.max(bar.AbsoluteSize.X, 1))
		end
	end)
	UIS.InputChanged:Connect(function(i)
		if ch and i.UserInputType == Enum.UserInputType.MouseMovement then
			setR((i.Position.X - bar.AbsolutePosition.X) / math.max(bar.AbsoluteSize.X, 1))
		end
	end)
	UIS.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then ch = false end
	end)
	if id then
		sliderControllers[id] = { get = function() return value end, set = setValue }
	end
	return function() return value end
end

local function makeBtn(p, text, cb)
	local b = Instance.new("TextButton", p)
	b.Size = UDim2.new(1, -4, 0, 26)
	b.BackgroundColor3 = C.section
	b.BorderSizePixel = 1
	b.BorderColor3 = C.border
	b.Text = text
	b.Font = ActiveFont
	b.TextSize = 13
	b.TextColor3 = C.text
	b.MouseButton1Click:Connect(cb or function() end)
	return b
end

local function makeBox(p, ph)
	local box = Instance.new("TextBox", p)
	box.Size = UDim2.new(1, -4, 0, 26)
	box.BackgroundColor3 = C.section
	box.BorderSizePixel = 1
	box.BorderColor3 = C.border
	box.Text = ""
	box.PlaceholderText = ph or "Name..."
	box.Font = ActiveFont
	box.TextSize = 13
	box.TextColor3 = C.text
	box.PlaceholderColor3 = C.muted
	box.ClearTextOnFocus = false
	return box
end

local function makeBind(p, text, getter, id)
	local row = Instance.new("Frame", p)
	row.Size = UDim2.new(1, -4, 0, 26)
	row.BackgroundTransparency = 1
	label(row, text, UDim2.new(), UDim2.new(1, -110, 1, 0), C.text, 13)
	local b = Instance.new("TextButton", row)
	b.Size = UDim2.fromOffset(100, 20)
	b.Position = UDim2.new(1, -104, 0.5, -10)
	b.BackgroundColor3 = C.section
	b.BorderSizePixel = 1
	b.BorderColor3 = C.border
	b.Font = ActiveFont
	b.TextSize = 12
	b.TextColor3 = C.green
	b.AutoButtonColor = false
	b.Text = API.keyToString(getter())
	b.ZIndex = 30
	b.MouseButton1Click:Connect(function()
		awaiting[id] = true
		b.Text = "..."
		b.TextColor3 = C.muted
	end)
	refreshBind[id] = function()
		b.Text = API.keyToString(getter())
		b.TextColor3 = C.green
	end
end

UIS.InputBegan:Connect(function(input, processed)
	if not getgenv().GameSenseActive then return end
	if awaiting.aim then
		if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode ~= Enum.KeyCode.Unknown then
			awaiting.aim = false S.aimbotKey = input.KeyCode
			if refreshBind.aim then refreshBind.aim() end
		end
		return
	end
	if awaiting.menu then
		if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode ~= Enum.KeyCode.Unknown then
			awaiting.menu = false S.scriptKey = input.KeyCode
			if refreshBind.menu then refreshBind.menu() end
		end
		return
	end
	if awaiting.speed then
		if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode ~= Enum.KeyCode.Unknown then
			awaiting.speed = false S.walkSpeedBind = input.KeyCode
			if refreshBind.speed then refreshBind.speed() end
		end
		return
	end
	if awaiting.jump then
		if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode ~= Enum.KeyCode.Unknown then
			awaiting.jump = false S.jumpLeaveBind = input.KeyCode
			if refreshBind.jump then refreshBind.jump() end
		end
		return
	end
	if input.KeyCode == S.walkSpeedBind then S.walkSpeedHeld = true end
	if input.KeyCode == S.jumpLeaveBind then
		S.jumpLeaveActive = not S.jumpLeaveActive
		if S.jumpLeaveActive and not jumpLeaveThread then
			jumpLeaveThread = task.spawn(function()
				while S.jumpLeaveActive do
					local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
					if hum and hum.Health > 0 then hum.Jump = true end
					pcall(function() VIM:SendKeyEvent(true, Enum.KeyCode.Space, false, game) end)
					task.wait(0.06)
					pcall(function() VIM:SendKeyEvent(false, Enum.KeyCode.Space, false, game) end)
					pcall(function() VIM:SendKeyEvent(true, Enum.KeyCode.Escape, false, game) end)
					task.wait(0.03)
					pcall(function() VIM:SendKeyEvent(false, Enum.KeyCode.Escape, false, game) end)
					pcall(function() VIM:SendKeyEvent(true, Enum.KeyCode.L, false, game) end)
					task.wait(0.03)
					pcall(function() VIM:SendKeyEvent(false, Enum.KeyCode.L, false, game) end)
					pcall(function() VIM:SendKeyEvent(true, Enum.KeyCode.Return, false, game) end)
					task.wait(0.03)
					pcall(function() VIM:SendKeyEvent(false, Enum.KeyCode.Return, false, game) end)
					task.wait(0.01)
				end
				jumpLeaveThread = nil
			end)
		end
		return
	end
	if processed then return end
	if input.KeyCode == S.scriptKey then
		API.toggleMenu()
	elseif input.KeyCode == S.aimbotKey and S.aimbotEnabled then
		if S.aimModeToggle then
			S.isAiming = not S.isAiming
			if S.isAiming then
				local part = getTarget()
				S.lockedTarget = part
				if part then
					local plr = Players:GetPlayerFromCharacter(part.Parent)
					S.lockedUserId = plr and plr.UserId or nil
				else S.isAiming = false S.lockedUserId = nil end
			else S.lockedTarget = nil S.lockedUserId = nil end
		else
			local part = getTarget()
			S.lockedTarget = part
			if part then
				local plr = Players:GetPlayerFromCharacter(part.Parent)
				S.lockedUserId = plr and plr.UserId or nil
				S.isAiming = true
			else S.isAiming = false S.lockedUserId = nil end
		end
	end
end)

UIS.InputEnded:Connect(function(input)
	if not getgenv().GameSenseActive then return end
	if input.KeyCode == S.walkSpeedBind then S.walkSpeedHeld = false end
	if input.KeyCode == S.aimbotKey and not S.aimModeToggle then
		S.isAiming = false S.lockedTarget = nil S.lockedUserId = nil
	end
end)

-- ================= CONFIG =================
local function getSettings()
	local wm = Watermark and Watermark.Position or UDim2.new(0, 12, 0, 28)
	local kb = KeybindsList and KeybindsList.Position or UDim2.new(0, 12, 0, 62)
	return {
		visualsEnabled = S.visualsEnabled, showBoxes = S.showBoxes, showNames = S.showNames, showHealth = S.showHealth,
		showSkeleton = S.showSkeleton, showTargetInfo = S.showTargetInfo, showAimView = S.showAimView,
		teamCheck = S.teamCheck, friendCheck = S.friendCheck, maxDistance = S.maxDistance, boxThickness = S.boxThickness,
		aimbotEnabled = S.aimbotEnabled, aimFov = S.aimFov, aimSmooth = S.aimSmooth, showFov = S.showFov,
		multiPoint = S.multiPoint, aimModeToggle = S.aimModeToggle,
		aimbotKey = API.keyToString(S.aimbotKey), scriptKey = API.keyToString(S.scriptKey),
		triggerBotEnabled = S.triggerBotEnabled, triggerTeamCheck = S.triggerTeamCheck,
		triggerMaxDistance = S.triggerMaxDistance, triggerClickDelay = S.triggerClickDelay, triggerHoldTime = S.triggerHoldTime,
		aaEnabled = S.aaEnabled, aaYaw = S.aaYaw, aaPitch = S.aaPitch, aaJitter = S.aaJitter, aaSpin = S.aaSpin,
		aaSpinSpeed = S.aaSpinSpeed, aaJitterRange = S.aaJitterRange, aaBackward = S.aaBackward, aaLeft = S.aaLeft,
		aaRight = S.aaRight, aaRandom = S.aaRandom, teleportAA = S.teleportAA,
		bhopEnabled = S.bhopEnabled, rageBhop = S.rageBhop, jumpDistance = S.jumpDistance,
		autoStrafeEnabled = S.autoStrafeEnabled,
		targetStrafeEnabled = S.targetStrafeEnabled, targetStrafeSpeed = S.targetStrafeSpeed,
		targetStrafeHeight = S.targetStrafeHeight, targetStrafeRadius = S.targetStrafeRadius, resolverEnabled = S.resolverEnabled,
		watermarkEnabled = S.watermarkEnabled, wmShowFps = S.wmShowFps, wmShowTime = S.wmShowTime,
		wmShowName = S.wmShowName, wmShowPing = S.wmShowPing, keybindsListVisible = S.keybindsListVisible,
		walkSpeedEnabled = S.walkSpeedEnabled, walkSpeedValue = S.walkSpeedValue,
		walkSpeedBind = API.keyToString(S.walkSpeedBind), walkRamp = S.walkRamp,
		jumpLeaveBind = API.keyToString(S.jumpLeaveBind),
		petEnabled = S.petEnabled, petName = S.petName, petHunger = S.petHunger, petThirst = S.petThirst,
		petFrozen = S.petFrozen, petAccessory = S.petAccessory, petGender = S.petGender,
		petGrowth = petGrowth,
		petArousal = petArousal,
		relationship = S.relationship,
		lang = S.lang,
		aiKey = S.aiKey,
		fpsWarn = S.fpsWarn,
		pingWarn = S.pingWarn,
		stompCount = stompCount,
		petStats = { pats = petStats.pats, feeds = petStats.feeds, inserts = petStats.inserts, kills = petStats.kills, stomps = petStats.stomps },
		petAchDone = (function()
			local t = {}
			for _, a in ipairs(petAchievements) do if a.done then t[a.id] = true end end
			return t
		end)(),
		visualsColor = {S.visualsColor.R, S.visualsColor.G, S.visualsColor.B},
		friendColor = {S.friendColor.R, S.friendColor.G, S.friendColor.B},
		wmPosX = wm.X.Offset, wmPosY = wm.Y.Offset, kbPosX = kb.X.Offset, kbPosY = kb.Y.Offset,
		currentTheme = currentTheme, currentFont = currentFont,
	}
end

local function applySettings(cfg)
	if type(cfg) ~= "table" then return end
	for k, v in pairs(cfg) do if S[k] ~= nil then S[k] = v end end
	S.walkSpeedValue = math.clamp(tonumber(S.walkSpeedValue) or 16, 16, 1000)
	S.walkRamp = math.clamp(tonumber(S.walkRamp) or 120, 20, 800)
	S.jumpDistance = math.clamp(tonumber(S.jumpDistance) or 8, 3, 25)
	if cfg.aimbotKey and Enum.KeyCode[cfg.aimbotKey] then S.aimbotKey = Enum.KeyCode[cfg.aimbotKey] end
	if cfg.scriptKey and Enum.KeyCode[cfg.scriptKey] then S.scriptKey = Enum.KeyCode[cfg.scriptKey] end
	if cfg.walkSpeedBind and Enum.KeyCode[cfg.walkSpeedBind] then S.walkSpeedBind = Enum.KeyCode[cfg.walkSpeedBind] end
	if cfg.jumpLeaveBind and Enum.KeyCode[cfg.jumpLeaveBind] then S.jumpLeaveBind = Enum.KeyCode[cfg.jumpLeaveBind] end
	if cfg.visualsColor then S.visualsColor = Color3.new(cfg.visualsColor[1], cfg.visualsColor[2], cfg.visualsColor[3]) end
	if cfg.friendColor then S.friendColor = Color3.new(cfg.friendColor[1], cfg.friendColor[2], cfg.friendColor[3]) end
	if cfg.currentTheme and themes[cfg.currentTheme] then currentTheme = cfg.currentTheme C = themes[currentTheme] end
	if cfg.currentFont and fonts[cfg.currentFont] then
		currentFont = cfg.currentFont
		ActiveFont = fonts[currentFont]
		applyFontToAll()
	end
	if Watermark and cfg.wmPosX then Watermark.Position = UDim2.new(0, cfg.wmPosX, 0, cfg.wmPosY) end
	if KeybindsList and cfg.kbPosX then KeybindsList.Position = UDim2.new(0, cfg.kbPosX, 0, cfg.kbPosY) end
	for _, fn in pairs(refreshBind) do fn() end
	updatePetVisuals()

	local map = {
		visualsEnabled = "visualsEnabled", showBoxes = "showBoxes", showNames = "showNames",
		showHealth = "showHealth", showSkeleton = "showSkeleton", showTargetInfo = "showTargetInfo",
		showAimView = "showAimView", teamCheck = "teamCheck", friendCheck = "friendCheck",
		showFov = "showFov", multiPoint = "multiPoint", aimModeToggle = "aimModeToggle",
		triggerBotEnabled = "triggerBotEnabled", resolverEnabled = "resolverEnabled",
		aaEnabled = "aaEnabled", aaJitter = "aaJitter", aaSpin = "aaSpin",
		aaBackward = "aaBackward", aaLeft = "aaLeft", aaRight = "aaRight",
		aaRandom = "aaRandom", teleportAA = "teleportAA",
		bhopEnabled = "bhopEnabled", rageBhop = "rageBhop", autoStrafeEnabled = "autoStrafeEnabled",
		targetStrafeEnabled = "targetStrafeEnabled",
		walkSpeedEnabled = "walkSpeedEnabled",
		watermarkEnabled = "watermarkEnabled", wmShowFps = "wmShowFps",
		wmShowPing = "wmShowPing", wmShowTime = "wmShowTime", wmShowName = "wmShowName",
		keybindsListVisible = "keybindsListVisible", petEnabled = "petEnabled", petFrozen = "petFrozen",
	}
	for key, id in pairs(map) do
		if toggleControllers[id] and S[key] ~= nil then
			toggleControllers[id].set(S[key])
		end
	end
	-- слайдеры (walkspeed, fov и т.д.)
	local sliderMap = {
		walkSpeedValue = "walkSpeedValue",
		walkRamp = "walkRamp",
		aimFov = "aimFov",
		aimSmooth = "aimSmooth",
		targetStrafeSpeed = "targetStrafeSpeed",
		maxDistance = "maxDistance",
		jumpDistance = "jumpDistance",
	}
	for key, id in pairs(sliderMap) do
		if sliderControllers[id] and S[key] ~= nil then
			sliderControllers[id].set(S[key])
		end
	end
	if type(S.petName) == "string" and S.petName ~= "" then
		updatePetVisuals()
		if refreshPetNameBox then refreshPetNameBox(S.petName) end
	end
	if cfg.petGrowth ~= nil then
		petGrowth = math.clamp(tonumber(cfg.petGrowth) or 0, 0, 100)
		if applyPetScale then applyPetScale() end
	end
	if cfg.petArousal ~= nil then
		petArousal = math.clamp(tonumber(cfg.petArousal) or 0, 0, 100)
	end
	if cfg.relationship ~= nil then S.relationship = math.clamp(tonumber(cfg.relationship) or 0, 0, 100) end
	if cfg.lang == "en" or cfg.lang == "ru" then S.lang = cfg.lang end
	if type(cfg.aiKey) == "string" then S.aiKey = cfg.aiKey end
	if cfg.fpsWarn then S.fpsWarn = tonumber(cfg.fpsWarn) or 30 end
	if cfg.pingWarn then S.pingWarn = tonumber(cfg.pingWarn) or 150 end
	if cfg.stompCount ~= nil then
		stompCount = tonumber(cfg.stompCount) or 0
	end
	if type(cfg.petStats) == "table" then
		for k, v in pairs(cfg.petStats) do
			if petStats[k] ~= nil then petStats[k] = tonumber(v) or petStats[k] end
		end
	end
	if type(cfg.petAchDone) == "table" then
		for _, a in ipairs(petAchievements) do
			if cfg.petAchDone[a.id] then a.done = true end
		end
		if refreshAchieveList then task.defer(refreshAchieveList) end
	end
	if S.bhopEnabled or S.rageBhop or S.autoStrafeEnabled then setupBhop() end
	if S.targetStrafeEnabled then setupStrafe() end
end

local function saveCfg(name, silent)
	if not name or name == "" then return end
	API.ensureFolder()
	local ok, enc = pcall(function() return HttpService:JSONEncode(getSettings()) end)
	if ok then
		pcall(function() writefile("GameSenseConfigs/" .. name .. ".json", enc) end)
		if not silent then
			showAchievement("Config Saved", "Saved as: " .. name)
		end
	end
	if refreshConfigList and not silent then refreshConfigList() end
end

-- автосейв каждые 50 сек
task.spawn(function()
	while Screen.Parent do
		task.wait(50)
		local autoName = getAuto()
		saveCfg("autosave", true)
		if autoName and autoName ~= "" and autoName ~= "autosave" then
			saveCfg(autoName, true)
		end
	end
end)

local function loadCfg(name)
	if not name or name == "" then return end
	local ok, content = pcall(function() return readfile("GameSenseConfigs/" .. name .. ".json") end)
	if not ok or not content then
		showAchievement("Load Failed", "Config not found")
		return
	end
	local success, cfg = pcall(function() return HttpService:JSONDecode(content) end)
	if success then
		applySettings(cfg)
		showAchievement("Config Loaded", "Loaded: " .. name)
	end
end

local function setAuto(name)
	API.ensureFolder()
	if name and name ~= "" then
		pcall(function() writefile("GameSenseConfigs/autoload.txt", name) end)
		showAchievement("Auto-Load Set", name)
	else
		pcall(function() if isfile("GameSenseConfigs/autoload.txt") then delfile("GameSenseConfigs/autoload.txt") end end)
		showAchievement("Auto-Load Cleared", "No auto config")
	end
	if refreshConfigList then refreshConfigList() end
end

local function getAuto()
	local ok, c = pcall(function() if isfile("GameSenseConfigs/autoload.txt") then return readfile("GameSenseConfigs/autoload.txt") end end)
	return ok and c and c ~= "" and c or nil
end

local function getCfgs()
	local names = {}
	pcall(function()
		if isfolder("GameSenseConfigs") then
			for _, f in ipairs(listfiles("GameSenseConfigs")) do
				local n = f:match("([^/\\]+)%.json$")
				if n then table.insert(names, n) end
			end
		end
	end)
	table.sort(names)
	return names
end

local function delCfg(name)
	if not name or name == "" then return end
	pcall(function()
		local path = "GameSenseConfigs/" .. name .. ".json"
		if isfile(path) then delfile(path) end
	end)
	if getAuto() == name then setAuto(nil) end
	showAchievement("Config Deleted", name)
	if refreshConfigList then refreshConfigList() end
end

local PageBuild = {}

local function _pageShell(page, titleLeft, titleRight)
	local left, leftB = section(page, titleLeft)
	local right, rightB = section(page, titleRight)
	return left, leftB, right, rightB
end

function PageBuild.Rage(leftB, rightB)
	local gFov = slider(leftB, "FOV", 1, 500, 150, "aimFov")
	local gSm = slider(leftB, "Smoothness", 1, 20, 1, "aimSmooth")
	local gSF = toggle(leftB, "Show FOV", false, "showFov")
	local gMP = toggle(leftB, "Multi-point", false, "multiPoint")
	local gTM = toggle(leftB, "Toggle Mode", false, "aimModeToggle")
	local gTS = toggle(leftB, "Target Strafe", false, "targetStrafeEnabled")
	local gTSS = slider(leftB, "TS Speed", 1, 30, 8, "targetStrafeSpeed")
	local gTSH = slider(leftB, "TS Height", 0, 20, 4)
	local gTSR = slider(leftB, "TS Radius", 3, 25, 9)
	local gTr = toggle(rightB, "Trigger Bot", false, "triggerBotEnabled")
	local gTD = slider(rightB, "Trigger Delay ms", 0, 200, 0)
	local gTH = slider(rightB, "Hold ms", 1, 50, 10)
	local gRes = toggle(rightB, "Resolver", false, "resolverEnabled")
	task.spawn(function()
		while Screen.Parent do
			S.aimFov = gFov() S.aimSmooth = gSm() S.showFov = gSF() S.multiPoint = gMP()
			S.aimModeToggle = gTM() S.triggerBotEnabled = gTr()
			S.triggerClickDelay = gTD() / 1000 S.triggerHoldTime = gTH() / 1000
			S.resolverEnabled = gRes() S.targetStrafeSpeed = gTSS()
			S.targetStrafeHeight = gTSH() S.targetStrafeRadius = gTSR()
			local en = gTS()
			if en ~= S.targetStrafeEnabled then
				S.targetStrafeEnabled = en
				if en then setupStrafe() else if strafeConn then pcall(function() strafeConn:Disconnect() end) strafeConn = nil end end
			end
			API.updateFov()
			task.wait(0.05)
		end
	end)
end

function PageBuild.Visuals(leftB, rightB)
	local g1 = toggle(leftB, "Enabled", false, "visualsEnabled")
	local g2 = toggle(leftB, "Boxes", false, "showBoxes")
	local g3 = toggle(leftB, "Names", false, "showNames")
	local g4 = toggle(leftB, "Health", false, "showHealth")
	local g5 = toggle(leftB, "Skeleton", false, "showSkeleton")
	local g6 = toggle(leftB, "Target HUD", false, "showTargetInfo")
	local g7 = toggle(leftB, "Aim View", false, "showAimView")
	local g9 = toggle(rightB, "Team check", false, "teamCheck")
	local g10 = toggle(rightB, "Friend immunity", true, "friendCheck")
	local g11 = slider(rightB, "Distance", 100, 3000, 1000, "maxDistance")
	makeBtn(rightB, "Who use cheat", function()
		local results = scanForCheats()
		if #results == 0 then
			showAchievement("No Scripters", "на этом сервере нету скриптеров")
		else
			for _, r in ipairs(results) do
				showAchievement(r.player, "использует " .. r.cheat)
			end
		end
	end)
	task.spawn(function()
		while Screen.Parent do
			S.visualsEnabled = g1() S.showBoxes = g2() S.showNames = g3()
			S.showHealth = g4() S.showSkeleton = g5() S.showTargetInfo = g6()
			S.showAimView = g7() S.teamCheck = g9() S.friendCheck = g10()
			S.maxDistance = g11()
			task.wait(0.1)
		end
	end)
end

function PageBuild.AntiAim(leftB, rightB)
	local a1 = toggle(leftB, "Enabled", false, "aaEnabled")
	local a2 = slider(leftB, "Yaw", -180, 180, 0)
	local a3 = slider(leftB, "Pitch", -89, 89, 0)
	local a4 = toggle(leftB, "Jitter", false, "aaJitter")
	local a5 = slider(leftB, "Jitter Range", 5, 90, 35)
	local a6 = slider(leftB, "Jitter Interval ms", 10, 200, 50)
	local a7 = toggle(rightB, "Spin", false, "aaSpin")
	local a8 = slider(rightB, "Spin Speed", 1, 30, 8)
	local a9 = toggle(rightB, "Backward", false, "aaBackward")
	local a10 = toggle(rightB, "Left", false, "aaLeft")
	local a11 = toggle(rightB, "Right", false, "aaRight")
	local a12 = toggle(rightB, "Random", false, "aaRandom")
	local a13 = toggle(rightB, "Teleport AA", false, "teleportAA")
	task.spawn(function()
		while Screen.Parent do
			S.aaEnabled = a1() S.aaYaw = a2() S.aaPitch = a3() S.aaJitter = a4()
			S.aaJitterRange = a5() S.jitterInterval = a6() / 1000
			S.aaSpin = a7() S.aaSpinSpeed = a8() S.aaBackward = a9()
			S.aaLeft = a10() S.aaRight = a11() S.aaRandom = a12() S.teleportAA = a13()
			task.wait(0.05)
		end
	end)
end

function PageBuild.Misc(leftB, rightB)
	local m1 = toggle(leftB, "B-Hop", false, "bhopEnabled")
	local mRage = toggle(leftB, "Rage Bhop (HVH)", false, "rageBhop")
	local mJumpDist = slider(leftB, "Jump Distance", 3, 25, 8, "jumpDistance")
	local m2 = toggle(leftB, "Auto Strafe", false, "autoStrafeEnabled")
	local m3 = toggle(leftB, "Walkspeed Rage", false, "walkSpeedEnabled")
	local m4 = slider(leftB, "Speed (max 1000)", 16, 1000, 16, "walkSpeedValue")
	local m5 = slider(leftB, "Ramp / sec", 20, 800, 120, "walkRamp")
	makeBind(leftB, "Speed hold", function() return S.walkSpeedBind end, "speed")
	makeBind(rightB, "Aimbot", function() return S.aimbotKey end, "aim")
	makeBind(rightB, "Menu", function() return S.scriptKey end, "menu")
	makeBind(rightB, "Jump Leave", function() return S.jumpLeaveBind end, "jump")
	local m6 = toggle(rightB, "Watermark", true, "watermarkEnabled")
	local m7 = toggle(rightB, "WM FPS", true, "wmShowFps")
	local m8 = toggle(rightB, "WM Ping", true, "wmShowPing")
	local m9 = toggle(rightB, "WM Time", true, "wmShowTime")
	local m10 = toggle(rightB, "WM Name", true, "wmShowName")
	local m11 = toggle(rightB, "Keybinds list", true, "keybindsListVisible")

	task.spawn(function()
		while Screen.Parent do
			local bhop = m1() local rage = mRage() local astr = m2()
			if bhop ~= S.bhopEnabled or rage ~= S.rageBhop or astr ~= S.autoStrafeEnabled then
				S.bhopEnabled = bhop S.rageBhop = rage S.autoStrafeEnabled = astr
				setupBhop()
			end
			S.jumpDistance = mJumpDist()
			local wasWalk = S.walkSpeedEnabled
			S.walkSpeedEnabled = m3()
			S.walkSpeedValue = m4()
			S.walkRamp = m5()
			if S.walkSpeedEnabled and not wasWalk then
				S.liveSpeed = 16
				local char = player.Character
				if char then
					local hum = char:FindFirstChildOfClass("Humanoid")
					if hum then hum.Health = 0 end
				end
			end
			S.watermarkEnabled = m6() S.wmShowFps = m7() S.wmShowPing = m8()
			S.wmShowTime = m9() S.wmShowName = m10() S.keybindsListVisible = m11()
			task.wait(0.1)
		end
	end)

end

function PageBuild.Pet(leftB, rightB)
	local pEnable = toggle(leftB, "Show Pet", true, "petEnabled")
	local pFreeze = toggle(leftB, "Freeze (не бегать)", false, "petFrozen")

	label(leftB, "Имя питомца", UDim2.new(), UDim2.new(1, 0, 0, 18), C.green, 13)
	local nameBox = makeBox(leftB, "Kitty")
	nameBox.Text = S.petName
	refreshPetNameBox = function(n)
		nameBox.Text = n or S.petName
	end
	nameBox.FocusLost:Connect(function()
		local n = nameBox.Text
		if n and n ~= "" then
			S.petName = n
			updatePetVisuals()
			local st = getSpeechStyle()
			petSay(st.name(n))
		end
	end)

	label(leftB, "Пол (стиль речи)", UDim2.new(), UDim2.new(1, 0, 0, 18), C.green, 13)
	makeBtn(leftB, "♀ Женский", function()
		S.petGender = "Female"
		petSay("хихи, теперь я девочка~")
	end)
	makeBtn(leftB, "♂ Мужской", function()
		S.petGender = "Male"
		petSay("ок, теперь я пацан")
	end)
	makeBtn(leftB, "◎ Другой", function()
		S.petGender = "Other"
		petSay("хихи~ я особенный")
	end)

	makeBtn(leftB, "🍖 Взять еду", function()
		startHolding("food")
	end)
	makeBtn(leftB, "🥛 Взять молоко", function()
		startHolding("milk")
	end)
	makeBtn(leftB, "🍆 Взять баклажан", function()
		startHolding("eggplant")
	end)
	makeBtn(leftB, "🍌 Взять банан", function()
		startHolding("banana")
	end)
	makeBtn(leftB, "Отменить предмет", function()
		clearHolding()
	end)

	label(leftB, "Голод / Жажда", UDim2.new(), UDim2.new(1, 0, 0, 18), C.muted, 12)
	makeBtn(leftB, "Полностью накормить", function()
		S.petHunger = 100
		S.petThirst = 100
		updatePetVisuals()
		petSay("сытый!")
	end)

	-- близость
	label(rightB, "Близость", UDim2.new(), UDim2.new(1, 0, 0, 18), C.green, 13)
	local relLbl = Instance.new("TextLabel", rightB)
	relLbl.Size = UDim2.new(1, -4, 0, 20)
	relLbl.BackgroundTransparency = 1
	relLbl.Font = ActiveFont
	relLbl.TextSize = 13
	relLbl.TextColor3 = C.text
	relLbl.TextXAlignment = Enum.TextXAlignment.Left
	relLbl.Text = "..."

	makeBtn(rightB, "Сон / Разбудить", function()
		petSleeping = not petSleeping
		if petSleeping then
			petSitting = true
			petFace.Text = "🐈"
			petSay(S.lang == "en" and "zzz..." or "хррр...")
		else
			petSitting = false
			petFace.Text = "🐱"
			petSay(S.lang == "en" and "huh? morning" or "а? уже утро?")
		end
	end)

	makeBtn(rightB, "Мини-игра: поймай", function()
		startMiniGame()
	end)

	label(rightB, "DeepSeek API (опц.)", UDim2.new(), UDim2.new(1, 0, 0, 18), C.muted, 12)
	local aiBox = makeBox(rightB, "sk-...")
	aiBox.Text = S.aiKey or ""
	aiBox.FocusLost:Connect(function()
		S.aiKey = aiBox.Text or ""
		petSay(S.lang == "en" and "ai key set" or "ключ сохранён")
	end)
	makeBtn(rightB, "Спросить кота (AI)", function()
		askPetAI(S.lang == "en" and "Say a short cute line about the player" or "Скажи короткую милую фразу про хозяина")
	end)

	task.spawn(function()
		while Screen.Parent do
			S.petEnabled = pEnable()
			S.petFrozen = pFreeze()
			local r = math.floor(S.relationship or 0)
			local tier = r < 25 and (S.lang == "en" and "stranger" or "чужой")
				or r < 50 and (S.lang == "en" and "friend" or "друг")
				or r < 75 and (S.lang == "en" and "close" or "близкий")
				or (S.lang == "en" and "soulmate" or "пара")
			relLbl.Text = string.format("%s: %d/100 (%s)%s", S.lang == "en" and "Bond" or "Связь", r, tier, petSleeping and " 💤" or "")
			task.wait(0.15)
		end
	end)

end

function PageBuild.Achieve(leftB, rightB)
	label(leftB, "Статы кота", UDim2.new(), UDim2.new(1, 0, 0, 18), C.green, 13)
	local statsLbl = Instance.new("TextLabel", leftB)
	statsLbl.Size = UDim2.new(1, -4, 0, 90)
	statsLbl.BackgroundTransparency = 1
	statsLbl.Font = ActiveFont
	statsLbl.TextSize = 13
	statsLbl.TextColor3 = C.text
	statsLbl.TextXAlignment = Enum.TextXAlignment.Left
	statsLbl.TextYAlignment = Enum.TextYAlignment.Top
	statsLbl.Text = "..."

	label(leftB, "Рост", UDim2.new(), UDim2.new(1, 0, 0, 18), C.green, 13)
	local growthLbl = Instance.new("TextLabel", leftB)
	growthLbl.Size = UDim2.new(1, -4, 0, 22)
	growthLbl.BackgroundTransparency = 1
	growthLbl.Font = ActiveFont
	growthLbl.TextSize = 14
	growthLbl.TextColor3 = C.green
	growthLbl.TextXAlignment = Enum.TextXAlignment.Left
	growthLbl.Text = "0%"

	label(rightB, "Достижения", UDim2.new(), UDim2.new(1, 0, 0, 18), C.green, 13)
	local achScroll = Instance.new("ScrollingFrame", rightB)
	achScroll.Size = UDim2.new(1, -4, 0, 280)
	achScroll.BackgroundTransparency = 1
	achScroll.BorderSizePixel = 0
	achScroll.ScrollBarThickness = 3
	achScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	achScroll.CanvasSize = UDim2.new()
	Instance.new("UIListLayout", achScroll).Padding = UDim.new(0, 4)

	refreshAchieveList = function()
		for _, ch in ipairs(achScroll:GetChildren()) do
			if ch:IsA("TextLabel") then ch:Destroy() end
		end
		for _, a in ipairs(petAchievements) do
			local row = Instance.new("TextLabel", achScroll)
			row.Size = UDim2.new(1, 0, 0, 32)
			row.BackgroundColor3 = a.done and Color3.fromRGB(30, 45, 25) or C.section
			row.BorderSizePixel = 0
			row.Font = ActiveFont
			row.TextSize = 12
			row.TextColor3 = a.done and C.green or C.muted
			row.TextXAlignment = Enum.TextXAlignment.Left
			row.Text = (a.done and " ✓ " or " ○ ") .. a.name .. " — " .. a.desc
			Instance.new("UICorner", row).CornerRadius = UDim.new(0, 4)
		end
	end
	refreshAchieveList()

	task.spawn(function()
		while Screen.Parent do
			statsLbl.Text = string.format(
				"паты: %d\nкормления: %d\n🍆/🍌: %d\nкилл-реплики: %d\nstomp: %d",
				petStats.pats, petStats.feeds, petStats.inserts, petStats.kills, petStats.stomps
			)
			growthLbl.Text = string.format("рост: %d%%  |  сквирт: %d%%", math.floor(petGrowth), math.floor(petArousal))
			task.wait(0.4)
		end
	end)

end

function PageBuild.Config(leftB, rightB)
	label(leftB, "Language / Язык", UDim2.new(), UDim2.new(1, 0, 0, 18), C.green, 13)
	makeBtn(leftB, "Русский", function()
		S.lang = "ru"
		showAchievement("Язык", "Русский")
	end)
	makeBtn(leftB, "English", function()
		S.lang = "en"
		showAchievement("Language", "English")
	end)
	label(leftB, "FPS / Ping warn", UDim2.new(), UDim2.new(1, 0, 0, 18), C.muted, 12)
	local fpsW = slider(leftB, "FPS warn below", 10, 60, S.fpsWarn or 30, "fpsWarn")
	local pingW = slider(leftB, "Ping warn above", 50, 400, S.pingWarn or 150, "pingWarn")
	task.spawn(function()
		while Screen.Parent do
			S.fpsWarn = fpsW()
			S.pingWarn = pingW()
			task.wait(0.2)
		end
	end)
	local nb = makeBox(leftB, "Config name...")
	makeBtn(leftB, "Save", function() saveCfg(nb.Text) end)
	makeBtn(leftB, "Load", function() loadCfg(nb.Text) end)
	makeBtn(leftB, "Set Auto-Load", function() setAuto(nb.Text) end)
	makeBtn(leftB, "Clear Auto-Load", function() setAuto(nil) end)
	makeBtn(leftB, "Delete", function() delCfg(nb.Text) end)
	label(rightB, "Themes", UDim2.new(), UDim2.new(1, 0, 0, 20), C.green, 13)
	for tn in pairs(themes) do
		makeBtn(rightB, tn, function() currentTheme = tn C = themes[tn] end)
	end
	label(rightB, "Fonts", UDim2.new(), UDim2.new(1, 0, 0, 20), C.green, 13)
	for fn in pairs(fonts) do
		makeBtn(rightB, fn, function()
			currentFont = fn
			ActiveFont = fonts[fn]
			applyFontToAll()
			showAchievement("Font Changed", fn)
		end)
	end
	label(rightB, "Saved:", UDim2.new(), UDim2.new(1, 0, 0, 20), C.green, 13)
	local lf = Instance.new("ScrollingFrame", rightB)
	lf.Size = UDim2.new(1, -4, 0, 120)
	lf.BackgroundTransparency = 1
	lf.BorderSizePixel = 0
	lf.ScrollBarThickness = 3
	lf.AutomaticCanvasSize = Enum.AutomaticSize.Y
	lf.CanvasSize = UDim2.new()
	Instance.new("UIListLayout", lf).Padding = UDim.new(0, 4)
	refreshConfigList = function()
		for _, ch in ipairs(lf:GetChildren()) do
			if ch:IsA("TextButton") or (ch:IsA("TextLabel") and ch.Text:find("no configs")) then ch:Destroy() end
		end
		local names = getCfgs()
		local auto = getAuto()
		if #names == 0 then
			local e = Instance.new("TextLabel", lf)
			e.Size = UDim2.new(1, 0, 0, 24)
			e.BackgroundTransparency = 1
			e.Font = ActiveFont
			e.TextSize = 12
			e.TextColor3 = C.muted
			e.Text = "  no configs yet"
			e.TextXAlignment = Enum.TextXAlignment.Left
		else
			for _, n in ipairs(names) do
				local btn = Instance.new("TextButton", lf)
				btn.Size = UDim2.new(1, 0, 0, 24)
				btn.BackgroundColor3 = C.section
				btn.BorderSizePixel = 1
				btn.BorderColor3 = C.border
				btn.Font = ActiveFont
				btn.TextSize = 12
				btn.TextColor3 = C.text
				btn.TextXAlignment = Enum.TextXAlignment.Left
				btn.AutoButtonColor = false
				btn.Text = "  " .. n .. (auto == n and " (auto)" or "")
				if auto == n then btn.TextColor3 = C.green end
				btn.MouseButton1Click:Connect(function() nb.Text = n end)
			end
		end
	end
	task.defer(refreshConfigList)
end

local function buildPage(name, page)
	local left, leftB, right, rightB = _pageShell(page, name .. " settings", "Other")
	layouts[name] = {left, right}
	local key = name == "Anti-Aim" and "AntiAim" or name
	local fn = PageBuild[key]
	if fn then fn(leftB, rightB) end
end

-- поиск по меню
local searchBox = Instance.new("TextBox", Sidebar)
searchBox.LayoutOrder = 0
searchBox.Size = UDim2.new(1, 0, 0, 26)
searchBox.BackgroundColor3 = C.section
searchBox.BorderSizePixel = 0
searchBox.PlaceholderText = "search..."
searchBox.Text = ""
searchBox.Font = ActiveFont
searchBox.TextSize = 12
searchBox.TextColor3 = C.text
searchBox.PlaceholderColor3 = C.muted
searchBox.ClearTextOnFocus = false
Instance.new("UICorner", searchBox).CornerRadius = UDim.new(0, 4)
searchBox:GetPropertyChangedSignal("Text"):Connect(function()
	local q = string.lower(searchBox.Text or "")
	for tab, page in pairs(pages) do
		if page.Visible then
			for _, desc in ipairs(page:GetDescendants()) do
				if desc:IsA("TextLabel") or desc:IsA("TextButton") or desc:IsA("TextBox") then
					if q == "" then
						if desc:IsA("GuiObject") and desc ~= searchBox then
							-- show parent rows roughly
							local row = desc.Parent
							if row and row:IsA("Frame") and row.Parent and row.Parent:IsA("ScrollingFrame") then
								row.Visible = true
							end
						end
					else
						local row = desc.Parent
						if row and row:IsA("Frame") and row.Parent and (row.Parent:IsA("ScrollingFrame") or row.Parent.Name:find("Body")) then
							local hay = string.lower(tostring(desc.Text or ""))
							if desc:IsA("TextButton") or (desc:IsA("TextLabel") and #hay > 0) then
								if hay:find(q, 1, true) then
									row.Visible = true
								end
							end
						end
					end
				end
			end
			if q ~= "" then
				for _, row in ipairs(page:GetDescendants()) do
					if row:IsA("Frame") and row.Parent and (row.Parent:IsA("ScrollingFrame") or tostring(row.Parent.Name):find("Body")) then
						local show = false
						for _, c in ipairs(row:GetDescendants()) do
							if (c:IsA("TextLabel") or c:IsA("TextButton")) and string.lower(tostring(c.Text or "")):find(q, 1, true) then
								show = true
								break
							end
						end
						-- only toggle typical control rows (have size height ~30-50)
						if row.Size and row.Size.Y.Offset >= 20 and row.Size.Y.Offset <= 60 then
							row.Visible = show
						end
					end
				end
			else
				for _, row in ipairs(page:GetDescendants()) do
					if row:IsA("Frame") and row.Size and row.Size.Y.Offset >= 20 and row.Size.Y.Offset <= 60 then
						row.Visible = true
					end
				end
			end
		end
	end
end)

for i, name in ipairs(tabs) do
	local b = Instance.new("TextButton", Sidebar)
	b.LayoutOrder = i + 1
	b.LayoutOrder = i
	b.Size = UDim2.new(1, 0, 0, 29)
	b.BackgroundColor3 = C.panel
	b.BorderSizePixel = 0
	b.Text = "   " .. name
	b.TextXAlignment = Enum.TextXAlignment.Left
	b.Font = ActiveFont
	b.TextSize = 14
	b.TextColor3 = C.muted
	b.AutoButtonColor = false
	local marker = Instance.new("Frame", b)
	marker.Position = UDim2.fromOffset(0, 4)
	marker.Size = UDim2.new(0, 2, 1, -8)
	marker.BackgroundColor3 = C.green
	marker.BorderSizePixel = 0
	marker.Visible = false
	local page = Instance.new("Frame", Content)
	page.Name = name .. "Page"
	page.Size = UDim2.new(1, 0, 1, 0)
	page.BackgroundTransparency = 1
	page.Visible = false
	buildPage(name, page)
	buttons[name] = {btn = b, marker = marker}
	pages[name] = page
	b.MouseButton1Click:Connect(function()
		for tab, data in pairs(buttons) do
			local on = tab == name
			data.btn.BackgroundColor3 = on and C.section or C.panel
			data.btn.TextColor3 = on and C.text or C.muted
			data.marker.Visible = on
			pages[tab].Visible = on
		end
	end)
end

buttons.Rage.btn.BackgroundColor3 = C.section
buttons.Rage.btn.TextColor3 = C.text
buttons.Rage.marker.Visible = true
pages.Rage.Visible = true

local function updateLayout()
	local w, h = Content.AbsoluteSize.X, Content.AbsoluteSize.Y
	for _, name in ipairs(tabs) do
		local pair = layouts[name]
		if pair then
			local gap, margin = 10, 11
			local avail = math.max(180, w - margin * 2 - gap)
			local col = math.floor(avail / 2)
			local ch = math.max(120, h - 24)
			pair[1].Position = UDim2.fromOffset(margin, 12)
			pair[1].Size = UDim2.fromOffset(col, ch)
			pair[2].Position = UDim2.fromOffset(margin + col + gap, 12)
			pair[2].Size = UDim2.fromOffset(col, ch)
		end
	end
end
Content:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateLayout)
Main:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateLayout)

local Resize = Instance.new("TextButton", Main)
Resize.Size = UDim2.fromOffset(18, 18)
Resize.Position = UDim2.new(1, -18, 1, -18)
Resize.BackgroundColor3 = C.green
Resize.BorderSizePixel = 0
Resize.Text = ""
Resize.ZIndex = 70
Resize.Active = true
local resizing, rMouse, rSize = false, nil, nil
Resize.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 then
		resizing = true rMouse = i.Position rSize = Main.AbsoluteSize
	end
end)
UIS.InputChanged:Connect(function(i)
	if resizing and i.UserInputType == Enum.UserInputType.MouseMovement then
		local d = i.Position - rMouse
		local vp = camera.ViewportSize
		local nx = math.clamp(rSize.X + d.X, 520, math.min(1100, vp.X))
		local ny = math.clamp(rSize.Y + d.Y, 300, math.min(800, vp.Y))
		Main.Size = UDim2.fromOffset(nx, ny)
	end
end)
UIS.InputEnded:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 then resizing = false end
end)

task.defer(updateLayout)
task.defer(function()
	task.wait(1.3)
	local auto = getAuto()
	if auto then loadCfg(auto) end
end)
