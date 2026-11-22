# Hello-World
Hello, world !

One "Hello, World" per language, built for every supported platform by the release workflow.

# Architectures

- [x] Linux x86-64
- [x] Linux ARM64

- [x] Windows x86-64
- [x] Windows ARM64

A language is built on a platform when it has a `<arch>/` folder and is not listed in its `unsupported.txt`
(one `<os>-<arch>` target per line, for example `windows-arm64`).

# Languages

Languages live in `hello/<category>/<language>/`.

## Roadmap

- [x] x86_64 Binary
- [x] x86_32 Binary
- [x] x86_64 Machine Code
- [x] x86_32 Machine Code
- [x] x86_32 Assembly
- [x] x86_64 Assembly
- [x] BASIC
- [x] COBOL
- [x] Fortran Fixed
- [x] Fortran Free
- [x] ALGOL-58
- [x] ALGOL-60
- [x] LISP
- [x] CPL
- [x] BCPL
- [x] C
- [x] Objective-C
- [x] C++
- [x] C#
- [x] D
- [x] Go
- [x] Nim
- [x] Zig
- [x] V
- [x] Ruby
- [x] R
- [x] Rust
- [x] Kite
- [x] Python
- [x] Java
- [x] HTML/CSS
- [x] JavaScript
- [x] PHP
- [x] Pony
- [x] Pascal
- [x] Shell
- [x] Batch

Added on top of the roadmap: ALGOL-68, Forth, Ada, Crystal, Modula-2, Vala, Haskell, OCaml, Scheme, Racket,
Prolog, Perl, Lua, Tcl, AWK, Brainfuck.

## By category

| Category | Languages |
|---|---|
| `machine/` (hand-written executables) | x86_64 Binary, x86_32 Binary, x86_64 Machine Code, x86_32 Machine Code |
| `assembly/` | x86_64 Assembly, x86_32 Assembly |
| `historical/` (before 1990) | BASIC, COBOL, Fortran Fixed, Fortran Free, Pascal, ALGOL-58, ALGOL-60, ALGOL-68, CPL, BCPL, Forth |
| `systems/` (native, compiled) | C, C++, Objective-C, D, Go, Nim, Rust, V, Zig, Ada, Crystal, Modula-2, Vala, Kite |
| `concurrent/` (actor model) | Pony |
| `functional/` | LISP, Scheme, Racket, Haskell, OCaml |
| `logic/` | Prolog |
| `managed/` (virtual machine) | Java, C# |
| `scripting/` | Python, Ruby, JavaScript, PHP, Perl, Lua, Tcl, AWK |
| `scientific/` | R |
| `shell/` | Shell, Batch |
| `markup/` | HTML/CSS |
| `esoteric/` | Brainfuck |

## How each language is delivered

- **Standalone executable**: most compiled languages. Ruby on Linux is compiled with mruby (static bytecode
  runtime, no Ruby installation needed); on Windows it uses OCRAN.
- **Source file** (the artifact is the program itself, checked with an interpreter when one is installed):
  BASIC, ALGOL-58, ALGOL-60, ALGOL-68, CPL, BCPL, Forth, Perl, Lua, Tcl, AWK, R, Shell, Batch, HTML/CSS.
  PHP is delivered as a runnable `.phar`.
- **Not verifiable today**: ALGOL-58, ALGOL-60, CPL and BCPL have no maintained toolchain available in CI,
  so their files are only checked for their content.

## Platform notes

- `machine/` and `assembly/` are x86 only and Linux only.
- COBOL, Fortran, Pascal, LISP, Haskell, OCaml, Scheme, Racket, Prolog, Ada, Crystal, Modula-2, Vala, Kite, Pony,
  Brainfuck and PHP are built on Linux only for now.
- A language whose toolchain cannot be installed on a runner (`install.sh` exits with code `77`) is skipped
  instead of failing the whole release. This is the case for Pony when `ponyup` is unreachable, and may
  happen for Crystal, Modula-2, Vala and Racket on distributions that do not package them.
- Kite is built with the official installer (`kite-lang.pages.dev`); if it fails, the compiler is built from
  `https://github.com/kite-language/kite` with cargo. Kite needs `clang`.

## Build locally

```bash
./scripts/install.sh                       # system update (Linux)
./scripts/compile.sh                       # every language, results in dist/
HELLO_LANGUAGES=C,Rust,Kite ./scripts/compile.sh   # only some languages
```

On Windows: `scripts\install.bat` then `scripts\compile.bat`.
