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

local rx, ry = gpu.getResolution()
bootdrive.makeDirectory("/operatingSystems")
local invoke = component.invoke
local unpack = table.unpack
local error = error

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
    gpu.set(2, 2, "multi bootloader, use more one operating systems!")
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

function component.invoke(address, method, ...)
    local args = {...}
    if address == bootdrive.address then
        if method == "open" then
            
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
    local result = {pcall(invoke(address, method, table.unpack(args)))}
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