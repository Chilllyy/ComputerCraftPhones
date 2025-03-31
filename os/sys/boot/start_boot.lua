function start_ui()
    shell.run("/os/sys/boot/ui.lua")
end

function start_backend()
    shell.run("/os/sys/boot/backend.lua")
end

parallel.waitForAll(start_ui, start_backend)