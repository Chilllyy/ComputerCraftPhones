local version_file = fs.open('/os/ver', 'r')
local version = version_file.readAll()

local user = "Chilllyy"
local repo = "ComputerCraftPhones"
local branch = settings.get("upd_branch") or "stable"
local url_template = "https://api.github.com/repos/" .. user .. "/" .. repo .. "/"

function check()
    local url = "https://raw.githubusercontent.com/" .. user .. "/" .. repo .. "/" .. branch .. "/os/ver"

    local resp = http.get(url)

    local cloud_version = tonumber(resp.readAll())
    local local_version = tonumber(version)
    return cloud_version > local_version
end

function update()
    fs.delete("/tmp/upd")

    delete("/startup.lua")
    fs.makeDir("/startup")
    fs.copy("/os/sys/update/startup.lua", "startup/install.lua")
    fs.copy("/os/lib/git.lua", "/startup/git.lua")
    delete("/os")
    os.sleep(2)
    os.reboot()
end

function delete(path)
    if fs.exists(path) then
        fs.delete(path)
        return true
    else
        return false
    end
end

return {check = check, update = update}
