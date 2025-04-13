function init()
    fs.makeDir('/os/log/')
end

function log_error(msg)
    local path = "/os/log/err.log"

    if not fs.exists(path) then fs.open(path, 'w').close() end
    local file = fs.open(path, 'a')
    file.writeLine(os.clock() .. ": " .. msg)
    file.close()
end

function log_sys(msg)
    local path = "/os/log/sys.log"
    if not fs.exists(path) then fs.open(path, 'w').close() end
    local file = fs.open(path, 'a')
    file.writeLine(os.clock() .. ": " .. msg)
    file.close()
end

init()

return {log_sys = log_sys, log_error = log_error}