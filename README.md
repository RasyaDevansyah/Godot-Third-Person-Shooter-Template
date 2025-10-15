# Godot Third Person Shooter Player Template (Experimental)

<img width="1919" height="1079" alt="image" src="https://github.com/user-attachments/assets/9db8e205-9d87-4ff0-b9f0-d499b927946e" />

This repository provides a ready-to-use, experimental player controller implementation for Godot 4.x. The entire controller and supporting resources are self-contained in the `Scenes/Player` folder and can be copied directly into your own Godot projects.

## Features

- Player movement and aiming
- Shooting input and basic weapon example
- Camera helper (camera shake)
- Example textures included in `Models/Player/textures/`
- Easy integration: simply copy the `Scenes/Player` folder into your project

## Quick Start / Setup

1.  **Copy the Player Folder**
    *   The `Scenes/Player` folder contains everything you need for the player (scene, scripts, textures).
    *   Copy the entire `Player` folder into your own Godot project's `Scenes` folder (keep the folder structure).

    <img width="632" height="546" alt="image" src="https://github.com/user-attachments/assets/1aef4b39-aba3-487b-a130-3eaf724622f6" />


2.  **Add the Player Scene to Your World**
    *   In your main scene, instance `Player.tscn` from `Scenes/Player` and position it in the world.

3.  **Input Map Setup**
    *   The following input actions are required. If you copy the controller into a new project, make sure to add these actions in `Project > Project Settings > Input Map`.
        *   `Forward` (default: W)
        *   `Backward` (default: S)
        *   `Left` (default: A)
        *   `Right` (default: D)
        *   `Sprint` (default: Left Shift)
        *   `Jump` (default: Spacebar)
        *   `Aim` (default: Right Mouse Button)
    * 

    <img width="1919" height="703" alt="image" src="https://github.com/user-attachments/assets/8997453a-c09c-4c38-bd8d-f47c4b6f7512" />


4.  **Test the Player**
    *   Open the project in Godot 4.x, instance the player scene into your world, press Play. Use WASD to move, Shift to sprint, Spacebar to jump, and Right Mouse Button to aim.

## How It Works

-   The player scene is `Player.tscn` and the main script is `Player.gd` (attached to the root player node).
-   Movement and input are read from the Input Map actions listed above.
-   Camera logic is implemented in `Camera.gd` and used by the player.
-   The included textures are in `Models/Player/textures/`.

## Folder Structure

```
Scenes/
  Player/
    Player.gd         # Main controller script
    player.tscn       # Player scene (instance this into your world)
    Camera.gd         # Camera helper script
    textures/         # Example textures used by the player
Models/
  Player/
    ThirdPersonCharacterModel.blend # Player model
    textures/         # Player textures
project.godot        # Project settings (input map)
```

## Customization

-   Movement speeds, aim sensitivity, and camera parameters are exposed as exported variables in `Player.gd` and `Camera.gd`. Tweak them in the Inspector to match your game feel.
-   You can replace the sample weapon logic with your own weapon system; `Player.tscn` already demonstrates basic shooting input.

## Credits

Created by Rasya Devansyah
Pistol Model by [j_albert05](https://www.instagram.com/j_albert05)

---

Feel free to copy this `Scenes/Player` folder into your own Godot projects and adapt it.
