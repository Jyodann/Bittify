# Bittify 🎵🎶
## About 🐳

Bittify is a rebuild of [Minify](https://github.com/Jyodann/MinifyPlayer/) in the Godot Engine. 

It is a Miniplayer built for Windows, MacOS and Linux which shows the current song you have playing on [Spotify](https://www.spotify.com/us/download/windows/). 

Useful for people who want to see what songs are currently playing without constantly tabbing back to the main application. It also be used as a Window Source on OBS for Twitch streamers to easily show what they are listening to.

## Why did you re-write this in Godot (again)? 💭

When using Unity, I faced many issues with Window-based opeartions, and also MacOS was really wonky with Unity. Godot was choosen due to the simpler Window Manager, and also after a lot of experimentation. I will be writing this whole application with GDScript, and re-architecting the app to support quicker building of features. 

There are actually a few other builds of Bittify/Minify, here are some of them and the issues I have faced:

- Godot (with C#)
    For some reason, C# support does not have the proper async/await use with the HTTPRequest Node, so even though a lot of the app was finished with Godot C#, I ultimately had to drop it. Godot has also yet to rework some of the GDScript features (like exporting to web) for C#
- Tauri (Rust+Svelte+TailwindCSS)
    I spent maybe 4 weeks on this build. I ultimately had to scrap it as the windowing and media queries for the Marquee effect were a bit too much for me to handle. 
    