local openssl = require'openssl'
local csr,bio,ssl = openssl.csr,openssl.bio, openssl.ssl
local sslctx = require'sslctx'

host = arg[1] or "127.0.0.1"; --only ip
port = arg[2] or "8383";

local params = {
   mode = "client",
   protocol = "tlsv1",
   key = "luasec/certs/clientAkey.pem",
   certificate = "luasec/certs/clientA.pem",
   cafile = "luasec/certs/rootA.pem",
   verify = {"peer", "fail_if_no_peer_cert"},
   options = {"all", "no_sslv2"},
}

local ctx = assert(sslctx.new(params))
ctx:set_verify({'peer'},function(arg) 
--[[
      --do some check
      for k,v in pairs(arg) do
            print(k,v)
      end
--]]
      return true --return false will fail ssh handshake
end)

print(string.format('CONNECT to %s:%s with %s',host,port,ctx))

function mk_connection(host,port,i)
  local cli = assert(bio.connect(host..':'..port,true))
  if(cli) then
    S = ctx:ssl(cli,false)
    if(i%2==2) then
        assert(S:handshake())
    else
        assert(S:connect())
    end
    local b,r = S:getpeerverification()
    assert(b)
    --[[
    print(b)
    for k,v in pairs(r) do
      print('INDEX',k)
      for kk,vv in pairs(v) do
            print(kk,vv)
      end
    end
    --]]
    s = 'aaa'
    io.write('.')
    for j=1,100 do
          assert(S:write(s))
          assert(S:read())
    end
    S:shutdown()
    cli:shutdown()
    cli:close()
    cli = nil
    collectgarbage()
    
  end
  openssl.error(true)
end

for i=1,1000000 do
  mk_connection(host,port,i)
end
