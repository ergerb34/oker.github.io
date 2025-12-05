--[[
    WindUI - Restructured
    Based on original WindUI styling with Obsidian-like clean architecture
    No folder/config dependencies - stable and crash-free
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
local Mouse = cloneref(LocalPlayer:GetMouse())

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
    TweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
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

    Scheme = {
        Accent = Color3.fromHex("#18181b"),
        Background = Color3.fromHex("#101010"),
        Dialog = Color3.fromHex("#161616"),
        Outline = Color3.fromHex("#FFFFFF"),
        Text = Color3.fromHex("#FFFFFF"),
        Placeholder = Color3.fromHex("#7a7a7a"),
        Button = Color3.fromHex("#52525b"),
        Icon = Color3.fromHex("#a1a1aa"),
        Toggle = Color3.fromHex("#33C759"),
        Slider = Color3.fromHex("#0091ff"),
        Dark = Color3.new(0, 0, 0),
        White = Color3.new(1, 1, 1),
    },

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
        ScreenGui = { ResetOnSpawn = false, ZIndexBehavior = "Sibling" },
        Frame = { BorderSizePixel = 0, BackgroundColor3 = Color3.new(1, 1, 1) },
        CanvasGroup = { BorderSizePixel = 0, BackgroundColor3 = Color3.new(1, 1, 1) },
        TextLabel = { BorderSizePixel = 0, BackgroundColor3 = Color3.new(1, 1, 1), Text = "", RichText = true, TextColor3 = Color3.new(1, 1, 1), TextSize = 14 },
        TextButton = { BorderSizePixel = 0, BackgroundColor3 = Color3.new(1, 1, 1), Text = "", AutoButtonColor = false, TextColor3 = Color3.new(1, 1, 1), TextSize = 14 },
        TextBox = { BorderSizePixel = 0, BackgroundColor3 = Color3.new(1, 1, 1), ClearTextOnFocus = false, Text = "", TextColor3 = Color3.new(0, 0, 0), TextSize = 14 },
        ImageLabel = { BackgroundTransparency = 1, BorderSizePixel = 0 },
        ImageButton = { BorderSizePixel = 0, AutoButtonColor = false },
        UIListLayout = { SortOrder = "LayoutOrder" },
        ScrollingFrame = { ScrollBarImageTransparency = 1, BorderSizePixel = 0 },
    },

    Icons = nil,
}

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
        icons.SetIconsType("lucide")
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
        if conn then conn:Disconnect() end
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
        return WindUI.Icons.Icon(name, nil, applyTheme ~= false)
    end
    return nil
end

function WindUI.New(className, properties, children)
    local instance = Instance.new(className)
    for prop, value in next, WindUI.DefaultProperties[className] or {} do
        instance[prop] = value
    end
    for prop, value in next, properties or {} do
        if prop ~= "ThemeTag" then
            instance[prop] = value
        end
    end
    for _, child in next, children or {} do
        child.Parent = instance
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
            frame[prop] = value
        end
    end

    local function UpdateSliceScale(r)
        local scale = shapeType ~= "Shadow-sm" and (r / 256) or (r / 512)
        frame.SliceScale = math.max(scale, 0.0001)
    end

    UpdateSliceScale(radius)

    local controller = {}
    function controller:SetRadius(r) UpdateSliceScale(r) end
    function controller:GetRadius() return radius end

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

    function dragController:Set(enabled) dragController.CanDraggable = enabled end
    return dragController
end

function WindUI:CreateWindow(options)
    options = options or {}

    local windowData = {
        Title = options.Title or "WindUI",
        Size = options.Size or UDim2.fromOffset(720, 500),
        Position = options.Position or UDim2.fromOffset(100, 100),
        Center = options.Center ~= false,
        Tabs = {},
        UICorner = options.CornerRadius or 13,
    }

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "WindUI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    pcall(function() screenGui.Parent = gethui() end)
    if not screenGui.Parent then screenGui.Parent = CoreGui end
    protectgui(screenGui)
    WindUI.ScreenGui = screenGui

    local shadow = WindUI.NewRoundFrame(windowData.UICorner + 8, "Shadow-sm", {
        Size = UDim2.new(1, 24, 1, 24),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ImageColor3 = Color3.new(0, 0, 0),
        ImageTransparency = 0.5,
        ZIndex = 0,
    })

    local mainFrame = WindUI.NewRoundFrame(windowData.UICorner, "Squircle", {
        Name = "MainWindow",
        Size = windowData.Size,
        Position = windowData.Center and UDim2.new(0.5, 0, 0.5, 0) or windowData.Position,
        AnchorPoint = windowData.Center and Vector2.new(0.5, 0.5) or Vector2.new(0, 0),
        ImageColor3 = WindUI.Scheme.Background,
        Parent = screenGui,
    }, {
        shadow,
        WindUI.NewRoundFrame(windowData.UICorner, "SquircleOutline", {
            Size = UDim2.new(1, 0, 1, 0),
            ImageColor3 = WindUI.Scheme.Outline,
            ImageTransparency = 0.9,
            ZIndex = 10,
        }),
    })

    local topbar = WindUI.NewRoundFrame(windowData.UICorner, "Squircle-TL-TR", {
        Name = "Topbar",
        Size = UDim2.new(1, 0, 0, 48),
        ImageColor3 = WindUI.Scheme.Accent,
        Parent = mainFrame,
        ZIndex = 2,
    }, {
        WindUI.New("TextLabel", {
            Name = "Title",
            Size = UDim2.new(1, -20, 1, 0),
            Position = UDim2.new(0, 16, 0, 0),
            BackgroundTransparency = 1,
            Text = windowData.Title,
            TextColor3 = WindUI.Scheme.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            FontFace = Font.new(WindUI.Font, Enum.FontWeight.SemiBold),
            TextSize = 18,
        }),
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
        Size = UDim2.new(0, 180, 1, 0),
        ImageColor3 = WindUI.Scheme.Accent,
        ClipsDescendants = true,
        Parent = contentFrame,
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
        Size = UDim2.new(1, -180, 1, 0),
        Position = UDim2.new(0, 180, 0, 0),
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

    function windowData:AddTab(tabOptions)
        tabOptions = tabOptions or {}
        local tabData = {
            Name = tabOptions.Name or "Tab",
            Icon = tabOptions.Icon or nil,
            Groupboxes = {},
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
                })
            end
        end

        local tabButton = WindUI.NewRoundFrame(8, "Squircle", {
            Name = tabData.Name,
            Size = UDim2.new(1, 0, 0, 36),
            ImageColor3 = WindUI.Scheme.Accent,
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
                    TextXAlignment = Enum.TextXAlignment.Left,
                    FontFace = Font.new(WindUI.Font, Enum.FontWeight.Medium),
                    TextSize = 15,
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
            WindUI.New("UIListLayout", { Padding = UDim.new(0, 12) }),
            WindUI.New("UIPadding", {
                PaddingTop = UDim.new(0, 12),
                PaddingLeft = UDim.new(0, 12),
                PaddingRight = UDim.new(0, 12),
                PaddingBottom = UDim.new(0, 12),
            }),
        })

        tabData.Button = tabButton
        tabData.Page = tabPage
        tabData.IconImage = iconImage

        tabButton.MouseButton1Click:Connect(function()
            for _, tab in pairs(windowData.Tabs) do
                if tab.Page then tab.Page.Visible = false end
                if tab.Button then
                    WindUI.Tween(tab.Button, 0.15, { ImageTransparency = 1 }):Play()
                end
                if tab.IconImage then
                    WindUI.Tween(tab.IconImage, 0.15, { ImageColor3 = WindUI.Scheme.Icon }):Play()
                end
            end
            tabPage.Visible = true
            WindUI.Tween(tabButton, 0.15, { ImageTransparency = 0.9 }):Play()
            if iconImage then
                WindUI.Tween(iconImage, 0.15, { ImageColor3 = WindUI.Scheme.Text }):Play()
            end
            WindUI.ActiveTab = tabData
        end)

        tabButton.MouseEnter:Connect(function()
            if WindUI.ActiveTab ~= tabData then
                WindUI.Tween(tabButton, 0.1, { ImageTransparency = 0.95 }):Play()
            end
        end)

        tabButton.MouseLeave:Connect(function()
            if WindUI.ActiveTab ~= tabData then
                WindUI.Tween(tabButton, 0.1, { ImageTransparency = 1 }):Play()
            end
        end)

        function tabData:AddGroupbox(groupOptions)
            groupOptions = groupOptions or {}
            local groupData = {
                Name = groupOptions.Name or "Groupbox",
                Elements = {},
            }

            local groupFrame = WindUI.NewRoundFrame(10, "Squircle", {
                Name = groupData.Name,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                ImageColor3 = WindUI.Scheme.Accent,
                ImageTransparency = 0.3,
                Parent = tabPage,
            }, {
                WindUI.NewRoundFrame(10, "SquircleOutline", {
                    Size = UDim2.new(1, 0, 1, 0),
                    ImageColor3 = WindUI.Scheme.Outline,
                    ImageTransparency = 0.92,
                }),
                WindUI.New("Frame", {
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                }, {
                    WindUI.New("UIPadding", {
                        PaddingTop = UDim.new(0, 12),
                        PaddingLeft = UDim.new(0, 14),
                        PaddingRight = UDim.new(0, 14),
                        PaddingBottom = UDim.new(0, 12),
                    }),
                    WindUI.New("UIListLayout", { Padding = UDim.new(0, 8) }),
                    WindUI.New("TextLabel", {
                        Name = "Title",
                        Size = UDim2.new(1, 0, 0, 20),
                        BackgroundTransparency = 1,
                        Text = groupData.Name,
                        TextColor3 = WindUI.Scheme.Text,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        FontFace = Font.new(WindUI.Font, Enum.FontWeight.SemiBold),
                        TextSize = 16,
                    }),
                }),
            })

            groupData.Frame = groupFrame
            groupData.ContentFrame = groupFrame.Frame

            function groupData:AddToggle(toggleOptions)
                toggleOptions = toggleOptions or {}
                local toggleData = {
                    Text = toggleOptions.Text or "Toggle",
                    Default = toggleOptions.Default or false,
                    Value = toggleOptions.Default or false,
                    Callback = toggleOptions.Callback or function() end,
                    Flag = toggleOptions.Flag,
                }

                local toggleFrame = WindUI.New("Frame", {
                    Name = toggleData.Text,
                    Size = UDim2.new(1, 0, 0, 28),
                    BackgroundTransparency = 1,
                    Parent = groupData.ContentFrame,
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

                local toggleBack = WindUI.NewRoundFrame(10, "Squircle", {
                    Size = UDim2.new(0, 40, 0, 22),
                    Position = UDim2.new(1, 0, 0.5, 0),
                    AnchorPoint = Vector2.new(1, 0.5),
                    ImageColor3 = toggleData.Value and WindUI.Scheme.Toggle or WindUI.Scheme.Button,
                    Parent = toggleFrame,
                }, nil, true)

                local toggleCircle = WindUI.NewRoundFrame(99, "Squircle", {
                    Size = UDim2.new(0, 16, 0, 16),
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
                        AnchorPoint = Vector2.new(value and 1 or 0, 0.5),
                    }):Play()
                    if not skipCallback then
                        WindUI.SafeCallback(toggleData.Callback, value)
                    end
                end

                toggleBack.MouseButton1Click:Connect(function()
                    toggleData:SetValue(not toggleData.Value)
                end)

                if toggleData.Default then
                    task.defer(function() toggleData:SetValue(toggleData.Default, true) end)
                end

                table.insert(groupData.Elements, toggleData)
                Toggles[toggleData.Text] = toggleData
                if toggleData.Flag then Options[toggleData.Flag] = toggleData end
                return toggleData
            end

            function groupData:AddButton(buttonOptions)
                buttonOptions = buttonOptions or {}
                local buttonData = {
                    Text = buttonOptions.Text or "Button",
                    Callback = buttonOptions.Callback or function() end,
                }

                local buttonFrame = WindUI.NewRoundFrame(8, "Squircle", {
                    Name = buttonData.Text,
                    Size = UDim2.new(1, 0, 0, 32),
                    ImageColor3 = WindUI.Scheme.Button,
                    Parent = groupData.ContentFrame,
                }, {
                    WindUI.New("TextLabel", {
                        Size = UDim2.new(1, 0, 1, 0),
                        BackgroundTransparency = 1,
                        Text = buttonData.Text,
                        TextColor3 = WindUI.Scheme.Text,
                        FontFace = Font.new(WindUI.Font, Enum.FontWeight.Medium),
                        TextSize = 14,
                    }),
                }, true)

                buttonFrame.MouseButton1Click:Connect(function()
                    WindUI.SafeCallback(buttonData.Callback)
                end)

                buttonFrame.MouseEnter:Connect(function()
                    WindUI.Tween(buttonFrame, 0.1, { ImageTransparency = 0.2 }):Play()
                end)
                buttonFrame.MouseLeave:Connect(function()
                    WindUI.Tween(buttonFrame, 0.1, { ImageTransparency = 0 }):Play()
                end)

                buttonData.Frame = buttonFrame
                table.insert(groupData.Elements, buttonData)
                Buttons[buttonData.Text] = buttonData
                return buttonData
            end

            function groupData:AddLabel(labelOptions)
                labelOptions = labelOptions or {}
                local labelData = {
                    Text = labelOptions.Text or "Label",
                }

                local labelFrame = WindUI.New("TextLabel", {
                    Name = labelData.Text,
                    Size = UDim2.new(1, 0, 0, 20),
                    BackgroundTransparency = 1,
                    Text = labelData.Text,
                    TextColor3 = WindUI.Scheme.Text,
                    TextTransparency = 0.3,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    FontFace = Font.new(WindUI.Font, Enum.FontWeight.Regular),
                    TextSize = 14,
                    Parent = groupData.ContentFrame,
                })

                labelData.Frame = labelFrame
                function labelData:SetText(text)
                    labelData.Text = text
                    labelFrame.Text = text
                end

                table.insert(groupData.Elements, labelData)
                Labels[labelData.Text] = labelData
                return labelData
            end

            function groupData:AddSlider(sliderOptions)
                sliderOptions = sliderOptions or {}
                local sliderData = {
                    Text = sliderOptions.Text or "Slider",
                    Min = sliderOptions.Min or 0,
                    Max = sliderOptions.Max or 100,
                    Default = sliderOptions.Default or sliderOptions.Min or 0,
                    Value = sliderOptions.Default or sliderOptions.Min or 0,
                    Increment = sliderOptions.Increment or 1,
                    Suffix = sliderOptions.Suffix or "",
                    Callback = sliderOptions.Callback or function() end,
                    Flag = sliderOptions.Flag,
                }

                local sliderFrame = WindUI.New("Frame", {
                    Name = sliderData.Text,
                    Size = UDim2.new(1, 0, 0, 44),
                    BackgroundTransparency = 1,
                    Parent = groupData.ContentFrame,
                })

                local sliderLabel = WindUI.New("TextLabel", {
                    Size = UDim2.new(1, -60, 0, 20),
                    BackgroundTransparency = 1,
                    Text = sliderData.Text,
                    TextColor3 = WindUI.Scheme.Text,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    FontFace = Font.new(WindUI.Font, Enum.FontWeight.Regular),
                    TextSize = 14,
                    Parent = sliderFrame,
                })

                local sliderValue = WindUI.New("TextLabel", {
                    Size = UDim2.new(0, 60, 0, 20),
                    Position = UDim2.new(1, 0, 0, 0),
                    AnchorPoint = Vector2.new(1, 0),
                    BackgroundTransparency = 1,
                    Text = tostring(sliderData.Value) .. sliderData.Suffix,
                    TextColor3 = WindUI.Scheme.Text,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    FontFace = Font.new(WindUI.Font, Enum.FontWeight.Medium),
                    TextSize = 14,
                    Parent = sliderFrame,
                })

                local sliderBack = WindUI.NewRoundFrame(6, "Squircle", {
                    Size = UDim2.new(1, 0, 0, 12),
                    Position = UDim2.new(0, 0, 0, 28),
                    ImageColor3 = WindUI.Scheme.Button,
                    Parent = sliderFrame,
                }, nil, true)

                local percent = (sliderData.Value - sliderData.Min) / (sliderData.Max - sliderData.Min)
                local sliderFill = WindUI.NewRoundFrame(6, "Squircle", {
                    Size = UDim2.new(math.max(percent, 0.02), 0, 1, 0),
                    ImageColor3 = WindUI.Scheme.Slider,
                    Parent = sliderBack,
                })

                local sliderThumb = WindUI.NewRoundFrame(99, "Squircle", {
                    Size = UDim2.new(0, 18, 0, 18),
                    Position = UDim2.new(percent, 0, 0.5, 0),
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    ImageColor3 = WindUI.Scheme.White,
                    ZIndex = 2,
                    Parent = sliderBack,
                })

                sliderData.Frame = sliderFrame
                sliderData.ValueLabel = sliderValue
                sliderData.Fill = sliderFill
                sliderData.Thumb = sliderThumb

                function sliderData:SetValue(value, skipCallback)
                    value = math.clamp(value, sliderData.Min, sliderData.Max)
                    value = math.floor(value / sliderData.Increment + 0.5) * sliderData.Increment
                    sliderData.Value = value

                    local pct = (value - sliderData.Min) / (sliderData.Max - sliderData.Min)
                    sliderValue.Text = tostring(value) .. sliderData.Suffix
                    WindUI.Tween(sliderFill, 0.1, { Size = UDim2.new(math.max(pct, 0.02), 0, 1, 0) }):Play()
                    WindUI.Tween(sliderThumb, 0.1, { Position = UDim2.new(pct, 0, 0.5, 0) }):Play()

                    if not skipCallback then
                        WindUI.SafeCallback(sliderData.Callback, value)
                    end
                end

                local dragging = false
                local function updateSlider(input)
                    local pos = (input.Position.X - sliderBack.AbsolutePosition.X) / sliderBack.AbsoluteSize.X
                    pos = math.clamp(pos, 0, 1)
                    local value = sliderData.Min + (sliderData.Max - sliderData.Min) * pos
                    sliderData:SetValue(value)
                end

                sliderBack.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        updateSlider(input)
                    end
                end)

                UserInputService.InputChanged:Connect(function(input)
                    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        updateSlider(input)
                    end
                end)

                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = false
                    end
                end)

                if sliderData.Default ~= sliderData.Min then
                    task.defer(function() sliderData:SetValue(sliderData.Default, true) end)
                end

                table.insert(groupData.Elements, sliderData)
                Sliders[sliderData.Text] = sliderData
                if sliderData.Flag then Options[sliderData.Flag] = sliderData end
                return sliderData
            end

            function groupData:AddDropdown(dropdownOptions)
                dropdownOptions = dropdownOptions or {}
                local dropdownData = {
                    Text = dropdownOptions.Text or "Dropdown",
                    Values = dropdownOptions.Values or {},
                    Default = dropdownOptions.Default,
                    Value = dropdownOptions.Default,
                    Multi = dropdownOptions.Multi or false,
                    Callback = dropdownOptions.Callback or function() end,
                    Flag = dropdownOptions.Flag,
                    Open = false,
                }

                if dropdownData.Multi then
                    dropdownData.Value = dropdownData.Default or {}
                end

                local dropdownFrame = WindUI.New("Frame", {
                    Name = dropdownData.Text,
                    Size = UDim2.new(1, 0, 0, 60),
                    BackgroundTransparency = 1,
                    ClipsDescendants = false,
                    Parent = groupData.ContentFrame,
                })

                local dropdownLabel = WindUI.New("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 20),
                    BackgroundTransparency = 1,
                    Text = dropdownData.Text,
                    TextColor3 = WindUI.Scheme.Text,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    FontFace = Font.new(WindUI.Font, Enum.FontWeight.Regular),
                    TextSize = 14,
                    Parent = dropdownFrame,
                })

                local function getDisplayText()
                    if dropdownData.Multi then
                        if #dropdownData.Value == 0 then return "None" end
                        return table.concat(dropdownData.Value, ", ")
                    else
                        return dropdownData.Value or "Select..."
                    end
                end

                local dropdownButton = WindUI.NewRoundFrame(8, "Squircle", {
                    Size = UDim2.new(1, 0, 0, 32),
                    Position = UDim2.new(0, 0, 0, 24),
                    ImageColor3 = WindUI.Scheme.Accent,
                    Parent = dropdownFrame,
                }, {
                    WindUI.NewRoundFrame(8, "SquircleOutline", {
                        Size = UDim2.new(1, 0, 1, 0),
                        ImageColor3 = WindUI.Scheme.Outline,
                        ImageTransparency = 0.9,
                    }),
                    WindUI.New("TextLabel", {
                        Size = UDim2.new(1, -30, 1, 0),
                        Position = UDim2.new(0, 12, 0, 0),
                        BackgroundTransparency = 1,
                        Text = getDisplayText(),
                        TextColor3 = WindUI.Scheme.Text,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        FontFace = Font.new(WindUI.Font, Enum.FontWeight.Regular),
                        TextSize = 14,
                        Name = "Selected",
                    }),
                }, true)

                local dropdownList = WindUI.NewRoundFrame(8, "Squircle", {
                    Size = UDim2.new(1, 0, 0, 0),
                    Position = UDim2.new(0, 0, 0, 58),
                    ImageColor3 = WindUI.Scheme.Dialog,
                    ClipsDescendants = true,
                    Visible = false,
                    ZIndex = 100,
                    Parent = dropdownFrame,
                }, {
                    WindUI.New("UIListLayout", { Padding = UDim.new(0, 2) }),
                    WindUI.New("UIPadding", {
                        PaddingTop = UDim.new(0, 4),
                        PaddingLeft = UDim.new(0, 4),
                        PaddingRight = UDim.new(0, 4),
                        PaddingBottom = UDim.new(0, 4),
                    }),
                })

                dropdownData.Frame = dropdownFrame
                dropdownData.Button = dropdownButton
                dropdownData.List = dropdownList
                dropdownData.SelectedLabel = dropdownButton.Selected

                local function updateList()
                    for _, child in pairs(dropdownList:GetChildren()) do
                        if child:IsA("ImageButton") or child:IsA("ImageLabel") then
                            child:Destroy()
                        end
                    end

                    for _, value in ipairs(dropdownData.Values) do
                        local isSelected = false
                        if dropdownData.Multi then
                            isSelected = table.find(dropdownData.Value, value) ~= nil
                        else
                            isSelected = dropdownData.Value == value
                        end

                        local optionButton = WindUI.NewRoundFrame(6, "Squircle", {
                            Size = UDim2.new(1, 0, 0, 28),
                            ImageColor3 = isSelected and WindUI.Scheme.Button or WindUI.Scheme.Dialog,
                            Parent = dropdownList,
                        }, {
                            WindUI.New("TextLabel", {
                                Size = UDim2.new(1, -10, 1, 0),
                                Position = UDim2.new(0, 10, 0, 0),
                                BackgroundTransparency = 1,
                                Text = value,
                                TextColor3 = WindUI.Scheme.Text,
                                TextXAlignment = Enum.TextXAlignment.Left,
                                FontFace = Font.new(WindUI.Font, Enum.FontWeight.Regular),
                                TextSize = 14,
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
                                dropdownFrame.Size = UDim2.new(1, 0, 0, 60)
                            end
                            dropdownData.SelectedLabel.Text = getDisplayText()
                            updateList()
                            WindUI.SafeCallback(dropdownData.Callback, dropdownData.Value)
                        end)

                        optionButton.MouseEnter:Connect(function()
                            WindUI.Tween(optionButton, 0.1, { ImageColor3 = WindUI.Scheme.Button }):Play()
                        end)
                        optionButton.MouseLeave:Connect(function()
                            local sel = dropdownData.Multi and table.find(dropdownData.Value, value) or dropdownData.Value == value
                            WindUI.Tween(optionButton, 0.1, { ImageColor3 = sel and WindUI.Scheme.Button or WindUI.Scheme.Dialog }):Play()
                        end)
                    end

                    local listHeight = math.min(#dropdownData.Values * 30 + 8, 150)
                    dropdownList.Size = UDim2.new(1, 0, 0, listHeight)
                    if dropdownData.Open then
                        dropdownFrame.Size = UDim2.new(1, 0, 0, 60 + listHeight + 4)
                    end
                end

                dropdownButton.MouseButton1Click:Connect(function()
                    dropdownData.Open = not dropdownData.Open
                    dropdownList.Visible = dropdownData.Open
                    if dropdownData.Open then
                        updateList()
                    else
                        dropdownFrame.Size = UDim2.new(1, 0, 0, 60)
                    end
                end)

                function dropdownData:SetValue(value)
                    dropdownData.Value = value
                    dropdownData.SelectedLabel.Text = getDisplayText()
                    updateList()
                end

                function dropdownData:SetValues(values)
                    dropdownData.Values = values
                    updateList()
                end

                table.insert(groupData.Elements, dropdownData)
                Dropdowns[dropdownData.Text] = dropdownData
                if dropdownData.Flag then Options[dropdownData.Flag] = dropdownData end
                return dropdownData
            end

            function groupData:AddInput(inputOptions)
                inputOptions = inputOptions or {}
                local inputData = {
                    Text = inputOptions.Text or "Input",
                    Default = inputOptions.Default or "",
                    Value = inputOptions.Default or "",
                    Placeholder = inputOptions.Placeholder or "Enter text...",
                    Numeric = inputOptions.Numeric or false,
                    Callback = inputOptions.Callback or function() end,
                    Flag = inputOptions.Flag,
                }

                local inputFrame = WindUI.New("Frame", {
                    Name = inputData.Text,
                    Size = UDim2.new(1, 0, 0, 56),
                    BackgroundTransparency = 1,
                    Parent = groupData.ContentFrame,
                })

                local inputLabel = WindUI.New("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 20),
                    BackgroundTransparency = 1,
                    Text = inputData.Text,
                    TextColor3 = WindUI.Scheme.Text,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    FontFace = Font.new(WindUI.Font, Enum.FontWeight.Regular),
                    TextSize = 14,
                    Parent = inputFrame,
                })

                local inputBack = WindUI.NewRoundFrame(8, "Squircle", {
                    Size = UDim2.new(1, 0, 0, 32),
                    Position = UDim2.new(0, 0, 0, 24),
                    ImageColor3 = WindUI.Scheme.Accent,
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
                    TextSize = 14,
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

                table.insert(groupData.Elements, inputData)
                Inputs[inputData.Text] = inputData
                if inputData.Flag then Options[inputData.Flag] = inputData end
                return inputData
            end

            function groupData:AddColorPicker(colorOptions)
                colorOptions = colorOptions or {}
                local colorData = {
                    Text = colorOptions.Text or "Color",
                    Default = colorOptions.Default or Color3.new(1, 0, 0),
                    Value = colorOptions.Default or Color3.new(1, 0, 0),
                    Callback = colorOptions.Callback or function() end,
                    Flag = colorOptions.Flag,
                    Open = false,
                }

                local colorFrame = WindUI.New("Frame", {
                    Name = colorData.Text,
                    Size = UDim2.new(1, 0, 0, 28),
                    BackgroundTransparency = 1,
                    ClipsDescendants = false,
                    Parent = groupData.ContentFrame,
                })

                local colorLabel = WindUI.New("TextLabel", {
                    Size = UDim2.new(1, -40, 1, 0),
                    BackgroundTransparency = 1,
                    Text = colorData.Text,
                    TextColor3 = WindUI.Scheme.Text,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    FontFace = Font.new(WindUI.Font, Enum.FontWeight.Regular),
                    TextSize = 14,
                    Parent = colorFrame,
                })

                local colorButton = WindUI.NewRoundFrame(6, "Squircle", {
                    Size = UDim2.new(0, 32, 0, 22),
                    Position = UDim2.new(1, 0, 0.5, 0),
                    AnchorPoint = Vector2.new(1, 0.5),
                    ImageColor3 = colorData.Value,
                    Parent = colorFrame,
                }, {
                    WindUI.NewRoundFrame(6, "SquircleOutline", {
                        Size = UDim2.new(1, 0, 1, 0),
                        ImageColor3 = WindUI.Scheme.Outline,
                        ImageTransparency = 0.8,
                    }),
                }, true)

                local colorPicker = WindUI.NewRoundFrame(10, "Squircle", {
                    Size = UDim2.new(0, 200, 0, 180),
                    Position = UDim2.new(1, 0, 0, 32),
                    AnchorPoint = Vector2.new(1, 0),
                    ImageColor3 = WindUI.Scheme.Dialog,
                    Visible = false,
                    ZIndex = 100,
                    Parent = colorFrame,
                }, {
                    WindUI.New("UIPadding", {
                        PaddingTop = UDim.new(0, 8),
                        PaddingLeft = UDim.new(0, 8),
                        PaddingRight = UDim.new(0, 8),
                        PaddingBottom = UDim.new(0, 8),
                    }),
                })

                local saturationFrame = WindUI.New("ImageLabel", {
                    Size = UDim2.new(1, 0, 0, 120),
                    BackgroundColor3 = colorData.Value,
                    Image = "rbxassetid://4155801252",
                    Parent = colorPicker,
                }, {
                    WindUI.New("UICorner", { CornerRadius = UDim.new(0, 6) }),
                    WindUI.New("ImageLabel", {
                        Size = UDim2.new(1, 0, 1, 0),
                        BackgroundTransparency = 1,
                        Image = "rbxassetid://4155801252",
                        ImageColor3 = Color3.new(0, 0, 0),
                        ImageTransparency = 0,
                    }, {
                        WindUI.New("UIGradient", {
                            Rotation = 90,
                            Transparency = NumberSequence.new({
                                NumberSequenceKeypoint.new(0, 1),
                                NumberSequenceKeypoint.new(1, 0),
                            }),
                        }),
                    }),
                })

                local hueFrame = WindUI.New("Frame", {
                    Size = UDim2.new(1, 0, 0, 16),
                    Position = UDim2.new(0, 0, 0, 128),
                    Parent = colorPicker,
                }, {
                    WindUI.New("UICorner", { CornerRadius = UDim.new(0, 4) }),
                    WindUI.New("UIGradient", {
                        Color = ColorSequence.new({
                            ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 1, 1)),
                            ColorSequenceKeypoint.new(0.167, Color3.fromHSV(0.167, 1, 1)),
                            ColorSequenceKeypoint.new(0.333, Color3.fromHSV(0.333, 1, 1)),
                            ColorSequenceKeypoint.new(0.5, Color3.fromHSV(0.5, 1, 1)),
                            ColorSequenceKeypoint.new(0.667, Color3.fromHSV(0.667, 1, 1)),
                            ColorSequenceKeypoint.new(0.833, Color3.fromHSV(0.833, 1, 1)),
                            ColorSequenceKeypoint.new(1, Color3.fromHSV(1, 1, 1)),
                        }),
                    }),
                })

                local h, s, v = colorData.Value:ToHSV()

                local satCursor = WindUI.New("Frame", {
                    Size = UDim2.new(0, 10, 0, 10),
                    Position = UDim2.new(s, 0, 1 - v, 0),
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    Parent = saturationFrame,
                }, {
                    WindUI.New("UICorner", { CornerRadius = UDim.new(1, 0) }),
                    WindUI.New("UIStroke", { Color = Color3.new(0, 0, 0), Thickness = 1 }),
                })

                local hueCursor = WindUI.New("Frame", {
                    Size = UDim2.new(0, 4, 1, 4),
                    Position = UDim2.new(h, 0, 0.5, 0),
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    Parent = hueFrame,
                }, {
                    WindUI.New("UICorner", { CornerRadius = UDim.new(0, 2) }),
                    WindUI.New("UIStroke", { Color = Color3.new(0, 0, 0), Thickness = 1 }),
                })

                colorData.Frame = colorFrame
                colorData.Button = colorButton
                colorData.Picker = colorPicker
                colorData.SatFrame = saturationFrame
                colorData.HueFrame = hueFrame
                colorData.SatCursor = satCursor
                colorData.HueCursor = hueCursor
                colorData.H = h
                colorData.S = s
                colorData.V = v

                local function updateColor()
                    colorData.Value = Color3.fromHSV(colorData.H, colorData.S, colorData.V)
                    colorButton.ImageColor3 = colorData.Value
                    saturationFrame.BackgroundColor3 = Color3.fromHSV(colorData.H, 1, 1)
                    satCursor.Position = UDim2.new(colorData.S, 0, 1 - colorData.V, 0)
                    hueCursor.Position = UDim2.new(colorData.H, 0, 0.5, 0)
                    WindUI.SafeCallback(colorData.Callback, colorData.Value)
                end

                colorButton.MouseButton1Click:Connect(function()
                    colorData.Open = not colorData.Open
                    colorPicker.Visible = colorData.Open
                    colorFrame.Size = colorData.Open and UDim2.new(1, 0, 0, 220) or UDim2.new(1, 0, 0, 28)
                end)

                local satDragging = false
                saturationFrame.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        satDragging = true
                    end
                end)

                UserInputService.InputChanged:Connect(function(input)
                    if satDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        local pos = input.Position
                        local rel = Vector2.new(pos.X - saturationFrame.AbsolutePosition.X, pos.Y - saturationFrame.AbsolutePosition.Y)
                        colorData.S = math.clamp(rel.X / saturationFrame.AbsoluteSize.X, 0, 1)
                        colorData.V = 1 - math.clamp(rel.Y / saturationFrame.AbsoluteSize.Y, 0, 1)
                        updateColor()
                    end
                end)

                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        satDragging = false
                    end
                end)

                local hueDragging = false
                hueFrame.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        hueDragging = true
                    end
                end)

                UserInputService.InputChanged:Connect(function(input)
                    if hueDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        local pos = input.Position
                        local rel = pos.X - hueFrame.AbsolutePosition.X
                        colorData.H = math.clamp(rel / hueFrame.AbsoluteSize.X, 0, 1)
                        updateColor()
                    end
                end)

                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        hueDragging = false
                    end
                end)

                function colorData:SetValue(color)
                    colorData.Value = color
                    colorData.H, colorData.S, colorData.V = color:ToHSV()
                    updateColor()
                end

                table.insert(groupData.Elements, colorData)
                ColorPickers[colorData.Text] = colorData
                if colorData.Flag then Options[colorData.Flag] = colorData end
                return colorData
            end

            table.insert(tabData.Groupboxes, groupData)
            return groupData
        end

        table.insert(windowData.Tabs, tabData)
        table.insert(WindUI.Tabs, tabData)

        if #windowData.Tabs == 1 then
            tabPage.Visible = true
            WindUI.Tween(tabButton, 0.15, { ImageTransparency = 0.9 }):Play()
            if iconImage then
                WindUI.Tween(iconImage, 0.15, { ImageColor3 = WindUI.Scheme.Text }):Play()
            end
            WindUI.ActiveTab = tabData
        end

        return tabData
    end

    function windowData:SetVisible(visible)
        mainFrame.Visible = visible
        WindUI.Toggled = visible
    end

    function windowData:Toggle()
        self:SetVisible(not mainFrame.Visible)
    end

    WindUI.AddSignal(UserInputService.InputBegan, function(input, processed)
        if processed then return end
        if input.KeyCode == WindUI.ToggleKeybind then
            windowData:Toggle()
        end
    end)

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
