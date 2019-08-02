description = [[
Detect uWSGI Server
]]

author = "Ricter Zheng"
license = "Same as https://github.com/RicterZ/My-NSE-Scripts/blob/master/LICENSE"
categories = {"default", "safe"}


portrule = function(host, port)
	return true
end


action = function(host, port)
	local client = nmap.new_socket()

	local catch = function()
		client:close()
		return false
	end

	local try = nmap.new_try(catch)

	try(client:connect(host, port))
	try(client:send("\x00+\x00\x00\x0e\x00REQUEST_METHOD\x03\x00GET\t\x00HTTP_HOST\t\x00127.0.0.1"))

	local ret = try(client:receive_lines(1))

	local status_code = "400"
	for word in string.gmatch(ret, "HTTP/1.%d (%d+)") do
		status_code = word
		break
	end

	try(client:close())

	if status_code ~= "400" then
		return "uWSGI returns code " .. status_code
	end

	return false

end

