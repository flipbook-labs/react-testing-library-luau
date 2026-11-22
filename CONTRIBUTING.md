# Contributing

Set up the toolchain and dependencies once:

```sh
rokit install      # toolchain (lute, rojo, darklua, selene, stylua, wally, ...)
lute run install   # Lute packages + Wally dependencies
```

Then run the checks before you open a pull request:

```sh
lute run lint      # selene + stylua
lute run analyze   # strict typecheck (luau-lsp, new solver)
lute run test      # jest via rocale-cli cloud execution
```

`lute run test` runs the specs in Roblox through Open Cloud, so it needs `ROBLOX_API_KEY` set in a `.env` file or the environment.

User-facing changes need a `.changes/` entry. See [`.changes/README.md`](.changes/README.md) for the fields. [AGENTS.md](AGENTS.md) covers the shared agent guidance and the repo layout.
