--// =========================================================
--// BlackUI Framework
--// Standalone Luau / Executor
--// =========================================================

local Library = {}

--=============================================================
-- SERVICES
--=============================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

--=============================================================
-- THEME
--=============================================================

Library.Theme = {
    Background = Color3.fromRGB(12, 12, 12),
    Secondary = Color3.fromRGB(18, 18, 18),
    Tertiary = Color3.fromRGB(25, 25, 25),

    Text = Color3.fromRGB(255, 255, 255),
    SubText = Color3.fromRGB(160, 160, 160),

    Accent = Color3.fromRGB(255, 255, 255),

    Border = Color3.fromRGB(40, 40, 40),

    Corner = 10
}

--=============================================================
-- UTILITY
--=============================================================

local function Create(className, properties)

    local object = Instance.new(className)

    for property, value in pairs(properties or {}) do
        object[property] = value
    end

    return object
end

local function AddCorner(object, radius)

    local corner = Instance.new("UICorner")

    corner.CornerRadius = UDim.new(
        0,
        radius or Library.Theme.Corner
    )

    corner.Parent = object

    return corner
end

local function AddStroke(object)

    local stroke = Instance.new("UIStroke")

    stroke.Color = Library.Theme.Border
    stroke.Thickness = 1

    stroke.Parent = object

    return stroke
end

local function AddPadding(object, value)

    local padding = Instance.new("UIPadding")

    padding.PaddingTop = UDim.new(0, value)
    padding.PaddingBottom = UDim.new(0, value)
    padding.PaddingLeft = UDim.new(0, value)
    padding.PaddingRight = UDim.new(0, value)

    padding.Parent = object

    return padding
end

--=============================================================
-- DRAG
--=============================================================

local function MakeDraggable(frame, handle)

    local dragging = false
    local dragStart
    local startPosition

    handle.InputBegan:Connect(function(input)

        if input.UserInputType == Enum.UserInputType.MouseButton1 then

            dragging = true

            dragStart = input.Position
            startPosition = frame.Position

        end

    end)

    UserInputService.InputChanged:Connect(function(input)

        if not dragging then
            return
        end

        if input.UserInputType ~= Enum.UserInputType.MouseMovement then
            return
        end

        local delta = input.Position - dragStart

        frame.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,

            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )

    end)

    UserInputService.InputEnded:Connect(function(input)

        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end

    end)

end

--=============================================================
-- WINDOW
--=============================================================

function Library:CreateWindow(options)

    options = options or {}

    local Window = {}

    local title = options.Title or "BlackUI"

    local size = options.Size
        or UDim2.fromOffset(650, 450)

    --=========================================================
    -- SCREEN GUI
    --=========================================================

    local ScreenGui = Create("ScreenGui", {
        Name = "BlackUI",

        ResetOnSpawn = false,

        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })

    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    --=========================================================
    -- MAIN
    --=========================================================

    local Main = Create("Frame", {

        Name = "Main",

        Parent = ScreenGui,

        Size = size,

        Position = UDim2.fromScale(0.5, 0.5),

        AnchorPoint = Vector2.new(0.5, 0.5),

        BackgroundColor3 =
            Library.Theme.Background,

        BorderSizePixel = 0
    })

    AddCorner(Main, 14)
    AddStroke(Main)

    --=========================================================
    -- TOP BAR
    --=========================================================

    local TopBar = Create("Frame", {

        Name = "TopBar",

        Parent = Main,

        Size = UDim2.new(1, 0, 0, 55),

        BackgroundColor3 =
            Library.Theme.Secondary,

        BorderSizePixel = 0
    })

    AddCorner(TopBar, 14)

    local Title = Create("TextLabel", {

        Name = "Title",

        Parent = TopBar,

        Size = UDim2.new(1, -30, 1, 0),

        Position = UDim2.fromOffset(15, 0),

        BackgroundTransparency = 1,

        Text = title,

        TextColor3 =
            Library.Theme.Text,

        Font = Enum.Font.GothamBold,

        TextSize = 18,

        TextXAlignment =
            Enum.TextXAlignment.Left
    })

    MakeDraggable(Main, TopBar)

    --=========================================================
    -- SIDEBAR
    --=========================================================

    local Sidebar = Create("Frame", {
        Name = "Sidebar",
        Parent = Main,
    
        Size = UDim2.new(0, 150, 1, -55),
        Position = UDim2.fromOffset(0, 55),
    
        BackgroundColor3 = Library.Theme.Secondary,
    
        BorderSizePixel = 0,
    
        ZIndex = 5
    })

    AddPadding(Sidebar, 10)

    local TabLayout = Create("UIListLayout", {

        Parent = Sidebar,

        Padding = UDim.new(0, 7),

        SortOrder = Enum.SortOrder.LayoutOrder
    })

    --=========================================================
    -- CONTENT
    --=========================================================

    local Content = Create("Frame", {
        Name = "Content",
        Parent = Main,
    
        Size = UDim2.new(1, -150, 1, -55),
        Position = UDim2.fromOffset(150, 55),
    
        BackgroundTransparency = 1,
    
        BorderSizePixel = 0,
    
        ZIndex = 1
    })

    --=========================================================
    -- WINDOW DATA
    --=========================================================

    Window.Gui = ScreenGui
    Window.Main = Main
    Window.Sidebar = Sidebar
    Window.Content = Content

    Window.Tabs = {}

    --=========================================================
    -- CREATE TAB
    --=========================================================

    function Window:CreateTab(name)

        local Tab = {}

        --=====================================================
        -- TAB BUTTON
        --=====================================================

        local Button = Create("TextButton", {
            Name = name,
            Parent = Sidebar,
        
            Size = UDim2.new(1, 0, 0, 40),
        
            BackgroundColor3 = Library.Theme.Tertiary,
        
            Text = name,
            TextColor3 = Library.Theme.SubText,
        
            Font = Enum.Font.GothamBold,
            TextSize = 13,
        
            AutoButtonColor = false,
            BorderSizePixel = 0,
        
            ZIndex = 10
        })

        AddCorner(Button, 8)

        --=====================================================
        -- PAGE
        --=====================================================

        local Page = Create("ScrollingFrame", {

            Name = name .. "_Page",

            Parent = Content,

            Size = UDim2.fromScale(1, 1),

            BackgroundTransparency = 1,

            BorderSizePixel = 0,

            ScrollBarThickness = 3,

            ScrollBarImageColor3 =
                Library.Theme.Text,

            Visible = false,

            CanvasSize = UDim2.new()
        })

        AddPadding(Page, 12)

        local Layout = Create("UIListLayout", {

            Parent = Page,

            Padding = UDim.new(0, 8),

            SortOrder = Enum.SortOrder.LayoutOrder
        })

        Layout:GetPropertyChangedSignal(
            "AbsoluteContentSize"
        ):Connect(function()

            Page.CanvasSize = UDim2.new(
                0,
                0,
                0,
                Layout.AbsoluteContentSize.Y + 24
            )

        end)

        Tab.Button = Button
        Tab.Page = Page
        Tab.Window = self

        --=====================================================
        -- SHOW
        --=====================================================

        function Tab:Show()

            for _, other in pairs(self.Window.Tabs) do

                other.Page.Visible = false

                other.Button.BackgroundColor3 =
                    Library.Theme.Tertiary

                other.Button.TextColor3 =
                    Library.Theme.SubText

            end

            self.Page.Visible = true

            self.Button.BackgroundColor3 =
                Library.Theme.Accent

            self.Button.TextColor3 =
                Library.Theme.Background

        end

        --=====================================================
        -- SECTION
        --=====================================================

        function Tab:AddSection(name)

            local Section = Create("TextLabel", {

                Parent = self.Page,

                Size = UDim2.new(1, -24, 0, 30),

                BackgroundTransparency = 1,

                Text = name,

                TextColor3 =
                    Library.Theme.SubText,

                Font = Enum.Font.GothamBold,

                TextSize = 12,

                TextXAlignment =
                    Enum.TextXAlignment.Left
            })

            return Section
        end

        --=====================================================
        -- LABEL
        --=====================================================

        function Tab:AddLabel(text)

            local Label = Create("TextLabel", {

                Parent = self.Page,

                Size = UDim2.new(1, -24, 0, 35),

                BackgroundTransparency = 1,

                Text = text,

                TextColor3 =
                    Library.Theme.SubText,

                Font = Enum.Font.Gotham,

                TextSize = 13,

                TextWrapped = true,

                TextXAlignment =
                    Enum.TextXAlignment.Left
            })

            return Label
        end

        --=====================================================
        -- BUTTON
        --=====================================================

        function Tab:AddButton(name, callback)

            local Button = Create("TextButton", {

                Parent = self.Page,

                Size = UDim2.new(1, -24, 0, 42),

                BackgroundColor3 =
                    Library.Theme.Secondary,

                Text = name,

                TextColor3 =
                    Library.Theme.Text,

                Font = Enum.Font.GothamBold,

                TextSize = 14,

                AutoButtonColor = false,

                BorderSizePixel = 0
            })

            AddCorner(Button, 9)
            AddStroke(Button)

            Button.MouseEnter:Connect(function()

                TweenService:Create(
                    Button,
                    TweenInfo.new(0.15),
                    {
                        BackgroundColor3 =
                            Library.Theme.Tertiary
                    }
                ):Play()

            end)

            Button.MouseLeave:Connect(function()

                TweenService:Create(
                    Button,
                    TweenInfo.new(0.15),
                    {
                        BackgroundColor3 =
                            Library.Theme.Secondary
                    }
                ):Play()

            end)

            Button.MouseButton1Click:Connect(function()

                if callback then
                    callback()
                end

            end)

            return Button
        end

        --=====================================================
        -- TOGGLE
        --=====================================================

        function Tab:AddToggle(name, default, callback)

            local Value = default == true

            local Button = Create("TextButton", {

                Parent = self.Page,

                Size = UDim2.new(1, -24, 0, 45),

                BackgroundColor3 =
                    Library.Theme.Secondary,

                Text = "",

                AutoButtonColor = false,

                BorderSizePixel = 0
            })

            AddCorner(Button, 9)
            AddStroke(Button)

            local Label = Create("TextLabel", {

                Parent = Button,

                Size = UDim2.new(1, -70, 1, 0),

                Position = UDim2.fromOffset(15, 0),

                BackgroundTransparency = 1,

                Text = name,

                TextColor3 =
                    Library.Theme.Text,

                Font = Enum.Font.GothamBold,

                TextSize = 14,

                TextXAlignment =
                    Enum.TextXAlignment.Left
            })

            local Switch = Create("Frame", {

                Parent = Button,

                Size = UDim2.fromOffset(38, 20),

                Position = UDim2.new(
                    1,
                    -50,
                    0.5,
                    -10
                ),

                BackgroundColor3 =
                    Color3.fromRGB(45, 45, 45),

                BorderSizePixel = 0
            })

            AddCorner(Switch, 20)

            local Circle = Create("Frame", {

                Parent = Switch,

                Size = UDim2.fromOffset(16, 16),

                Position = UDim2.fromOffset(2, 2),

                BackgroundColor3 =
                    Color3.fromRGB(255, 255, 255),

                BorderSizePixel = 0
            })

            AddCorner(Circle, 20)

            local Object = {}

            local function Update()

                if Value then

                    TweenService:Create(
                        Switch,
                        TweenInfo.new(0.15),
                        {
                            BackgroundColor3 =
                                Library.Theme.Accent
                        }
                    ):Play()

                    TweenService:Create(
                        Circle,
                        TweenInfo.new(0.15),
                        {
                            Position =
                                UDim2.new(
                                    1,
                                    -18,
                                    0,
                                    2
                                ),

                            BackgroundColor3 =
                                Library.Theme.Background
                        }
                    ):Play()

                else

                    TweenService:Create(
                        Switch,
                        TweenInfo.new(0.15),
                        {
                            BackgroundColor3 =
                                Color3.fromRGB(
                                    45,
                                    45,
                                    45
                                )
                        }
                    ):Play()

                    TweenService:Create(
                        Circle,
                        TweenInfo.new(0.15),
                        {
                            Position =
                                UDim2.fromOffset(2, 2),

                            BackgroundColor3 =
                                Color3.fromRGB(
                                    255,
                                    255,
                                    255
                                )
                        }
                    ):Play()

                end

                if callback then
                    callback(Value)
                end

            end

            function Object:Set(value)

                Value = value == true

                Update()

            end

            function Object:Get()

                return Value

            end

            Button.MouseButton1Click:Connect(function()

                Value = not Value

                Update()

            end)

            Update()

            return Object
        end

        --=====================================================
        -- REGISTER TAB
        --=====================================================

        table.insert(self.Tabs, Tab)

        Button.MouseButton1Click:Connect(function()
            Tab:Show()
        end)

        if #self.Tabs == 1 then
            Tab:Show()
        end

        return Tab
    end

    --=========================================================
    -- WINDOW METHODS
    --=========================================================

    function Window:SetVisible(state)

        ScreenGui.Enabled = state == true

    end

    function Window:Toggle()

        ScreenGui.Enabled =
            not ScreenGui.Enabled

    end

    function Window:Destroy()

        ScreenGui:Destroy()

    end

    return Window
end

--=============================================================
-- RETURN LIBRARY
--=============================================================

return Library
