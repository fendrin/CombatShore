This is a design document, scripting where the development of CombatShore shall head for.
Don't expect anything of the described working right now.

Content Types
=============

The game was designed with easy and versatile content creation in mind
as a design goal.  ugly sentence!!!! Thus it offers a public
[API](https://en.wikipedia.org/wiki/API) for writing your own stories.

The following content types are ordered by skill level required for
their mastery.

[Content API documentation](file:docs/API)

Map
---

Most Scenarios rely on predefined maps which can be created within the
[Map Editor](#Map-Editor).

But it is also possible to create a pure map that comes without any
event scripting. Those maps are for usage in skirmishes or multiplayer.

Scenario
--------

Scenarios extend on the map concept by adding event
[scripting](#ScenarioScripting) capabilities. Those allow for difficulty
levels, story telling, complex objectives, new or modified game
mechanics and [more](file:docs/API/campaign.html).

Campaign
--------

A campaign is a sequenced (or otherwise connected) set of scenarios
following (in most cases) the storyline of a faction or protagonist.
Usually a subset of units, resources and knowledge is transferred into
the next scenario in this game mode. It is also possible to share
information between the scenarios allowing dynamic events.

Campaigns support [Difficulty Level](#Difficulty-Level)

### Singleplayer Campaign

Supposed to be played offline by a single player.

### Multiplayer Campaign

Supposed to be played online by multiple players.

#### Cooperative Multiplayer Campaign

#### Competitive Multiplayer Campaign

Faction
-------

A faction is a set of unit and building types available to a playable
group.

Era
---

Eras define a set of factions meant to compete with each other. An Era
meant for use in competitive multiplayer content is supposed to have the
factions to be balanced against each other.


Artificial Intelligence
-----------------------

The AI that controls the non player sides.  
Developing an AI from scratch is a hard and time consuming task.
Nevertheless, a AI is not more than a function that takes the current
known game state as an argument and returns a set of actions the side
will try to perform during the next turn.

Beside writing an AI completely from scratch AI frameworks can be used.
The API is framework specific but CS ships with a default
[one](file:docs/API/AI.html).

Conversion
----------

A total conversion replaces the game's core, providing its own game
mechanics with a high degree of freedom. In most cases it will also rely
on its own AI, factions and eras.

Assets
------

Assets mostly consists of binaries containing artwork.

### Music

Supported music formats are:
ogg, wav and mp3

Usually music is shipped within a module of type campaign, conversion.
But if you have reusable music it might be worth to ship it in an extra
package.

#### Replacement Music Pack

The music titles in such a module share the id's with the music of core
or A replacement music pack might replace the default playlist with a
set of another style.

#### Additional Music

These music files come with fresh identifiers meant to be used by other
modules deliberately.

### Meshes

3D Meshes for buildings and units.
LOVR supports OBJ, glTF, and binary STL files.

Modules
=======

Add-ons come in modules which are loaded on demand. So CS only uses
those modules which are needed to start a game.  
This shall safe loading time, memory consumption and prevent properties
of different add-ons shadowing each other.

Locations
---------

| OS      | Path                                    |
| ------- | --------------------------------------- |
| Linux   | ~/.local/share/LOVR/CombatShore/modules |
| Windows |                                         |
| MacOSX  |                                         |

Dependencies
------------

It is good practice to split your add-on into several modules to provide
better re-usability for yourself and other content creators.

In order to get everything loaded a module needs to specify which other
modules it depends on.

Packages
--------

A module package contains one or more modules for CombatShore.  
It is usually shipped in form of a packed archive file with the suffix
*.CombatShore*.

The file is a normal zip archive.  
They can be unpacked like this:

``` bash
unzip *.CombatShore
```

Files
-----

CombatShore's content files are either '*.moon' files containing
Yuescript or a '*.lua' files containing Lua.  
If both files (same name, different suffix) are present it is assumed
that the lua file is compiled from the Yuescript one and preferred for
performance reasons.

### Including Files

To make things easy for the designer (and for security reasons) the 
usual way to include files and load modules in Lua/Yuescript is not supported.

This means the *require* function is not available for module coder.

Instead files containing code (other as assets) are all loaded in lexical order. TODO: link to a definition of that exact order.
[iff](https://en.wikipedia.org/wiki/If_and_only_if) their 
[extension](https://en.wikipedia.org/wiki/Filename_extension) is one of the supported languages'. TODO: is that grammar right?

### Lua Bytecode

Note: If you don't know about bytecode and are not courious feel free to skip this section.

Some implementations of Lua support [bytecode](https://en.wikipedia.org/wiki/Bytecode).
[luajit](https://luajit.org/luajit.html) the [just in time](https://en.wikipedia.org/wiki/Just-in-time_compilation) 

### Config File

Location depends on your operating system Linux:

| OS       | Path                                                                 |
| -------- | -------------------------------------------------------------------- |
| Linux    | ~/.local/share/LOVR/CombatShore/config.moon                          |
| Windows  | C:\Users\user\AppData\Roaming\LOVR\CombatShore\config.moon           |
| MacOSX   | /Users/user/Library/Application Support/LOVR/CombatShore/config.moon |

Table shows the location of the config file

You may want to edit the config file and enable the debug mode while
developing an add-on.  
You do so by changing 'debug: false' to 'debug:
true'.

### Init File

Your module needs a 'init.moon' or 'init.lua' file which contains the
basic information.

This file is read when the server starts up. The rest of the addon is
only loaded if the player starts the game with a configuration in need
of it.

In the init file you can make use of several functions to register your
addon. Those are

-   Campaign
-   Faction
-   Era
-   Mod

Each of them (like all global functions in the addon namespace) takes a
single table as the first and only argument. This table needs a
key/value pair with the key 'id'. Sounds complicated but the Syntax is
easy:

``` yuescript
Campaign
   id: 'starleague'
   name: _'Star League'
   description: _"Follow the rise and fall of the famous Star League from it's beginning to the bitter end."
   depends: 'unitpak_starleague'
```

Note that 'name' and 'description' are holding strings which are
presented to the user.  
For that matter they are pretended by '\_', a predefined function that
takes the string as an arguement and uses gettext to translate in the
user's language if possible.

The Lua syntax is slightly more heavy:

``` lua
Campaign({
   id= 'starleage',
   name= _('Star League'),
   description= _ ("Follow the rise and fall of the famous Star League from it's beginning to the bitter end."),
   depends= 'unitpak_starleague'
})
```

Note: You can register more than one module in a single init file.
Meaning a single package can contain a Mod that comes with it's own Era
containg their own factions with corresponding campaigns.

### DataFiles

Data files contain Lua/Yuescript code and are read by the server. It is
a convention to group them into directories like

units maps scenarios

### AssetFiles

Have a look at the module api [module api](file:docs/API/toplevel.html).

Note: Other from calling one of the functions from the module API you
can do all kind of calculations.

``` moonscript
campaign = {

}

for i=1, 10
   Campaign
      id: "${}"
```

DirectoryStructure
------------------

The addon namespace does not feature Lua's usual way of loading more
code from files with the 'include' function method.  
Instead every file is loaded and evaluated in alphabethical order
(except the init file which always comes first).

For every module registered in the init file a directory with the name
matching the module's 'id' at the same level in the filesystem
hierarchy.

-   init.moon
-   starleague
    -   units
    -   maps
    -   scenarios

Environments
------------

### Predefined Variables

Depending on the context the code is executed in different environments.

#### CommonPredefinedVariables

Lua/Yuescript can't be used properly without a minimum of helper functions.
Thus they are part of every environment you can stumble upon in CombatShore.

*pairs* and *ipairs* are used when [iterating](https://www.lua.org/pil/7.3.html)
over tables in for loops.

*string*
TODO: exposing the whole string object might lead to some security issues. Investigate!

#### init phase

At startup the server will read the init (and only the init) file found
at the toplevel of each module. During that process only the functions
found in the [module api](file:docs/API/module.html) are part of the
environment.

This means only CAMPAIGN, ERA, MOD and FACTION are predefined functions
usable in the init file.

#### loading phase

During the loading phase every Lua/Yuescript file of every module that 
is part of the started campaign/scenario is processed.

[toplevel api](file:docs/API/toplevel.html)

| Function name |         |
| ------------- | ------- |
| SCENARIO      |         |
| UNIT_TYPE     |         |
| TERRAIN_TYPE  |         |
| MAP           |         |
|               |         |

#### event handler execution

Whenever an event is fired all event handlers of its type are checked
for matching filter rules and their *do* function is executed if so. 
Only during event handler execution the [action api](file:docs/API/action.html) can be used.

Map Creation
============

Pure Maps (without any scenario scripting) can be designed without any
coding skills.

Coordinate System
-----------------

Unlike most hex field games Combat Shore uses 
[Axial Coordinates](https://www.redblobgames.com/grids/hexagons/#coordinates).

Note: The website distinquishes between *flat* and *pointy* hex field orientation.
In a full 3d application where the player can choose an arbitrary viewpoint that differentiation is pointless.

I have used that website a lot.
TODO: Sadly at the time of this writting I have not found a donation system.

The default orientation is what the guide at redblobgames calls *pointy*.
Note that you can switch to *flat* oriented hex fields in both,
Combatshore and the interactive website.

TODO: Does that even make sense in a full 3d application? I guess not.

The hex field in the center of the map is always located at 0/0.

The *Q* coordinate 

Map Editor
----------

### Modes

#### Height

In this mode you define the height level of each hex field.
Zero equals the sealevel of the planet you battle on.  Negative heights mean underwater.
On a planetary body without an ocean it is the lowest geographical point 

#### Terrain

### Areas

Areas are a set of hexfields bound to an identifier for referencing
them. They are meant to define regions on the map which can then be used
during scenario scripting. Currently there is no other way to put them
into use.

### Units

### Buildings

Map Files
---------

Maps are stored in a human readable file format and are also Lua or
Yuescript code. They are usually only written into by the map editor
but can be modified manually.

[toplevel API map](file:/docs/API/toplevel/map.html)

Scenarios can make use of a map generator but in most cases they will be
based on a predefined map as well.

Map Generators
--------------

A map generator is basically a function returning the generated map. 
The returned map needs to be a table in the same format as the 
[MAP](file:docs/API/toplevel/MAP.html) function accepts.

Your generator can either follow the default interface 
(meaning it can replace the generator CS ships with easily)
or you can define your own.
[toplevel API mapGenerator](file:docs/API/toplevel/mapGenerator.html)

Scenario Scripting
==================

Side Definitions
----------------

[API Sides](#file:docs/API/sides.html)

``` moonscript
SCENARIO
   sides: {
      {
         id: 'player' 
         controller: 'human'
         team: 'goodies'
      }
      {
         id: 'ally'
         controller: 'ai'
         team: 'goodies'
      }
      {
         id: 'foe1'
         controller: 'ai'
         team: 'enemy'
      }
      {
         id: 'foe2'
         controller: 'ai'
         team: 'enemy'
      }
   }
```

``` yuescript
SCENARIO
   sides: 
      *  id: 'player' 
         controller: 'human'
         team: 'goodies'   
      *  id: 'ally'
         controller: 'ai'
         team: 'goodies'	  
      *  id: 'foe1'
         controller: 'ai'
         team: 'enemy'
      *  id: 'foe2'
         controller: 'ai'
         team: 'enemy'
``` 

This scenario definition defines a 2 vs 2 setup in wich the player
fights with a computer controlled ally against two allied enemies.

Scenarios are defined by calling the
[SCENARIO](file:docs/API/toplevel/scenario.html) function with a table
as its single argument. Script heavy scenarios mostly consist of event
handler functions.

Every scenario needs a unique identifier (the 'id' key).
You need to specify the *id* and also need a map to play on.

Event Handlers
--------------

> It can't hurd if you already have a rough idea about 
> [functions](https://en.wikipedia.org/wiki/Function_(computer_programming)).

Most (TODO if not all?) happenings in the game trigger a corresponding event
to be fired.

By defining handlers for a type of event the content creator can script
the scenario's mechanics.

Whenever an event is fired each defined event handler of the corresponding type
will be checked for execution.

``` moonscript
{
   type: 'moveto'
   firstTimeOnly: false
   filter:
      id: 'tank5'   
}
```

### Event Types

#### Events only fired once

| Name      |           |
| --------- | --------- |
| preload   |           |
| prestart  |           | 
| start     |           |
| endgame   |           |

#### Repeating Events

| Name       |              |
| ---------- | ------------ |
| new_turn   |              |
| turn  X    |              |
| moveto     |              |
| moveover   |              |
| sighted    | fires when the primary unit is sighted by the secondary |   
   
This events are fired more than once, for example fires *moveTo* every time a unit moves.

The *do* function of an event handler is executed only once by default.

``` yuescript
{
   type: 'moveTo'
   firstTimeOnly: false -- true is the default
   do: ->
}
```

#### Costum Event Types

You can use [FIRE_EVENT](file:docs/) to fire your own or one of the predefined events by your own.

``` yuescript
events:
   *  type: 'start'
      do: -> 
         FIRE_EVENT
            type: 'myOwnEvent'
   *  type: 'myOwnEvent'
      do: ->
         MESSAGE
            text: 'myOwnEvent fired!'
```

### Event Filter

Before the execution of the event all defined filters must match.

A filter is either a table [filter API](file:docs/API/filter.html) or a
function that takes as first and only arguement the table the filter
shall be checked against. 
It must return *true* if the filter matches and *false* otherwise.

You can filter for:

| filter name    |          |
| -------------- | -------- |
| primary unit   | the unit that triggered the event to be fired (attacker, mover, ...) |
| secandary unit | a second unit involved in the event (defender, spotted unit, ...)    |
| location       | the map location the event occured upon                              |
| time of day    |                                                                      |

* primary unit 
    When the event is triggered by a unit this unit must
match the specified filter.
secondary unit Some event types involve a secondary unit. For
example the attack event features the attacker as the primary and
the defender as the secondary unit.

``` yuescript
events:
   *  type: 'moveTo' 
      filter: 
         side: 2 
         q: 46 
         r: 35
      do: ->
         Message text:'Side ${SIDES[2].name} has reached 46/35'
   *  type: 'moveTo' 
      filter: (unit) -> 
         unit.side == 2 and unit.q == 46 and unit.r == 35
      do: -> 
         Message text:'Side ${SIDES[2].name} has reached 46/35'
   *  type: 'moveTo' 
      filter: (unit) ->
         FILTER_UNIT unit,
            side: 2
            q: 46
            r: 35
      do: -> 
         Message text:'Side ${SIDES[2].name} has reached 46/35'
```

In the above example all event handler's *do* scripts will execute
when player 2 moved a unit to the coordinates 46/35.

### Filter Functions vs Filter Tables

``` yuescript
event:
   type: 'turn 5'
   do: ->
      STORE_UNITS
         filter:
            r: 34
            q: 16  
      STORE_UNITS
         filter: (unit) ->
            unit.r == 34 and unit.q == 16
```

Both function calls will store the units at the hex field 34/16 into a table list.
The method using the function will have a much longer runtime in this context.
Whenever a filter is applied to a set of units it will be aplied to each unit in question.
In this case STORE_UNITS filters over every unit present on the map.

The filter table allows for a much quicker result as it only checks the hex file in question.

### Event Function

Each event handler defines a *do* function.
TODO: think about renaming the function. *do* is a keyword in Lua/Yuescript.

Every effect of the event handler is scripted inside this function.

``` yuescript
{
   type: 'start'
   do: ->


}
```

The *do* function is executed in the [action API](file:docs/API/action) environment.
Beside the functions and objects from the action API there is also a certain set of functions
and predefined symbols to know about:

| Identifier | Value                              |
| ---------- | ---------------------------------- |
| Q1         | Q-coordinate of the primary unit   | 
| Q2         | Q-coordinate of the secondary unit |
| R1         | R-coordinate of the primary unit   | 
| R2         | R-coordinate of the secondary unit |
| TURN       | The current turn number            |
| TURN_LIMIT | The scenario ends at this turn     |
| P_UNIT     | The primary unit                   |
| S_UNIT     | The secondary unit                 |

### Nested Events

The [EVENT](#file:docs/API/event.html) function is used to register new events at runtime.
Meaning it is registered during the execution of a parent handler's *do* function.

In the following example we script a scenario in which the player needs to build a 
``` moonscript
nested =
   type: ''
   do: ->
      
hello =
   type: 'destroyed'
   filter: 
      side: 3
   do: ->
      MESSAGE
         text: 'We made it! Now the Truck has to reach the depot.'
      EVENT nested -- this won't work
      
victory =
   type: 'moveTo'
   filter:
      q: 23
      r: 34
   do: ->
      MESSAGE
         text: 'something'
      END_SCENARIO
         victory: true

events = {
   hello
   victory
}

SCENARIO
   id: 'first'
   name: 'A Fancy Title'
   :events
```

In the example above the event list is constructed proceduraly to keep
the indentation level low.

Please have a look at he lined commented "this won't work". The reason
for this is that the "nested" variable has already ran out of scope at
the time the event handler is executed.

### Base Scenario

If your scenario table (the arguement for the SCENARIO scripting) ommits 
the *base* key/value (the value is meant to be a scenario *id*) it defaults to the scenario with the id *default_base*.

The values and more important the event handlers (the list table stored in the *events* key)
are merged in the child scenario.

``` moonscript
SCENARIO
   base: ''
```

Campaign Design
===============

Difficulty Levels
-----------------

You can define an arbitrary amount of difficult levels for your campaign.
But there is a predefined set based on 3 levels.

``` moonscript
CAMPAIGN
   id: 'starleague'
   difficulties: {
      {
         symbol: 'EASY'
       name: 'Easy'
       description: ''
     {
     {
        symbol: 'HARD'
     }
     {
        symbol: 'MEDIUM'
       default: true
     }
   }
   
CAMPAIGN
   id: 'starleague'
   difficulties: DEFAULT_DIFFICULTIES
```

After the player has selected a difficulty level the campaign is loaded with a variable named 

Scenario Order
--------------

### First Scenario

Every Campaign needs a starting scenario.
Since the init file of the campaign is reloaded with the difficulty level's symbol set (a global variable set to *true*)
the starting scenario can be depending on the difficulty level:

``` moonscript
CAMPAIGN
   firstScenario: if EASY then 'tutorial' else 'first'
```
In this example the tutorial scenario is skipped on difficulty levels other than *EASY*.

### Linear

Campaigns with a simple linear order of the scenarios are the easiest 
to balance.

### Tree Structure

Depending on if and how the player solves a scenario different next scenarios can be choosen.

### Graph

A Graph like structure is

Persistent Sides
----------------

During a campaign the player's resources are usually taken into the next 
scenario.

The game supports making every side persistent to allow easy access to them in
later scenarios.

Faction Design
==============

Era Design
==========

Balancing
---------

Balancing is the art of adjusting the power of each faction to be a match for each other.
It shouldn't come to a surprise that more factions in an era means it is more difficult to balance.
One of the best balanced games of all times is Blizzard's *Starcraft* featuring only 3 factions.

AI Development
==============

Conversion Development
======================

The game mechanics are not hardcoded but implemented using the event handlers facility.
Since each of them comes with an *id* they can be redefined easily.

So there are 2 possibilities for creating content with core mechanics altered.
1  Don't load the default *core* module and define a complete new one.
2  Redefine only a subset of the core event handlers.

Scripting Languages
===================

Lua
---

Beside being the only (TODO: is that true?) scripting language LÖVR supports the language isn't
found often in the codebase. 

Only a small few tiny startup files are implemented in Lua directly: 
conf.lua <- that file sets up the environment for the Yuescript compiler to run and configures
the game engine.
main.lua <- this file needs to be present for LÖVR and LÖVE (LÖVR is derived from LÖVR) to start. 

Some 3rd party code, mostly (TODO: or all?) located in game/utils:
MoonScript contains some lua code although the compiler is written in MoonScript itself.
lovr's gui library is implemented in lua.
Penlight

Savefiles are Lua files generated by [luapersist]() and thus human readable.
Their execution returns a lua table containing the gamestate at savetime.
This can be a useful debuging tool but don't expect the genereted Lua code to be easy to read.
After execution the gamestate can be printed with [Penlight Pretty Printer]()

The [Savefile Printer](file:/docs/)
#TODO advertise that small script that pretty prints a savefile.

### Variables

#### Identifiers

Variable identifiers follow the following nameing scheme:

| Style     | Type       |
|-----------|------------|
| UPPERCASE | predefined |
| CamelCase | global     |
| lowerCase | local      |

#### Local Variables

To declare a local variable in Lua the keyword ***local*** exists.
Yuescript also knows the keyword *local* but it is only used to forward
declare uninitialized variables.

Lua's (and thus Yuescripts) local variables run out of scope. Meaning
they are no longer accessable when you leave So a local variable runs
out of scope, no later than the current file loading returns.

When it comes to local variable names remember that you can't use
symbols already occupied by Lua/Yuescript keywords. Those are:

Lua: and break do else elseif end false for function if in local nil not
or repeat return then true until while

Yuescript: export when in class extends

note: The list of Yuescript keywords is extending the Lua one.

There are also some utility functions defined in all contexts. Have a
look at them [here](#CommonPredefinedVariables).

#### Global variables

Global variables can be accessed in any context during the runtime of a
lua session. Meaning you can reuse their values in a different file.

Lua variables are global by default, Yuescript variables need the
***export*** keyword in the line of declaration.

``` moonscript 
export Range=5 -- Range is a global variable export \^ --
export every proper symbol after this line (names beginning with a
capital letter) export \* -- export any symbol after this line
```

#### Local vs Global Variables

It is good practice to use always local variables if their is no reason
to do otherwise. Yuescript defaults to local variables, in Lua the
keyword ***local*** is used for declaration.

Global variables are meant to be used for sharing code between different
files, for reusing a multiple used event handler by several scenarios
for example. 
Lua's variables are global by default, MoonScript

| Language   | local syntax      | global syntax      |
| ---------- | ----------------  | ------------------ |
| Lua        | local identifier= | identifier=        |
| MoonScript | identifier=       | export identifier= |
| Yuescript  | identifier=       | global identifier= |

### DataTypes

#### PrimitiveTypes

-   [Nil](https://www.lua.org/pil/2.1.html)
-   [Boolean](https://www.lua.org/pil/2.2.html)
-   [Number](https://www.lua.org/pil/2.3.html)

#### String

Yuescript supports 3 different syntaxes for
[string](https://www.lua.org/pil/2.4.html) definitions.

1.  'Simple Strings' Strings escaped with the '-character don't do any
    interpolation and are stored as they are.
2.  "Interpolated Strings" Strings escaped with the "-character are
    parsed for any occorance of \${expression}.
    [Expression](https://www.lua.org/manual/2.4/node9.html) can be any
    Lua/Yuescript code that evaluates to a datatype handable by the
    tostring() function.
3.  \[\[Multiline Strings\]\] Strings escaped inside double squared
    brakets can spawn multiple lines but are not interpolated.

#### TranslatedStrings

Every string presented to the user is a possible subject to the
translation system. The values of 'id', 'type' and more keys are never
translatable while name or description are always.

Value interpolation is available inside of translated strings but there
are some issues to consider:

-   Avoid splitting translated strings:
``` moonscript 
speech = 'We have ' .. x .. ' scouts left on our purpose' -- bad practice
```
   The reason for this is that not all languages follow the english
    sentence structure and the number can't be put at the right
    location.

#### Table

The only complex datastructure known to Lua/MoonScript/Yuescript is the
[table](https://www.lua.org/pil/2.5.html).  
It can't hurt if the reader takes the time to make herself familiar with it.

**Note:**
Beside each language comes with a different syntax for designing and
handling tables, the semantic is always the same.
If you have questions regarding Lua tables the Lua documentation found
on the internet will be useful, minus the need to adjust the syntax a bit.
**This is true for everything Lua/MoonScript/Yuescript.**

``` lua
-- lua
SCENARIO({
   id: 'first',
   sides: {
      {
        id: 'player',
       team: 'allies'
     },
     {
        id: 'friend',
       team: 'allies'
     },
     {
        id: 'foe1',
       team: 'enemies'
     },
     {
        id: 'foe2',
       team: 'enemies'
     }
   }
})

```
``` moonscript
-- moonscript
SCENARIO
   id: 'first'
   sides: { 
      { 
         id: 'player'
         team: 'allies'
      } 
      { 
         id: 'friend'
         team: 'allies'
      }
      { 
         id: 'foe1'
         team: 'enemies'
      } 
      { 
         id: 'foe2'
         team: 'enemies'
      }
   }
```

``` yuescript
-- yuescript
SCENARIO 
   id: 'first'
   sides:
      *  id: 'player'
         team: 'allies'
      *  id: 'friend'
         team: 'allies'
      *  id: 'foe1'
         team: 'enemies'
      *  id: 'foe2'
         team: 'enemies'	 
```

Note how the syntax of the table constructor differs from Lua over MoonScript to Yuescript.
The compact notation of the table constructor syntax was a major 
consideration for MoonScript over Lua and Yuescript over MoonScript.

``` yuescript
-- yuescript but very dense notation
SCENARIO id: 'first', sides: 
   *  id: 'player', team: 'allies'
   *  id: 'friend', team: 'allies'
   *  id: 'foe1',   team: 'enemies'
   *  id: 'foe2',   team: 'enemies'
```

#### Function

[functions](https://www.lua.org/pil/2.6.html)

Transcompiled Languages
-----------------------

This section contains background information the urgent reader can skip for the first read.

The majority of the codebase is implemented in languages which are at runtime [transcompiled]() into Lua.
In the next step LÖVR's luajit's Just in Time compiler translates into its own bytecode format which is finally executed.

You can manually trigger the transcompilation and speed up the start of the game a bit.
If there are several files sharing the same base name but differing with the ending, the *.lua* file is prefered.
TODO that was true for MoonScript but is it for Yuescript?
TODO What if there are .moon .lua and .yue?

This leads to the following error chain:
* The transcompiler fails parsing the file. This is most likely a Syntax error. 
    With a bit of luck you are even gifted with an meaningful error message pointing to a faulty line in the file.
* The luajit compiler fails to process the generated lua code. This is most likely a bug in luajit and might be worth reporting to that project.
But please fill a bug report at CombatShore's Bug tracker first to avoid unecessary overhead for the developers.  TODO Bugtracker link
This should hopefully rarely happen and in most cases workarounds are available.
* During the runtime of the bytecode a runtime error is thrown.
This is most likely a problem with the semantic of the code you wrote.
Depending on the context the code is executed in we might miss the correct line numbers in error messages:

* Lua Code misses correct line numbers in error messages during event script execution but is fine everywhere else TODO: is that true?
* MoonScript code must have all file line numbers translated in error messages. Solutions are available but not implemented yet.
    It seems we skip that for yuescript

Yuescript and MoonScript are not the only languages transcompiling into Lua.
[Lua Languages](https://github.com/hengestone/lua-languages) features a compilation of them.

While CombatShore supports MoonScript and Yuescript just-in-time compilation, any language
transcompiling into Lua can be used when the code is precompiled.

### White Space Sensitivity

Unlike Lua the transcompiled languages are both white space sensitiv.

MoonScript allows the coder to avoid parentheses and closing keywords
(end) by a lot and makes most of their occurences optional. To archive
that the language uses white space sensitivity.

``` moonscript
-- moonscript
if x < 4
   Message'Too few of those x things!'
   enough_x = false
   if x == 0
      Message'The last one just got lost!'
MESSAGE"There are ${x} things left."
```
``` lua
-- lua
if x < 4 then
   MESSAGE('Too few of those x things!')
   enough_x = false
   if x == 0 then
      MESSAGE('The last one just got lost!')
   end
end
MESSAGE('There are ' .. x .. ' things left.') -- Lua does not support Yuescripts string interpolation syntax
```
Note how the indentation level is mandatary to define the range of the
if statement's conclusion. 
The Lua version relies on additional *then* and *end* keywords to define the range of the blocks.

CombatShore uses 3 white spaces for each indentation level.
Yuescript can cope with an arbitrary amount of Whitespace characters for an 
indentation level. 
But you need to keep it consistent during a single file.

If you dislike syntax of this sort don't feel bad, you are not alone.  
A lot of coders really hate it and there are some disadvantages.

Although most of the annoyances of white space sensitive languages can
be managed by using a matching texteditor, the natural solution is the
fallback to Lua.

Since Yuescript is transcompiled into Lua you don't loose any
functionality except for the syntactic sugar introduced by Yuescript.

The project also accepts Lua contributions, it is just not garanteed
they won't be converted into Yuescript at some time in the future.

Note that you can have both languages in your content project.  
Unit or Terrain definitions could be hosted in Yuescript files
(benefiting from the slimligned syntax) while script heavy scenario
files (where white space sensitivity might bother you more) can be Lua
ones.

You can even mix both languages in a single file although it confuses
the text editor. Wait, is that true? TODO: try that


### Common Semantics

Both MoonScript and Yuescript share most of their semantics with Lua.

Note: The project is currently in the transition process from MoonScript to Yuescript.

MoonScript
----------

Warning: If Yuescript holds what it seems to promise right now MoonScript support might be removed in the future.

### Compiler

[Online Compiler](https://moonscript.org/compiler)

Can be used to check the syntax of a Yuescript file:

``` bash 
$ game/utils/moonscript/bin/moonc -l filename.moon
``` 

You can also use the moonc command to compile your .moon file in a .lua one.

Inspecting the transcompiled code can give you an idea what went wrong
if you know how to code in Lua. Of course generated code is not as
readable as handwritten one.

### MoonScript Editors

Some of the simpler MoonScript modes might still give you good results since both languages are not that different.
I had no luck getting the Emacs MoonScript Mode to run at all.

##### Howl 

is a nice editor and supports Lua and MoonScript very well.
It is written in MoonScript itself.

Since MoonScript also compiles into Lua you might want to use it nevertheless Yuescript is the recommended language.
-   [Howl](https://howl.io/Howl) - Linux and other Unixes, no extra mode needed
-   [vim](https://github.com/leafo/moonscript-vim) - Powerful but not userfriendly, support for all platforms?
-   [Emacs](https://github.com/k2052/moonscript-mode) - all platforms
-   [Sublime Text/Textmate](https://github.com/leafo/moonscript-tmbundle) - Userfriendly and available on all
    Plattforms.

MoonScript comes with more editors supporting it.
It is also better documented than Yuescript. 

Yuescript
---------

[Yuescript](https://moonscript.org) is a scripting language that
transcompiles into [Lua](https://www.lua.org).  

Lua is the scripting language of the [LÖVR](https://lovr.org/) game engine CombatShore uses.

Yue is the chinese word for moon (but also the language family to which cantonese belongs iiuc) hinting towards it being a [MoonScript](https://moonscript.org) dialect. #TODO ugly sentence

Earlier versions of CombatShore were based on MoonScript (which also compiles into Lua) but it seems Yuescript is a good replacement for it.
Yuescript is under active development, MoonScript only recieves casual commits since years.
Yuescript also enhances further on the features including modern trends in scriptcoding. <-- this needs some references
The compiler comes as a Lua library and a standalone version, written in c++.
But for the cost of that additional dependency the parsing library MoonScript (which is lpeg) depends on can be dropped.
Yuescript's documentation and error messaging is still a bit rough.
And there is currently only one supported editor: Microsoft Visual Studio Code.
Suprisingly (at least for me) there are Linux binaries available which even gave me good experience.

CombatShore compiles its content at runtime thus there is no need to do
that manually. The best adress to learn the syntax of Yuescript is its
[reference page](https://moonscript.org/reference).

The main difference between Lua and Yuescript is that the later
introduces [syntactic
sugar](https://en.wikipedia.org/wiki/Syntactic_sugar) and has a reduced
footprint.

Additional syntax is introduced for classes and other stuff (TODO write
more).

CombatShore is centered around the scripting language 'Yuescript'.
There are several reasons for choosing that language.

-   It's easy to learn (especially when you already know Lua).
    CombtShore's content and the core of the game are both encoded with
    Yuescript. This removes the barrier between moding through the
    content api and contributing to the game core itself. Most game
    projects have a more or less easy learning curve for creating
    content but a possible contributor hits a wall when it comes to the
    game core. Since the codebase is put under the GPL open source
    license encouraging the public to enhance or base upon

-   Yuescripts overheadpoor table construction syntax allows it to be
    used as a content data storage language as well as a formidable
    event scripting one.

-   It is good practice in Lua to use local variables instead of global
    ones whenever possible. But Lua's syntax makes global variables the
    default by requiring the extra 'local' keyword. Yuescript on the
    other hand defaults to local variables requiring the extra 'export'
    keyword for declaring a global identifier.

-   The table construction syntax is a bit too heavy to be optimal as a
    content data solution. Yuescript comes with a much smaller
    footprint at the cost of introducing white space sensitivity.

``` moonscript
Scenario
   id: 'day_after'
   turns: 28
```

``` lua
Scenario({
   id= 'day after',
   turns= 28
})
```
### Editors

A Yuescript/MoonScript/Lua mode for your texteditor makes live a lot easier.

At the time of this writing the only known editor with support for Yuescript is **Microsoft Visual Studio Code**.


Use the right tools.

#### Installation

* Download it [here](https://code.visualstudio.com/download).
* Install the software in the ways of your favourite operating system. #TODO write more here lazy bastard
* The [VS Marketplace](https://marketplace.visualstudio.com/items?itemName=LiJin.yuescript) features a freee **Syntax Highlighting** plugin.
    * Open the newly installed editor.
    * Press Ctrl+P
   * Copy ```ext install LiJin.yuescript``` into the upcoming prompt and press enter. 

### Yuescript Interpreter

``` bash 
$ game/utils/moonscript/bin/moon filename.moon
```

### Yuescript Compiler

Tools
-----

### Penlight

Penlight tries to be a standart library for Lua.
