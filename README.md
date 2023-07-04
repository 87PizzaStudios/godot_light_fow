# Light based fog of war in godot 4
This fog of war (FOW) system only reveals areas where light touches using godot's built-in 2d lighting system. This preserves FOW in areas that are shadowed by light-occluding objects. This tool supports scrolling of the fog texture, multiple light sources, different reveal modes, and use of cameras.

Click image to see demo on youtube: 

[![Video demo](http://img.youtube.com/vi/SyBqYFzUPOw/0.jpg)](http://www.youtube.com/watch?v=SyBqYFzUPOw)

## How it works
The system duplicates the light sources and occluders into an unrendered [SubViewport](https://docs.godotengine.org/en/stable/classes/class_subviewport.html). We use a shader to compute the FOW alpha mask from the lighting in the SubViewport and blend this mask with a user-provided fog texture to create the effect. The mask calculations can hurt performance in high-resolution scenes. To reduce the overhead, the user can downscale the unrendered viewport to compute the alpha mask at a lower resolution than the native game resolution.   

## Usage
To add into your own projects: 
1. Add the provided `fow_light.tscn` as a node in your scene. 
2. Create a [node group](https://docs.godotengine.org/en/stable/tutorials/scripting/groups.html) with [PointLight2D](https://docs.godotengine.org/en/stable/classes/class_pointlight2d.html) nodes from your project. These lights will reveal fog.
3. Create a second node group containing [LightOccluder2D](https://docs.godotengine.org/en/stable/classes/class_lightoccluder2d.html) nodes from your project.
4. Set the scene arguments (see below).
5. Implement signals to update the FOW scene with changes to your in-game light and occluder objects. 

See the provided project for example usage. 

## Scene arguments
1. `Fog Texture`: the Texture2D instance used to overlay the scene.
2. `Fog Scroll Velocity`: the provided fog texture will scroll with this velocity.
3. `Persistent Reveal`: determines whether observed areas stay revealed after moving to a new area.
4. `Light Group`: the name of the group with light sources.
5. `Light Occluder Group`: the name of the group with light occluders.
6. `Fow Scale Factor`: downscales objects in the FOW scene for reduced computation overhead. Higher values produce higher resolution fog at greater computational cost.
7. `Initial Reveal`: whether to reveal initial light location.
