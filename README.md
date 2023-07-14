# Bittify 🎵🎶

[![wakatime](https://wakatime.com/badge/user/f5667326-f378-4a99-aacd-abd866a8364d/project/c531fef6-7f26-4dc9-9ce5-bae4281ad3a8.svg)](https://wakatime.com/badge/user/f5667326-f378-4a99-aacd-abd866a8364d/project/c531fef6-7f26-4dc9-9ce5-bae4281ad3a8)
[![Export Bittify for All Platforms](https://github.com/Jyodann/Bittify/actions/workflows/godot_deploy.yml/badge.svg)](https://github.com/Jyodann/Bittify/actions/workflows/godot_deploy.yml)
[![Github All Releases](https://img.shields.io/github/downloads/jyodann/Bittify/total.svg)]()
# General
## About 🐳
Bittify is a rebuild of [Minify](https://github.com/Jyodann/MinifyPlayer/) in the Godot Engine. 

It is a Miniplayer built for Windows, MacOS and Linux which shows the current song you have playing on [Spotify](https://www.spotify.com/us/download/). 

Useful for people who want to see what songs are currently playing without constantly tabbing back to the main application. It also be used as a Window Source on OBS for Twitch streamers to easily show what they are listening to.

[Download it here](https://github.com/Jyodann/Bittify/releases/tag/v0.1.0-alpha)

## How do I use it ❓
1. Unzip/unpack the file, then open the .dmg or .exe file:

![image](https://github.com/Jyodann/Bittify/assets/48559311/3d95e107-7aef-497d-9fe0-a022ff8781c2)

2. Click on "Login to Spotify", you will be brought to the Spotify Login page to Login.
3. Agree to the Information to share with Bittify. Do note that Bittify **does not store any of your information**
4. Paste the Given code into the App and Click Go!
5. You will be greeted with a Settings Menu at first, you can change some of the player settings before clicking **"Launch Player"**

![image](https://github.com/Jyodann/Bittify/assets/48559311/9e65da2e-7844-4e8a-a9c4-5a544fa2d5fc)

![image](https://github.com/Jyodann/Bittify/assets/48559311/772fa42c-6afc-44de-9771-d16dd2e46d4b)


6. Feel free to resize the player to your liking, and use it as an OBS source. 

## FAQ 🤔

### Why does the player take so long to refresh my song?

Sadly, due to [Spotify's Usage Quotas](https://developer.spotify.com/policy#vii-access-usage-and-quotas) , I have to limit the number of times I ask the Spotify Servers for information. I am actively looking for a better way to do things, if you have any ideas, please feel free to drop me an email here: jordynwinnie@gmail.com or open a pull request

# Technical Details
## Why did you re-write this in Godot (again)? 💭

When using Unity, I faced many issues with Window-based opeartions, and also MacOS was really wonky with Unity. Godot was choosen due to the simpler Window Manager, and also after a lot of experimentation. I will be writing this whole application with GDScript, and re-architecting the app to support quicker building of features. 

There are actually a few other builds of Bittify/Minify, here are some of them and the issues I have faced:

- Godot (with C#)
    For some reason, C# support does not have the proper async/await use with the HTTPRequest Node, so even though a lot of the app was finished with Godot C#, I ultimately had to drop it. Godot has also yet to rework some of the GDScript features (like exporting to web) for C#
- Tauri (Rust+Svelte+TailwindCSS)
    I spent maybe 4 weeks on this build. I ultimately had to scrap it as the windowing and media queries for the Marquee effect were a bit too much for me to handle. 
    
