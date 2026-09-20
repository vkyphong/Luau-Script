# BlackUI – Hướng dẫn sử dụng

Thư viện UI tối giản (giao diện đen) cho Roblox, viết bằng Luau. Hỗ trợ chuột và cảm ứng, có animation, tab, nút, toggle, label và section.

---

## Mục lục

1. [Cài đặt / Nạp thư viện](#1-cài-đặt--nạp-thư-viện)
2. [Bắt đầu nhanh](#2-bắt-đầu-nhanh)
3. [Window](#3-window)
4. [Tab](#4-tab)
5. [Các thành phần (Elements)](#5-các-thành-phần-elements)
6. [Theme (đổi màu)](#6-theme-đổi-màu)
7. [Ví dụ đầy đủ](#7-ví-dụ-đầy-đủ)
8. [Lưu ý quan trọng](#8-lưu-ý-quan-trọng)

---

## 1. Cài đặt / Nạp thư viện

Lưu file `BlackUI.lua` rồi nạp bằng một trong các cách sau:

```lua
-- Cách 1: đọc từ file trong workspace của executor
local Library = loadstring(readfile("BlackUI.lua"))()

-- Cách 2: nạp từ link raw (thay bằng link của bạn)
local Library = loadstring(game:HttpGet("LINK_RAW_CUA_BAN"))()

-- Cách 3: dùng như ModuleScript
local Library = require(path.to.BlackUI)
```

---

## 2. Bắt đầu nhanh

```lua
local Library = loadstring(readfile("BlackUI.lua"))()

local Window = Library:CreateWindow({
    Title = "BlackUI Demo",
})

local Tab = Window:CreateTab("Main")

Tab:AddSection("General")

Tab:AddButton("Click me", function()
    print("Đã bấm!")
end)

Tab:AddToggle("Feature", false, function(value)
    print("Toggle:", value)
end)
```

Tab đầu tiên được tạo sẽ tự động được chọn.

---

## 3. Window

### `Library:CreateWindow(options)`

Tạo cửa sổ chính.

| Option      | Kiểu                     | Mặc định                 | Mô tả                                              |
|-------------|--------------------------|--------------------------|----------------------------------------------------|
| `Title`     | `string`                 | `"BlackUI"`              | Tiêu đề hiển thị trên thanh trên cùng              |
| `Size`      | `UDim2`                  | `UDim2.fromOffset(650, 450)` | Kích thước cửa sổ                              |
| `Parent`    | `Instance`               | `gethui()` hoặc `PlayerGui` | Nơi đặt ScreenGui                               |
| `ToggleKey` | `Enum.KeyCode` hoặc `false` | `Enum.KeyCode.RightShift` | Phím ẩn/hiện UI. Đặt `false` để tắt              |

```lua
local Window = Library:CreateWindow({
    Title = "My Script",
    Size = UDim2.fromOffset(600, 400),
    ToggleKey = Enum.KeyCode.RightControl,
})
```

> Nếu đã có một cửa sổ `BlackUI` trong cùng `Parent`, nó sẽ bị xoá trước khi tạo cửa sổ mới (tránh trùng UI khi chạy script nhiều lần).

### Phương thức của Window

| Phương thức                | Mô tả                                  |
|----------------------------|----------------------------------------|
| `Window:CreateTab(name)`   | Tạo tab mới, trả về đối tượng `Tab`    |
| `Window:SelectTab(tab)`    | Chuyển sang tab chỉ định               |
| `Window:Toggle()`          | Đảo trạng thái ẩn/hiện                 |
| `Window:SetVisible(bool)`  | Ẩn/hiện cửa sổ                         |
| `Window:Destroy()`         | Xoá UI và ngắt toàn bộ kết nối         |

### Thuộc tính của Window

| Thuộc tính          | Mô tả                                   |
|---------------------|-----------------------------------------|
| `Window.Gui`        | `ScreenGui`                             |
| `Window.Main`       | Frame chính                             |
| `Window.TopBar`     | Thanh tiêu đề (dùng để kéo cửa sổ)      |
| `Window.Sidebar`    | Khung chứa nút tab                      |
| `Window.Content`    | Khung chứa các trang                    |
| `Window.Tabs`       | Danh sách các tab đã tạo                |
| `Window.CurrentTab` | Tab đang được chọn                      |

Kéo thanh tiêu đề để di chuyển cửa sổ (hỗ trợ cả chuột và cảm ứng).

---

## 4. Tab

### `Window:CreateTab(name)`

```lua
local MainTab = Window:CreateTab("Main")
local SettingsTab = Window:CreateTab("Settings")
```

### Phương thức của Tab

| Phương thức                          | Mô tả                                |
|--------------------------------------|--------------------------------------|
| `Tab:Show()`                         | Chuyển sang tab này                  |
| `Tab:AddSection(text)`               | Thêm tiêu đề nhóm                    |
| `Tab:AddLabel(text)`                 | Thêm đoạn chữ (tự xuống dòng)        |
| `Tab:AddButton(text, callback)`      | Thêm nút bấm                         |
| `Tab:AddToggle(text, default, callback)` | Thêm công tắc bật/tắt            |

### Thuộc tính của Tab

`Tab.Name`, `Tab.Window`, `Tab.Button`, `Tab.Page`, `Tab.Active`

---

## 5. Các thành phần (Elements)

Mọi thành phần đều trả về một **element object**, có các thành viên chung:

| Thành viên             | Mô tả                                       |
|------------------------|---------------------------------------------|
| `element.Instance`     | Instance Roblox gốc                         |
| `element:SetText(text)`| Đổi chữ hiển thị                            |
| `element:SetVisible(b)`| Ẩn/hiện thành phần                          |
| `element:Destroy()`    | Xoá thành phần                              |

### Section

```lua
local section = Tab:AddSection("Combat")
section:SetText("Combat Settings")
```

### Label

```lua
local label = Tab:AddLabel("Đây là một đoạn mô tả dài, sẽ tự động xuống dòng và tự giãn chiều cao.")
label:SetText("Nội dung mới")
```

### Button

```lua
local btn = Tab:AddButton("Reset", function()
    print("Reset!")
end)

btn:SetText("Reset All")
```

Callback được bọc trong `pcall`, nên nếu callback bị lỗi thì UI vẫn hoạt động bình thường (lỗi sẽ được `warn` ra console).

### Toggle

```lua
local toggle = Tab:AddToggle("Auto Farm", false, function(value)
    print("Auto Farm:", value)
end)
```

| Phương thức                  | Mô tả                                                        |
|------------------------------|--------------------------------------------------------------|
| `toggle:Set(value, silent)`  | Đặt giá trị. `silent = true` thì **không** gọi callback      |
| `toggle:Get()`               | Lấy giá trị hiện tại (`true`/`false`)                        |
| `toggle:SetText(text)`       | Đổi nhãn                                                     |
| `toggle.Value`               | Giá trị hiện tại                                             |

```lua
toggle:Set(true)          -- bật, có gọi callback
toggle:Set(false, true)   -- tắt, không gọi callback
print(toggle:Get())       --> false
```

Ghi chú:
- Callback được gọi **một lần** khi tạo toggle, với giá trị mặc định (chạy trễ một nhịp để biến `toggle` đã tồn tại).
- `Set` với giá trị **không đổi** sẽ không làm gì và không gọi callback.

---

## 6. Theme (đổi màu)

Theme nằm ở `Library.Theme`. Hãy chỉnh **trước khi** gọi `CreateWindow`, vì màu chỉ được đọc lúc tạo UI.

```lua
local Library = loadstring(readfile("BlackUI.lua"))()

Library.Theme.Accent = Color3.fromRGB(0, 170, 255)
Library.Theme.Background = Color3.fromRGB(10, 10, 20)

local Window = Library:CreateWindow({ Title = "Blue Theme" })
```

| Khoá         | Ý nghĩa                                   | Mặc định            |
|--------------|-------------------------------------------|---------------------|
| `Background` | Nền vùng nội dung                         | `12, 12, 12`        |
| `Secondary`  | Nền cửa sổ, nút, toggle                   | `18, 18, 18`        |
| `Tertiary`   | Nút tab chưa chọn, hover                  | `25, 25, 25`        |
| `Text`       | Màu chữ chính                             | `255, 255, 255`     |
| `SubText`    | Màu chữ phụ                               | `160, 160, 160`     |
| `Accent`     | Màu nhấn (tab đang chọn, toggle bật)      | `255, 255, 255`     |
| `Border`     | Viền                                      | `40, 40, 40`        |
| `SwitchOff`  | Màu công tắc khi tắt                      | `45, 45, 45`        |
| `Corner`     | Bo góc mặc định (pixel)                   | `10`                |
| `TweenTime`  | Thời gian animation (giây)                | `0.15`              |

> Hãy sửa từng khoá (`Library.Theme.Accent = ...`), **đừng** gán lại cả bảng `Library.Theme = {...}`, vì thư viện giữ tham chiếu tới bảng gốc.

---

## 7. Ví dụ đầy đủ

```lua
local Library = loadstring(readfile("BlackUI.lua"))()

-- Tuỳ chỉnh theme (tuỳ chọn)
Library.Theme.Accent = Color3.fromRGB(0, 200, 120)

local Window = Library:CreateWindow({
    Title = "Demo Hub",
    ToggleKey = Enum.KeyCode.RightShift,
})

-- Tab Main
local Main = Window:CreateTab("Main")

Main:AddSection("Actions")

Main:AddButton("Say Hello", function()
    print("Hello!")
end)

local farm = Main:AddToggle("Auto Farm", false, function(state)
    print("Auto Farm ->", state)
end)

Main:AddLabel("Nhấn RightShift để ẩn/hiện menu.")

-- Tab Settings
local Settings = Window:CreateTab("Settings")

Settings:AddSection("Danger Zone")

Settings:AddButton("Đóng UI", function()
    Window:Destroy()
end)

-- Điều khiển bằng code
task.delay(3, function()
    farm:Set(true)      -- tự bật sau 3 giây
end)
```

---

## 8. Lưu ý quan trọng

- **Thay đổi so với bản cũ:** `AddSection`, `AddLabel`, `AddButton` giờ trả về *element object* thay vì Instance thô. Dùng `.Instance` nếu cần Instance gốc.
- **Ngắt kết nối:** luôn gọi `Window:Destroy()` khi muốn gỡ UI để dọn sạch các kết nối input.
- **Parent mặc định:** dùng `gethui()` nếu môi trường có hỗ trợ, nếu không thì dùng `PlayerGui`. Truyền `Parent` để ghi đè.
- **Theme:** đổi sau khi đã tạo cửa sổ sẽ **không** cập nhật UI đang hiển thị.
- **Tên tab trùng nhau** vẫn chạy được nhưng nên đặt tên khác nhau cho dễ quản lý.
