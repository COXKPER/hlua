local socket = require("socket")
local VERSION = "1.0.0"

-- store HTTP response code (default 200)
local response_code = 200

-- parse query string / form data
local function parse_query(str)
    local params = {}
    if not str then return params end
    for key, val in string.gmatch(str, "([^&=?]+)=([^&=?]+)") do
        params[key] = val
    end
    return params
end

-- simple runtime API
local function make_runtime(query_params, post_params)
    return {
        response = function(self, code)
            response_code = tonumber(code) or 200
        end,
        getdata = function(self, key)
            return post_params[key] or query_params[key]
        end
    }
end

-- render HLUA file
local function render_hlua(path, query_params, post_params)
    local f = io.open(path, "r")
    if not f then return "<h1>404 Not Found</h1>" end
    local content = f:read("*a")
    f:close()

    local output = content:gsub("<hlua>(.-)</hlua>", function(code)
        -- load Lua code safely
        local chunk, err
        if _VERSION == "Lua 5.1" then
            chunk, err = loadstring(code)
        else
            chunk, err = load(code, "hlua", "t", {})
        end
        if not chunk then
            return "<pre>HLUA Error: " .. err .. "</pre>"
        end

        -- buffer for print()
        local buffer = {}

        -- sandbox environment
        local env = {
            print = function(...)
                local args = {...}
                for i=1,#args do args[i] = tostring(args[i]) end
                table.insert(buffer, table.concat(args, " "))
            end,
            runtime = make_runtime(query_params, post_params),

            -- safe standard libs
            tostring = tostring,
            tonumber = tonumber,
            pairs = pairs,
            ipairs = ipairs,
            string = string,
            math = math,
            table = table,
            os = { date = os.date, time = os.time }
        }

        if _VERSION == "Lua 5.1" then
            setfenv(chunk, env)
        else
            debug.setupvalue(chunk, 1, env)
        end

        local ok, res = pcall(chunk)
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
        response_code = 200 -- reset per request
        local method, path = request:match("^(%w+)%s+([^%s]+)")
        local query = path:match("%?(.*)")
        path = path:match("([^?]+)") or "/"

        -- read headers
        local headers = {}
        local line
        repeat
            line = client:receive("*l")
            if line and line ~= "" then
                local k,v = line:match("^(.-):%s*(.*)")
                if k and v then headers[k:lower()] = v end
            end
        until not line or line == ""

        -- read POST data if any
        local post_data = ""
        if method == "POST" and headers["content-length"] then
            post_data = client:receive(tonumber(headers["content-length"]))
        end

        local query_params = parse_query(query)
        local post_params  = parse_query(post_data)

        if path == "/" then
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
            body = render_hlua(fullpath, query_params, post_params)
        else
            local f = io.open(fullpath, "r")
            if f then
                body = f:read("*a")
                f:close()
            else
                response_code = 404
                body = "<h1>404 Not Found</h1>"
            end
        end

        local status = (response_code == 200 and "OK") or
                       (response_code == 400 and "Bad Request") or
                       (response_code == 404 and "Not Found") or
                       "Error"

        local header = "HTTP/1.1 " .. response_code .. " " .. status .. "\r\n" ..
                       "Content-Type: text/html\r\n" ..
                       "Server: Neon Lua Server/" .. VERSION .. "\r\n" ..
                       "Content-Length: " .. #body .. "\r\n" ..
                       "Connection: close\r\n" ..
                       "Date: " .. os.date("!%a, %d %b %Y %H:%M:%S GMT") .. "\r\n\r\n"

        client:send(header .. body)
    end
    client:close()
end
