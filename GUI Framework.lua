--// =========================================================
--// BlackUI Framework (refactored)
--// Standalone Luau UI library
--// =========================================================

local Library = {}
Library.Version = "1.1.0"

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

	SwitchOff = Color3.fromRGB(45, 45, 45),

	Corner = 10,
	TweenTime = 0.15,
}

local Theme = Library.Theme

--=============================================================
-- UTILITY
--=============================================================

-- Creates an instance, applies properties, then parents it LAST
-- (setting Parent first causes needless re-layout/replication work).
local function Create(className, properties, children)
	local object = Instance.new(className)
	local parent

	for property, value in pairs(properties or {}) do
		if property == "Parent" then
			parent = value
		else
			object[property] = value
		end
	end

	for _, child in ipairs(children or {}) do
		child.Parent = object
	end

	object.Parent = parent
	return object
end

local function AddCorner(object, radius)
	return Create("UICorner", {
		CornerRadius = UDim.new(0, radius or Theme.Corner),
		Parent = object,
	})
end

local function AddStroke(object, color)
	return Create("UIStroke", {
		Color = color or Theme.Border,
		Thickness = 1,
		-- FIX: without this, a UIStroke on a TextButton/TextLabel outlines
		-- the TEXT instead of the frame border.
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Parent = object,
	})
end

local function AddPadding(object, top, right, bottom, left)
	right = right or top
	bottom = bottom or top
	left = left or right

	return Create("UIPadding", {
		PaddingTop = UDim.new(0, top),
		PaddingRight = UDim.new(0, right),
		PaddingBottom = UDim.new(0, bottom),
		PaddingLeft = UDim.new(0, left),
		Parent = object,
	})
end

local function Tween(object, properties, duration)
	local tween = TweenService:Create(
		object,
		TweenInfo.new(duration or Theme.TweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		properties
	)
	tween:Play()
	return tween
end

-- Sets properties instantly or via tween.
local function Apply(object, properties, animate)
	if animate then
		Tween(object, properties)
	else
		for property, value in pairs(properties) do
			object[property] = value
		end
	end
end

-- User callbacks must never be able to break the UI.
local function SafeCall(callback, ...)
	if type(callback) ~= "function" then
		return
	end

	local ok, err = pcall(callback, ...)
	if not ok then
		warn("[BlackUI] Callback error: " .. tostring(err))
	end
end

-- Picks a sensible parent for the ScreenGui.
local function ResolveGuiParent(custom)
	if custom then
		return custom
	end

	if typeof(gethui) == "function" then
		local ok, result = pcall(gethui)
		if ok and typeof(result) == "Instance" then
			return result
		end
	end

	return LocalPlayer:WaitForChild("PlayerGui")
end

--=============================================================
-- MAID (connection / instance cleanup)
--=============================================================

local Maid = {}
Maid.__index = Maid

function Maid.new()
	return setmetatable({ _tasks = {} }, Maid)
end

function Maid:Give(item)
	table.insert(self._tasks, item)
	return item
end

function Maid:Clean()
	for _, item in ipairs(self._tasks) do
		local kind = typeof(item)

		if kind == "RBXScriptConnection" then
			item:Disconnect()
		elseif kind == "Instance" then
			item:Destroy()
		elseif kind == "function" then
			pcall(item)
		end
	end

	table.clear(self._tasks)
end

--=============================================================
-- DRAG
--=============================================================

local function MakeDraggable(frame, handle, maid)
	local dragging = false
	local dragInput
	local dragStart
	local startPosition

	local function isPointer(input)
		return input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
	end

	maid:Give(handle.InputBegan:Connect(function(input)
		if not isPointer(input) then
			return
		end

		dragging = true
		dragStart = input.Position
		startPosition = frame.Position

		local endedConnection
		endedConnection = input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
				endedConnection:Disconnect()
			end
		end)
	end))

	maid:Give(handle.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end))

	maid:Give(UserInputService.InputChanged:Connect(function(input)
		if not dragging or input ~= dragInput then
			return
		end

		local delta = input.Position - dragStart

		frame.Position = UDim2.new(
			startPosition.X.Scale,
			startPosition.X.Offset + delta.X,
			startPosition.Y.Scale,
			startPosition.Y.Offset + delta.Y
		)
	end))
end

--=============================================================
-- ELEMENT BASE CLASS
--=============================================================

local Element = {}
Element.__index = Element

function Element.new(instance)
	return setmetatable({ Instance = instance }, Element)
end

function Element:SetText(text)
	self.Instance.Text = tostring(text)
end

function Element:SetVisible(visible)
	self.Instance.Visible = visible == true
end

function Element:Destroy()
	self.Instance:Destroy()
end

--=============================================================
-- TOGGLE CLASS
--=============================================================

local Toggle = setmetatable({}, { __index = Element })
Toggle.__index = Toggle

function Toggle:_Render(animate)
	local on = self.Value

	Apply(self._switch, {
		BackgroundColor3 = on and Theme.Accent or Theme.SwitchOff,
	}, animate)

	Apply(self._circle, {
		Position = on and UDim2.new(1, -18, 0, 2) or UDim2.fromOffset(2, 2),
		BackgroundColor3 = on and Theme.Background or Theme.Text,
	}, animate)
end

-- silent = true skips the callback
function Toggle:Set(value, silent)
	value = value == true

	if value == self.Value then
		return
	end

	self.Value = value
	self:_Render(true)

	if not silent then
		SafeCall(self._callback, value)
	end
end

function Toggle:Get()
	return self.Value
end

function Toggle:SetText(text)
	self._label.Text = tostring(text)
end

--=============================================================
-- TAB CLASS
--=============================================================

local Tab = {}
Tab.__index = Tab

function Tab:_NextOrder()
	self._order += 1
	return self._order
end

function Tab:_SetActive(active)
	self.Active = active
	self.Page.Visible = active

	Tween(self.Button, {
		BackgroundColor3 = active and Theme.Accent or Theme.Tertiary,
		TextColor3 = active and Theme.Background or Theme.SubText,
	})
end

function Tab:Show()
	self.Window:SelectTab(self)
end

function Tab:AddSection(text)
	local label = Create("TextLabel", {
		Name = "Section",
		Parent = self.Page,
		LayoutOrder = self:_NextOrder(),

		Size = UDim2.new(1, 0, 0, 24),
		BackgroundTransparency = 1,

		Text = tostring(text),
		TextColor3 = Theme.SubText,
		Font = Enum.Font.GothamBold,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
	})

	return Element.new(label)
end

function Tab:AddLabel(text)
	local label = Create("TextLabel", {
		Name = "Label",
		Parent = self.Page,
		LayoutOrder = self:_NextOrder(),

		-- FIX: fixed 35px height clipped long wrapped text; grow with content.
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,

		Text = tostring(text),
		TextColor3 = Theme.SubText,
		Font = Enum.Font.Gotham,
		TextSize = 13,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
	})

	return Element.new(label)
end

function Tab:AddButton(text, callback)
	local button = Create("TextButton", {
		Name = "Button",
		Parent = self.Page,
		LayoutOrder = self:_NextOrder(),

		Size = UDim2.new(1, 0, 0, 42),
		BackgroundColor3 = Theme.Secondary,
		BorderSizePixel = 0,
		AutoButtonColor = false,

		Text = tostring(text),
		TextColor3 = Theme.Text,
		Font = Enum.Font.GothamBold,
		TextSize = 14,
	})

	AddCorner(button, 9)
	AddStroke(button)

	button.MouseEnter:Connect(function()
		Tween(button, { BackgroundColor3 = Theme.Tertiary })
	end)

	button.MouseLeave:Connect(function()
		Tween(button, { BackgroundColor3 = Theme.Secondary })
	end)

	button.MouseButton1Click:Connect(function()
		SafeCall(callback)
	end)

	return Element.new(button)
end

function Tab:AddToggle(text, default, callback)
	local row = Create("TextButton", {
		Name = "Toggle",
		Parent = self.Page,
		LayoutOrder = self:_NextOrder(),

		Size = UDim2.new(1, 0, 0, 45),
		BackgroundColor3 = Theme.Secondary,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Text = "",
	})

	AddCorner(row, 9)
	AddStroke(row)

	local label = Create("TextLabel", {
		Parent = row,

		Size = UDim2.new(1, -70, 1, 0),
		Position = UDim2.fromOffset(15, 0),
		BackgroundTransparency = 1,

		Text = tostring(text),
		TextColor3 = Theme.Text,
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
	})

	local switch = Create("Frame", {
		Name = "Switch",
		Parent = row,

		AnchorPoint = Vector2.new(1, 0.5),
		Size = UDim2.fromOffset(38, 20),
		Position = UDim2.new(1, -12, 0.5, 0),

		BackgroundColor3 = Theme.SwitchOff,
		BorderSizePixel = 0,
	})

	AddCorner(switch, 20)

	local circle = Create("Frame", {
		Name = "Circle",
		Parent = switch,

		Size = UDim2.fromOffset(16, 16),
		Position = UDim2.fromOffset(2, 2),

		BackgroundColor3 = Theme.Text,
		BorderSizePixel = 0,
	})

	AddCorner(circle, 20)

	local object = setmetatable({
		Instance = row,
		Value = default == true,

		_label = label,
		_switch = switch,
		_circle = circle,
		_callback = callback,
	}, Toggle)

	object:_Render(false)

	row.MouseButton1Click:Connect(function()
		object:Set(not object.Value)
	end)

	-- Preserves the original behaviour (callback fires once with the
	-- initial value) but deferred so `object` exists for the caller first.
	task.defer(SafeCall, callback, object.Value)

	return object
end

--=============================================================
-- WINDOW CLASS
--=============================================================

local Window = {}
Window.__index = Window

function Window:CreateTab(name)
	name = tostring(name)

	local button = Create("TextButton", {
		Name = name .. "_Button",
		Parent = self.Sidebar,
		LayoutOrder = #self.Tabs + 1,

		Size = UDim2.new(1, 0, 0, 38),
		BackgroundColor3 = Theme.Tertiary,
		BorderSizePixel = 0,
		AutoButtonColor = false,

		Text = name,
		TextColor3 = Theme.SubText,
		Font = Enum.Font.GothamBold,
		TextSize = 13,
		TextTruncate = Enum.TextTruncate.AtEnd,
	})

	AddCorner(button, 8)

	local page = Create("ScrollingFrame", {
		Name = name .. "_Page",
		Parent = self.Content,

		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Visible = false,

		CanvasSize = UDim2.new(),
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = Theme.Text,
		ScrollingDirection = Enum.ScrollingDirection.Y,
	})

	AddPadding(page, 12)

	local layout = Create("UIListLayout", {
		Parent = page,
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		page.CanvasSize = UDim2.fromOffset(0, layout.AbsoluteContentSize.Y + 24)
	end)

	local tab = setmetatable({
		Name = name,
		Window = self,
		Button = button,
		Page = page,
		Active = false,
		_order = 0,
	}, Tab)

	button.MouseEnter:Connect(function()
		if not tab.Active then
			Tween(button, { BackgroundColor3 = Theme.Border })
		end
	end)

	button.MouseLeave:Connect(function()
		if not tab.Active then
			Tween(button, { BackgroundColor3 = Theme.Tertiary })
		end
	end)

	button.MouseButton1Click:Connect(function()
		self:SelectTab(tab)
	end)

	table.insert(self.Tabs, tab)

	if #self.Tabs == 1 then
		self:SelectTab(tab)
	end

	return tab
end

function Window:SelectTab(tab)
	if self.CurrentTab == tab then
		return
	end

	if self.CurrentTab then
		self.CurrentTab:_SetActive(false)
	end

	self.CurrentTab = tab
	tab:_SetActive(true)
end

function Window:SetVisible(visible)
	self.Main.Visible = visible == true
end

function Window:Toggle()
	self.Main.Visible = not self.Main.Visible
end

function Window:Destroy()
	if self._destroyed then
		return
	end

	self._destroyed = true
	self.Maid:Clean()
	self.Gui:Destroy()
end

--=============================================================
-- LIBRARY: CREATE WINDOW
--=============================================================

--[[
	options:
		Title     string
		Size      UDim2
		Parent    Instance   (defaults to gethui() or PlayerGui)
		ToggleKey Enum.KeyCode | false   (default RightShift, false = disabled)
]]
function Library:CreateWindow(options)
	options = options or {}

	local title = options.Title or "BlackUI"
	local size = options.Size or UDim2.fromOffset(650, 450)
	local toggleKey = options.ToggleKey
	if toggleKey == nil then
		toggleKey = Enum.KeyCode.RightShift
	end

	local guiParent = ResolveGuiParent(options.Parent)

	-- FIX: creating a second window used to stack a duplicate "BlackUI" GUI.
	local existing = guiParent:FindFirstChild("BlackUI")
	if existing then
		existing:Destroy()
	end

	local maid = Maid.new()

	local gui = Create("ScreenGui", {
		Name = "BlackUI",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Parent = guiParent,
	})

	-- FIX: Main uses the Secondary colour and Content is an inset rounded
	-- panel. Previously the square TopBar/Sidebar poked out of Main's
	-- rounded corners.
	local main = Create("Frame", {
		Name = "Main",
		Parent = gui,

		Size = size,
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),

		BackgroundColor3 = Theme.Secondary,
		BorderSizePixel = 0,
	})

	AddCorner(main, 14)
	AddStroke(main)

	local topBar = Create("Frame", {
		Name = "TopBar",
		Parent = main,

		Size = UDim2.new(1, 0, 0, 50),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	})

	Create("TextLabel", {
		Name = "Title",
		Parent = topBar,

		Size = UDim2.new(1, -30, 1, 0),
		Position = UDim2.fromOffset(15, 0),
		BackgroundTransparency = 1,

		Text = title,
		TextColor3 = Theme.Text,
		Font = Enum.Font.GothamBold,
		TextSize = 18,
		TextXAlignment = Enum.TextXAlignment.Left,
	})

	local sidebar = Create("Frame", {
		Name = "Sidebar",
		Parent = main,

		Size = UDim2.new(0, 150, 1, -50),
		Position = UDim2.fromOffset(0, 50),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	})

	AddPadding(sidebar, 8, 8, 8, 10)

	Create("UIListLayout", {
		Parent = sidebar,
		Padding = UDim.new(0, 7),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	local content = Create("Frame", {
		Name = "Content",
		Parent = main,

		Size = UDim2.new(1, -158, 1, -58),
		Position = UDim2.fromOffset(150, 50),

		BackgroundColor3 = Theme.Background,
		BorderSizePixel = 0,
		ClipsDescendants = true,
	})

	AddCorner(content, 12)

	MakeDraggable(main, topBar, maid)

	local window = setmetatable({
		Gui = gui,
		Main = main,
		TopBar = topBar,
		Sidebar = sidebar,
		Content = content,

		Tabs = {},
		CurrentTab = nil,
		Maid = maid,
	}, Window)

	if toggleKey then
		maid:Give(UserInputService.InputBegan:Connect(function(input, processed)
			if not processed and input.KeyCode == toggleKey then
				window:Toggle()
			end
		end))
	end

	return window
end

--=============================================================
-- RETURN LIBRARY
--=============================================================

return Library
