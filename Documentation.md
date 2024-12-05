# Module Documentation

## Animate
This module's purpose is to store and recycle AnimationTracks loaded through this module.

Thats useful because if you call LoadAnimation() on an AnimationController itself, it'll give you a fresh AnimationTrack. Doesn't matter if you loaded the same one beforehand, it always reloads. To prevent reloading (and with that, delays inbetween already played animations), you can use this method instead. It'll return the already used AnimationTrack which completely gets rid of that delay.

|Dependencies|
|---|
|[Auxillery](https://github.com/Fire1Sky/Modules/blob/main/Modules/Auxillery.luau)|

### <ins>Animate:LoadAnimation()</ins>
This is used to load Animations on a AnimationController. The AnimationTrack will then be saved within the module.

Takes *3* Arguments:

-**AnimationController** (Humanoid, Animator, AnimationController): The AnimationController to load the animation upon.

-**Animation** (Animation, number): The Animation to load.

-**GivenArgs** (table): The Arguments to use on the *AnimationTrack*. This table may take up to 4 Values:

|Key|Type|Standard|Description|
|---|---|---|---|
|Priority|Enum.AnimationPriority|Action|Indicates the priority of the animation.|
|TimePosition|number|0|Indicates where to start the animation from.|
|Speed|number|1|Indicates the speed of the Animation.|
|Looped|boolean|false|Indicated whether or not the Animation repeats playing itself.|

> [!TIP]
> The GivenArgs Argument is entirely optional.

The Method returns the AnimationTrack.

Code Sample:
```lua
local Animate = require(game.ReplicatedStorage.Modules.Animate)
local Character = workspace.CharacterXYZ

local AnimationController = Character.Humanoid.Animator
local Animation = Instance.new("Animation")
Animation.AnimationId = "rbxassetid://987654321"

for i = 1, 5 do
    local Track = Animate:LoadAnimation(AnimationController, Animation, {Priority = Enum.AnimationPriority.Action})
    Track:Play()
    Track.Ended:Wait()
end

local Animation2 = 987654321

for i = 1, 5 do
    local Track = Animate:LoadAnimation(AnimationController, Animation)
    Track:Play()
    Track.Ended:Wait()
end
```
In the sample, we called the loadanimation method 10 times. Normally, this would load the animation 10 times. but instead, we only loaded it once and replayed it 9 times by using this specific method.

### Animate:UnloadAnimation()
In case you want to remove a AnimationTrack from the Cache, you use this method.

Takes *2* Arguments:

-**AnimationController** (Humanoid, Animator, AnimationController): The AnimationController to remove the animation from.

-**Animation** (Animation, number): The Animation to unload.

Code Sample:
```lua
local Animate = require(game.ReplicatedStorage.Modules.Animate)
local Character = workspace.CharacterXYZ

local AnimationController = Character.Humanoid.Animator
local Animation = Instance.new("Animation")
Animation.AnimationId = "rbxassetid://987654321"

for i = 1, 5 do
    local Track = Animate:LoadAnimation(AnimationController, Animation, {Priority = Enum.AnimationPriority.Action})
    Track:Play()
    Track.Ended:Wait()
end

--After you're done, you can just unload the Animation.
Animate:UnloadAnimation(AnimationController, Animation)
```

## Auxillery


## CustomSignals


## CustomTypes