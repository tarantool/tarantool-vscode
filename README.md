# 🕷 Tarantool VS Code Extension

<a href="http://tarantool.io">
 <img src="https://avatars2.githubusercontent.com/u/2344919?v=2&s=100" align="right">
</a>

Tarantool VS Code Extension helps you to develop Tarantool applications in VS Code. It enhances your text editor with completions, suggestions, and snippets.

Please, note that this extension uses [EmmyLua extension](https://github.com/EmmyLua/VSCode-EmmyLua) as a backend for Tarantool-specific stuff.

---

## Features

<img src="https://i.postimg.cc/k5cnrtZc/box-commit.gif" width="320" align="right">

This extension offers the following features.

* Static type checks and documentation for the most popular Lua and Tarantool builtin modules.
* Cluster configuration schema validation for Tarantool 3.0+.
* [tt cluster management utility](https://github.com/tarantool/tt) inside the command pallete.
* Other auxiliary commands, e.g. install Tarantool of a specific version right from VS Code.

---

## Usage

That's how you use this extension.

* Install the extension from the VS Code marketplace.
* Open a Tarantool project in VS Code.
* Run `Tarantool: Initialize VS Code extension in existing app` command from the command palette (`Ctrl+Shift+P` or `Cmd+Shift+P` on macOS).

You may statically type your Lua functions as follows.

```lua
---@class user_info
---@field name string User's name.
---@field age? number User's age (optional).

---@alias user_tuple [string, number]

---@param tuples user_tuple[]
---@return user_info[]
local function deflatten_users(tuples)
    -- ...
end

---@type user_info
local unnamed_user = { name = 'Unnamed' }
```

For more examples, refer to [Emmylua documentation](https://emmylua.github.io/annotation.html).

## Contributing

Feel free to open issues on feature requests, wrong type annotations and bugs. If you're dealing with the problem related to LSP we'd appreciate addressing a direct issue to [emmylua-analyzer-rust](https://github.com/CppCXY/emmylua-analyzer-rust) which is used as a language server.

We also appreciate contributions via pull requests.

Thank you for your interest in Tarantool and its development tools!

## References & acknowledgments

This is an extension for the [Tarantool database](https://www.tarantool.io/) internally using [VS Code EmmyLua extension used as a language server](https://github.com/EmmyLua/VSCode-EmmyLua).

A lot of the initial work has been done by Tarantool community in the [original Tarantool VS Code annotations](https://github.com/vaintrub/vscode-tarantool).
