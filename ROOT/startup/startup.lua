if not fs.exists("/user") then
    fs.makeDir("/user")
end

shell.run("cd", "user")
shell.run("/os/sys/boot/start_boot.lua")