
# A 3D Game via ECS and React

This is an experiment in blending my ECS core with a React-based view system to make a 3d game.

I'm attracted by the notion of using declarative, reusable view elements to convert abstract game elements into rich 3d objects and animations without having to write custom view synchronization logic for every new element... I'd rather come up with a way of representing view elements as data and let something else do the sync.

* ECS core (made up stuff I made in my metroid-clone sandbox https://github.com/dcrosby42/metroid-clone)
* React
* THREE
* react-three-renderer

I've jiggered thigs such that I can use JSX to get up and rolling though I don't know how much I like using JSX.
* coffee-reactify 

# Run

```
git clone https://github.com/dcrosby42/3d-game.git
cd 3d-game
npm install
gulp
# http://localhost:3000
```

# Status

Just started.
* Get some practice with react-three-renderer.  Learn a lot more about THREE.js
* Bring in my ECS core and wire up the game loop
* Make a simple interactive game with 3d primitives
* Physics (Canon? physijs?)
* Sound (find that howler.js/react adapter, someone made one)

