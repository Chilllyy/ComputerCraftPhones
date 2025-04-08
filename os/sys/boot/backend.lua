local update = require("/os/sys/update/update")

local has_update = update.check()

function checkUpdate()
    return has_update
end

function update()
    if update.check() then
        update.update()
    end
end

return {checkUpdate = checkUpdate, update = update}