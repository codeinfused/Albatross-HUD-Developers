<div id="top"></div>
<!--
*** Thanks for checking out the Best-README-Template. If you have a suggestion
*** that would make this better, please fork the repo and create a pull request
*** or simply open an issue with the tag "enhancement".
*** Don't forget to give the project a star!
*** Thanks again! Now go create something AMAZING! :D
-->


<!-- PROJECT SHIELDS -->
<!--
*** I'm using markdown "reference style" links for readability.
*** Reference links are enclosed in brackets [ ] instead of parentheses ( ).
*** See the bottom of this document for the declaration of the reference variables
*** for contributors-url, forks-url, etc. This is an optional, concise syntax you may use.
*** https://www.markdownguide.org/basic-syntax/#reference-style-links
-->
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![MIT License][license-shield]][license-url]
[![Twitch][twitch-shield]][twitch-url]



<!-- PROJECT LOGO -->
<br />
<div align="center">
  <a href="https://github.com/codeinfused/Albatross-HUD-Developers">
    <img src="images/albatross-logo-wide.png" alt="Logo" style="width:600px; max-width:80%;">
  </a>

  <h3 align="center">Albatross HUD Developer Edition</h3>

  <p align="center">
    A customizable piloting HUD skin for Dual Universe!
    <br />
    <a href="https://twitch.tv/codeinfused">Watch a Demo</a>
    ·
    <a href="https://github.com/codeinfused/Albatross-HUD-Developers/issues">Report Bug</a>
  </p>
</div>



<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li><a href="#about-albatross-hud">About the HUD</a></li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#installing">Installing</a></li>
        <li><a href="#build-process">Build Process</a></li>
        <li><a href="#source-files">Source Files</a></li>
        <li><a href="#updating-build-version">Updating Build Version</a></li>
      </ul>
    </li>
    <li>
      <a href="#The Code">The Code</a>
      <ul>
        <li><a href="#methodology">Methodology</a></li>
        <li><a href="#unit-start">Unit Start</a></li>
        <li><a href="#system-events">System Events</a></li>
        <li><a href="#html-template">HTML Template</a></li>
        <li><a href="#adding-altkey-buttons">Adding AltKey Buttons</a></li>
      </ul>
    </li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#license">License</a></li>
  </ol>
</details>



<!-- ABOUT ALBATROSS HUD -->
## About Albatross HUD

This piloting HUD for Dual Universe is designed for players of all experience levels. It's a visual improvement over the default, adding new features and flight controls to assist both new players and veterans. Our goal with this release is make sure everyone has access to an easy-to-use HUD and make their Dual Universe experience a little better.

_**Developer Version:**_
**If you are just looking to download the HUD, you're in the wrong place! See the "Community" version below.**  This version of the Albatross HUD is the raw build files for developers to tweak and contribute to, including my custom build process _(I had developed a build process for my own needs before the community released much better ones, and just stuck with my solution)._ As a warning, there are lots of commented-out blocks; either with older code or with unfinished features.

_**Community Version:**_
The community version has the downloadable autoconf files for fast installation, along with all the instructions for customizing the HUD's colors and setup. [Albatross HUD Community Version](https://github.com/codeinfused/Albatross-HUD-Community)

<p align="right">(<a href="#top">back to top</a>)</p>



<!-- GETTING STARTED -->
## Getting Started

_I have a custom build process that I made in alpha and stuck with, it compiles and minifies the source files together using npm and then builds the autoconf yaml for you. It's certainly not the best process, and updating the version number is a bit of a hassle (see that section)._

_FYI: This build process was made for Windows, and the npm commands would have to be tweaked to run on Mac._

### Installing

You'll need node/npm installed. If running on Windows, I'd also recommend installing "nvm-windows" for managing the node version. This build has been tested up to `20.17.0`. Then simply run `npm install` to get the necessary dependencies.

### Build Process

Before running the build command, check the package.json for any changes to your local path you may need. There's likely a better way this could be done via environment variables. Also check the "Updating Build Version" section below if you want to rename your test builds.

This command will build the entire minified autoconf to the build folder: `npm run build:all`

### The Source Files

_Source files for editing are located in `/src`, and the other folders should not be touched for the most part._ 

* `/src` Most of the raw Lua files for the HUD, broken into functionality pieces.
* `/yaml` Holds the yaml template that gets used to build the autoconf, the System events are key.
* `/build` Temporary folder that build files go into.

For details on the component files inside the src path, see The Code section below.

### Updating Build Version

It's a bit tedious, but when updating the version number _(such as 2.4.4)_, there are a few different files to change **before** running the build process.

* `/yaml/hud_template.conf` The "name" attribute is what will show in the game's menu when selecting a custom autoconf to use.
* `/package.json` "version": _Don't PR updates to this number, as actual version updates in the main repo will be maintained._
* `/package.json` The "compile" script on line 22 also puts the version number into the output file's name.
* `/src/unit-start.lua` Around line 426 is the version number that gets printed into the game HUD display.

<p align="right">(<a href="#top">back to top</a>)</p>



## The Code

### Methodology

Ideally, each functional component of the HUD should live in a separate Lua file. For example, `library-fuel.lua`, `library-throttle.lua`, `library-agg.lua`, etc. 

Each of these components is set up as a singleton object, with an `:init()` to define what needs to run during the `unit.start` bootup. Any methods of the component, such as: keybind actions, renders, events, keyframes.. should all live within the component file if possible. For a good example, check out the **Throttle** component. It has keybindings, html/svg templates, and creates one of the UI's buttons.

### Unit Start

The components first get loaded into the library's start event. Then the `unit-start.lua` file starts up the HUD. It sets up the customizable variables that a user can change in Lua Parameters. It also reads from a databank to pull stored params. Most important, **_every component needs to run their :init() method here._** Commenting out a component's init() call will disable that component.

There are also a couple of minor components here that I didn't break into their own files, such as the headlights toggle and HUD-Engineer toggle.

Additionally, the core functions of the Flight code get registered into System-Flush from here _(see system flush in next section)_. These functions, such as torque/rotation/brakes, are assigned an order of execution using the SystemFlush registry. You can replace or supercede these with your own. If you read the `library-flight.lua` you'll notice that it is mostly the stock NovaQuark Flight Navigation, but injected into my modular setup.

### System Events

If you look at the `hud_template.conf` file, you'll note the two key system events run their loops there: `SystemFlush:exec()` and `KeyActions:exec('system', 'update')`, for the Flush and Update events respectively.

**SystemFlush** is an event registry for specifically ordering the sequence of Flush code to run. As noted above in "Unit Start", all the default Navigation code is in `library-flight.lua`. If you use the same **SystemFlush** registry ID number as an existing one, it will replace it in the execution queue.

The other event registry class is called **KeyActions**. It is used moreso for keybinding events, but I'm also using it to fire the System Update event function _(which is also registered in library-flight)_.

With **KeyActions**, you can register known event types, such as keybindings, or create your own pubsub uses. Each event you bind needs a custom name for the registry index, which allows multiple functions to be bound to the same event action. To register an event:

`KeyActions:register( [event type], [name of action to listen for], [name for registry index], [singleton object], [method of the singleton object] );`

For example, the "OnStart" event of pressing Alt:4 is `KeyActions:register('start', 'option4', 'APAlign', Autopilot, 'stop');`

To trigger all the registered events of a type, use `KeyActions:exec( [event type], [action] );` such as `KeyActions:exec('start', 'option4');`

### HTML Template

I wrote a custom HTML templating engine that also minifies the HTML. Like most templating libs, you define the template as a string, and your template contains the pattern `{{...}}` to identify swappable parts. Whatever name you give inside becomes the registered name of that block, such as `{{ReticleFwd}}`. You'll use that block's name to define what to replace it with.

To create a new template object, `local mytmp = Template.new( [template string] );`

To change what is being stored in a block within the template, for example:
`mytmp:bind({ReticleFwd = "<polygon class='' />})`

Instead of replacing the block with a string, you can use a function (which will be called at render):
`mytmp:bind({ReticleFwd = Reticle.render})`

You can listen for when the template's render is called:
`mytmp:listen( Reticle.afterRender );`

And, to manually trigger the render event:
`mytmp:render()`

### Adding AltKey Buttons

Another registry class exists for all of the UI Buttons in the lower-right of the HUD. Registering a new button will place it visually in the order it was added. Because of this, several the `:init()` calls inside `Unit Start` are defined in a specific order to have their UI Buttons show up in that order.

To register a button:
`local mybutton = HUD.buttons:createButton( [registry name], [label text], [key command], ["on" or "off" or "lock" or "dis"] )`

"on" = green, "off" = red, "lock" = yellow, "dis" = greyed out.

You can update the state of the button, and you can also optionally update the label text of the button:
`mybutton.button:toggle({active = "on", label = "Autopilot Is On"})`

<p align="right">(<a href="#top">back to top</a>)</p>



<!-- CONTACT -->
## Contact

_While I do love Dual Universe and its community, I also have very little free time typically. I will try to answer questions via Discord, or if you catch me online on Twitch. But keep in mind this is a free resource, and I've spent a good chunk of time on it, so please be constructive and kind :)_

Discord: [Albatross HUD on DU-OSI](https://discord.gg/EThSxMGXBg)

Twitch: [Watch CodeInfused on Twitch](https://twitch.tv/codeinfused)<br/>
_I go online at pretty random times, so if you'd like to catch my streams, just go here and hit Follow_

<p align="right">(<a href="#top">back to top</a>)</p>



<!-- CONTRIBUTING -->
## Contributing

Use the Discord above if you'd like to give feedback or have questions about the codebase here. I will try to answer as best I can. I'm definitely open to contributions and pull requests to update the main repo here, but the "Community Version" is a different repo so I can ensure a complete version is maintained separately there for non-developers.

<p align="right">(<a href="#top">back to top</a>)</p>



<!-- LICENSE -->
## License

Distributed under the GNU GPLv3 license. See `LICENSE.txt` for more information.

<p align="right">(<a href="#top">back to top</a>)</p>



<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[download-url]: https://github.com/codeinfused/Albatross-HUD-Community/raw/main/ais_albatross_hud_2_2_0.zip
[contributors-shield]: https://img.shields.io/github/contributors/codeinfused/Albatross-HUD-Developers.svg?style=plastic
[contributors-url]: https://github.com/codeinfused/Albatross-HUD-Developers/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/codeinfused/Albatross-HUD-Developers.svg?style=plastic
[forks-url]: https://github.com/codeinfused/Albatross-HUD-Developers/network/members
[stars-shield]: https://img.shields.io/github/stars/codeinfused/Albatross-HUD-Developers.svg?style=plastic
[stars-url]: https://github.com/codeinfused/Albatross-HUD-Developers/stargazers
[issues-shield]: https://img.shields.io/github/issues/codeinfused/Albatross-HUD-Developers.svg?style=plastic
[issues-url]: https://github.com/codeinfused/Albatross-HUD-Developers/issues
[license-shield]: https://img.shields.io/github/license/codeinfused/Albatross-HUD-Developers.svg?style=plastic
[license-url]: https://github.com/codeinfused/Albatross-HUD-Developers/blob/master/LICENSE.txt
[twitch-shield]: https://img.shields.io/badge/twitch-live-red?logo=twitch&style=social
[twitch-url]: https://twitch.tv/codeinfused
[product-screenshot]: images/screenshot.png
