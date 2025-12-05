--[[
     _      ___         ____  ______
    | | /| / (_)__  ___/ / / / /  _/
    | |/ |/ / / _ \/ _  / /_/ // /  
    |__/|__/_/_//_/\_,_/\____/___/
    
    WindUI - Stable Build (API Compatible)
    Clean architecture - No folder/config dependencies
    
    Original Author: Footagesus
    Restructured for stability while maintaining original API compatibility
]]

local cloneref = (cloneref or clonereference or function(instance)
    return instance
end)

local CoreGui = cloneref(game:GetService("CoreGui"))
local HttpService = cloneref(game:GetService("HttpService"))
local Players = cloneref(game:GetService("Players"))
local RunService = cloneref(game:GetService("RunService"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local TextService = cloneref(game:GetService("TextService"))
local TweenService = cloneref(game:GetService("TweenService"))

local getgenv = getgenv or function()
    return shared
end
local protectgui = protectgui or (syn and syn.protect_gui) or function() end
local gethui = gethui or function()
    return CoreGui
end

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local Mouse = LocalPlayer:GetMouse()

local Labels = {}
local Buttons = {}
local Toggles = {}
local Sliders = {}
local Dropdowns = {}
local Inputs = {}
local ColorPickers = {}
local Options = {}

local WindUI = {
    LocalPlayer = LocalPlayer,
    IsMobile = false,
    IsRobloxFocused = true,
    ScreenGui = nil,
    ActiveTab = nil,
    Tabs = {},
    ToggleKeybind = Enum.KeyCode.RightControl,
    TweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    Toggled = true,
    Unloaded = false,
    
    Labels = Labels,
    Buttons = Buttons,
    Toggles = Toggles,
    Sliders = Sliders,
    Dropdowns = Dropdowns,
    Inputs = Inputs,
    ColorPickers = ColorPickers,
    Options = Options,
    
    CanDraggable = true,
    Signals = {},
    UnloadSignals = {},
    DPIScale = 1,
    CornerRadius = 10,
    Font = "rbxassetid://12187365364",
    Theme = nil,
    Objects = {},
    FontObjects = {},
    NotificationHolder = nil,
    OpenButton = nil,

    Themes = {
        Dark = {
            Accent = Color3.fromRGB(24, 24, 27),
            Background = Color3.fromRGB(15, 15, 16),
            Dialog = Color3.fromRGB(22, 22, 24),
            Outline = Color3.fromRGB(255, 255, 255),
            Text = Color3.fromRGB(255, 255, 255),
            Placeholder = Color3.fromRGB(106, 106, 106),
            Button = Color3.fromRGB(63, 63, 70),
            Icon = Color3.fromRGB(161, 161, 170),
            Toggle = Color3.fromRGB(34, 197, 94),
            Slider = Color3.fromRGB(59, 130, 246),
            Dark = Color3.new(0, 0, 0),
            White = Color3.new(1, 1, 1),
        },
        Light = {
            Accent = Color3.fromRGB(240, 240, 245),
            Background = Color3.fromRGB(255, 255, 255),
            Dialog = Color3.fromRGB(245, 245, 250),
            Outline = Color3.fromRGB(0, 0, 0),
            Text = Color3.fromRGB(0, 0, 0),
            Placeholder = Color3.fromRGB(120, 120, 120),
            Button = Color3.fromRGB(200, 200, 210),
            Icon = Color3.fromRGB(80, 80, 90),
            Toggle = Color3.fromRGB(34, 197, 94),
            Slider = Color3.fromRGB(59, 130, 246),
            Dark = Color3.new(0, 0, 0),
            White = Color3.new(1, 1, 1),
        },
    },

    Scheme = nil,

    Shapes = {
        Square = "rbxassetid://82909646051652",
        Squircle = "rbxassetid://80999662900595",
        SquircleOutline = "rbxassetid://117788349049947",
        ["Squircle-Outline"] = "rbxassetid://117817408534198",
        ["Shadow-sm"] = "rbxassetid://84825982946844",
        ["Squircle-TL-TR"] = "rbxassetid://73569156276236",
        ["Squircle-BL-BR"] = "rbxassetid://93853842912264",
    },

    DefaultProperties = {
        ScreenGui = { ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling },
        Frame = { BorderSizePixel = 0, BackgroundColor3 = Color3.new(1, 1, 1) },
        CanvasGroup = { BorderSizePixel = 0, BackgroundColor3 = Color3.new(1, 1, 1) },
        TextLabel = { BorderSizePixel = 0, BackgroundColor3 = Color3.new(1, 1, 1), Text = "", RichText = true, TextColor3 = Color3.new(1, 1, 1), TextSize = 14 },
        TextButton = { BorderSizePixel = 0, BackgroundColor3 = Color3.new(1, 1, 1), Text = "", AutoButtonColor = false, TextColor3 = Color3.new(1, 1, 1), TextSize = 14 },
        TextBox = { BorderSizePixel = 0, BackgroundColor3 = Color3.new(1, 1, 1), ClearTextOnFocus = false, Text = "", TextColor3 = Color3.new(0, 0, 0), TextSize = 14 },
        ImageLabel = { BackgroundTransparency = 1, BorderSizePixel = 0 },
        ImageButton = { BorderSizePixel = 0, AutoButtonColor = false },
        UIListLayout = { SortOrder = Enum.SortOrder.LayoutOrder },
        ScrollingFrame = { ScrollBarImageTransparency = 1, BorderSizePixel = 0 },
    },

    Icons = nil,
}

WindUI.Scheme = WindUI.Themes.Dark

pcall(function()
    WindUI.DevicePlatform = UserInputService:GetPlatform()
end)
WindUI.IsMobile = (WindUI.DevicePlatform == Enum.Platform.Android or WindUI.DevicePlatform == Enum.Platform.IOS)

local function LoadIcons()
    local success, icons = pcall(function()
        local iconUrl = "https://raw.githubusercontent.com/Footagesus/Icons/main/Main-v2.lua"
        return loadstring(game:HttpGet(iconUrl))()
    end)
    if success and icons then
        pcall(function() icons.SetIconsType("lucide") end)
        WindUI.Icons = icons
        return icons
    end
    return nil
end

pcall(LoadIcons)

function WindUI.AddSignal(signal, callback)
    local connection = signal:Connect(callback)
    table.insert(WindUI.Signals, connection)
    return connection
end

function WindUI.DisconnectAll()
    for i = #WindUI.Signals, 1, -1 do
        local conn = table.remove(WindUI.Signals, i)
        if conn then pcall(function() conn:Disconnect() end) end
    end
end

function WindUI.SafeCallback(callback, ...)
    if not callback then return end
    local success, result = pcall(callback, ...)
    if not success then
        warn("[ WindUI ] Callback Error: " .. tostring(result))
    end
    return success, result
end

function WindUI.Icon(name, applyTheme)
    if WindUI.Icons and WindUI.Icons.Icon then
        local success, result = pcall(function()
            return WindUI.Icons.Icon(name, nil, applyTheme ~= false)
        end)
        if success then return result end
    end
    return nil
end

function WindUI.New(className, properties, children)
    local instance = Instance.new(className)
    for prop, value in next, WindUI.DefaultProperties[className] or {} do
        pcall(function() instance[prop] = value end)
    end
    for prop, value in next, properties or {} do
        if prop ~= "ThemeTag" then
            pcall(function() instance[prop] = value end)
        end
    end
    for _, child in next, children or {} do
        if child then child.Parent = instance end
    end
    if properties and properties.FontFace then
        table.insert(WindUI.FontObjects, instance)
    end
    return instance
end

function WindUI.Tween(object, duration, properties, easingStyle, easingDirection)
    easingStyle = easingStyle or Enum.EasingStyle.Quad
    easingDirection = easingDirection or Enum.EasingDirection.Out
    return TweenService:Create(object, TweenInfo.new(duration, easingStyle, easingDirection), properties)
end

function WindUI.NewRoundFrame(radius, shapeType, properties, children, isButton, returnController)
    local function getImageForType(sType)
        return WindUI.Shapes[sType] or WindUI.Shapes.Squircle
    end

    local function getSliceCenterForType(sType)
        return sType ~= "Shadow-sm" and Rect.new(256, 256, 256, 256) or Rect.new(512, 512, 512, 512)
    end

    local frame = WindUI.New(isButton and "ImageButton" or "ImageLabel", {
        Image = getImageForType(shapeType),
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = getSliceCenterForType(shapeType),
        SliceScale = 1,
        BackgroundTransparency = 1,
    }, children)

    for prop, value in pairs(properties or {}) do
        if prop ~= "ThemeTag" then
            pcall(function() frame[prop] = value end)
        end
    end

    local function UpdateSliceScale(r)
        local scale = shapeType ~= "Shadow-sm" and (r / 256) or (r / 512)
        frame.SliceScale = math.max(scale, 0.0001)
    end

    UpdateSliceScale(radius)

    local controller = {}
    function controller:SetRadius(r) 
        radius = r
        UpdateSliceScale(r) 
    end
    function controller:GetRadius() 
        return radius 
    end
    function controller:SetType(newType)
        shapeType = newType
        frame.Image = getImageForType(newType)
        frame.SliceCenter = getSliceCenterForType(newType)
        UpdateSliceScale(radius)
    end
    function controller:GetType()
        return shapeType
    end
    function controller:UpdateShape(newRadius, newType)
        if newType then
            shapeType = newType
            frame.Image = getImageForType(newType)
            frame.SliceCenter = getSliceCenterForType(newType)
        end
        if newRadius then
            radius = newRadius
        end
        UpdateSliceScale(radius)
    end

    return frame, returnController and controller or nil
end

function WindUI.Drag(target, dragElements, onDragCallback)
    local currentDragElement
    local isDragging = false
    local dragStart, startPos
    local dragController = { CanDraggable = true }

    if not dragElements or typeof(dragElements) ~= "table" then
        dragElements = { target }
    end

    local function update(input)
        if not isDragging or not dragController.CanDraggable then return end
        local delta = input.Position - dragStart
        WindUI.Tween(target, 0.02, {
            Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        }):Play()
    end

    for _, element in pairs(dragElements) do
        element.InputBegan:Connect(function(input)
            if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and dragController.CanDraggable then
                if currentDragElement == nil then
                    currentDragElement = element
                    isDragging = true
                    dragStart = input.Position
                    startPos = target.Position
                    if onDragCallback then onDragCallback(true, currentDragElement) end
                    input.Changed:Connect(function()
                        if input.UserInputState == Enum.UserInputState.End then
                            isDragging = false
                            currentDragElement = nil
                            if onDragCallback then onDragCallback(false, nil) end
                        end
                    end)
                end
            end
        end)

        element.InputChanged:Connect(function(input)
            if isDragging and currentDragElement == element then
                if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                    update(input)
                end
            end
        end)
    end

    UserInputService.InputChanged:Connect(function(input)
        if isDragging and currentDragElement ~= nil then
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                update(input)
            end
        end
    end)

    function dragController:Set(enabled) 
        dragController.CanDraggable = enabled 
    end
    
    return dragController
end

function WindUI:Notify(options)
    options = options or {}
    local notifyData = {
        Title = options.Title or "Notification",
        Content = options.Content or options.Desc or "",
        Duration = options.Duration or 5,
        Icon = options.Icon,
    }
    
    if not WindUI.NotificationHolder then
        return notifyData
    end
    
    local iconImage
    if notifyData.Icon and WindUI.Icons then
        local iconData = WindUI.Icon(notifyData.Icon)
        if iconData then
            iconImage = WindUI.New("ImageLabel", {
                Size = UDim2.new(0, 20, 0, 20),
                BackgroundTransparency = 1,
                Image = iconData[1],
                ImageRectSize = iconData[2] and iconData[2].ImageRectSize or Vector2.new(0, 0),
                ImageRectOffset = iconData[2] and iconData[2].ImageRectPosition or Vector2.new(0, 0),
                ImageColor3 = WindUI.Scheme.Icon,
            })
        end
    end
    
    local contentHeight = 0
    if notifyData.Content and notifyData.Content ~= "" then
        contentHeight = 20
    end
    
    local notifyHeight = 44 + contentHeight
    
    local notifyFrame = WindUI.NewRoundFrame(WindUI.CornerRadius, "Squircle", {
        Size = UDim2.new(1, 0, 0, notifyHeight),
        Position = UDim2.new(1, 0, 0, 0),
        ImageColor3 = WindUI.Scheme.Dialog,
        Parent = WindUI.NotificationHolder,
        ClipsDescendants = true,
    }, {
        WindUI.NewRoundFrame(WindUI.CornerRadius, "SquircleOutline", {
            Size = UDim2.new(1, 0, 1, 0),
            ImageColor3 = WindUI.Scheme.Outline,
            ImageTransparency = 0.9,
        }),
    })
    
    local progressBar = WindUI.New("Frame", {
        Size = UDim2.new(0, 0, 0, 3),
        Position = UDim2.new(0, 0, 1, -3),
        BackgroundColor3 = WindUI.Scheme.Slider,
        Parent = notifyFrame,
    }, {
        WindUI.New("UICorner", { CornerRadius = UDim.new(0, 2) }),
    })
    
    local contentFrame = WindUI.New("Frame", {
        Size = UDim2.new(1, 0, 1, -3),
        BackgroundTransparency = 1,
        Parent = notifyFrame,
    }, {
        WindUI.New("UIPadding", {
            PaddingTop = UDim.new(0, 10),
            PaddingLeft = UDim.new(0, 12),
            PaddingRight = UDim.new(0, 12),
            PaddingBottom = UDim.new(0, 10),
        }),
        WindUI.New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            VerticalAlignment = Enum.VerticalAlignment.Top,
            Padding = UDim.new(0, 10),
        }),
    })
    
    if iconImage then
        iconImage.Parent = contentFrame
    end
    
    local textFrame = WindUI.New("Frame", {
        Size = UDim2.new(1, iconImage and -30 or 0, 1, 0),
        BackgroundTransparency = 1,
        Parent = contentFrame,
    }, {
        WindUI.New("UIListLayout", { Padding = UDim.new(0, 2) }),
        WindUI.New("TextLabel", {
            Size = UDim2.new(1, 0, 0, 20),
            BackgroundTransparency = 1,
            Text = notifyData.Title,
            TextColor3 = WindUI.Scheme.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            FontFace = Font.new(WindUI.Font, Enum.FontWeight.SemiBold),
            TextSize = 15,
        }),
    })
    
    if notifyData.Content and notifyData.Content ~= "" then
        WindUI.New("TextLabel", {
            Size = UDim2.new(1, 0, 0, 18),
            BackgroundTransparency = 1,
            Text = notifyData.Content,
            TextColor3 = WindUI.Scheme.Text,
            TextTransparency = 0.4,
            TextXAlignment = Enum.TextXAlignment.Left,
            FontFace = Font.new(WindUI.Font, Enum.FontWeight.Regular),
            TextSize = 13,
            TextWrapped = true,
            Parent = textFrame,
        })
    end
    
    WindUI.Tween(notifyFrame, 0.3, { Position = UDim2.new(0, 0, 0, 0) }, Enum.EasingStyle.Quint):Play()
    WindUI.Tween(progressBar, notifyData.Duration, { Size = UDim2.new(1, 0, 0, 3) }, Enum.EasingStyle.Linear):Play()
    
    task.delay(notifyData.Duration, function()
        WindUI.Tween(notifyFrame, 0.3, { Position = UDim2.new(1, 0, 0, 0) }, Enum.EasingStyle.Quint):Play()
        task.wait(0.35)
        if notifyFrame and notifyFrame.Parent then
            notifyFrame:Destroy()
        end
    end)
    
    return notifyData
end

function WindUI:CreateWindow(options)
    options = options or {}

    local themeName = options.Theme or "Dark"
    if WindUI.Themes[themeName] then
        WindUI.Scheme = WindUI.Themes[themeName]
    end

    local windowData = {
        Title = options.Title or "WindUI",
        Author = options.Author or "",
        Size = options.Size or UDim2.fromOffset(580, 460),
        Position = options.Position or UDim2.fromOffset(100, 100),
        Center = options.Center ~= false,
        Tabs = {},
        UICorner = options.CornerRadius or WindUI.CornerRadius,
        Icon = options.Icon or nil,
        Debug = options.Debug or false,
        Folder = options.Folder or nil,
        Transparent = options.Transparent or false,
        HasOutline = options.HasOutline ~= false,
        Theme = themeName,
    }

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "WindUI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    pcall(function() screenGui.Parent = gethui() end)
    if not screenGui.Parent then 
        pcall(function() screenGui.Parent = CoreGui end)
    end
    if not screenGui.Parent then
        pcall(function() screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end)
    end
    pcall(function() protectgui(screenGui) end)
    WindUI.ScreenGui = screenGui
    windowData.ScreenGui = screenGui

    local notificationHolder = WindUI.New("Frame", {
        Position = UDim2.new(1, -20, 0, 50),
        AnchorPoint = Vector2.new(1, 0),
        Size = UDim2.new(0, 280, 1, -100),
        BackgroundTransparency = 1,
        Parent = screenGui,
        ZIndex = 100,
    }, {
        WindUI.New("UIListLayout", {
            VerticalAlignment = Enum.VerticalAlignment.Top,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            Padding = UDim.new(0, 8),
        }),
    })
    WindUI.NotificationHolder = notificationHolder

    local shadow = WindUI.NewRoundFrame(windowData.UICorner + 8, "Shadow-sm", {
        Size = UDim2.new(1, 24, 1, 24),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ImageColor3 = Color3.new(0, 0, 0),
        ImageTransparency = 0.4,
        ZIndex = 0,
    })

    local outlineFrame
    if windowData.HasOutline then
        outlineFrame = WindUI.NewRoundFrame(windowData.UICorner, "SquircleOutline", {
            Size = UDim2.new(1, 0, 1, 0),
            ImageColor3 = WindUI.Scheme.Outline,
            ImageTransparency = 0.92,
            ZIndex = 10,
        })
    end

    local mainFrame = WindUI.NewRoundFrame(windowData.UICorner, "Squircle", {
        Name = "MainWindow",
        Size = windowData.Size,
        Position = windowData.Center and UDim2.new(0.5, 0, 0.5, 0) or windowData.Position,
        AnchorPoint = windowData.Center and Vector2.new(0.5, 0.5) or Vector2.new(0, 0),
        ImageColor3 = WindUI.Scheme.Background,
        ImageTransparency = windowData.Transparent and 0.1 or 0,
        Parent = screenGui,
        ClipsDescendants = true,
    }, {
        shadow,
        outlineFrame,
    })

    local topbarContent = {
        WindUI.New("UIPadding", {
            PaddingLeft = UDim.new(0, 16),
            PaddingRight = UDim.new(0, 16),
        }),
        WindUI.New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, 12),
        }),
    }

    local iconImage
    if windowData.Icon and WindUI.Icons then
        local iconData = WindUI.Icon(windowData.Icon)
        if iconData then
            iconImage = WindUI.New("ImageLabel", {
                Size = UDim2.new(0, 24, 0, 24),
                BackgroundTransparency = 1,
                Image = iconData[1],
                ImageRectSize = iconData[2] and iconData[2].ImageRectSize or Vector2.new(0, 0),
                ImageRectOffset = iconData[2] and iconData[2].ImageRectPosition or Vector2.new(0, 0),
                ImageColor3 = WindUI.Scheme.Text,
            })
            table.insert(topbarContent, iconImage)
        end
    end

    table.insert(topbarContent, WindUI.New("TextLabel", {
        Name = "Title",
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        Text = windowData.Title,
        TextColor3 = WindUI.Scheme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        FontFace = Font.new(WindUI.Font, Enum.FontWeight.SemiBold),
        TextSize = 18,
    }))

    if windowData.Author and windowData.Author ~= "" then
        table.insert(topbarContent, WindUI.New("TextLabel", {
            Name = "Author",
            Size = UDim2.new(0, 0, 1, 0),
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundTransparency = 1,
            Text = "| " .. windowData.Author,
            TextColor3 = WindUI.Scheme.Text,
            TextTransparency = 0.5,
            TextXAlignment = Enum.TextXAlignment.Left,
            FontFace = Font.new(WindUI.Font, Enum.FontWeight.Regular),
            TextSize = 14,
        }))
    end

    local topbar = WindUI.NewRoundFrame(windowData.UICorner, "Squircle-TL-TR", {
        Name = "Topbar",
        Size = UDim2.new(1, 0, 0, 48),
        ImageColor3 = WindUI.Scheme.Accent,
        ImageTransparency = windowData.Transparent and 0.2 or 0,
        Parent = mainFrame,
        ZIndex = 2,
    }, topbarContent)

    local separator = WindUI.New("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = WindUI.Scheme.Outline,
        BackgroundTransparency = 0.92,
        Parent = topbar,
    })

    local contentFrame = WindUI.New("Frame", {
        Name = "Content",
        Size = UDim2.new(1, 0, 1, -48),
        Position = UDim2.new(0, 0, 0, 48),
        BackgroundTransparency = 1,
        Parent = mainFrame,
        ZIndex = 1,
    })

    local tabContainer = WindUI.NewRoundFrame(windowData.UICorner, "Squircle-BL-BR", {
        Name = "TabContainer",
        Size = UDim2.new(0, 160, 1, 0),
        ImageColor3 = WindUI.Scheme.Accent,
        ImageTransparency = windowData.Transparent and 0.3 or 0,
        ClipsDescendants = true,
        Parent = contentFrame,
    })

    local tabSeparator = WindUI.New("Frame", {
        Size = UDim2.new(0, 1, 1, 0),
        Position = UDim2.new(1, -1, 0, 0),
        BackgroundColor3 = WindUI.Scheme.Outline,
        BackgroundTransparency = 0.92,
        Parent = tabContainer,
    })

    local tabScroll = WindUI.New("ScrollingFrame", {
        Name = "TabScroll",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ScrollBarThickness = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = tabContainer,
    }, {
        WindUI.New("UIListLayout", { Padding = UDim.new(0, 4) }),
        WindUI.New("UIPadding", {
            PaddingTop = UDim.new(0, 8),
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
            PaddingBottom = UDim.new(0, 8),
        }),
    })

    local pageContainer = WindUI.New("Frame", {
        Name = "PageContainer",
        Size = UDim2.new(1, -160, 1, 0),
        Position = UDim2.new(0, 160, 0, 0),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Parent = contentFrame,
    })

    windowData.MainFrame = mainFrame
    windowData.TabContainer = tabContainer
    windowData.TabScroll = tabScroll
    windowData.PageContainer = pageContainer
    windowData.Window = windowData

    WindUI.Drag(mainFrame, { topbar })

    function windowData:EditOpenButton(btnOptions)
        btnOptions = btnOptions or {}
        
        if WindUI.OpenButton then
            WindUI.OpenButton:Destroy()
        end
        
        local btnTitle = btnOptions.Title or "Open"
        local btnIcon = btnOptions.Icon
        local btnCorner = btnOptions.CornerRadius or UDim.new(0, 8)
        local btnStroke = btnOptions.StrokeThickness or 2
        local btnColor = btnOptions.Color or ColorSequence.new(Color3.fromRGB(100, 100, 255), Color3.fromRGB(100, 200, 255))
        local btnDraggable = btnOptions.Draggable ~= false
        
        local openBtn = WindUI.New("TextButton", {
            Name = "OpenButton",
            Size = UDim2.new(0, 140, 0, 36),
            Position = UDim2.new(0, 20, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundColor3 = WindUI.Scheme.Dialog,
            Text = "",
            Parent = screenGui,
            ZIndex = 50,
            Visible = not WindUI.Toggled,
        }, {
            WindUI.New("UICorner", { CornerRadius = btnCorner }),
            WindUI.New("UIStroke", {
                Thickness = btnStroke,
                Color = typeof(btnColor) == "ColorSequence" and btnColor.Keypoints[1].Value or btnColor,
            }),
            WindUI.New("UIGradient", {
                Color = typeof(btnColor) == "ColorSequence" and btnColor or ColorSequence.new(btnColor),
            }),
        })
        
        local btnContent = WindUI.New("Frame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Parent = openBtn,
        }, {
            WindUI.New("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                Padding = UDim.new(0, 8),
            }),
        })
        
        if btnIcon and WindUI.Icons then
            local iconData = WindUI.Icon(btnIcon)
            if iconData then
                WindUI.New("ImageLabel", {
                    Size = UDim2.new(0, 18, 0, 18),
                    BackgroundTransparency = 1,
                    Image = iconData[1],
                    ImageRectSize = iconData[2] and iconData[2].ImageRectSize or Vector2.new(0, 0),
                    ImageRectOffset = iconData[2] and iconData[2].ImageRectPosition or Vector2.new(0, 0),
                    ImageColor3 = WindUI.Scheme.Text,
                    Parent = btnContent,
                })
            end
        end
        
        WindUI.New("TextLabel", {
            Size = UDim2.new(0, 0, 1, 0),
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundTransparency = 1,
            Text = btnTitle,
            TextColor3 = WindUI.Scheme.Text,
            FontFace = Font.new(WindUI.Font, Enum.FontWeight.Medium),
            TextSize = 14,
            Parent = btnContent,
        })
        
        openBtn.MouseButton1Click:Connect(function()
            mainFrame.Visible = true
            openBtn.Visible = false
            WindUI.Toggled = true
        end)
        
        if btnDraggable then
            WindUI.Drag(openBtn, { openBtn })
        end
        
        WindUI.OpenButton = openBtn
        return openBtn
    end

    function windowData:Tab(tabOptions)
        tabOptions = tabOptions or {}
        local tabData = {
            Name = tabOptions.Title or tabOptions.Name or "Tab",
            Icon = tabOptions.Icon or nil,
            Elements = {},
            Visible = true,
        }

        local iconImage
        if tabData.Icon and WindUI.Icons then
            local iconData = WindUI.Icon(tabData.Icon)
            if iconData then
                iconImage = WindUI.New("ImageLabel", {
                    Size = UDim2.new(0, 18, 0, 18),
                    BackgroundTransparency = 1,
                    Image = iconData[1],
                    ImageRectSize = iconData[2] and iconData[2].ImageRectSize or Vector2.new(0, 0),
                    ImageRectOffset = iconData[2] and iconData[2].ImageRectPosition or Vector2.new(0, 0),
                    ImageColor3 = WindUI.Scheme.Icon,
                    Name = "TabIcon",
                })
            end
        end

        local tabButton = WindUI.NewRoundFrame(8, "Squircle", {
            Name = tabData.Name,
            Size = UDim2.new(1, 0, 0, 36),
            ImageColor3 = WindUI.Scheme.Button,
            ImageTransparency = 1,
            Parent = tabScroll,
        }, {
            WindUI.New("Frame", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
            }, {
                WindUI.New("UIListLayout", {
                    FillDirection = Enum.FillDirection.Horizontal,
                    VerticalAlignment = Enum.VerticalAlignment.Center,
                    Padding = UDim.new(0, 10),
                }),
                WindUI.New("UIPadding", {
                    PaddingLeft = UDim.new(0, 12),
                }),
                iconImage,
                WindUI.New("TextLabel", {
                    Name = "Label",
                    Size = UDim2.new(1, iconImage and -28 or 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text = tabData.Name,
                    TextColor3 = WindUI.Scheme.Text,
                    TextTransparency = 0.3,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    FontFace = Font.new(WindUI.Font, Enum.FontWeight.Medium),
                    TextSize = 14,
                }),
            }),
        }, true)

        local tabPage = WindUI.New("ScrollingFrame", {
            Name = tabData.Name .. "Page",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = WindUI.Scheme.Button,
            ScrollBarImageTransparency = 0.5,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible = false,
            Parent = pageContainer,
        }, {
            WindUI.New("UIListLayout", { Padding = UDim.new(0, 8) }),
            WindUI.New("UIPadding", {
                PaddingTop = UDim.new(0, 12),
                PaddingLeft = UDim.new(0, 16),
                PaddingRight = UDim.new(0, 16),
                PaddingBottom = UDim.new(0, 12),
            }),
        })

        tabData.Button = tabButton
        tabData.Page = tabPage
        tabData.IconImage = iconImage

        local function activateTab()
            for _, tab in pairs(windowData.Tabs) do
                if tab.Page then tab.Page.Visible = false end
                if tab.Button then
                    WindUI.Tween(tab.Button, 0.15, { ImageTransparency = 1 }):Play()
                end
                if tab.IconImage then
                    WindUI.Tween(tab.IconImage, 0.15, { ImageColor3 = WindUI.Scheme.Icon }):Play()
                end
                local label = tab.Button and tab.Button:FindFirstChild("Frame") and tab.Button.Frame:FindFirstChild("Label")
                if label then
                    WindUI.Tween(label, 0.15, { TextTransparency = 0.3 }):Play()
                end
            end
            tabPage.Visible = true
            WindUI.Tween(tabButton, 0.15, { ImageTransparency = 0.85 }):Play()
            if iconImage then
                WindUI.Tween(iconImage, 0.15, { ImageColor3 = WindUI.Scheme.Text }):Play()
            end
            local label = tabButton:FindFirstChild("Frame") and tabButton.Frame:FindFirstChild("Label")
            if label then
                WindUI.Tween(label, 0.15, { TextTransparency = 0 }):Play()
            end
            WindUI.ActiveTab = tabData
        end

        tabButton.MouseButton1Click:Connect(activateTab)

        tabButton.MouseEnter:Connect(function()
            if WindUI.ActiveTab ~= tabData then
                WindUI.Tween(tabButton, 0.1, { ImageTransparency = 0.92 }):Play()
            end
        end)

        tabButton.MouseLeave:Connect(function()
            if WindUI.ActiveTab ~= tabData then
                WindUI.Tween(tabButton, 0.1, { ImageTransparency = 1 }):Play()
            end
        end)

        function tabData:Toggle(toggleOptions)
            toggleOptions = toggleOptions or {}
            local toggleData = {
                Text = toggleOptions.Title or toggleOptions.Text or "Toggle",
                Default = toggleOptions.Default or false,
                Value = toggleOptions.Default or false,
                Callback = toggleOptions.Callback or function() end,
                Flag = toggleOptions.Flag,
            }

            local toggleFrame = WindUI.New("Frame", {
                Name = toggleData.Text,
                Size = UDim2.new(1, 0, 0, 32),
                BackgroundTransparency = 1,
                Parent = tabPage,
            })

            local toggleLabel = WindUI.New("TextLabel", {
                Size = UDim2.new(1, -50, 1, 0),
                BackgroundTransparency = 1,
                Text = toggleData.Text,
                TextColor3 = WindUI.Scheme.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                FontFace = Font.new(WindUI.Font, Enum.FontWeight.Regular),
                TextSize = 14,
                Parent = toggleFrame,
            })

            local toggleBack = WindUI.NewRoundFrame(11, "Squircle", {
                Size = UDim2.new(0, 44, 0, 24),
                Position = UDim2.new(1, 0, 0.5, 0),
                AnchorPoint = Vector2.new(1, 0.5),
                ImageColor3 = toggleData.Value and WindUI.Scheme.Toggle or WindUI.Scheme.Button,
                Parent = toggleFrame,
            }, nil, true)

            local toggleCircle = WindUI.NewRoundFrame(99, "Squircle", {
                Size = UDim2.new(0, 18, 0, 18),
                Position = toggleData.Value and UDim2.new(1, -3, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
                AnchorPoint = Vector2.new(toggleData.Value and 1 or 0, 0.5),
                ImageColor3 = WindUI.Scheme.White,
                Parent = toggleBack,
            })

            toggleData.Frame = toggleFrame
            toggleData.Back = toggleBack
            toggleData.Circle = toggleCircle

            function toggleData:SetValue(value, skipCallback)
                toggleData.Value = value
                WindUI.Tween(toggleBack, 0.2, { ImageColor3 = value and WindUI.Scheme.Toggle or WindUI.Scheme.Button }):Play()
                WindUI.Tween(toggleCircle, 0.2, { 
                    Position = value and UDim2.new(1, -3, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
                    AnchorPoint = Vector2.new(value and 1 or 0, 0.5)
                }):Play()
                if not skipCallback then
                    WindUI.SafeCallback(toggleData.Callback, value)
                end
            end

            function toggleData:GetValue()
                return toggleData.Value
            end
            
            function toggleData:Set(value)
                toggleData:SetValue(value)
            end

            toggleBack.MouseButton1Click:Connect(function()
                toggleData:SetValue(not toggleData.Value)
            end)

            table.insert(tabData.Elements, toggleData)
            Toggles[toggleData.Text] = toggleData
            if toggleData.Flag then Options[toggleData.Flag] = toggleData end
            return toggleData
        end

        function tabData:Button(buttonOptions)
            buttonOptions = buttonOptions or {}
            local buttonData = {
                Text = buttonOptions.Title or buttonOptions.Text or "Button",
                Desc = buttonOptions.Desc or nil,
                Callback = buttonOptions.Callback or function() end,
            }

            local buttonHeight = buttonData.Desc and 50 or 36

            local buttonFrame = WindUI.NewRoundFrame(8, "Squircle", {
                Name = buttonData.Text,
                Size = UDim2.new(1, 0, 0, buttonHeight),
                ImageColor3 = WindUI.Scheme.Button,
                Parent = tabPage,
            }, {
                WindUI.NewRoundFrame(8, "SquircleOutline", {
                    Size = UDim2.new(1, 0, 1, 0),
                    ImageColor3 = WindUI.Scheme.Outline,
                    ImageTransparency = 0.9,
                }),
            }, true)

            local textContent = WindUI.New("Frame", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Parent = buttonFrame,
            }, {
                WindUI.New("UIListLayout", {
                    VerticalAlignment = Enum.VerticalAlignment.Center,
                    HorizontalAlignment = Enum.HorizontalAlignment.Center,
                    Padding = UDim.new(0, 2),
                }),
            })

            WindUI.New("TextLabel", {
                Size = UDim2.new(1, -20, 0, 18),
                BackgroundTransparency = 1,
                Text = buttonData.Text,
                TextColor3 = WindUI.Scheme.Text,
                FontFace = Font.new(WindUI.Font, Enum.FontWeight.Medium),
                TextSize = 14,
                Parent = textContent,
            })

            if buttonData.Desc then
                WindUI.New("TextLabel", {
                    Size = UDim2.new(1, -20, 0, 14),
                    BackgroundTransparency = 1,
                    Text = buttonData.Desc,
                    TextColor3 = WindUI.Scheme.Text,
                    TextTransparency = 0.4,
                    FontFace = Font.new(WindUI.Font, Enum.FontWeight.Regular),
                    TextSize = 12,
                    Parent = textContent,
                })
            end

            buttonData.Frame = buttonFrame

            buttonFrame.MouseButton1Click:Connect(function()
                WindUI.Tween(buttonFrame, 0.1, { ImageColor3 = WindUI.Scheme.Toggle }):Play()
                task.wait(0.1)
                WindUI.Tween(buttonFrame, 0.1, { ImageColor3 = WindUI.Scheme.Button }):Play()
                WindUI.SafeCallback(buttonData.Callback)
            end)

            buttonFrame.MouseEnter:Connect(function()
                WindUI.Tween(buttonFrame, 0.1, { ImageTransparency = 0.1 }):Play()
            end)

            buttonFrame.MouseLeave:Connect(function()
                WindUI.Tween(buttonFrame, 0.1, { ImageTransparency = 0 }):Play()
            end)

            table.insert(tabData.Elements, buttonData)
            Buttons[buttonData.Text] = buttonData
            return buttonData
        end

        function tabData:Slider(sliderOptions)
            sliderOptions = sliderOptions or {}
            local sliderData = {
                Text = sliderOptions.Title or sliderOptions.Text or "Slider",
                Default = sliderOptions.Default or sliderOptions.Min or 0,
                Min = sliderOptions.Min or 0,
                Max = sliderOptions.Max or 100,
                Rounding = sliderOptions.Rounding or 0,
                Suffix = sliderOptions.Suffix or "",
                Value = sliderOptions.Default or sliderOptions.Min or 0,
                Callback = sliderOptions.Callback or function() end,
                Flag = sliderOptions.Flag,
            }

            local sliderFrame = WindUI.New("Frame", {
                Name = sliderData.Text,
                Size = UDim2.new(1, 0, 0, 48),
                BackgroundTransparency = 1,
                Parent = tabPage,
            })

            local sliderLabel = WindUI.New("TextLabel", {
                Size = UDim2.new(0.7, 0, 0, 18),
                BackgroundTransparency = 1,
                Text = sliderData.Text,
                TextColor3 = WindUI.Scheme.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                FontFace = Font.new(WindUI.Font, Enum.FontWeight.Regular),
                TextSize = 14,
                Parent = sliderFrame,
            })

            local percent = (sliderData.Value - sliderData.Min) / math.max(sliderData.Max - sliderData.Min, 0.001)

            local sliderValueLabel = WindUI.New("TextLabel", {
                Size = UDim2.new(0.3, 0, 0, 18),
                Position = UDim2.new(0.7, 0, 0, 0),
                BackgroundTransparency = 1,
                Text = tostring(sliderData.Value) .. sliderData.Suffix,
                TextColor3 = WindUI.Scheme.Text,
                TextTransparency = 0.3,
                TextXAlignment = Enum.TextXAlignment.Right,
                FontFace = Font.new(WindUI.Font, Enum.FontWeight.Regular),
                TextSize = 14,
                Parent = sliderFrame,
            })

            local sliderBack = WindUI.NewRoundFrame(6, "Squircle", {
                Size = UDim2.new(1, 0, 0, 12),
                Position = UDim2.new(0, 0, 0, 26),
                ImageColor3 = WindUI.Scheme.Button,
                ImageTransparency = 0.3,
                Parent = sliderFrame,
            })

            local sliderFill = WindUI.NewRoundFrame(6, "Squircle", {
                Size = UDim2.new(math.clamp(percent, 0, 1), 0, 1, 0),
                ImageColor3 = WindUI.Scheme.Slider,
                Parent = sliderBack,
            })

            local sliderThumb = WindUI.NewRoundFrame(99, "Squircle", {
                Size = UDim2.new(0, 18, 0, 18),
                Position = UDim2.new(math.clamp(percent, 0, 1), 0, 0.5, 0),
                AnchorPoint = Vector2.new(0.5, 0.5),
                ImageColor3 = WindUI.Scheme.White,
                Parent = sliderBack,
            }, nil, true)

            sliderData.Frame = sliderFrame
            sliderData.Back = sliderBack
            sliderData.Fill = sliderFill
            sliderData.Thumb = sliderThumb
            sliderData.ValueLabel = sliderValueLabel

            local function round(num, places)
                local mult = 10 ^ places
                return math.floor(num * mult + 0.5) / mult
            end

            function sliderData:SetValue(value, skipCallback)
                value = math.clamp(value, sliderData.Min, sliderData.Max)
                value = round(value, sliderData.Rounding)
                sliderData.Value = value
                local p = (value - sliderData.Min) / math.max(sliderData.Max - sliderData.Min, 0.001)
                p = math.clamp(p, 0, 1)
                WindUI.Tween(sliderFill, 0.1, { Size = UDim2.new(p, 0, 1, 0) }):Play()
                WindUI.Tween(sliderThumb, 0.1, { Position = UDim2.new(p, 0, 0.5, 0) }):Play()
                sliderValueLabel.Text = tostring(value) .. sliderData.Suffix
                if not skipCallback then
                    WindUI.SafeCallback(sliderData.Callback, value)
                end
            end

            function sliderData:GetValue()
                return sliderData.Value
            end
            
            function sliderData:Set(value)
                sliderData:SetValue(value)
            end

            local dragging = false

            sliderThumb.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                end
            end)

            sliderBack.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    local pos = input.Position
                    local rel = (pos.X - sliderBack.AbsolutePosition.X) / sliderBack.AbsoluteSize.X
                    rel = math.clamp(rel, 0, 1)
                    local newValue = sliderData.Min + (sliderData.Max - sliderData.Min) * rel
                    sliderData:SetValue(newValue)
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    local pos = input.Position
                    local rel = (pos.X - sliderBack.AbsolutePosition.X) / sliderBack.AbsoluteSize.X
                    rel = math.clamp(rel, 0, 1)
                    local newValue = sliderData.Min + (sliderData.Max - sliderData.Min) * rel
                    sliderData:SetValue(newValue)
                end
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)

            table.insert(tabData.Elements, sliderData)
            Sliders[sliderData.Text] = sliderData
            if sliderData.Flag then Options[sliderData.Flag] = sliderData end
            return sliderData
        end

        function tabData:Dropdown(dropdownOptions)
            dropdownOptions = dropdownOptions or {}
            local dropdownData = {
                Text = dropdownOptions.Title or dropdownOptions.Text or "Dropdown",
                Values = dropdownOptions.List or dropdownOptions.Values or {},
                Default = dropdownOptions.Default,
                Multi = dropdownOptions.Multi or false,
                Value = dropdownOptions.Multi and {} or nil,
                Callback = dropdownOptions.Callback or function() end,
                Flag = dropdownOptions.Flag,
                Open = false,
            }

            if dropdownData.Default then
                if dropdownData.Multi then
                    if typeof(dropdownData.Default) == "table" then
                        dropdownData.Value = dropdownData.Default
                    else
                        dropdownData.Value = { dropdownData.Default }
                    end
                else
                    dropdownData.Value = dropdownData.Default
                end
            end

            local function getDisplayText()
                if dropdownData.Multi then
                    if #dropdownData.Value == 0 then
                        return "None selected"
                    else
                        return table.concat(dropdownData.Value, ", ")
                    end
                else
                    return dropdownData.Value or "Select..."
                end
            end

            local dropdownFrame = WindUI.New("Frame", {
                Name = dropdownData.Text,
                Size = UDim2.new(1, 0, 0, 56),
                BackgroundTransparency = 1,
                ClipsDescendants = false,
                Parent = tabPage,
            })

            local dropdownLabel = WindUI.New("TextLabel", {
                Size = UDim2.new(1, 0, 0, 18),
                BackgroundTransparency = 1,
                Text = dropdownData.Text,
                TextColor3 = WindUI.Scheme.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                FontFace = Font.new(WindUI.Font, Enum.FontWeight.Regular),
                TextSize = 14,
                Parent = dropdownFrame,
            })

            local dropdownButton = WindUI.NewRoundFrame(8, "Squircle", {
                Size = UDim2.new(1, 0, 0, 32),
                Position = UDim2.new(0, 0, 0, 22),
                ImageColor3 = WindUI.Scheme.Button,
                Parent = dropdownFrame,
            }, {
                WindUI.NewRoundFrame(8, "SquircleOutline", {
                    Size = UDim2.new(1, 0, 1, 0),
                    ImageColor3 = WindUI.Scheme.Outline,
                    ImageTransparency = 0.9,
                }),
                WindUI.New("Frame", {
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                }, {
                    WindUI.New("UIPadding", {
                        PaddingLeft = UDim.new(0, 12),
                        PaddingRight = UDim.new(0, 12),
                    }),
                    WindUI.New("UIListLayout", {
                        FillDirection = Enum.FillDirection.Horizontal,
                        VerticalAlignment = Enum.VerticalAlignment.Center,
                    }),
                    WindUI.New("TextLabel", {
                        Name = "Selected",
                        Size = UDim2.new(1, -20, 1, 0),
                        BackgroundTransparency = 1,
                        Text = getDisplayText(),
                        TextColor3 = WindUI.Scheme.Text,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        FontFace = Font.new(WindUI.Font, Enum.FontWeight.Regular),
                        TextSize = 13,
                    }),
                }),
            }, true)

            local dropdownList = WindUI.NewRoundFrame(8, "Squircle", {
                Size = UDim2.new(1, 0, 0, 0),
                Position = UDim2.new(0, 0, 0, 58),
                ImageColor3 = WindUI.Scheme.Dialog,
                Visible = false,
                ZIndex = 50,
                ClipsDescendants = true,
                Parent = dropdownFrame,
            }, {
                WindUI.NewRoundFrame(8, "SquircleOutline", {
                    Size = UDim2.new(1, 0, 1, 0),
                    ImageColor3 = WindUI.Scheme.Outline,
                    ImageTransparency = 0.9,
                    ZIndex = 50,
                }),
                WindUI.New("ScrollingFrame", {
                    Name = "Options",
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    ScrollBarThickness = 3,
                    ScrollBarImageColor3 = WindUI.Scheme.Button,
                    AutomaticCanvasSize = Enum.AutomaticSize.Y,
                    ZIndex = 51,
                }, {
                    WindUI.New("UIListLayout", { Padding = UDim.new(0, 2) }),
                    WindUI.New("UIPadding", {
                        PaddingTop = UDim.new(0, 4),
                        PaddingLeft = UDim.new(0, 4),
                        PaddingRight = UDim.new(0, 4),
                        PaddingBottom = UDim.new(0, 4),
                    }),
                }),
            })

            dropdownData.Frame = dropdownFrame
            dropdownData.Button = dropdownButton
            dropdownData.List = dropdownList
            dropdownData.SelectedLabel = dropdownButton.Frame.Selected

            local function updateList()
                local optionsFrame = dropdownList.Options
                for _, child in pairs(optionsFrame:GetChildren()) do
                    if child:IsA("ImageButton") or child:IsA("ImageLabel") then
                        child:Destroy()
                    end
                end

                for _, value in ipairs(dropdownData.Values) do
                    local isSelected = dropdownData.Multi and table.find(dropdownData.Value, value) or dropdownData.Value == value

                    local optionButton = WindUI.NewRoundFrame(6, "Squircle", {
                        Size = UDim2.new(1, 0, 0, 26),
                        ImageColor3 = isSelected and WindUI.Scheme.Button or WindUI.Scheme.Dialog,
                        Parent = optionsFrame,
                        ZIndex = 52,
                    }, {
                        WindUI.New("TextLabel", {
                            Size = UDim2.new(1, -24, 1, 0),
                            Position = UDim2.new(0, 12, 0, 0),
                            BackgroundTransparency = 1,
                            Text = value,
                            TextColor3 = WindUI.Scheme.Text,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            FontFace = Font.new(WindUI.Font, Enum.FontWeight.Regular),
                            TextSize = 12,
                            ZIndex = 52,
                        }),
                    }, true)

                    optionButton.MouseButton1Click:Connect(function()
                        if dropdownData.Multi then
                            local idx = table.find(dropdownData.Value, value)
                            if idx then
                                table.remove(dropdownData.Value, idx)
                            else
                                table.insert(dropdownData.Value, value)
                            end
                        else
                            dropdownData.Value = value
                            dropdownData.Open = false
                            dropdownList.Visible = false
                            dropdownFrame.Size = UDim2.new(1, 0, 0, 56)
                        end
                        dropdownData.SelectedLabel.Text = getDisplayText()
                        updateList()
                        WindUI.SafeCallback(dropdownData.Callback, dropdownData.Value)
                    end)

                    optionButton.MouseEnter:Connect(function()
                        if not (dropdownData.Multi and table.find(dropdownData.Value, value) or dropdownData.Value == value) then
                            WindUI.Tween(optionButton, 0.1, { ImageColor3 = WindUI.Scheme.Button }):Play()
                        end
                    end)

                    optionButton.MouseLeave:Connect(function()
                        local sel = dropdownData.Multi and table.find(dropdownData.Value, value) or dropdownData.Value == value
                        WindUI.Tween(optionButton, 0.1, { ImageColor3 = sel and WindUI.Scheme.Button or WindUI.Scheme.Dialog }):Play()
                    end)
                end

                local listHeight = math.min(#dropdownData.Values * 28 + 8, 140)
                dropdownList.Size = UDim2.new(1, 0, 0, listHeight)
                if dropdownData.Open then
                    dropdownFrame.Size = UDim2.new(1, 0, 0, 56 + listHeight + 4)
                end
            end

            dropdownButton.MouseButton1Click:Connect(function()
                dropdownData.Open = not dropdownData.Open
                dropdownList.Visible = dropdownData.Open
                if dropdownData.Open then
                    updateList()
                else
                    dropdownFrame.Size = UDim2.new(1, 0, 0, 56)
                end
            end)

            function dropdownData:SetValue(value)
                dropdownData.Value = value
                dropdownData.SelectedLabel.Text = getDisplayText()
                updateList()
            end
            
            function dropdownData:Set(values)
                if typeof(values) == "table" and not dropdownData.Multi then
                    dropdownData.Values = values
                else
                    dropdownData:SetValue(values)
                end
                updateList()
            end

            function dropdownData:SetValues(values)
                dropdownData.Values = values
                updateList()
            end

            function dropdownData:GetValue()
                return dropdownData.Value
            end

            table.insert(tabData.Elements, dropdownData)
            Dropdowns[dropdownData.Text] = dropdownData
            if dropdownData.Flag then Options[dropdownData.Flag] = dropdownData end
            return dropdownData
        end

        function tabData:Input(inputOptions)
            inputOptions = inputOptions or {}
            local inputData = {
                Text = inputOptions.Title or inputOptions.Text or "Input",
                Default = inputOptions.Default or "",
                Value = inputOptions.Default or "",
                Placeholder = inputOptions.Placeholder or "Enter text...",
                Numeric = inputOptions.Numeric or false,
                Callback = inputOptions.Callback or function() end,
                Flag = inputOptions.Flag,
            }

            local inputFrame = WindUI.New("Frame", {
                Name = inputData.Text,
                Size = UDim2.new(1, 0, 0, 52),
                BackgroundTransparency = 1,
                Parent = tabPage,
            })

            local inputLabel = WindUI.New("TextLabel", {
                Size = UDim2.new(1, 0, 0, 18),
                BackgroundTransparency = 1,
                Text = inputData.Text,
                TextColor3 = WindUI.Scheme.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                FontFace = Font.new(WindUI.Font, Enum.FontWeight.Regular),
                TextSize = 14,
                Parent = inputFrame,
            })

            local inputBack = WindUI.NewRoundFrame(8, "Squircle", {
                Size = UDim2.new(1, 0, 0, 30),
                Position = UDim2.new(0, 0, 0, 20),
                ImageColor3 = WindUI.Scheme.Button,
                Parent = inputFrame,
            }, {
                WindUI.NewRoundFrame(8, "SquircleOutline", {
                    Size = UDim2.new(1, 0, 1, 0),
                    ImageColor3 = WindUI.Scheme.Outline,
                    ImageTransparency = 0.9,
                }),
            })

            local inputBox = WindUI.New("TextBox", {
                Size = UDim2.new(1, -24, 1, 0),
                Position = UDim2.new(0, 12, 0, 0),
                BackgroundTransparency = 1,
                Text = inputData.Default,
                PlaceholderText = inputData.Placeholder,
                TextColor3 = WindUI.Scheme.Text,
                PlaceholderColor3 = WindUI.Scheme.Placeholder,
                TextXAlignment = Enum.TextXAlignment.Left,
                FontFace = Font.new(WindUI.Font, Enum.FontWeight.Regular),
                TextSize = 13,
                ClearTextOnFocus = false,
                Parent = inputBack,
            })

            inputData.Frame = inputFrame
            inputData.Box = inputBox

            inputBox.FocusLost:Connect(function(enterPressed)
                local text = inputBox.Text
                if inputData.Numeric then
                    text = tonumber(text) or inputData.Value
                    inputBox.Text = tostring(text)
                end
                inputData.Value = text
                WindUI.SafeCallback(inputData.Callback, text, enterPressed)
            end)

            function inputData:SetValue(value)
                inputData.Value = value
                inputBox.Text = tostring(value)
            end

            function inputData:GetValue()
                return inputData.Value
            end
            
            function inputData:Set(value)
                inputData:SetValue(value)
            end

            table.insert(tabData.Elements, inputData)
            Inputs[inputData.Text] = inputData
            if inputData.Flag then Options[inputData.Flag] = inputData end
            return inputData
        end

        function tabData:Paragraph(paragraphOptions)
            paragraphOptions = paragraphOptions or {}
            local paragraphData = {
                Title = paragraphOptions.Title or "",
                Desc = paragraphOptions.Desc or paragraphOptions.Content or "",
            }

            local paragraphFrame = WindUI.New("Frame", {
                Name = paragraphData.Title,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                Parent = tabPage,
            }, {
                WindUI.New("UIListLayout", { Padding = UDim.new(0, 4) }),
            })

            if paragraphData.Title ~= "" then
                WindUI.New("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    Text = paragraphData.Title,
                    TextColor3 = WindUI.Scheme.Text,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    FontFace = Font.new(WindUI.Font, Enum.FontWeight.SemiBold),
                    TextSize = 15,
                    TextWrapped = true,
                    Parent = paragraphFrame,
                })
            end

            if paragraphData.Desc ~= "" then
                WindUI.New("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    Text = paragraphData.Desc,
                    TextColor3 = WindUI.Scheme.Text,
                    TextTransparency = 0.3,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    FontFace = Font.new(WindUI.Font, Enum.FontWeight.Regular),
                    TextSize = 13,
                    TextWrapped = true,
                    Parent = paragraphFrame,
                })
            end

            paragraphData.Frame = paragraphFrame
            return paragraphData
        end

        function tabData:Divider()
            local divider = WindUI.New("Frame", {
                Size = UDim2.new(1, 0, 0, 1),
                BackgroundColor3 = WindUI.Scheme.Outline,
                BackgroundTransparency = 0.9,
                Parent = tabPage,
            })
            return divider
        end

        table.insert(windowData.Tabs, tabData)
        table.insert(WindUI.Tabs, tabData)

        if #windowData.Tabs == 1 then
            activateTab()
        end

        return tabData
    end

    windowData.AddTab = windowData.Tab

    function windowData:SetVisible(visible)
        mainFrame.Visible = visible
        WindUI.Toggled = visible
        if WindUI.OpenButton then
            WindUI.OpenButton.Visible = not visible
        end
    end

    function windowData:Toggle()
        self:SetVisible(not mainFrame.Visible)
    end

    function windowData:Destroy()
        WindUI:Unload()
    end

    WindUI.AddSignal(UserInputService.InputBegan, function(input, processed)
        if processed then return end
        if input.KeyCode == WindUI.ToggleKeybind then
            windowData:Toggle()
        end
    end)

    windowData.Window = windowData
    return windowData
end

function WindUI:Unload()
    WindUI.DisconnectAll()
    WindUI.Unloaded = true
    if WindUI.ScreenGui then
        WindUI.ScreenGui:Destroy()
    end
    print("[WindUI] Library unloaded")
end

return WindUI
