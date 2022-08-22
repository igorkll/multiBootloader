local gpu = component.proxy((computer.getBootGpu() or component.list("gpu")()) or "")
local screen = computer.getBootScreen() or component.list("screen")()

if gpu and screen then
    if not gpu.getScreen() then
        gpu.bind(screen)
    end
end

------------------------------------