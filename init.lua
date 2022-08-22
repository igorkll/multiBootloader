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

------------------------------------

local rx, ry = gpu.getResolution()

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

------------------------------------

if gpu then
    clear()
    gpu.fill(1, 1, rx, ry, "+")
    gpu.fill(2, 2, rx - 2, ry - 2, "+")
end
computer.beep(784)
delay(0.25)
computer.beep(784)
delay(0.25)
computer.beep(784)
computer.beep(659)
computer.beep(1047)