# Light based fog of war in godot
This fog of war (FOW) system only reveals areas where light touches using godot's built-in 2d lighting system. This preserves FOW in areas that are shadowed by light-occluding objects. 

Click image to see demo on youtube: 

[![Video demo](http://img.youtube.com/vi/SyBqYFzUPOw/0.jpg)](http://www.youtube.com/watch?v=SyBqYFzUPOw)

# Usage
See the provided project for example usage. To add into your own projects, add the provided `fow_light.tscn` as a node in your scene hierarchy. This node should go below any nodes you wish to shroud with FOW. 

There are three exported variables in this scene to integrate with your project: 
1. Fog Texture: This is the Texture2D instance used to overlay the scene.
2. Light: This is a Light2D instance from your own project that will be used to reveal the scene. See the provided sample project for example. These 
3. Light Occluders: This is a node in your scene hierarchy that has all of the light-occluding polygons as children. 

