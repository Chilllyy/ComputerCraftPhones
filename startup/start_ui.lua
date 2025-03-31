if not fs.exists("/user") then
    fs.makeDir("/user")
end

shell.run("cd", "user")
shell.run("/apps/ui")