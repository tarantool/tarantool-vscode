# Tarantool EmmyLua annotations [alpha]

This repository provides experimental EmmyLua annotations for a [Tarantool in-memory computing platform](https://github.com/tarantool/tarantool).
Using it you may find out how to configure your IDE for developing Tarantool applications with static checks and autocompletion.

For the ones unfamiliar with the LSP and annotations they extend Lua code with type system in the similar way TypeScript does the following to JavaScript. Types don't exist during the Runtime but allows one to statically check the applications.

See the usage section for examples on how to use it.

## Installation (stable)

This path lua-language-server

1. Set up [lua-language-server](https://github.com/LuaLS/lua-language-server) using the [instructions from the official website](https://luals.github.io/#vscode-install).
    - __VS Code__:
        Search for "Lua" by sumneko in the extension marketplace. Install it. There you go.
    - __NeoVim__:
        If you are new to NeoVim, follow this guide to setup plugin manager and the Tarantool annotations. If you already familiar with this text editor you might proceed to the fourth step.

        Step 1. Setup plugin manager. This guide uses [packer.nvim](https://github.com/wbthomason/packer.nvim) but there might be other options.
        ```bash
        git clone --depth 1 https://github.com/wbthomason/packer.nvim ~/.local/share/nvim/site/pack/packer/start/packer.nvim
        ```

        Step 2. Setup [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig/tree/master), [nvim-cmp](https://github.com/hrsh7th/nvim-cmp) and [cmp-nvim-lsp](https://github.com/hrsh7th/cmp-nvim-lsp) plugins. They're needed for easy LSP configuration and for adding completions support. To do this, create `~/.config/nvim/lua/plugins.lua` with the following contents.
        ```lua
        -- ~/.config/nvim/lua/plugins.lua

        vim.cmd [[packadd packer.nvim]]

        return require('packer').startup(function(use)
            use 'wbthomason/packer.nvim'
            use 'neovim/nvim-lspconfig'
            use 'hrsh7th/cmp-nvim-lsp'
            use 'hrsh7th/nvim-cmp'
        end)
        ```

        NeoVim supports both Lua and VimScript for its configuration. If you previously used vanilla Vim you might wanna use your `.vimrc`. This can be done using `source` command in the `~/.config/nvim/init.vim` initialization file. You also need to enable the created plugins script using the `lua` command. Create `~/.config/nvim/init.vim` with the following contents.
        ```vim
        " ~/.config/nvim/init.vim

        source ~/.vimrc

        lua require('plugins')
        ```

        Step 3. Run NeoVim and execute `:PackerSync` to install the configured plugins.

        Step 4. Install [Lua Language Server](https://github.com/LuaLS/lua-language-server)

        If you have `homebrew`, `scoop`, `macports` run one of these:
        ```bash
        # Scoop
        scoop install lua-language-server

        # Homebrew
        brew install lua-language-server

        # Macports
        sudo port install lua-language-server
        ```

        Otherwise, install it from the [latest releases](https://github.com/LuaLS/lua-language-server/releases/latest) or build it from sources.

        Step 4. Now you should have all the needed plugins installed. Add this to `~/.config/nvim/lua/config.lua` to set up Lua Language Server for Lua files.
        ```lua
        -- ~/.config/nvim/lua/config.lua

        -- Setup Lua Language Server.
        require'lspconfig'.lua_ls.setup{}

        -- Setup completions and arrows for navigating them.
        local cmp = require'cmp'
        cmp.setup({
            sources = {
                { name = "nvim_lsp" },
                { name = "buffer" },
            },
            mapping = {
                ["<cr>"] = cmp.mapping.confirm({select = true}),
                ["<Up>"] = cmp.mapping.select_prev_item(),
                ["<Down>"] = cmp.mapping.select_next_item(),
            },
        })
        ```
        And enable this file inside your initialization `init.vim` file.
        ```vim
        " ~/.config/nvim/init.vim

        source ~/.vimrc

        lua require('plugins')
        lua require('config')
        ```

        That's it, you now have NeoVim configured for using it with Tarantool annotations.
    - __JetBrains__:
        Install [SumnekoLua](https://plugins.jetbrains.com/plugin/22315-sumnekolua) from the plugin marketplace.
2. Configure LSP to find annotations Library. Create `.luarc.json` inside you Tarantool app (or within the Tarantool sources if you want to use the annotations within the Tarantool repository) with the following contents.
```json
{
  "runtime": {
    "version": "LuaJIT"
  },
  "workspace": {
    "library": [
      "<path to the cloned repository>/Library"
    ]
  }
}
```

For more information on configuring language server refer to the [project's documentation](https://luals.github.io/wiki/configuration/).

## Installation (experimental)

*Note:* [lua-language-server](https://github.com/LuaLS/lua-language-server) is a mature project. Though at the time of publishing this repository it has [poor support of generics](https://github.com/LuaLS/lua-language-server/issues/1861). But using a generic concept is crucial for Tarantool objects. Take [spaces](https://www.tarantool.io/en/doc/latest/platform/ddl_dml/value_store/#index-box-space) as an example. Tarantool spaces are the containers for the data of generic type defined by the user (similarly to the tables storing rows satisfying corresponding to some schema in relational databases). Thus, function for processing the tuples can't be simply implemented without generics.

Since there, there is an experimental solution based on the [emmylua-analyzer-rust project](https://github.com/CppCXY/emmylua-analyzer-rust). Currently, this language server may throw some false-positive warnings. Thus, it's not recommended to use it within the CI. Though it provides better autocompletion, stricter type-checking, and more tools for code analysis (honestly it's also easier to contribute to since it's written in Rust).

1. Install [emmylua-analyzer-rust LSP](https://github.com/CppCXY/emmylua-analyzer-rust).
2. Configure your text editor to use it.
If you're using NeoVim, put this in your Lua configuration:
```lua
vim.lsp.start({
  cmd = { "emmylua_ls" },
  root_dir = vim.fn.getcwd(),
})
```
If you're using VSCode, install an extension [https://marketplace.visualstudio.com/items?itemName=tangzx.emmylua](https://marketplace.visualstudio.com/items?itemName=tangzx.emmylua).

3. Clone the annotations repository
```bash
git clone https://github.com/georgiy-belyanin/tarantool-emmylua
```
4. Configure LSP to find annotations Library. Create `.emmyrc.json` with the following contents.
```json
{
  "runtime": {
    "version": "LuaJIT"
  },
  "workspace": {
    "library": [
      "<path to the cloned repository>/Library"
    ]
  }
}
```

For more information on configuring language sesrver refer to the [project's documentation](https://github.com/CppCXY/emmylua-analyzer-rust/blob/main/docs/config/emmyrc_json_EN.md).

## Usage

After installing text-editor-specific IDE provides documentation and completion for the most popular Tarantool functions. For instance, pressing `K` in NeoVim having a Tarantool call under the cursor displays a documentation and information on the arguments and return types. This is a piece of the documentation for `fiber.new()`.

```markdown
Create a fiber but do not start it.

The created fiber starts after the fiber creator (that is, the job that is calling `fiber.new()`) yields. The initial fiber state is ready.

**Note:** `fiber.status()` returns the suspended state for ready fibers because the ready state is not observable using the fiber module API.

You can join fibers created using `fiber.new()` by calling the `fiber_object:join()` function and get the result returned by the fiber's function.

To join the fiber, you need to make it joinable using `fiber_object:set_joinable()`.
```

You might want to include annotations for user-defined functions and data types.

```lua
-- Define type aliases for the user-defined types.

---@alias deposit_tuple [number, string, number]

-- You may define custom classes with fields and inherit them one from another.

---@class deposit: table
---@field id number ID of the deposit.
---@field owner string Owner's name.
---@field amount number Amount.

-- Define type annotations for the user-defined calls.

---The call processes a deposit tuple. This is a short description.
---
---This call really processes a tuple. This is a long description. Believe me.
---
---@param t deposit_tuple
---@return deposit_tuple updated_tuple
local function process_tuple(t)
    return {t[1], t[2], t[3] + 1000}
end

-- Warning: wrong arument type.
local tuple_1 = process_tuple({1, 2, 3})
-- Ok.
local tuple_2 = process_tuple({1, 'Stan', 1000})

-- Define types for the user-defined variables.

---@type deposit
local stan_deposit = { id = 1, owner = 'Stan', amount = 1000 }
```

If you use experimental [emmylua-analyzer-rust](https://github.com/CppCXY/emmylua-analyzer-rust) as a language server you may annotate your spaces by defining a project-specific language server definition file with similar generic type annotations.

```lua
---@meta

--Define the types used within the space.

---@alias deposit_tuple [number, string, number]
---@alias deposit { id: number, owner: string, amount: number }

--Define the space type itself.

---@type box.space<deposit_tuple, deposit>
box.space.deposits = {}
```

LSP now guides you if you're trying to use yielding method implicitly.

```lua
local function is_it_yield()
    -- Warning: using an async (~ yielding) function within non-async function.
    require('net.box').connect('127.0.0.1:3300')
    -- ...
end

-- Marking the function with `@async` explicitly allows it to yield.

---@async
local function is_it_yield()
    -- Ok.
    local conn = require('net.box').connect('127.0.0.1:3300')
    -- ...
end
```

[Emmylua-analyzer-rust](https://github.com/CppCXY/emmylua-analyzer-rust) also provides a tool for running CLI checks similar to the ones provided by LSP.

```bash
# Run CLI checks and linting of the Lua files within the current directory.
emmylua_check .
```

For more information on using LSP refer to the [project's documentation](https://github.com/CppCXY/emmylua-analyzer-rust/blob/main/docs/features/features_EN.md).

## Progress

* Builtin Tarantool CE modules
    - [x] `box` (partial)
        + [x] `backup`
        + [x] `cfg`
        + [x] `ctl` (partial)
        + [x] `error`
        + [x] `index` (partial)
        + [x] `info`
        + [x] `schema` (partial, `user`/`role` is missing)
        + [x] `session`
        + [x] `slab`
        + [x] `space` (partial)
        + [x] `stat` (partial)
        + [x] `tuple`
    - [ ] `buffer`
    - [x] `clock`
    - [x] `console`
    - [ ] `config`
    - [ ] `crypto`
    - [ ] `csv`
    - [x] `datetime`
    - [x] `decimal`
    - [ ] `digest`
    - [ ] `errno`
    - [ ] `experimental.connpool`
    - [x] `fiber`
    - [x] `fio`
    - [ ] `fun`
    - [ ] `http`
        + [ ] `client`
        + [ ] `server`
    - [ ] `iconv`
    - [ ] `jit`
    - [x] `json` (partial)
    - [x] `log`
    - [ ] `merger`
    - [ ] `msgpack`
    - [x] `net.box` (partial)
    - [ ] `pickle`
    - [ ] `popen`
    - [ ] `socket`
    - [ ] `strict`
    - [x] `string`
    - [ ] `tarantool`
    - [x] `uri`
    - [ ] `utf8`
    - [x] `uuid`
    - [ ] `xlog`
    - [x] `yaml`

* Popular Tarantool rocks
    - [ ] `checks`
    - [ ] `crud`
    - [ ] `exprationd`
    - [ ] `luatest`
    - [ ] `metrics`
    - [ ] `queue`
    - [ ] `vshard`

## Contributing

If you have suggestions, ideas, etc. on the Language Server or annotations themselves feel free to leave issues, pull requests and discussions.

## References, see also, acknowledgements

This project is the future development of the [VSCode Tarantool extension](https://github.com/vaintrub/vscode-tarantool/) owned by @vaintrub. Also, thanks @ochaton and @totktonada for writing the annotations and helping to define the shape of the project.
