# Change Log

All notable changes to the "tarantool-vscode" extension will be documented in
this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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

### Fixed

- Removed duplicating `tarantool-emmylua` and GitHub CI from the bundle.

## [0.0.1] - 28.03.2025

### Added

- Added support for EmmyLua LSP and Tarantool-specific annottations.
- Added jsonschema checks for Tarantool cluster configuration.
- Added `tt` start and stop commands to the command palette.
