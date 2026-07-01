# 7.4.1.1.1 Realistic Pathing Workflow in Unreal (Simplified)

- **Place Navigation Bounds Volume** → Covers the area NPCs can navigate.
- **Enable Dynamic Obstacle Updates** → Mark objects that may move or block paths.
- **Add Perception System to AIController** → So NPCs can see/hear/react.
- **Use Behavior Trees** → To define goals (like "go to town square" or "patrol randomly").
- **Query Smart Objects or Use EQS** → To figure out how to interact with the world like a human.

### 🧠 Example: A Lumberjack NPC Navigating a Forest

- Starts at their cabin.
- Needs to walk to a tree, but a fallen log is in the way.
- NPC sees the log using perception → triggers EQS to find alternate route or way to move it.
- If they’re strong enough, they might clear it. If not, they reroute using NavMesh and DetourCrowd.
- They chop the tree, pick up logs, and return — all dynamically and adaptively.

### 🔧 Advanced Extensions for “Like a Real Person” Behavior

| Feature | Description |
| --- | --- |
| **Navigation Invokers** | Allow NavMesh to generate **on-demand** in very large or procedurally generated worlds. |
| **Local Avoidance (RVO)** | Avoids collisions with moving objects or other characters. |
| **Crowd Simulation** | Useful for towns or marketplaces — characters reroute smoothly around others. |
| **Machine Learning (optional)** | Can layer in behaviors learned from player/NPC data, though it’s complex and overkill unless needed. |