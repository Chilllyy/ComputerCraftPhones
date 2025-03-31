local update = require("/os/sys/update")

if update.check() then
    print("Update found, downloading now!")
    update.update()
else
    print("No Update Found")
end