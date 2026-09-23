# Hyprland Lua + LuaLS + LazyVim IntelliSense Setup

## What We Were Trying to Solve

Hyprland's newer configuration system uses **Lua** instead of the old
`hyprland.conf` syntax.

A Hyprland Lua configuration looks like:

```lua
hl.monitor({
    name = "DP-1",
    width = 1920,
    height = 1080,
})

hl.bind("SUPER, Q", function()
    hl.dsp.window.close()
end)
```

The problem was that normal Lua/Neovim tooling does not automatically
know what `hl` is.

We wanted LazyVim to understand the **actual Hyprland Lua API**, so that
typing:

```lua
hl.
```

would give proper completion, documentation, and type information.

---

# 1. What Is Lua?

**Lua** is the programming language used by Hyprland's new configuration
system.

For example:

```lua
local name = "DP-1"

print(name)
```

Lua itself knows about its own language features:

```lua
string
table
math
print
pairs
ipairs
```

But Lua has no built-in knowledge of Hyprland.

This:

```lua
hl.monitor(...)
```

is not a standard Lua function.

`hl` is something provided by **Hyprland**.

---

# 2. What Is `hl`?

`hl` is Hyprland's Lua API.

It exposes Hyprland-specific functionality to the configuration:

```lua
hl.monitor(...)
hl.config(...)
hl.bind(...)
hl.animation(...)
hl.device(...)
hl.gesture(...)
hl.window_rule(...)
hl.workspace_rule(...)
```

So conceptually:

```text
Lua
 │
 └── Hyprland provides
          │
          ▼
         `hl`
          │
          ├── monitor()
          ├── config()
          ├── bind()
          ├── animation()
          ├── device()
          ├── gesture()
          ├── window_rule()
          └── ...
```

The important distinction is:

> `hl` is not part of the Lua language. It is Hyprland's API exposed to
> Lua.

---

# 3. Why Didn't Neovim Know What `hl` Was?

LazyVim uses Neovim's LSP ecosystem to provide features such as:

- autocomplete
- type information
- diagnostics
- function signatures
- documentation
- jump-to-definition

For Lua, the language server is **LuaLS** (`lua-language-server`).

LuaLS understands Lua, but initially it had no information about
Hyprland's custom API.

Therefore, when we typed:

```lua
hl.
```

LuaLS did not know what members existed on `hl`.

It could only treat it as an unknown Lua value.

---

# 4. What Is LuaLS?

**LuaLS** means **Lua Language Server**.

It is the program that analyzes Lua code and provides the editor with
language intelligence.

The chain is:

```text
Neovim
   │
   ▼
LazyVim
   │
   ▼
LuaLS
   │
   ▼
Understands Lua code
```

LuaLS can understand things such as:

```lua
local x = 10
x.
```

and it can also understand custom APIs if we provide type definitions
for them.

---

# 5. Hyprland Already Provides the Definitions

This was the important discovery.

Hyprland installs:

```text
/usr/share/hypr/stubs/hl.meta.lua
```

We found it with:

```bash
pacman -Ql hyprland | grep -E 'lua|\.lua$'
```

The file starts with:

```lua
---@meta
```

and contains definitions for Hyprland's Lua API.

It describes things such as:

```lua
HL.API
HL.ConfigOpt
HL.DeviceSpec
HL.Dispatcher
HL.Keybind
```

and, importantly, the global:

```lua
hl
```

with its available functions.

The file is **not the implementation of Hyprland**.

It is a **stub/type description for tools such as LuaLS**.

Think of it as documentation written in a form the language server can
understand.

---

# 6. What Is `hl.meta.lua`?

A useful mental model is:

```text
Actual Hyprland
      │
      │ provides
      ▼
     `hl`
      │
      │ described for editors by
      ▼
hl.meta.lua
```

The real Hyprland code implements the API.

The stub tells LuaLS:

> "`hl` exists, and these are the functions, arguments, types, and
> objects associated with it."

For example, the stub can tell LuaLS that:

```lua
hl.bind(...)
```

exists and that it expects particular kinds of arguments.

That is what allows the editor to provide meaningful completion and type
checking.

---

# 7. What Is `.luarc.json`?

LuaLS supports a configuration file called:

```text
.luarc.json
```

We created:

```text
~/.config/hypr/.luarc.json
```

with:

```json
{
  "workspace.library": ["/usr/share/hypr/stubs"],
  "workspace.checkThirdParty": false
}
```

This file tells LuaLS how to analyze the Hyprland Lua workspace.

---

# 8. `workspace.library`

This is the most important part:

```json
"workspace.library": [
  "/usr/share/hypr/stubs"
]
```

It tells LuaLS:

> "Treat this directory as an additional Lua library when analyzing this
> project."

That directory contains:

```text
/usr/share/hypr/stubs/
└── hl.meta.lua
```

So LuaLS can now discover Hyprland's API definitions.

The relationship is:

```text
~/.config/hypr/
│
├── hyprland.lua
│
└── .luarc.json
       │
       │ tells LuaLS to load
       ▼
/usr/share/hypr/stubs/
       │
       └── hl.meta.lua
```

---

# 9. What Is `workspace.checkThirdParty`?

We also have:

```json
"workspace.checkThirdParty": false
```

This controls LuaLS's handling of third-party libraries.

In our setup, the Hyprland stub directory is external to the project
itself, so disabling third-party checking avoids LuaLS getting in the
way of using that library.

It is not what provides the Hyprland API.

The important setting is:

```json
"workspace.library"
```

---

# 10. Where Does LazyDev Fit?

Our editor setup is:

```text
Neovim
   │
   ▼
LazyVim
   │
   ├── LazyDev
   │
   ▼
LuaLS
```

**LazyDev is not the Hyprland API and it is not LuaLS itself.**

LazyDev is a Neovim plugin that improves Lua development by helping
LuaLS discover libraries and development environments, especially in a
LazyVim configuration.

The actual language analysis is still performed by:

```text
lua-language-server
```

We verified that `lua_ls` was attached to our `hyprland.lua` buffer.

So the important distinction is:

```text
LazyVim
   │
   └── LazyDev
          │
          └── helps configure/discover Lua libraries
                         │
                         ▼
                       LuaLS
                         │
                         └── analyzes Lua
                                │
                                ▼
                         Hyprland stubs
```

---

# 11. What Changed After Adding `.luarc.json`?

Before:

```lua
hl.
```

LuaLS essentially had:

```text
"What's hl?"
```

After adding the Hyprland stub library:

```lua
hl.
```

LuaLS can resolve:

```text
hl → HL.API
```

and therefore completion shows things like:

```text
animation
bind
clear_crashed_lockscreen
config
curve
define_submap
device
dispatch
dsp
env
...
```

This is exactly what we wanted.

---

# 12. The Whole Setup

The complete relationship is:

```text
                    HYPRLAND
                       │
                       │ provides
                       ▼
                     Lua API
                       │
                       │ described by
                       ▼
              hl.meta.lua
        /usr/share/hypr/stubs/
                       │
                       │ loaded as a library
                       ▼
                    LuaLS
                       │
                       │ language intelligence
                       ▼
                    LazyDev
                       │
                       │ integrated into
                       ▼
                    LazyVim
                       │
                       ▼
                    Neovim
                       │
                       ▼
                 hyprland.lua
```

Or, more practically:

```text
hyprland.lua
     │
     │ uses
     ▼
    hl.*
     │
     │ understood because
     ▼
.luarc.json
     │
     │ points LuaLS toward
     ▼
/usr/share/hypr/stubs
     │
     └── hl.meta.lua
             │
             ▼
           LuaLS
             │
             ▼
     autocomplete / types /
       diagnostics / docs
```

---

# 13. Why This Is Better Than Manually Defining `hl`

We could have created our own Lua definitions such as:

```lua
---@class HL
---@field monitor function
---@field bind function
---@field config function

---@type HL
hl = hl
```

But that would be a bad long-term solution.

Hyprland already generates and ships:

```text
hl.meta.lua
```

So we use the **official API stub provided by the installed Hyprland
package**.

That means when Hyprland's Lua API changes and its generated stub
changes, our editor can use the updated definitions instead of
maintaining our own fake API description.

---

# 14. Final Configuration

Our Hyprland Lua workspace now has:

```text
~/.config/hypr/
├── hyprland.lua
└── .luarc.json
```

`.luarc.json`:

```json
{
  "workspace.library": ["/usr/share/hypr/stubs"],
  "workspace.checkThirdParty": false
}
```

And Hyprland provides:

```text
/usr/share/hypr/stubs/hl.meta.lua
```

The result is full Hyprland-aware Lua completion in LazyVim:

```lua
hl.
```

→ Hyprland API completion.

---

## The One-Sentence Version

**We told LuaLS, through `.luarc.json`, to load Hyprland's own
`/usr/share/hypr/stubs/hl.meta.lua` API definitions, allowing
LazyVim/LazyDev to give us proper IntelliSense and type information for
the Hyprland `hl` Lua API.**
