# VelaSU Lua Bootstrap Watchface

This is the source overlay used by `.github/workflows/build-lua-watchface.yml`.

The CI workflow pins `FangAiden/LuaDevTemplate` to commit
`0eb8346ce0c9c11f2316c6b154ed91fd4a0d419d`, overlays this directory's `app/` tree, and builds a `.face` artifact on a Windows runner.

The current bootstrap is UI-only and performs no native loading or persistent system modification.
