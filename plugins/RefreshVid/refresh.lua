--#解决转发后令牌过期问题
--@author gaochitao 2013-12-14
local static = 1
local time = 0
local timeout = 20
local ext = 'html'
local httpcode = 301

-- uri like /v1_1/mBSg4/1107/112.html

local m,err = ngx.re.match(ngx.var.uri,"(v1_1)/([0-9a-zA-Z]+)/(?<tid>[0-9a-zA-Z]+)/(?<gid>[0-9a-zA-Z]+)")

if err == nil then
        local tid = m['tid']
        local gid = m['gid']
        time = ngx.now() - ngx.var.arg_t

        if static == 2 then
                ext = 'php'
        end

        if time < timeout then
                -- access
                local uri = "/" .. ext .. "/" .. tid .. "/" .. gid .. "." .. ext

                local res = ngx.location.capture(uri,{args = ngx.req.get_uri_args()})
                ngx.print(res.body)
                ngx.exit(res.status)
        else
                -- timeout & redirect
                local args = ngx.req.get_uri_args()

                local uri = "/v1" .. "/" .. tid .. "/" .. gid .. ".html?"

                for key, val in pairs(args) do
                        if (key == "vid" or key == "sign" or key == "t" or key == "" or val == "" or type(val) == "table") then
                        else
                                uri = uri  .. key .. "=" .. val .. "&"
                        end
                end
                return ngx.redirect(uri)
        end
else
        ngx.log(ngx.ERR,"mpstatic request error: ",err)
        return
end