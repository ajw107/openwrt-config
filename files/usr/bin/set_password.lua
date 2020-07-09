local sys = require "luci.sys"

function set_password(user,pass)
    sys.user.setpasswd(user,pass)
    print(0)
    return
end

if #arg == 2
then
    set_password(...)
else
    print(1)
end

