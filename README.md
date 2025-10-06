# Shootaz

_A simple, customizable, open-source aim trainer._

### Features

- Creating maps and scenarios using [Lua](https://www.lua.org/) scripts.
- Support for normal aiming maps and tracking.

### Why?

I wanted to improve my aim in FPS games and I realized that the main options in the aim community are [Aimlabs](https://aimlabs.com/) and [Koovak's](https://www.kovaaks.com/). 

I wanted to learn more about game development without a game engine, so I decided that making an aim trainer would be a good way of doing it, due to it's relatively simple nature.

**NOTE:** Shootaz is incredibly barebones and lacks many features that the aforementioned aim trainers have. It does not seek to replace either of them, but I do wish for it to one day offer a similar experience to them.

### Building

_Prerequisites: you must have [Zig](https://ziglang.org/) 0.15.1 installed._

Run this for a debug build:

      zig build

Run this for a release build.

      zig build -Doptimize=ReleaseFast

[There are more build modes if you wish to use them.](https://ziglang.org/documentation/0.14.1/#Build-Mode)

### Configuration

Inside `config/` you will find `.zon` files which can be modified in order to alter the game experience, allowing you to change things such as controls and statistics settings.