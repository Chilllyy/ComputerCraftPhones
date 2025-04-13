function getWebTable(user, repo, branch, file) 
    local url = string.format("https://raw.githubusercontent.com/%s/%s/%s/%s", user, repo, branch, file)

    return __getTable(url)
end


function __getTable(url)
    local response = http.get(url)
    local data = response.readAll()
    return textutils.unserializeJSON(data)
end

function __getRaw(url)
    local response = http.get(url)
    return response.readAll()
end

function getWebRaw(user, repo, branch, file)
    local url = string.format("https://raw.githubusercontent.com/%s/%s/%s/%s", user, repo, branch, file)

    return __getRaw(url)
end

function clone(user, repo, branch, folder)
    local url = string.format("https://api.github.com/repos/%s/%s/contents?ref=%s", user, repo, branch)

    __clone(url, folder)
end

function __clone(url, folder)
    fs.makeDir(folder)
    local data = __getTable(url)
    for i,v in ipairs(data) do
        if v.type == "dir" then
            local new_url = v.url
            local new_dir = folder .. "/" .. v.name
            __clone(new_url, new_dir)
        elseif v.type == "file" then
            local dl_url = v.download_url
            local raw = __getRaw(dl_url)
            local file = folder .. "/" .. v.name
            local f = fs.open(file, "w")
            f.write(raw)
            f.close()
        end
    end
end

return {clone = clone, getWebTable = getWebTable, getWebRaw = getWebRaw}