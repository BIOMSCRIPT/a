--라이브러리
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

--라이브러리 기본 설정
local Window = Fluent:CreateWindow({
    Title = "Biom Script Hub V3",
    SubTitle = "By Biom Script",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

--메인,세팅 탭
local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "box" }),
    Tools = Window:AddTab({ Title = "Tools", Icon = "hammer" }),
    Teleport = Window:AddTab({ Title = "Teleport", Icon = "map-pin" }),
    ESP = Window:AddTab({ Title = "ESP", Icon = "eye" }),
    ACS = Window:AddTab({ Title = "ACS Engine", Icon = "swords" }),
    CE = Window:AddTab({ Title = "Carbon Engine", Icon = "swords" }),
    GunKit = Window:AddTab({ Title = "자체 총킷", Icon = "swords" }),
    Misc = Window:AddTab({ Title = "Misc", Icon = "layers" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

--실행시 타이틀
Fluent:Notify({
        Title = "Biom Script Hub V3",
        Content = "버그 또는 문의 사항은 아래의 디스코드를 이용해주세요.",
        SubContent = "https://discord.gg/ZKEzevBXFx",
        Duration = 10
    })

--세팅 설정
InterfaceManager:SetLibrary(Fluent)
InterfaceManager:SetFolder("FluentScriptHub")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)

--메인.스피드
local Slider = Tabs.Main:AddSlider("Slider", {
        Title = "Speed",
        Description = "플레이어의 속도를 조절합니다.",
        Default = 16,
        Min = 0,
        Max = 1000,
        Rounding = 1,
        Callback = function(Value)
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
        end
    })

--메인.점프
local Slider = Tabs.Main:AddSlider("Slider", {
        Title = "Jump",
        Description = "플레이어의 점프 강도를 조절합니다.",
        Default = 50,
        Min = 0,
        Max = 1000,
        Rounding = 1,
        Callback = function(Value)
            game.Players.LocalPlayer.Character.Humanoid.JumpPower = Value
        end
    })

--메인.플라이
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local plr = Players.LocalPlayer

repeat wait() until plr and plr.Character and plr.Character:FindFirstChild("Head") and plr.Character:FindFirstChild("Humanoid")

local mouse = plr:GetMouse()
repeat wait() until mouse

local torso = plr.Character.Head
local flying = false
local ctrl = {f = 0, b = 0, l = 0, r = 0}
local lastctrl = {f = 0, b = 0, l = 0, r = 0}
local maxspeed = 400
local speed = 5000

local bg, bv, connection

function StartFly()
    bg = Instance.new("BodyGyro", torso)
    bg.P = 9e4
    bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bg.CFrame = torso.CFrame

    bv = Instance.new("BodyVelocity", torso)
    bv.Velocity = Vector3.new(0, 0.1, 0)
    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)

    connection = RunService.RenderStepped:Connect(function()
        plr.Character.Humanoid.PlatformStand = true

        if ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0 then
            speed = speed + 0.5 + (speed / maxspeed)
            if speed > maxspeed then
                speed = maxspeed
            end
        elseif speed ~= 0 then
            speed = speed - 1
            if speed < 0 then
                speed = 0
            end
        end

        local cam = workspace.CurrentCamera.CFrame
        local move = Vector3.new(ctrl.l + ctrl.r, 0, ctrl.f + ctrl.b)
        if move.Magnitude > 0 then
            bv.Velocity = (cam.LookVector * ctrl.f + cam.RightVector * ctrl.r + cam.LookVector * ctrl.b + cam.RightVector * ctrl.l).Unit * speed
            lastctrl = {f = ctrl.f, b = ctrl.b, l = ctrl.l, r = ctrl.r}
        elseif speed ~= 0 then
            bv.Velocity = (cam.LookVector * lastctrl.f + cam.RightVector * lastctrl.r + cam.LookVector * lastctrl.b + cam.RightVector * lastctrl.l).Unit * speed
        else
            bv.Velocity = Vector3.new(0, 0.1, 0)
        end

        bg.CFrame = cam * CFrame.Angles(-math.rad((ctrl.f + ctrl.b) * 50 * speed / maxspeed), 0, 0)
    end)
end

function StopFly()
    if connection then connection:Disconnect() end
    if bg then bg:Destroy() end
    if bv then bv:Destroy() end
    plr.Character.Humanoid.PlatformStand = false
    ctrl = {f = 0, b = 0, l = 0, r = 0}
    lastctrl = {f = 0, b = 0, l = 0, r = 0}
    speed = 0
end

local Keybind = Tabs.Main:AddKeybind("FlyKeybind", {
    Title = "Fly",
    Mode = "Toggle",
    Default = "F",
    Description = "플레이어가 날수있게 바꿔줍니다.",
    Callback = function(active)
        flying = active
        if flying then
            StartFly()
        else
            StopFly()
        end
    end,
})

mouse.KeyDown:Connect(function(key)
    key = key:lower()
    if key == "w" then ctrl.f = 1 end
    if key == "s" then ctrl.b = -1 end
    if key == "a" then ctrl.l = -1 end
    if key == "d" then ctrl.r = 1 end
end)

mouse.KeyUp:Connect(function(key)
    key = key:lower()
    if key == "w" then ctrl.f = 0 end
    if key == "s" then ctrl.b = 0 end
    if key == "a" then ctrl.l = 0 end
    if key == "d" then ctrl.r = 0 end
end)

--메인.차날기
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local plr = Players.LocalPlayer

repeat wait() until plr and plr.Character and plr.Character:FindFirstChild("Humanoid")
local mouse = plr:GetMouse()
repeat wait() until mouse

local torso = plr.Character:WaitForChild("HumanoidRootPart")
local flying = false
local ctrl = {f = 0, b = 0, l = 0, r = 0}
local lastctrl = {f = 0, b = 0, l = 0, r = 0}
local maxspeed = 500
local speed = 0

local bg, bv, connection

local function StartVehicleFly()
    bg = Instance.new("BodyGyro", torso)
    bg.P = 9e4
    bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bg.CFrame = torso.CFrame

    bv = Instance.new("BodyVelocity", torso)
    bv.Velocity = Vector3.new(0, 0.1, 0)
    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)

    connection = RunService.RenderStepped:Connect(function()
        if not flying then return end

        plr.Character.Humanoid.PlatformStand = false

        if ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0 then
            speed = speed + 125 + (speed / maxspeed)
            if speed > maxspeed then speed = maxspeed end
        elseif speed ~= 0 then
            speed = speed - 250
            if speed < 0 then speed = 0 end
        end

        local cam = workspace.CurrentCamera.CFrame
        if (ctrl.l + ctrl.r ~= 0) or (ctrl.f + ctrl.b ~= 0) then
            bv.Velocity = ((cam.LookVector * (ctrl.f + ctrl.b)) +
                          ((cam * CFrame.new(ctrl.l + ctrl.r, (ctrl.f + ctrl.b) * 0.2, 0).p) - cam.p)) * speed
            lastctrl = {f = ctrl.f, b = ctrl.b, l = ctrl.l, r = ctrl.r}
        elseif speed ~= 0 then
            bv.Velocity = ((cam.LookVector * (lastctrl.f + lastctrl.b)) +
                          ((cam * CFrame.new(lastctrl.l + lastctrl.r, (lastctrl.f + lastctrl.b) * 0.2, 0).p) - cam.p)) * speed
        else
            bv.Velocity = Vector3.new(0, 0.1, 0)
        end

        bg.CFrame = cam * CFrame.Angles(-math.rad((ctrl.f + ctrl.b) * 50 * speed / maxspeed), 0, 0)
    end)
end

local function StopVehicleFly()
    if connection then connection:Disconnect() end
    if bg then bg:Destroy() end
    if bv then bv:Destroy() end
    plr.Character.Humanoid.PlatformStand = false
    ctrl = {f = 0, b = 0, l = 0, r = 0}
    lastctrl = {f = 0, b = 0, l = 0, r = 0}
    speed = 0
end

local VehicleFlyKeybind = Tabs.Main:AddKeybind("VehicleFlyKeybind", {
    Title = "CFly",
    Mode = "Toggle",
    Default = "Z",
    Description = "플레이어가 차를 타고 날수있게 바꿔줍니다.",
    Callback = function(active)
        flying = active
        if flying then
            StartVehicleFly()
        else
            StopVehicleFly()
        end
    end,
})

mouse.KeyDown:Connect(function(key)
    key = key:lower()
    if key == "w" then ctrl.f = 1 end
    if key == "s" then ctrl.b = -1 end
    if key == "a" then ctrl.l = -1 end
    if key == "d" then ctrl.r = 1 end
end)

mouse.KeyUp:Connect(function(key)
    key = key:lower()
    if key == "w" then ctrl.f = 0 end
    if key == "s" then ctrl.b = 0 end
    if key == "a" then ctrl.l = 0 end
    if key == "d" then ctrl.r = 0 end
end)

--메인.노클립
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Noclip = false
local NoclipConnection = nil

local function EnableNoclip()
    if NoclipConnection then
        NoclipConnection:Disconnect()
    end
    Noclip = true
    NoclipConnection = RunService.Stepped:Connect(function()
        if not Noclip then return end
        local character = LocalPlayer.Character
        if character then
            for _, part in pairs(character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
end

local function DisableNoclip()
    if NoclipConnection then
        NoclipConnection:Disconnect()
        NoclipConnection = nil
    end
    Noclip = false
    local character = LocalPlayer.Character
    if character then
        for _, part in pairs(character:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end

local NoclipToggle = Tabs.Main:AddToggle("NoclipToggle", {
    Title = "Noclip",
    Default = false,
    Description = "플레이어가 벽을 뚫을 수 있게 바꿔줍니다.",
})

NoclipToggle:OnChanged(function()
    if NoclipToggle.Value then
        EnableNoclip()
    else
        DisableNoclip()
    end
end)

--메인.무한점프
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local Player = Players.LocalPlayer

local InfiniteJumpEnabled = false
local JumpHeight = 50
local JumpConnection = nil

local function EnableInfiniteJump()
    if JumpConnection then JumpConnection:Disconnect() end
    JumpConnection = UIS.InputBegan:Connect(function(UserInput)
        if UserInput.UserInputType == Enum.UserInputType.Keyboard and UserInput.KeyCode == Enum.KeyCode.Space then
            local character = Player.Character
            if character and character:FindFirstChild("Humanoid") and character:FindFirstChild("HumanoidRootPart") then
                local humanoid = character.Humanoid
                if humanoid:GetState() == Enum.HumanoidStateType.Jumping or humanoid:GetState() == Enum.HumanoidStateType.Freefall then
                    character.HumanoidRootPart.Velocity = Vector3.new(0, JumpHeight, 0)
                end
            end
        end
    end)
end

local function DisableInfiniteJump()
    if JumpConnection then
        JumpConnection:Disconnect()
        JumpConnection = nil
    end
end

local InfiniteJumpToggle = Tabs.Main:AddToggle("InfiniteJumpToggle", {
    Title = "Infinite Jump",
    Default = false,
    Description = "플레이어가 무한으로 점프를 할수있게 바꿔줍니다.",
})

InfiniteJumpToggle:OnChanged(function()
    InfiniteJumpEnabled = InfiniteJumpToggle.Value
    if InfiniteJumpEnabled then
        EnableInfiniteJump()
    else
        DisableInfiniteJump()
    end
end)

--메인.투명
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Player = Players.LocalPlayer

local Transparency = true
local NoClip = false
local IsInvisible = false

local RealCharacter = Player.Character or Player.CharacterAdded:Wait()
RealCharacter.Archivable = true
local FakeCharacter = RealCharacter:Clone()

local Part = Instance.new("Part", workspace)
Part.Anchored = true
Part.Size = Vector3.new(200, 1, 200)
Part.CFrame = CFrame.new(0, -500, 0)
Part.CanCollide = true

FakeCharacter.Parent = workspace
FakeCharacter.HumanoidRootPart.CFrame = Part.CFrame * CFrame.new(0, 5, 0)

for _, v in ipairs(RealCharacter:GetChildren()) do
    if v:IsA("LocalScript") then
        local clone = v:Clone()
        clone.Disabled = true
        clone.Parent = FakeCharacter
    end
end

if Transparency then
    for _, v in ipairs(FakeCharacter:GetDescendants()) do
        if v:IsA("BasePart") then
            v.Transparency = 0.7
        end
    end
end

local PseudoAnchor = FakeCharacter.HumanoidRootPart

RunService.RenderStepped:Connect(function()
    if PseudoAnchor then
        PseudoAnchor.CFrame = Part.CFrame * CFrame.new(0, 5, 0)
    end
    if NoClip and IsInvisible then
        FakeCharacter.Humanoid:ChangeState(11)
    end
end)

local function SetInvisible(enabled)
    if enabled and not IsInvisible then
        local StoredCF = RealCharacter.HumanoidRootPart.CFrame
        RealCharacter.HumanoidRootPart.CFrame = FakeCharacter.HumanoidRootPart.CFrame
        FakeCharacter.HumanoidRootPart.CFrame = StoredCF

        RealCharacter.Humanoid:UnequipTools()
        Player.Character = FakeCharacter
        workspace.CurrentCamera.CameraSubject = FakeCharacter.Humanoid
        PseudoAnchor = RealCharacter.HumanoidRootPart

        for _, v in ipairs(FakeCharacter:GetChildren()) do
            if v:IsA("LocalScript") then
                v.Disabled = false
            end
        end

        IsInvisible = true
    elseif not enabled and IsInvisible then
        local StoredCF = FakeCharacter.HumanoidRootPart.CFrame
        FakeCharacter.HumanoidRootPart.CFrame = RealCharacter.HumanoidRootPart.CFrame
        RealCharacter.HumanoidRootPart.CFrame = StoredCF

        FakeCharacter.Humanoid:UnequipTools()
        Player.Character = RealCharacter
        workspace.CurrentCamera.CameraSubject = RealCharacter.Humanoid
        PseudoAnchor = FakeCharacter.HumanoidRootPart

        for _, v in ipairs(FakeCharacter:GetChildren()) do
            if v:IsA("LocalScript") then
                v.Disabled = true
            end
        end

        IsInvisible = false
    end
end

local InvisibilityToggle = Tabs.Main:AddToggle("InvisibilityToggle", {
    Title = "Invisibility",
    Description = "플레이어를 투명 상태로 바꿔줍니다.",
    Default = false,
    Callback = function(enabled)
        SetInvisible(enabled)
    end
})

--텔레포트.플레이어
local playerNameToTeleport = ""

local Input = Tabs.Teleport:AddInput("TeleportInput", {
    Title = "Target Name",
    Description = "텔레포트 할 플레이어의 이름을 입력하세요.",
    Placeholder = "Target Name",
    Numeric = false,
    CharacterLimit = 20,
    Callback = function(text)
        playerNameToTeleport = text
        print(playerNameToTeleport)
    end
})

Tabs.Teleport:AddButton({
        Title = "Teleport by Target",
        Description = "이름을 적은 플레이어에게 텔레포트합니다.",
        Callback = function()
            Window:Dialog({
                Title = playerNameToTeleport.."님에게 텔레포트 하시겠습니까?",
                Buttons = {
                    {
                        Title = "Confirm",
                        Callback = function()
                            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = workspace[playerNameToTeleport].HumanoidRootPart.CFrame
                        end
                    },
                    {
                        Title = "Cancel",
                        Callback = function()
                            Fluent:Notify({
                            Title = "Biom Script Hub V3",
                            Content = "Teleport by Target",
                            SubContent = "텔레포트가 취소 되었습니다.",
                            Duration = 5
                            })
                        end
                    }
                }
            })
        end
    })

--툴.Btool얻기
Tabs.Tools:AddButton({
        Title = "Btools",
        Description = "Btool을 플레이어에게 지급합니다.",
        Callback = function()
            Window:Dialog({
                Title = "Btool을 인벤토리에 지급하겠습니까?",
                Buttons = {
                    {
                        Title = "Confirm",
                        Callback = function()
                              a = Instance.new("HopperBin", game.Players.LocalPlayer.Backpack)
                              a.BinType = 2
                              b = Instance.new("HopperBin", game.Players.LocalPlayer.Backpack)
                              b.BinType = 3
                              c = Instance.new("HopperBin", game.Players.LocalPlayer.Backpack)
                              c.BinType = 4
                        end
                    },
                    {
                        Title = "Cancel",
                        Callback = function()
                            Fluent:Notify({
                            Title = "Biom Script Hub V3",
                            Content = "Btools",
                            SubContent = "Btool 지급을 취소하셨습니다.",
                            Duration = 5
                            })
                        end
                    }
                }
            })
        end
    })

--툴.텔레포트 툴얻기
Tabs.Tools:AddButton({
        Title = "TP Tool",
        Description = "Tp Tool을 플레이어에게 지급합니다.",
        Callback = function()
            Window:Dialog({
                Title = "Tp Tool을 인벤토리에 지급하겠습니까?",
                Buttons = {
                    {
                        Title = "Confirm",
                        Callback = function()
                              mouse = game.Players.LocalPlayer:GetMouse()
                              tool = Instance.new("Tool")
                              tool.RequiresHandle = false
                              tool.Name = "TP Tool"
                              tool.Activated:connect(function()
                                 local pos = mouse.Hit+Vector3.new(0,2.5,0)
                                 pos = CFrame.new(pos.X,pos.Y,pos.Z)
                                 game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = pos
                              end)
                              tool.Parent = game.Players.LocalPlayer.Backpack
                        end
                    },
                    {
                        Title = "Cancel",
                        Callback = function()
                            Fluent:Notify({
                            Title = "Biom Script Hub V3",
                            Content = "Tp Tool",
                            SubContent = "Tp Tool 지급을 취소하셨습니다.",
                            Duration = 5
                            })
                        end
                    }
                }
            })
        end
    })

--툴.모든 툴 얻기
Tabs.Tools:AddButton({
        Title = "Get all tools",
        Description = "모든 아이템을 플레이어에게 지급합니다.",
        Callback = function()
            Window:Dialog({
                Title = "모든 아이템을 인벤토리에 지급하겠습니까?",
                Buttons = {
                    {
                        Title = "Confirm",
                        Callback = function()
                              for i, v in pairs(game['Players']:GetChildren()) do
                              wait();
                              for i, b in pairs(v['Backpack']:GetChildren()) do
                                 b['Parent'] = game['Players']['LocalPlayer']['Backpack'];
                              end
                        end
                     end
                    },
                    {
                        Title = "Cancel",
                        Callback = function()
                            Fluent:Notify({
                            Title = "Biom Script Hub V3",
                            Content = "Get all tools",
                            SubContent = "모든 아이템 지급을 취소하셨습니다.",
                            Duration = 5
                            })
                        end
                    }
                }
            })
        end
    })

--기타.리셋
Tabs.Misc:AddButton({
        Title = "Reset",
        Description = "캐릭터를 초기화 시킵니다.",
        Callback = function()
            Window:Dialog({
                Title = "캐릭터를 초기화 시키시겠습니까?",
                Buttons = {
                    {
                        Title = "Confirm",
                        Callback = function()
                           game.Players.LocalPlayer.Character.Humanoid.Health = 0
                     end
                    },
                    {
                        Title = "Cancel",
                        Callback = function()
                            Fluent:Notify({
                            Title = "Biom Script Hub V3",
                            Content = "Reset",
                            SubContent = "캐릭터 초기화를 취소하셨습니다.",
                            Duration = 5
                            })
                        end
                    }
                }
            })
        end
    })

--기타.재접속
Tabs.Misc:AddButton({
        Title = "Rejoin",
        Description = "서버 재접속을 합니다",
        Callback = function()
            Window:Dialog({
                Title = "서버에 재접속을 하시겠습니까?",
                Buttons = {
                    {
                        Title = "Confirm",
                        Callback = function()
                           queue_on_teleport("loadstring(game:HttpGet('https://github.com/BIOMSCRIPT/Biom-Script-Hub-V2/raw/refs/heads/main/Script.lua'))()")
                           game:GetService("TeleportService"):Teleport(game.PlaceId)
                        end
                    },
                    {
                        Title = "Cancel",
                        Callback = function()
                            Fluent:Notify({
                            Title = "Biom Script Hub V3",
                            Content = "Rejoin",
                            SubContent = "서버재접속을 취소하셨습니다.",
                            Duration = 5
                            })
                        end
                    }
                }
            })
        end
    })


local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

local BorderESP = false
local BorderConnection = nil
local BorderHolder = nil

local function EnableBorderESP()
    if BorderConnection then BorderConnection:Disconnect() end
    BorderESP = true
    
    -- 객체를 담을 홀더 생성
    BorderHolder = Instance.new("Folder")
    BorderHolder.Name = "BorderESP_Holder"
    BorderHolder.Parent = CoreGui

    local function CreateESP(v)
        if v == LocalPlayer then return end
        
        local function Apply(char)
            if not char then return end
            
            -- 테두리 하이라이트
            local highlight = Instance.new("Highlight")
            highlight.Name = "ESP_Highlight"
            highlight.FillTransparency = 0.5
            highlight.OutlineTransparency = 0
            highlight.Adornee = char
            highlight.Parent = char
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

            -- 이름표 (BillboardGui)
            local head = char:WaitForChild("Head", 10)
            if head then
                local billboard = Instance.new("BillboardGui")
                billboard.Name = "ESP_Tag"
                billboard.Adornee = head
                billboard.Size = UDim2.new(0, 200, 0, 50)
                billboard.StudsOffset = Vector3.new(0, 2, 0)
                billboard.AlwaysOnTop = true
                billboard.Parent = BorderHolder

                local label = Instance.new("TextLabel")
                label.BackgroundTransparency = 1
                label.Size = UDim2.new(1, 0, 1, 0)
                label.Text = v.Name
                label.TextColor3 = Color3.new(1, 1, 1)
                label.TextStrokeTransparency = 0
                label.Font = Enum.Font.SourceSansBold
                label.TextSize = 14
                label.Parent = billboard
                
                -- 팀 색상 업데이트 루프
                task.spawn(function()
                    while BorderESP and char.Parent do
                        local color = v.TeamColor.Color
                        highlight.FillColor = color
                        label.TextColor3 = color
                        task.wait(1)
                    end
                end)
            end
        end

        v.CharacterAdded:Connect(Apply)
        if v.Character then Apply(v.Character) end
    end

    BorderConnection = Players.PlayerAdded:Connect(CreateESP)
    for _, v in pairs(Players:GetPlayers()) do CreateESP(v) end
end

local function DisableBorderESP()
    BorderESP = false
    if BorderConnection then
        BorderConnection:Disconnect()
        BorderConnection = nil
    end
    if BorderHolder then
        BorderHolder:Destroy()
        BorderHolder = nil
    end
    for _, v in pairs(Players:GetPlayers()) do
        if v.Character then
            local h = v.Character:FindFirstChild("ESP_Highlight")
            if h then h:Destroy() end
        end
    end
end

local HitboxESP = false
local HitboxConnection = nil
local HitboxObjects = {}

local function CreateHitbox(v)
    if v == LocalPlayer then return end
    
    local box = {
        Quad = Drawing.new("Quad"),
        Text = Drawing.new("Text"),
        Player = v
    }
    
    box.Quad.Thickness = 2
    box.Quad.Filled = false
    box.Quad.Transparency = 1
    
    box.Text.Size = 18
    box.Text.Center = true
    box.Text.Outline = true
    
    HitboxObjects[v] = box
end

local function EnableHitboxESP()
    HitboxESP = true
    
    for _, v in pairs(Players:GetPlayers()) do CreateHitbox(v) end
    HitboxConnection = Players.PlayerAdded:Connect(CreateHitbox)
    
    -- 매 프레임마다 그리기
    RunService:BindToRenderStep("HitboxUpdate", Enum.RenderPriority.Camera.Value, function()
        for v, obj in pairs(HitboxObjects) do
            local char = v.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            
            if root then
                local cam = workspace.CurrentCamera
                local pos, onScreen = cam:WorldToViewportPoint(root.Position)
                
                if onScreen then
                    local size = Vector3.new(4, 6, 0)
                    local cf = root.CFrame * CFrame.new(0, -1.5, 0)
                    
                    local tl = cam:WorldToViewportPoint((cf * CFrame.new(size.X/2, size.Y/2, 0)).p)
                    local tr = cam:WorldToViewportPoint((cf * CFrame.new(-size.X/2, size.Y/2, 0)).p)
                    local bl = cam:WorldToViewportPoint((cf * CFrame.new(size.X/2, -size.Y/2, 0)).p)
                    local br = cam:WorldToViewportPoint((cf * CFrame.new(-size.X/2, -size.Y/2, 0)).p)
                    
                    obj.Quad.Visible = true
                    obj.Quad.PointA = Vector2.new(tr.X, tr.Y)
                    obj.Quad.PointB = Vector2.new(tl.X, tl.Y)
                    obj.Quad.PointC = Vector2.new(bl.X, bl.Y)
                    obj.Quad.PointD = Vector2.new(br.X, br.Y)
                    obj.Quad.Color = v.TeamColor.Color
                    
                    obj.Text.Visible = true
                    obj.Text.Position = Vector2.new(pos.X, tl.Y - 20)
                    obj.Text.Text = v.Name
                    obj.Text.Color = v.TeamColor.Color
                else
                    obj.Quad.Visible = false
                    obj.Text.Visible = false
                end
            else
                obj.Quad.Visible = false
                obj.Text.Visible = false
            end
        end
    end)
end

local function DisableHitboxESP()
    HitboxESP = false
    RunService:UnbindFromRenderStep("HitboxUpdate")
    if HitboxConnection then HitboxConnection:Disconnect() end
    
    for v, obj in pairs(HitboxObjects) do
        obj.Quad:Remove()
        obj.Text:Remove()
    end
    HitboxObjects = {}
end

-- 테두리 ESP 토글
local BorderToggle = Tabs.ESP:AddToggle("BorderToggle", {
    Title = "테두리 ESP",
    Default = false,
    Description = "플레이어에게 하이라이트 테두리와 이름표를 표시합니다.",
})

BorderToggle:OnChanged(function()
    if BorderToggle.Value then
        EnableBorderESP()
    else
        DisableBorderESP()
    end
end)

-- 히트박스 ESP 토글
local HitboxToggle = Tabs.ESP:AddToggle("HitboxToggle", {
    Title = "히트박스 ESP",
    Default = false,
    Description = "2D 박스 형태로 플레이어의 위치를 표시합니다.",
})

HitboxToggle:OnChanged(function()
    if HitboxToggle.Value then
        EnableHitboxESP()
    else
        DisableHitboxESP()
    end
end)

-- 자체 총킷 탭 설정
local GunKitTab = Tabs.GunKit

-- 상태 변수
local AuraEnabled = false
local AllKillEnabled = false
local currentTarget = nil
local targetHighlight = nil
local nicknameToKill = ""

-- 하이라이트(ESP) 생성/제거 함수
local function updateHighlight(targetChar)
    if targetHighlight then targetHighlight:Destroy() targetHighlight = nil end
    if targetChar then
        local highlight = Instance.new("Highlight")
        highlight.Name = "Target_ESP"
        highlight.FillColor = Color3.fromRGB(255, 0, 0)
        highlight.Adornee = targetChar
        highlight.Parent = targetChar
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        targetHighlight = highlight
    end
end

-- 리모트 발사 함수
local function fireAttack(pos)
    local char = game.Players.LocalPlayer.Character
    if char then
        local m2 = char:FindFirstChild("M2")
        if m2 and m2:FindFirstChild("FireEvent") then
            m2.FireEvent:FireServer(Vector3.new(pos.X, pos.Y, pos.Z))
        end
    end
end

-- [1] 민간인 부대 킬아우라 토글
GunKitTab:AddToggle("AuraToggle", {
    Title = "민간인 부대 킬아우라",
    Default = false,
    Description = "팀 제외, 가장 가까운 플레이어를 거리 제한 없이 공격합니다.",
    Callback = function(Value)
        AuraEnabled = Value
        if not AuraEnabled then 
            updateHighlight(nil)
            currentTarget = nil 
        end
    end
})

-- [2] 민간인 부대 올킬 토글
GunKitTab:AddToggle("AllKillToggle", {
    Title = "민간인 부대 올킬",
    Default = false,
    Description = "모든 플레이어를 순회하며 머리 위로 텔레포트후 공격합니다.",
    Callback = function(Value)
        AllKillEnabled = Value
        if not AllKillEnabled then updateHighlight(nil) end
    end
})

-- [3] 닉네임 킬 섹션
GunKitTab:AddInput("NickInput", {
    Title = "플레이어 이름",
    Placeholder = "닉네임 일부 입력...",
    Callback = function(Value) nicknameToKill = Value end
})

GunKitTab:AddButton({
    Title = "닉네임 킬 실행",
    Description = "해당 플레이어 공격 후 원래 위치로 복귀합니다.",
    Callback = function()
        if nicknameToKill == "" then return end
        local targetPlayer = nil
        for _, p in pairs(game.Players:GetPlayers()) do
            if p ~= game.Players.LocalPlayer and string.find(p.Name:lower(), nicknameToKill:lower()) then
                targetPlayer = p
                break
            end
        end

        if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            task.spawn(function()
                local lp = game.Players.LocalPlayer
                local root = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
                if not root then return end

                local originalCF = root.CFrame
                local targetChar = targetPlayer.Character
                local startTime = tick()

                updateHighlight(targetChar)
                -- 3초간 공격 시도
                while (tick() - startTime) < 3 and targetChar.Parent and targetChar:FindFirstChild("Humanoid") and targetChar.Humanoid.Health > 0 do
                    root.CFrame = targetChar.HumanoidRootPart.CFrame * CFrame.new(0, 50, 0)
                    root.Velocity = Vector3.new(0, 0, 0)
                    fireAttack(targetChar.HumanoidRootPart.Position)
                    task.wait(0.1)
                end
                root.CFrame = originalCF
                updateHighlight(nil)
            end)
        end
    end
})

-- [4] 레이더 되기 버튼
GunKitTab:AddButton({
    Title = "민간인 부대 레이더로 팀 변경",
    Description = "자신의 팀을 레이더로 변경합니다.",
    Callback = function()
        local root = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root then
            root.CFrame = CFrame.new(751, 40, -83)
            task.wait(0.3)
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("ProximityPrompt") then
                    if (root.Position - obj.Parent:GetPivot().Position).Magnitude < 20 then
                        obj.HoldDuration = 0
                        obj:InputHoldBegin()
                        obj:InputHoldEnd()
                    end
                end
            end
        end
    end
})

-- Carbon Engine (CE) 탭 설정
local CETab = Tabs.CE

-- 상태 변수
local NonsanAllKill = false
local NonsanLagEnabled = false
local NonsanTargetNickname = ""

-- [공통] Carbon Engine 리모트 발사 함수
local function fireCEDamage(targetInstance, pos)
    local char = game.Players.LocalPlayer.Character
    local tool = char and char:FindFirstChildOfClass("Tool")
    local remote = game:GetService("ReplicatedStorage"):WaitForChild("CarbonResource"):WaitForChild("Events"):WaitForChild("DamageEvent")

    if tool and remote then
        -- 닉네임킬이 안 될 경우를 대비해 테이블 구조를 가장 안정적인 형태로 전달
        local args = {
            [1] = {
                ["tool"] = tool,
                ["remoteK"] = nil, 
                ["rayResult"] = {
                    ["Instance"] = targetInstance,
                    ["Material"] = Enum.Material.Plastic,
                    ["Normal"] = Vector3.new(0, 1, 0),
                    ["Position"] = pos
                }
            }
        }
        remote:FireServer(unpack(args))
    end
end

-- 1. 논산부대 올킬
CETab:AddToggle("NonsanAllKillToggle", {
    Title = "논산부대 올킬",
    Default = false,
    Description = "모든 플레이어를 순회하며 공격합니다.",
    Callback = function(Value)
        NonsanAllKill = Value
    end
})

-- 2. 논산부대 닉네임킬
CETab:AddInput("NonsanNickInput", {
    Title = "논산부대 닉네임킬 대상",
    Placeholder = "닉네임 일부 입력...",
    Callback = function(Value) 
        NonsanTargetNickname = Value 
    end
})

CETab:AddButton({
    Title = "논산부대 닉네임킬 실행",
    Description = "해당 플레이어를 공격합니다.",
    Callback = function()
        if NonsanTargetNickname == "" then return end
        local targetPlayer = nil
        for _, p in pairs(game.Players:GetPlayers()) do
            if p ~= game.Players.LocalPlayer and string.find(p.Name:lower(), NonsanTargetNickname:lower()) then
                targetPlayer = p
                break
            end
        end

        if targetPlayer and targetPlayer.Character then
            task.spawn(function()
                local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                if not targetRoot then return end
                
                local startTime = tick()
                -- 3초간 집중 포화
                while (tick() - startTime) < 3 and targetPlayer.Character.Parent do
                    fireCEDamage(targetRoot, targetRoot.Position)
                    task.wait(0.05)
                end
            end)
        end
    end
})

-- 3. 논산부대 레이더되기
CETab:AddButton({
    Title = "논산부대 레이더되기",
    Description = "플레이어의 팀을 레이더로 변경합니다.",
    Callback = function()
        local teams = game:GetService("Teams")
        local raiderTeam = teams:FindFirstChild("Raider")

        if raiderTeam then
            local teamColor = raiderTeam.TeamColor
            local args = {
                [1] = teamColor
            }

            game:GetService("ReplicatedStorage")
                :WaitForChild("Remotes")
                :WaitForChild("ChangeTeam")
                :FireServer(unpack(args))
        end
    end
})

-- 4. 논산부대 서버 렉 (수정된 부분)
CETab:AddToggle("NonsanLagToggle", {
    Title = "논산부대 서버 렉",
    Default = false,
    Description = "서버에 렉을 유발시킵니다.",
    Callback = function(Value) 
        NonsanLagEnabled = Value 
    end
})

-- [메인 루프] 0.01초 단위 실행
task.spawn(function()
    while true do
        task.wait(0.01)
        local lp = game.Players.LocalPlayer
        if not lp.Character then continue end

        -- 1. 올킬 로직 (팀이 다른 적만 사살)
        if NonsanAllKill then
            for _, player in pairs(game.Players:GetPlayers()) do
                if player ~= lp and player.Character and player.Team ~= lp.Team then
                    local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
                    local hum = player.Character:FindFirstChild("Humanoid")
                    if targetRoot and hum and hum.Health > 0 then
                        fireCEDamage(targetRoot, targetRoot.Position)
                    end
                end
            end
        end

        -- 2. 서버 렉 로직 (요청하신 대로 본인 제외 모든 플레이어 머리 위 30스터드 연사)
        if NonsanLagEnabled then
            -- 데미지 방지용 무생물 파트 (바닥 등)
            local ignorePart = workspace:FindFirstChild("Baseplate") or workspace:FindFirstChildOfClass("Terrain")
            
            for _, player in pairs(game.Players:GetPlayers()) do
                -- 본인 제외
                if player ~= lp and player.Character and player.Character:FindFirstChild("Head") then
                    local head = player.Character.Head
                    -- 머리 위 30스터드 좌표
                    local lagPos = head.Position + Vector3.new(0, 30, 0)

                    -- 한 명당 프레임당 100번의 리모트 신호 폭사
                    for i = 1, 100 do
                        fireCEDamage(ignorePart, lagPos)
                    end
                end
            end
        end
    end
end)
