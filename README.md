# Real-Time Strategy

This is a game created with Godot 4.3 game engine.  
Game is client-server and allows users to:
- create an account and log in,
- compete against other players.

The game uses:
- SQLite database,
- TCP with TLS to sign up and in players,
- UDP to communicate in game.

Game mechanics:
- creating building,
- summoning units,
- controlling units to:
  - move (auto pathfiding),
  - gather resources,
  - fight opponents buildings and units.
