local socket = require("socket")

local VERSION = "0.0.1-alpha"

-- simple function to process HLUA files
local function render_hlua(path)
    local f = io.open(path, "r")
    if not f then return "<h1>404 Not Found</h1>" end
    local content = f:read("*a")
    f:close()

    -- Replace <hlua> ... </hlua> with executed Lua code
    local output = content:gsub("<hlua>(.-)</hlua>", function(code)
        local chunk, err
if _VERSION == "Lua 5.1" then
    chunk, err = loadstring(code)
else
    chunk, err = load(code)
end

        if not chunk then
            return "<pre>HLUA Error: " .. err .. "</pre>"
        end
        -- capture print output
        local buffer = {}
        local function capture_print(...)
            local args = {...}
            for i=1,#args do
                args[i] = tostring(args[i])
            end
            table.insert(buffer, table.concat(args, "\t"))
        end
        local old_print = print
        print = capture_print
        local ok, res = pcall(chunk)
        print = old_print
        if not ok then
            return "<pre>HLUA Runtime Error: " .. res .. "</pre>"
        end
        if #buffer > 0 then
            return table.concat(buffer, "\n")
        elseif res then
            return tostring(res)
        else
            return ""
        end
    end)

    return output
end

-- start server
local server = assert(socket.bind("*", 8080))
print("Neon Lua Server/" .. VERSION .. " running at http://localhost:8080/")

while true do
    local client = server:accept()
    client:settimeout(1)

    local request = client:receive("*l")
    if request then
        local method, path = request:match("^(%w+)%s+([^%s]+)")
        if path == "/" then
            -- fallback priority: index.hlua → index.html
            if io.open("index.hlua") then
                path = "/index.hlua"
            else
                path = "/index.html"
            end
        end

        local ext = path:match("%.([%w]+)$") or ""
        local fullpath = "." .. path

        local body = ""
        if ext == "hlua" then
            body = render_hlua(fullpath)
        else
            local f = io.open(fullpath, "r")
            if f then
                body = f:read("*a")
                f:close()
            else
                body = "<h1>404 Not Found</h1>"
            end
        end

        local header = "HTTP/1.1 200 OK\r\n" ..
                       "Content-Type: text/html\r\n" ..
                       "Server: Neon Lua Server/" .. VERSION .. "\r\n" ..
                       "Content-Length: " .. #body .. "\r\n\r\n"
        client:send(header .. body)
    end
    client:close()
end
