#!/opt/wrtnet/bin/lua

-- Created by yejq.jiaqiang@gmail.com
-- Simple Network startup Script for WRTNET
-- 2026/10/01

local sysutil    = require "sysutil"
local gfmt       = string.format

local g_prefix   = "/opt/wrtnet"

local function symlink(src, dst)
	if not sysutil.access(src) then
		io.stderr:write(gfmt("Error, source file/directory not found: %s\n", src))
		io.stderr:flush()
		return false
	end

	if src == dst then
		io.stderr:write(gfmt("Error, invalid argument for symlink: %s\n", src))
		io.stderr:flush()
		return false
	end

	local spath = sysutil.readlink(dst)
	if spath == src then return true end

	if spath then
		io.stdout:write(gfmt("INFO: removing conflicting file: %s ...\n", dst))
		io.stdout:flush()
		sysutil.unlink(dst)
	end
	io.stdout:write(gfmt("INFO: symlinking '%s' as '%s' ...\n", src, dst))
	io.stdout:flush()
	if not sysutil.symlink(src, dst) then
		io.stderr:write(gfmt("Error, symlink '%s' as '%s' has failed.\n", src, dst))
		io.stderr:flush()
		return false
	end
	return true
end

local g_symlinks = {
	{ source = g_prefix .. "/lib/wifi",                dest = "/lib/wifi", },
	{ source = g_prefix .. "/lib/netifd",              dest = "/lib/netifd", },
	{ source = g_prefix .. "/lib/ucode",               dest = "/lib/ucode", },
	{ source = g_prefix .. "/share/libubox",           dest = "/usr/share/libubox", },
	{ source = g_prefix .. "/sbin/wifi",               dest = "/sbin/wifi", },
	{ source = g_prefix .. "/sbin/hostapd",            dest = "/usr/sbin/hostapd", },
	{ source = g_prefix .. "/sbin/wpa_supplicant",     dest = "/usr/sbin/wpa_supplicant", },
}

local function mainfunc()
	sysutil.chdir("/")
	sysutil.setname("WRTNET")
	sysutil.setenv("LD_LIBRARY_PATH", nil)
	sysutil.setenv("PATH", gfmt("%s/bin:%s/sbin:/usr/local/bin:/usr/bin:/usr/sbin:/bin:/sbin", g_prefix, g_prefix))

	for _, symtab in ipairs(g_symlinks) do
		if not symlink(symtab.source, symtab.dest) then
			return false
		end
	end

	sysutil.mkdir("/etc/config")
	sysutil.mkdir("/var/run/ubus", nil, true)
	local netapp = g_prefix .. "/sbin/netapp.lua"
	sysutil.call(sysutil.OPT_NOWAIT, "lua", netapp, g_prefix .. "/sbin/ubusd")
	sysutil.mdelay(666)
	sysutil.call(sysutil.OPT_NOWAIT, "lua", netapp, g_prefix .. "/sbin/netifd")
	sysutil.call(sysutil.OPT_NOWAIT, "lua", netapp, g_prefix .. "/sbin/wpad")

	io.stdout:write(gfmt("[%s]: Waiting for child processes...\n", os.date()))
	io.stdout:flush()
	while true do
		local run, err, epid = sysutil.waitpid(-1, false)
		if run == nil and err ~= sysutil.EINTR then
			io.stderr:write(gfmt("Error, waitpid has failed: %s\n", sysutil.strerror(err)))
			io.stderr:flush()
			break
		end
		if run == false then
			io.stderr:write(gfmt("Error, detected child process termination: %d\n", epid))
			io.stderr:flush()
			break
		end
	end
end

mainfunc()
os.exit(1)
