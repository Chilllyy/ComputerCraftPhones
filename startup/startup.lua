if not fs.exists("/user") then
    fs.makeDir("/user")
end

if not fs.exists("/apps") then
    fs.makeDir("/apps")
end

shell.run("cd", "user")
shell.run("/os/sys/boot/start_boot.lua")