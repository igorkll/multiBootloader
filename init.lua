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