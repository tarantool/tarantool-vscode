---@meta

---# Builtin `fio` module
---
---Tarantool supports file input/output with an API that is similar to POSIX syscalls. All operations are performed asynchronously. Multiple fibers can access the same file simultaneously.
---
---* Functions for common pathname manipulations.
---* Functions for directory or file existence and type checks.
---* Functions for common file manipulations.
---* Constants which are the same as POSIX flag values (for example `fio.c.flag.O_RDONLY` = POSIX O_RDONLY).

local fio = {}

---Concatenate partial string, separated by '/' to form a path name.
---
---**Example:** `fio.pathjoin('/etc', 'default', 'myfile')` => `'/etc/default/myfile'`
---@vararg string ...
---@return string
function fio.pathjoin(...) end

---Get a file name.
---
---Given a full path name, remove all but the final part (the file name). Also remove the suffix, if it is passed.
---
---Note that the basename of a path with a trailing slash is an empty string. It is different from how the Unix basename program interprets such a path.
---
---**Example:**
---
---`fio.basename('/path/to/my.lua', '.lua')` => `'my'`
---
---@param path_name string path name
---@param suffix? string suffix
---@return string file_name
function fio.basename(path_name, suffix) end

---Get a directory name.
---
---**Example:**
---
---`fio.dirname('/path/to/my.lua')` => `'/path/to/'`
---
---@param path_name string path-name
---@return string
function fio.dirname(path_name) end

---Get a directory and file name.
---
---Given a full path name, remove the final part (the file name).
---
---**Example:**
---
---`fio.abspath('my.lua')` => `'/path/to/my.lua'`
---
---@param file_name string
---@return string directory_name that is, path name including file name.
function fio.abspath(file_name) end

---Check if file or directory exists.
---
---@param path string
---@return boolean # `true` if path-name refers to a directory or file that exists and is not a broken symbolic link; otherwise `false`.
function fio.path.exists(path) end

---Check if file or directory is a directory.
---
---@param path string
---@return boolean # `true` if path-name refers to a directory; otherwise `false`.
function fio.path.is_dir(path) end

---Check if file or directory is a file.
---
---@param path string
---@return boolean # `true` if path-name refers to a file; otherwise `false`
function fio.path.is_file(path) end

---Check if file or directory is a link.
---
---@param path string
---@return boolean # `true` if path-name refers to a symbolic link; otherwise `false`
function fio.path.is_link(path) end

---Check if file or directory exists.
---
---@param path string
---@return boolean # `true` if path-name refers to a directory or file that exists or is a broken symbolic link; otherwise `false`
function fio.path.lexists(path) end

---Set the mask bits used when creating files or directories.
---
---For a detailed description type `man 2 umask`.
---
---@param mask_bits number
---@return number # previous mask bits
function fio.umask(mask_bits) end

---@class fio.stat:table
---@field inode number
---@field rdev number
---@field size number
---@field atime number
---@field mode number
---@field mtime number
---@field nlink number
---@field uid number
---@field blksize number
---@field gid number
---@field ctime number
---@field dev number
---@field blocks number

---Get information about a file object.
---
---Returns information about a file object. For details type `man 2 lstat` or `man 2 stat`.
---
---**Example:**
---
--- `fio.lstat('/etc')`
---
--- ```yaml
---   inode: 1048577
---   rdev: 0
---   size: 12288
---   atime: 1421340698
---   mode: 16877
---   mtime: 1424615337
---   nlink: 160
---   uid: 0
---   blksize: 4096
---   gid: 0
---   ctime: 1424615337
---   dev: 2049
---   blocks: 24
--- ```
---
---@param path string path name of file.
---@return fio.stat
function fio.lstat(path) end

---Get information about a file object.
---
---Returns information about a file object. For details type `man 2 lstat` or `man 2 stat`.
---
---@param path string path name of file.
---@return fio.stat
function fio.stat(path) end

---Create directory.
---
---**Example:**
---
---`fio.mkdir('/etc')` => `false`
---
---@param path_name string path of directory.
---@param mode? number Mode bits can be passed as a number or as string constants, for example S_IWUSR. Mode bits can be combined by enclosing them in braces.
---@return boolean success, string error_message?
function fio.mkdir(path_name, mode) end

---Delete a directory
---
---@param path_name string
---@return boolean success, string message?
function fio.rmdir(path_name) end

---Change working directory.
---
---**Example:**
---
---`fio.chdir('/etc')` => `true`
---
---@param path_name string path of directory.
---@return boolean success
function fio.chdir(path_name) end

---List files in a directory.
---
---The result is similar to the ls shell command.
---
---@param path_name string  path of directory.
---@return string[]|nil, string? error_message #
function fio.listdir(path_name) end

---Get files whose names match a given string.
---
---Return a list of files that match an input string.
---
---The list is constructed with a single flag that controls the behavior of the function: GLOB_NOESCAPE.
---
---For details type `man 3 glob`.
---
---**Example:**
---
--- `fio.glob('/etc/x*')`
--- ```
--- - - /etc/xdg
---   - /etc/xml
---   - /etc/xul-ext
--- ```
---@return string[] list list of files whose names match the input string
function fio.glob(path_name) end

---Return the name of a directory that can be used to store temporary files.
---
---`fio.tempdir()` stores the created temporary directory into `/tmp` by default.
---
---*Since 2.4.1*, this can be changed by setting the `TMPDIR` environment variable.
---
---Before starting Tarantool, or at runtime by `os.setenv()`.
---
---**Example:**
---
--- ```tarantoolsession
--- tarantool> fio.tempdir()
--- ---
--- - /tmp/lG31e7
--- ...
--- tarantool> fio.mkdir('./mytmp')
--- ---
--- - true
--- ...
---
--- tarantool> os.setenv('TMPDIR', './mytmp')
--- ---
--- ...
---
--- tarantool> fio.tempdir()
--- ---
--- - ./mytmp/506Z0b
--- ```
---@return string
function fio.tempdir() end

---Get the name of the current working directory.
---
---**Example:**
---
---`fio.cwd()` => `'/home/username/tarantool_sandbox'`
---
---@return string
function fio.cwd() end

---Copy everything in the `from-path`, including subdirectory contents, to the `to-path`.
---
---The result is similar to the `cp -r` shell command.
---
---The `to-path` should not be empty.
---@param from_path string
---@param to_path string
---@return boolean success, string? error_message
function fio.copytree(from_path, to_path) end

---Create the path, including parent directories, but without file contents.
---
---The result is similar to the `mkdir -p` shell command.
---
---**Example:**
---
---`fio.mktree('/home/archives')` => `true`
---
---@param path_name string
---@return boolean success, string? error_message
function fio.mktree(path_name) end

---Delete directories.
---
---**Example:**
---
---`fio.rmtree('/home/archives')` => `true`
---
---@param path_name string
---@return boolean success, string? error_message
function fio.rmtree(path_name) end

---Creates link
---@param src string existing file name.
---@param dst string linked name.
---@return boolean success, string? error_message
function fio.link(src, dst) end

---Creates link.
---
---@param src string existing file name.
---@param dst string linked name.
---@return boolean success, string? error_message
function fio.symlink(src, dst) end

---Reads link.
---
---@param src string path to the link
---@return string link_source
function fio.readlink(src) end

---Deletes link or file.
---
---@param path_name string
---@return boolean success, string? error_message
function fio.unlink(path_name) end

---Rename a file or directory.
---
---@param path_name string original name.
---@param new_path_name string new name.
---@return boolean success, string? error_message
function fio.rename(path_name, new_path_name) end

---Change the access time and possibly also change the update time of a file.
---
---For details type man 2 utime.
---
---Times should be expressed as number of seconds since the epoch.
---
---@param file_name string name.
---@param accesstime? number time of last access. default current time.
---@param updatetime? number time of last update. default = access time.
---@return boolean success, string? error_message
function fio.utime(file_name, accesstime, updatetime) end

---Copy a file. The result is similar to the cp shell command.
---
---@param path_name string path to original file.
---@param new_path_name string path to new file.
---@return boolean success, string? error_message
function fio.copyfile(path_name, new_path_name) end

---Manage rights to and ownership of file objects.
---
---**Example:**
---
--- ```tarantoolsession
--- tarantool> fio.chown('/home/username/tmp.txt', 'username', 'username')
--- - true
--- ```
---
---@param owner_user string new username.
---@param owner_group string new groupname.
---@return boolean success, string? error_message
function fio.chown(path_name, owner_user, owner_group) end

---Manage rights to and ownership of file objects.
---
---**Example:**
---
--- ```tarantoolsession
--- tarantool> fio.chmod('/home/username/tmp.txt', tonumber('0755', 8))
--- - true
--- ```
---@param path_name string
---@param new_rights number new permissions
---@return boolean success, string? error_message
function fio.chmod(path_name, new_rights) end

---Reduce the file size.
---
---@param path_name string
---@param new_size number
---@return boolean success, string? error_message
function fio.truncate(path_name, new_size) end

---Ensure that changes are written to disk.
---
---@return boolean success
function fio.sync() end

---Open a file.
---
---@param path_name string
---@param flags? number|flags|flags[]
---@param mode? number
---@return fio.file, box.error err?
function fio.open(path_name, flags, mode) end

---@class fio.file
local file_handle = {}

---Close a file.
---
---@return boolean success, string? error_message
function file_handle:close() end

---Perform random-access read on a file.
---
---@overload fun(buffer: ffi.cdata*, count: number, offset: number): number
---@param count number number of bytes to read
---@param offset number offset within file where reading begins
---@return string
function file_handle:pread(count, offset) end

---Perform random-access write on a file.
---
---@overload fun(buffer: ffi.cdata*, count: number, offset: number): number
---@param new_string string value to write (if the format is pwrite(new-string, offset))
---@param offset number offset within file where writing begins
---@return boolean success, string? error_message
function file_handle:pwrite(new_string, offset) end

---Perform non-random-access read on a file.
---
---@overload fun(buffer: ffi.cdata*, count: number): number
---@param count? number number of bytes to read
---@return string buffer
function file_handle:read(count) end

---Perform non-random-access write on a file.
---
---@overload fun(buffer: ffi.cdata*, count: number): boolean
---@param new_string string
---@return boolean success
function file_handle:write(new_string) end

---Change the size of an open file.
---
---@param new_size number
---@return boolean success, string? error_message
function file_handle:truncate(new_size) end

---Change position in a file.
---
---@param position number position to seek to
---@param offset_from? seek
---
---`SEEK_END` = end of file,
---
---`SEEK_CUR` = current position,
---
---`SEEK_SET` = start of file.
---@return number # the new position if success
function file_handle:seek(position, offset_from) end

---Get statistics about an open file.
---
---@return fio.stat
function file_handle:stat() end

---Ensure that changes made to an open file are written to disk.
---
---@return boolean success, string? error_message
function file_handle:fsync() end

---Ensure that changes made to an open file are written to disk.
---
---@return boolean success, string? error_message
function file_handle:fdatasync() end

---@alias seek
---| 'SEEK_SET'
---| 'SEEK_DATA'
---| 'SEEK_HOLE'
---| 'SEEK_END'
---| 'SEEK_CUR'

---@alias mode
---| 'S_IWGRP'
---| 'S_IXGRP'
---| 'S_IROTH'
---| 'S_IXOTH'
---| 'S_IRUSR'
---| 'S_IXUSR'
---| 'S_IRWXU'
---| 'S_IRWXG'
---| 'S_IWOTH'
---| 'S_IRWXO'
---| 'S_IWUSR'
---| 'S_IRGRP'

---@alias flags
---| 'O_APPEND' # (start at end of file)
---| 'O_ASYNC' # (signal when IO is possible)
---| 'O_CLOEXEC' # (enable a flag related to closing)
---| 'O_CREAT' # (create file if it doesn’t exist)
---| 'O_DIRECT' # (do less caching or no caching)
---| 'O_DIRECTORY' # (fail if it’s not a directory)
---| 'O_EXCL' # (fail if file cannot be created)
---| 'O_LARGEFILE' # (allow 64-bit file offsets)
---| 'O_NDELAY'
---| 'O_NOATIME' # (no access-time updating)
---| 'O_NOCTTY' # (no console tty)
---| 'O_NOFOLLOW' # (no following symbolic links)
---| 'O_NONBLOCK' # (no blocking)
---| 'O_PATH' # (get a path for low-level use)
---| 'O_RDONLY' # (read only)
---| 'O_RDWR' # (either read or write)
---| 'O_SYNC' # (force writing if it’s possible)
---| 'O_TMPFILE' # (the file will be temporary and nameless)
---| 'O_TRUNC' # (truncate)
---| 'O_WRONLY' # (write only)


fio.c = {
    seek = {
        SEEK_SET = 0,
        SEEK_DATA = 4,
        SEEK_HOLE = 3,
        SEEK_END = 2,
        SEEK_CUR = 1,
    },
    mode = {
        S_IWGRP = 16,
        S_IXGRP = 8,
        S_IROTH = 4,
        S_IXOTH = 1,
        S_IRUSR = 256,
        S_IXUSR = 64,
        S_IRWXU = 448,
        S_IRWXG = 56,
        S_IWOTH = 2,
        S_IRWXO = 7,
        S_IWUSR = 128,
        S_IRGRP = 32,
    },
    flag = {
        O_EXCL = 2048,
        O_NONBLOCK = 4,
        O_RDONLY = 0,
        O_CLOEXEC = 16777216,
        O_SYNC = 128,
        O_NDELAY = 4,
        O_WRONLY = 1,
        O_TRUNC = 1024,
        O_NOFOLLOW = 256,
        O_RDWR = 2,
        O_ASYNC = 64,
        O_CREAT = 512,
        O_APPEND = 8,
        O_DIRECTORY = 1048576,
        O_NOCTTY = 131072,
    }
}

return fio
