local gpu = component.proxy((computer.getBootGpu() or component.list("gpu")()) or "")
local screen = computer.getBootScreen() or component.list("screen")()
local bootdrive = computer.getBootAddress()

if gpu and screen then
    if not gpu.getScreen() then
        gpu.bind(screen)
    end
    if gpu.maxDepth() > 1 then
        gpu.setDepth(1)
        gpu.setDepth(gpu.maxDepth())
    end
else
    gpu = nil
    screen = nil
end

------------------------------------

local path = "/operatingSystems"
bootdrive.makeDirectory(path)

local rx, ry = gpu.getResolution()

local invoke = component.invoke
local unpack = table.unpack
local error = error
local pcall = pcall

local function clear()
    gpu.setBackground(0)
    gpu.setForeground(0xFFFFFF)
    gpu.fill(1, 1, rx, ry, " ")
end

local function delay(time)
    local inTime = computer.uptime()
    while computer.uptime() - inTime < time do
        computer.pullSignal(time - (computer.uptime() - inTime))
    end
end

local function drawMainLogo()
    clear()
    gpu.fill(1, 1, rx, ry, "@")
    gpu.fill(2, 2, rx - 2, ry - 2, " ")
    gpu.setBackground(0xFFFFFF)
    gpu.setForeground(0)
    gpu.fill(2, 2, rx - 2, 1, " ")
    gpu.set(2, 2, "multi bootloader, use more one operating system!")
    gpu.setBackground(0)
    gpu.setForeground(0xFFFFFF)
end

if gpu then
    drawMainLogo()
end
computer.beep(784)
delay(0.25)
computer.beep(784)
delay(0.25)
computer.beep(784)
computer.beep(659)
computer.beep(1047)

------------------------------------

local function segments(path)
    local parts = {}
    for part in path:gmatch("[^\\/]+") do
        local current, up = part:find("^%.?%.$")
        if current then
            if up == 2 then
                table.remove(parts)
            end
        else
            table.insert(parts, part)
        end
    end
    return parts
end

local function findNode(path, create, resolve_links)
    checkArg(1, path, "string")
    local visited = {}
    local parts = segments(path)
    local ancestry = {}
    local node = mtab
    local index = 1
    while index <= #parts do
        local part = parts[index]
        ancestry[index] = node
        if not node.children[part] then
            local link_path = node.links[part]
            if link_path then
                if not resolve_links and #parts == index then
                    break
                end

                if visited[path] then
                    return nil, string.format("link cycle detected '%s'", path)
                end
                -- the previous parts need to be conserved in case of future ../.. link cuts
                visited[path] = index
                local pst_path = "/" .. table.concat(parts, "/", index + 1)
                local pre_path

                if link_path:match("^[^/]") then
                    pre_path = table.concat(parts, "/", 1, index - 1) .. "/"
                    local link_parts = segments(link_path)
                    local join_parts = segments(pre_path .. link_path)
                    local back = (index - 1 + #link_parts) - #join_parts
                    index = index - back
                    node = ancestry[index]
                else
                    pre_path = ""
                    index = 1
                    node = mtab
                end

                path = pre_path .. link_path .. pst_path
                parts = segments(path)
                part = nil -- skip node movement
            elseif create then
                node.children[part] = {name = part, parent = node, children = {}, links = {}}
            else
                break
            end
        end
        if part then
            node = node.children[part]
            index = index + 1
        end
    end

    local vnode, vrest = node, #parts >= index and table.concat(parts, "/", index)
    local rest = vrest
    while node and not node.fs do
        rest = rest and filesystem.concat(node.name, rest) or node.name
        node = node.parent
    end
    return node, rest, vnode, vrest
end

local function fs_canonical(path)
    local result = table.concat(segments(path), "/")
    if unicode.sub(path, 1, 1) == "/" then
        return "/" .. result
    else
        return result
    end
end

local function fs_concat(...)
    local set = table.pack(...)
    for index, value in ipairs(set) do
        checkArg(index, value, "string")
    end
    return fs_canonical(table.concat(set, "/"))
end

local newpath = "/"
local function repath(path)
    local lpath = ""
    for i = 1, unicode.len(path) do
        if unicode.sub(path, i, i) == "\\" then
            lpath = lpath .. "/"
        else
            lpath = lpath .. unicode.sub(path, i, i)
        end
    end
    path = lpath

    if unicode.sub(path, 1, 1) ~= "/" then
        path = "/" .. path
    end

    if unicode.sub(path, 1, unicode.len(newpath)) ~= newpath then
        return newpath
    end
    return path
end

function component.invoke(address, method, ...)
    local args = {...}
    if address == bootdrive.address then
        if method == "open" then
            args[1] = repath(fs_concat(newpath, args[1]))
        elseif method == "rename" then
            args[1] = repath(fs_concat(newpath, args[1]))
            args[2] = repath(fs_concat(newpath, args[2]))
        elseif method == "remove" then
            args[1] = repath(fs_concat(newpath, args[1]))
        elseif method == "size" then
            args[1] = repath(fs_concat(newpath, args[1]))
        elseif method == "exists" then
            args[1] = repath(fs_concat(newpath, args[1]))
        elseif method == "isDirectory" then
            args[1] = repath(fs_concat(newpath, args[1]))
        elseif method == "list" then
            args[1] = repath(fs_concat(newpath, args[1]))
        elseif method == "lastModified" then
            args[1] = repath(fs_concat(newpath, args[1]))
        elseif method == "makeDirectory" then
            args[1] = repath(fs_concat(newpath, args[1]))
        end
    end
    local result = {pcall(invoke(address, method, unpack(args)))}
    if not result[1] then
        error(result[2], 0)
    end
    return unpack(result, 2)
end

local function boot(name)
    newpath = fs_concat(newpath, name)

    local buffer = ""
    local file = bootdrive.open(newpath, "rb")
    while true do
        local data = bootdrive.read(file, math.huge)
        if not data then
            break
        end
        buffer = buffer .. data
    end

    local code = assert(load(buffer, "=init"))
    code()
end

local function menu(strs)
    local selected = 1

    drawMainLogo()

    local function draw()
        for i, v in ipairs(strs) do
            if selected == i then
                gpu.setBackground(0xFFFFFF)
                gpu.setForeground(0x000000)
            else
                gpu.setBackground(0x000000)
                gpu.setForeground(0xFFFFFF)
            end
            gpu.set(2, i + 2, v)
        end 
    end
    draw()

    while true do
        local eventData = {computer.pullSignal()}
        if eventData[1] == "key_down" then
            if eventData[4] == 28 then
                return strs[selected]
            elseif eventData[4] == 200 then
                if selected > 1 then
                    selected = selected - 1
                end
                draw()
            elseif eventData[4] == 208 then
                if selected < #strs then
                    selected = selected + 1
                end
                draw()
            end
        end
    end
end

local strs = {}
for i, v in ipairs(bootdrive.list(path) or {}) do
    table.insert(strs, fs_canonical(v))
end
table.sort(strs)
table.insert(strs, "shutdown")

local name = menu(strs)
if name == "shutdown" then
    computer.shutdown()
else
    boot(name)
end