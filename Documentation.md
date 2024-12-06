# Module Documentation

## Animate
This module's purpose is to store and recycle AnimationTracks loaded through this module.

Thats useful because if you call LoadAnimation() on an AnimationController itself, it'll give you a fresh AnimationTrack. Doesn't matter if you loaded the same one beforehand, it always reloads. To prevent reloading (and with that, delays inbetween already played animations), you can use this method instead. It'll return the already used AnimationTrack which completely gets rid of that delay.

|Dependencies|
|---|
|[Auxillery](https://github.com/Fire1Sky/Modules/blob/main/Modules/Auxillery.luau)|

### Animate:LoadAnimation()
This is used to load Animations on a AnimationController. The AnimationTrack will then be saved within the module.


Takes *3* Arguments:

- **AnimationController** (Humanoid, Animator, AnimationController): The AnimationController to load the animation upon.

- **Animation** (Animation, number): The Animation to load.

- **GivenArgs** (table?): The Arguments to use on the *AnimationTrack*. This table may take up to 4 Values:

|Key|Type|Standard|Description|
|---|---|---|---|
|Priority|Enum.AnimationPriority|Action|Indicates the priority of the animation.|
|TimePosition|number|0|Indicates where to start the animation from.|
|Speed|number|1|Indicates the speed of the Animation.|
|Looped|boolean|false|Indicated whether or not the Animation repeats playing itself.|

> [!TIP]
> The GivenArgs Argument is entirely optional.


<ins>The Method returns the AnimationTrack.</ins>


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

- **AnimationController** (Humanoid, Animator, AnimationController): The AnimationController to remove the animation from.

- **Animation** (Animation, number): The Animation to unload.


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
The purpose of this module is to make writing code easier. It contains functions which are useful for most scripts.

### Auxillery:GetServices()
Instead of defining all services needed repetitively, you can use this method to get a <ins>table with services that are commonly used</ins>. You can edit it to your needs.

I added a custom variable for bridgenet2, since its a direct upgrade to remotes. you may keep it at nil if unused.

### Auxillery:AssertWarn()
Replicates the behaviour of assert(), but uses warn() instead to prevent errors.


Takes *2* Arguments:

- **Condition** (boolean): The condition to check.

- **Msg** (string?): The message to display.


If the condition given equals false or nil, the script will halt and the given msg will be printed.


Code Sample:
```lua
local Auxillery = require(game.ReplicatedStorage.Modules.Auxillery)

local function PrintSomething(MessageToPrint : string)
    Auxillery:AssertWarn(typeof(MessageToPrint) == "string", "MessageToPrint isn't a string")
    print(MessageToPrint)
end

PrintSomething("Hi there") --Output: Hi there
PrintSomething(true) --Output: MessageToPrint isn't a string
```

### Auxillery:GenerateRandomID()
Uses HttpService to obtain a randomly generated ID

<ins>Returns a string if HttpService is enabled, else it'll return nil.</ins>

### Auxillery:NumberInRange()
This method is used to check the distance between 2 numbers.


Takes *3* Arguments:

- **ReferenceNumber** (number): The base number.

- **TargetNumber** (number): The number to check the distance from the ReferenceNumber to the TargetNumber.

- **MaxDistance** (number): The maximal range between ReferenceNumber and TargetNumber which decides if the boolean is true or false.


<ins>Returns a boolean which indicates whether or not the TargetNumber is within the ReferenceNumber, and the distance.</ins>


Code Sample:
```lua
local Auxillery = require(game.ReplicatedStorage.Modules.Auxillery)

local IsInRange, Distance = Auxillery:NumberInRange(50, 40, 1)

print(IsInRange) --Output: false
print(Distance) --Output: 10
```


### Auxillery.TableFunctions:DeepCopy()
Using table.clone() doesn't truly create a new independant table with the same values. Because of that, there's now a DeepCopy method. It also returns a copy of the table, but fully independant.

Takes *1* Argument:

- **val** (table): The table to copy


<ins>Returns the copied table.</ins>

### Auxillery.TableFunctions:DeepCopyGetTableType()
Tables come in 2 types: Arrays and Dictionaries. This method indicates which one of the 2 the table is.

Takes *1* Argument:

- **Table** (table): The table to check


<ins>Returns a string indicating the type of the table</ins>

Code Sample:
```lua
local Auxillery = require(game.ReplicatedStorage.Modules.Auxillery)

local function PrintTableType(tab)
    print(Auxillery.TableFunctions:GetTableType(tab))
end

PrintTableType({1, 2, 3}) --Output: Array
PrintTableType({Hi = "Hello", Bye = "Cya"}) --Output: Dictionary
```

### Auxillery.TableFunctions:Await()
> [!WARNING]
> This method yields.

Waits for a value within a table per key.

Takes *3* Arguments:

- **tab** (table): The table to go through
- **key** (any): the key to wait for
- **timeout** (number?): The amount of time to wait for maximally.

If no timeout parameter is provided, the script will yield forever until the key is added to the table. After ~5 seconds of waiting, a warning will appear in the output informing you that a infinite yield is possible in the given table with the given key. 

<ins>Returns the value if there is any.</ins>


Code Sample:
```lua
local Auxillery = require(game.ReplicatedStorage.Modules.Auxillery)
local Table = {"hi"}

print(Auxillery.TableFunctions:Await(Table, 1)) --Output: hi
print(Auxillery.TableFunctions:Await(Table, "KeyXYZ")) --Delayed Output (2s): I am a value.
task.wait(2)
Table.KeyXYZ = "I am a value."
print(Auxillery.TableFunctions:Await(Table, 5, 1)) --Output: nil
print(Auxillery.TableFunctions:Await(Table, 10)) --Delayed Output (5s): Infinite yield possible with table Table and key 10
```

### Auxillery.InstanceFunctions:GetDistance()
<ins>Returns the Distance between 2 BaseParts.</ins>

Takes *2* Arguments:

- **Inst1** (BasePart): The first basepart to compare.

- **Inst2** (BasePart): The second basepart to compare.

## CustomSignals


## CustomTypes