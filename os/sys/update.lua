version = require("../ver")

local user = "Chilllyy"
local repo = "ComputerCraftPhones"
local branch = settings.get("upd_branch") or "stable"
local url_template = "https://api.github.com/repos/" .. user .. "/" .. repo .. "/"

function getWebTable(url)
    local response = http.get(url)
    local data = response.readAll()
    return textutils.unserializeJSON(response.readAll())
end

function getWebRaw(url)
    local response = http.get(url)
    return response.readAll()
end

function check()
    local url = url_template .. "releases/latest"
    local table = getWebTable(url)
    local cloud_version = table.tag_name
    local local_version = version.getVersion()
    return cloud_version > local_version
end

function clone(url, folder)
    fs.makeDir(folder)
    local response = http.get(url)
    local data = textutils.unserializeJSON(response.readAll())
    for i,v in ipairs(data) do
        if v.type == "dir" then
            local new_url = v.url
            local new_dir = folder .. "/" .. v.name
            clone(new_url, new_dir)
        elseif v.type == "file" then
            local dl_url = v.download_url
            local dl_r = http.get(dl_url)
            local dl_d = dl_r.readAll()
            local file = folder .. "/" .. v.name
            local f = fs.open(file, "w")
            f.write(dl_d)
            f.close()
        end
    end
end

function update()
    local url = url_template .. "contents?ref=" .. branch
    local folder = "/tmp/upd"

    fs.delete(folder)

    pcall(clone(url, folder))
end

return {check = check, update = update}