# SZTE-Thesis-RTS-2022
WIP - Unplayable (empty) state currently  
This repository be used for my Thesis work for my Computer Science Bachelor's at University of Szeged,  
which will be written in C# and GDScript, using [Godot Engine](https://godotengine.org/) (using 4.0 beta currently)

## TODO:
This list is subject to change
- [ ] Core functionality
  - [ ] Pathfinding
    - [ ] A* implementation
    - [X] FlowField implementation
  - [X] Unit Selection mechanic
  - [ ] Steering behaviors for regular units with 2D movement
  - [ ] Steering behaviors for 3D objects, such as spaceships and/or planes
- [ ] Networking
  - [ ] Ability to host/connect to games
  - [X] Player connect/disconnect behavior
  - [ ] Ability to kick players as host
  - [ ] Server list to browse games to connect to
  - [ ] Manage connecting players
- [ ] City builder module
- [ ] "Classic" RTS module
- [ ] 3D RTS module (inspired by Homeworld)
- [ ] 4X module
  - [X] Random map generation
  - [ ] Map synchronization between server and clients
    - [X] Initial map state synchronization
  - [X] Configurable map generation (ex. star density, map size)
  - [ ] Map generation config "presets" accessible from pre-game UI
  - [ ] Fleet battles
    - [ ] Connect to 3D RTS module
      - [ ] Initialize battle from colliding 4X fleets
        - [ ] Pass fleet data (ships, fleet stat modifiers) to populate the RTS field
        - [ ] Pass post-battle data back to 4X module (win/loss, unit count changes)
  - [ ] Connect to City builder/Classic RTS module
    - [ ] Load city associated to given star on specific input
    - [ ] Aggregate data from cities/planets (summed income/min, average "happiness", research progression speed, etc.)
    - [ ] Pass appropriate data (ground units) on fleet-planet "collision"
    - [ ] Pass post-battle data back to 4X module
    - [ ] Handle ownership changes (diplomacy/post-battle)
  ### This list is subject to change
  As the project progresses/ideas are finalized, items will most likely be changed/added.
