## Simple Embedded Software Compilation

**Fighters** is a project proposed and named by my former colleague, who asked me to post some scripts on Github, to foster the building process of embedded softwares. The development activity has long stagnated, and I think it would be better to keep the code as simple as possible.

The goal of `Fighters` project is primarily to create **an easy and simple software development kit**, mostly used for embedded devices. Currently, it strives to compile various core components from [openwrt](https://openwrt.org), primary the network manager [netifd](https://github.com/openwrt/netifd). To achive that, you need to download prebuilt toolchain from [bootlin.com](https://toolchains.bootlin.com/toolchains.html), extract that toolchain to `/opt` directory, and then:

```sh
cd opensource && ./download.lua && ./git_fetch.lua
cd .. && rm -f target && ln -sv target-aarch64-musl target
./build.bash # compile the opensource applications
```

Note that, the above two [Lua](https://lua.org) scripts need [sysutil](https://github.com/jaqchen/sysutil) installed on host.

#### Planned Features

- [ ] Replace `build.bash` with a new script written in [Lua](https://lua.org);
- [ ] Split the project as multiple sub-projects (managed via `gitmodules`);
- [ ] Generate software package with the integration of [apk](https://wiki.alpinelinux.org/wiki/Alpine_Package_Keeper);
- [ ] Package selection via `menuconfig`;
- [ ] Documentation;