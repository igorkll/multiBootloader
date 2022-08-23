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

bootdrive.makeDirectory("/operatingSystems")

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
            if args[2] then

            end
        elseif method == "rename" then

        elseif method == "remove" then

        elseif method == "size" then
            
        elseif method == "exists" then

        elseif method == "isDirectory" then

        elseif method == "list" then

        elseif method == "lastModified" then

        elseif method == "" then

        end
    end
    local result = {pcall(invoke(address, method, unpack(args)))}
    if not result[1] then
        error(result[2], 0)
    end
    return unpack(result, 2)
end

local function ()
    
end

local function boot(name)
    
end

while true do
    
end