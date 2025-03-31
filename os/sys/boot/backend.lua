update = require("../update")

if update.check() then
    print("Update found, downloading now!")
    update.update()
end