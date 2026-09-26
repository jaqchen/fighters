#!/usr/bin/lua5.1

-- Created by yejq.jiaqiang@gmail.com
-- Download opensource source tarballs
-- 2026/09/26

local sysutil   = require "sysutil"
local gfmt      = string.format

-- list of opensource tarballs to download
local pkg_list  = {}

local function fetch_pkgs()
	local npkg = 1

	pkg_list[npkg] = { url = "https://www.lua.org/ftp/lua-5.1.5.tar.gz",
		sha256sum = "2640fc56a795f29d28ef15e13c34a47e223960b0240e8cb0a82d9b0738695333", }

	npkg = npkg + 1
	pkg_list[npkg] = { url = "https://s3.amazonaws.com/json-c_releases/releases/json-c-0.18-nodoc.tar.gz",
		name = "json-c-0.18.tar.gz",
		sha256sum = "602cdefc1d2aab8318fc0814b7ce7d59e72514d4276ca3eff92f35f86cf1c160", }

	npkg = npkg + 1
	pkg_list[npkg] = { url = "https://www.kernel.org/pub/software/network/iw/iw-6.17.tar.xz",
		sha256sum = "7d182e498289ab39b257da6780d562e415377107f50358ee5b55b8cfe40b1e33", }

	npkg = npkg + 1
	pkg_list[npkg] = { url = "https://archive.hadrons.org/software/libmd/libmd-1.2.0.tar.xz",
		sha256sum = "ac15ffb8430502fbaccdec66c5a82ee0eab0b0f36220df56710feadfeb13d0a0", }

	npkg = npkg + 1
	pkg_list[npkg] = { url = "https://github.com/openssl/openssl/releases/download/openssl-3.5.7/openssl-3.5.7.tar.gz",
		sha256sum = "a8c0d28a529ca480f9f36cf5792e2cd21984552a3c8e4aa11a24aa31aeac98e8", }
end

local function download_init(arg0)
	-- must be invoked in `fighters/opensource directory
	arg0 = sysutil.basename(arg0)
	local fst = sysutil.stat(arg0)
	if not (fst and fst.isreg) then
		if type(arg0) ~= "string" then arg0 = "nil" end
		io.stderr:write(gfmt("Error, script not found: %s\n", arg0))
		io.stderr:flush()
		return false
	end
	return true
end

local function download_file(url, fname, chksum)
	if type(url) ~= "string" or #url == 0 then
		io.stderr:write("Error, download URL must be a valid string.\n")
		io.stderr:flush()
		return false
	end

	if not fname then fname = sysutil.basename(url) end
	if type(fname) ~= "string" or #fname == 0 or string.find(fname, "/", 1, true) then
		io.stderr:write(gfmt("Error, cannot determine file name for URL: %s\n", url))
		io.stderr:flush()
		return false
	end

	local tst = sysutil.stat(fname)
	if tst and tst.isreg then
		if sysutil.sha256(fname, true, true) == chksum then
			io.stdout:write(gfmt("INFO: source tarball already downloaded: %s\n", fname))
			io.stdout:flush()
			return true
		end
		io.stderr:write(gfmt("Remove corrupted or partial downloaded file: %s\n", fname))
		io.stderr:flush()
		sysutil.unlink(fname)
	end

	io.stdout:write(gfmt("INFO: Downloading source tarball '%s' from %s ...\n", fname, url))
	io.stdout:flush()

	sysutil.call(0, "curl", url, "-o", fname)
	if sysutil.sha256(fname, true, true) == chksum then
		sysutil.chmod(fname, 292) -- set file as read-only
		io.stdout:write(gfmt("INFO: source tarball downloaded OKAY: %s\n", fname))
		io.stdout:flush()
		return true
	end

	sysutil.unlink(fname)
	io.stderr:write(gfmt("Error, failed to download: %s\n", url))
	io.stderr:flush()
	return false
end

local function mainfunc()
	fetch_pkgs()
	local errnum = 0
	for _, pkg in ipairs(pkg_list) do
		if not download_file(pkg.url, pkg.name, pkg.sha256sum) then
			errnum = errnum + 1
		end
	end
	if errnum >= 1 then
		io.stderr:write(gfmt("Error, tarballs failed to download: %d\n", errnum))
		io.stderr:flush()
		os.exit(2)
	end
end

if not download_init(arg[0]) then
	os.exit(1)
end
mainfunc()
os.exit(0)
