#!/opt/wrtnet/bin/lua

-- Created by yejq.jiaqiang@gmail.com
-- Simple Network startup Script for WRTNET
-- 2026/10/01

local sysutil    = require "sysutil"
local gfmt       = string.format

local g_argtab   = nil
local g_pidfile  = nil

local function netapp_init()
	local app = arg[1]
	if type(app) ~= "string" then
		io.stderr:write("Error, invalid application specified for netapp.\n")
		io.stderr:flush()
		return false
	end

	local ast = sysutil.stat(app)
	if not (ast and ast.isreg) then
		io.stderr:write(gfmt("Error, invalid network application: %s\n", app))
		io.stderr:flush()
		return false
	end

	local bname = sysutil.basename(app)
	if type(bname) ~= "string" or #bname == 0 then
		io.stderr:write(gfmt("Error, cannot determine executable file: %s\n", app))
		io.stderr:flush()
		return false
	end

	local idx, argtab = 1, {}
	while type(arg[idx]) == "string" do
		argtab[idx] = arg[idx]
		idx = idx + 1
	end
	g_argtab = argtab
	g_pidfile = "/tmp/.pidfile-" .. bname
	return true
end

local function netapp_start()
	local oldpid = sysutil.read(g_pidfile, 1024, nil, sysutil.OPT_RSTRIP)
	if type(oldpid) == "string" then -- kill existing process
		local proc = gfmt("/proc/%s/exe", oldpid)
		proc = sysutil.realpath(proc)
		if proc then
			io.stdout:write(gfmt("Killing process '%s' with PID %s ...\n", proc, oldpid))
			io.stdout:flush()
			sysutil.kill(tonumber(oldpid), sysutil.SIGKILL)
		end
	end

	-- lock the pid file
	local lockfd = sysutil.lockfile(g_pidfile, nil, 3000)
	if not lockfd then
		io.stderr:write(gfmt("Error, failed to lockfile: %s\n", g_pidfile))
		io.stderr:flush()
		return false
	end
	sysutil.truncate(lockfd, 0)
	sysutil.write(lockfd, gfmt("%d\n", sysutil.getpid()))
	if lockfd ~= 1024 then
		sysutil.dup(lockfd, 1024)
		sysutil.close(lockfd)
	end
	sysutil.cloexec(1024, false)

	-- now start the application
	sysutil.call(sysutil.OPT_EXEC, g_argtab)
	io.stderr:write(gfmt("Error, failed to run application: %s\n", g_argtab[1]))
	io.stderr:flush()
	return false
end

if not netapp_init() then os.exit(1) end
if not netapp_start() then os.exit(2) end
os.exit(0)
