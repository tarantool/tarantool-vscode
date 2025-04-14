# Change Log

All notable changes to the "tarantool-vscode" extension will be documented in
this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Builtin `buffer` module definitions.
- Builtin `csv` module definitions.
- Partial `fun` module definitions.
- Builtin `http.client` module definitions.
- Builtin `errno` module definitions.
- Builtin `strict` module definitions.
- Partial `vshard` rock definitions.
- `box.execute()` documentation used for evaluating SQL statements.
- `box.space.*:format()` documentation and annotations.
- `box.schema.role` and `box.schema.user` documentation and type annotations.
- Annotations on a few supplementary spaces like `box.schema._cluster`.
- Setting up provided Rock type annotations (currently only `vshard` is done).

### Changed

- Tightened some of the `box` `number` types to `integer`.
- Tightened some of the `string` `number` types to `integer`.

### Fixed

- A `box.atomic()` overload has now proper variadic arguments.
- `box.tuple` now doesn't issue diagnostics on missing field.
- Missing `fio` file handle `:read()` overload.
- A few typos in various Tarantool builtin modules caught up by automatic spell
  checking.
- Marked `vshard.router.call*` arguments and options optional.
- Added missing `map`, `any`, `double` tuple type names.
- Overloads of `box.space.*:format()` are now resolved properly.

## [0.1.2] - 08.04.2025

### Changed

- Now the minimum required VS Code version is 1.88.0 making it possible to
  install the extension to the apps based on the older version of VS Code like
  Cursor.

## [0.1.1] - 07.04.2025

### Added

- Added `iconv` builtin Lua module annotations.
- Added `jit` builtin Lua module annotations.
- Added stubs for `box.schema` submodules.

### Fixed

- A few typo fixes in the `box` module and its submodules annotations.

## [0.1.0] - 01.04.2025

### Added

- Added `tt` restart and status to the command palette.
- Added `tt` install Tarantool CE to the command palette.
- Added plugin icon.
- Now the extension performs startup checks whether there are Tarantool
  annotations when it starts.
- Added `tt` create command for creating Tarantool projects from a template.

### Changed

- Now the id is `tarantool` instead of `tarantool-vscode` and the package name
  is simple `Tarantool`.
- Tarantool annotations aren't longer used as a submodule.
- Now initialize the extension command also tries to initialize the extension
  in the workspace folder in which the opened file is located.

### Fixed

- Removed duplicating `tarantool-emmylua` and GitHub CI from the bundle.

## [0.0.1] - 28.03.2025

### Added

- Added support for EmmyLua LSP and Tarantool-specific annottations.
- Added jsonschema checks for Tarantool cluster configuration.
- Added `tt` start and stop commands to the command palette.
