#!/usr/bin/lua5.1

-- Created by yejq.jiaqiang@gmail.com
-- Download opensource project via `git clone`
-- 2026/09/26

local sysutil   = require "sysutil"
local gfmt      = string.format

-- list of opensource Git repositories to clone
local g_opendir = nil
local repo_list = {}

local function fetch_repos()
	local npkg = 1

	repo_list[npkg] = { url = "https://git.openwrt.org/project/libubox.git",
		dirname = "libubox", commit = "7677b7a4f3a46f68e6f5ba6818f7b72fdd7dbaa0", }

	npkg = npkg + 1
	repo_list[npkg] = { url = "https://git.openwrt.org/project/uci.git",
		dirname = "uci", commit = "66127cd76c5d0bd46d5a90302cc6110f53a4e2f8", }
end

local function clone_init(arg0)
	-- must be invoked in `fighters/opensource directory
	arg0 = sysutil.basename(arg0)
	local fst = sysutil.stat(arg0)
	if not (fst and fst.isreg) then
		if type(arg0) ~= "string" then arg0 = "nil" end
		io.stderr:write(gfmt("Error, script not found: %s\n", arg0))
		io.stderr:flush()
		return false
	end
	g_opendir = sysutil.getcwd()
	if not g_opendir then
		io.stderr:write("Error, cannot determine current working directory.\n")
		io.stderr:flush()
		return false
	end
	return true
end

local function get_commit_id(pdir)
	if not sysutil.chdir(pdir) then
		io.stderr:write(gfmt("Error, cannot goto directory: %s\n", pdir))
		io.stderr:flush()
		return nil
	end

	local cflags = sysutil.OPT_OUTPUT + sysutil.OPT_RSTRIP
	local okay, cid = sysutil.call(cflags, "git", "log", "--pretty=%H", "-1")
	if okay ~= 0 or type(cid) ~= "string" or #cid ~= 40 then
		sysutil.chdir(g_opendir)
		io.stderr:write(gfmt("Error, failed to get commit-ID in %s\n", pdir))
		io.stderr:flush()
		return nil
	end

	sysutil.chdir(g_opendir)
	return cid
end

local function download_git(url, gdir, cid)
	if type(url) ~= "string" or #url == 0 then
		io.stderr:write("Error, download URL must be a valid string.\n")
		io.stderr:flush()
		return false
	end

	if type(gdir) ~= "string" or #gdir == 0 or string.find(gdir, "/", 1, true) then
		io.stderr:write(gfmt("Error, invalid git repository directory name: %s\n", gdir))
		io.stderr:flush()
		return false
	end

	local tst = sysutil.stat(gdir)
	if tst and tst.isdir then
		if get_commit_id(gdir) == cid then
			io.stdout:write(gfmt("INFO: repository already cloned: %s\n", gdir))
			io.stdout:flush()
			return true
		end
	end

	sysutil.call(0, "rm", "-rf", gdir)
	io.stdout:write(gfmt("INFO: Cloning git repository '%s' from %s ...\n", gdir, url))
	io.stdout:flush()

	local okay = sysutil.call(0, "sh", "-c",
		gfmt("git clone '%s' '%s' && cd '%s' && git checkout '%s'", url, gdir, gdir, cid))
	if okay ~= 0 then
		io.stderr:write(gfmt("Error, failed to clone '%s' to directory '%s'\n", url, gdir))
		io.stderr:flush()
		return false
	end

	if get_commit_id(gdir) ~= cid then
		io.stderr:write(gfmt("Error, failed to download: %s\n", url))
		io.stderr:flush()
		return true
	end

	io.stdout:write(gfmt("INFO: repository cloned from '%s' into '%s'\n", url, gdir))
	io.stdout:flush()
	return false
end

local function mainfunc()
	fetch_repos()
	local errnum = 0
	for _, repo in ipairs(repo_list) do
		if not download_git(repo.url, repo.dirname, repo.commit) then
			errnum = errnum + 1
		end
	end
	if errnum >= 1 then
		io.stderr:write(gfmt("Error, opensource projects failed to download: %d\n", errnum))
		io.stderr:flush()
		os.exit(2)
	end
end

if not clone_init(arg[0]) then
	os.exit(1)
end
mainfunc()
os.exit(0)
