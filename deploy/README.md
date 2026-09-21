# Deploy configuration

`vercel.json` is copied into `build/web/` by the web build workflow after Godot exports the site.

This keeps deployment configuration separate from the Godot project files while ensuring the generated static site carries the headers/cache rules Vercel needs.
