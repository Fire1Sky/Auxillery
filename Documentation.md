# Low Level

These Components don't have any Dependencies and are often required in other High Level Components.

## Emitter

A Component mimicing the Signals from the Roblox engine. It's very straight forward to use, and probably the most important Dependency within Auxillery.

### new() -> Emitter

The constructor for a **Emitter**.

### Emitter:Fire(...) -> ()

Fires a **Event**, if existent. You may pass in Arguments in form of a **Tuple**.

### Emitter:Connect(Event, Callback) -> Connection

Connects a Callback to a **Event**. If the Event doesn't exist, it'll create one.

|Argument|Type|Optional|Description|
|--------|----|--------|-----------|
|Event|string|No|The Event to connect to.|
|Callback|function|No|The Method to execute once the Event is fired. All Arguments parsed through **Emitter:Fire()** will sink into this method.|

### Emitter:Once(Event, Callback) -> Connection

Identical to **Emitter:Connect()**, with the exception that the callback given only runs once. The Connection gets terminated afterwards.

### Connection:Disconnect() -> ()

Removes the **Connection** from the **Event**, preventing it from being called again.

## Loot

Simplifies Lootpools.

### new(LootPool) -> LootPool
Constructor for **LootPools**.

|Argument|Type|Optional|Description|
|--------|----|--------|-----------|
|LootPool|table (Array)|No|The LootPool containing all Items. The Items should be in this format: {Name : string, Rarity : number}|


### LootPool:GetRandomItem() -> Loot
Returns one random Item in the Loot pool depending on the rarities.

## Instance

Extends upon the Instance Library. Part of the BaseTypes Library.

### CreateInstance<_Type>(Class, Properties) -> _Type

Equivalent to the standard **Instance.new()**, but let's you apply Properties when creating the Instance.

|Argument|Type|Optional|Description|
|--------|----|--------|-----------|
|Class|string|No|The Class to create.|
|Properties|table (Dictionary)|Yes|The Properties to apply onto the Instance.|

Code Sample:

```lua
local Instance = require("./Instance")

local Part : Part = Instance:CreateInstance("Part", {
    Color = Color3.fromRGB(255,0,0),
    Size = Vector3.new(1,1,1),
    Transparency = 0.5,
    Parent = workspace,
    Name = "CreatedPart"
})

print(Part.Name) --CreatedPart
```

### SafeCheckProperty(Inst, Property) -> boolean

Safely checks the Instance has the given Property

|Argument|Type|Optional|Description|
|--------|----|--------|-----------|
|Inst|Instance|No|The Instance to check.|
|Property|string|No|The Property Name to check.|

## Table

Extends upon the table Library. Part of the BaseTypes Library.

### Await(tab, key, timeout) -> any
>
> *This method yields*.

Waits for a value within a table per key and returns it.

|Argument|Type|Optional|Description|
|--------|----|--------|-----------|
|tab|table|No|The table to go through|
|key|any|No|the key to wait for|
|timeout|number|Yes|The amount of time to wait for until stopping execution|

If no timeout parameter is provided, the thread will yield forever until the key is added to the table. After ~5 seconds of waiting, a warning will appear in the output informing you that a infinite yield is possible in the given table with the given key.

Code Sample:

```lua
local Table = require("./Table")
local Example = {"hi"}

task.delay(2, function()
    Example[2] = 5
end)

print(Table:Await(Example, 2)) --(2s delay) 5
print(Table:Await(Example, 3, 2)) --No Output
print(Table:Await(Example, 4)) --Infinite Yield possible with table Example and Key 4
```

### DeepCopy(Table) -> Table

Creates a independant copy of a table and returns it.

|Argument|Type|Optional|Description|
|--------|----|--------|-----------|
|Table|table|No|The table to make a copy of.|

## String

Extends upon the string Library. Part of the BaseTypes Library.

### GenerateID(Length, Set) -> string

Generates a ID with a set of characters to use.

|Argument|Type|Optional|Description|
|--------|----|--------|-----------|
|Length|number|No|The amount of characters to use for the ID.|
|Set|table (Array)|Yes|The Set of characters to use.|

Code Sample:

```lua
local String = require("./String")

local CustomSet = {"a", "b", "c"}

local ID1 = String:GenerateID(7) --Uses a preset defined within the Method (including numbers)
local ID2 = String:GenerateID(7, CustomSet)

print(ID1, ID2)
```

### FormatTime(TimeInSeconds) -> string

Returns a formatted string in this format: Seconds, Minutes, Hours

|Argument|Type|Optional|Description|
|--------|----|--------|-----------|
|TimeInSeconds|number|No|N/A|

### GetTableType(Table) -> "Array" | "Dictionary"

Gets the table type.

|Argument|Type|Optional|Description|
|--------|----|--------|-----------|
|Table|table|No|The table to check.|

Code Sample:

```lua
local Table = require("./Table")

print(Table:GetTableType({true, false, ""})) --Array
print(Table:GetTableType({x = 1, y = false})) --Dictionary
```

## Number

Creates number functionality. Part of the BaseType Library.

### NumberInRange(ReferenceNumber, TargetNumber, MaxDistance) -> (boolean, number)

This method is used to check the distance between 2 numbers.

|Argument|Type|Optional|Description|
|--------|----|--------|-----------|
|ReferenceNumber|number|No|The base number.|
|TargetNumber|number|No|The number to check the distance from the ReferenceNumber to the TargetNumber.|
|MaxDistance|number|No|The maximal range between ReferenceNumber and TargetNumber which decides if the boolean is true or false.|

<ins>Returns a boolean which indicates whether or not the TargetNumber is within the ReferenceNumber, and the distance.</ins>

Code Sample:

```lua
local Number = require("./Number")

local IsInRange, Distance = Number:NumberInRange(50, 40, 1)

print(IsInRange) --false
print(Distance) --10
```

### DecimalLock(Number, Decimals) -> number

Decimal-locks a number.

|Argument|Type|Optional|Description|
|--------|----|--------|-----------|
|Number|number|No|The number to decimal-lock.|
|Decimals|number|No|the amount of decimals to keep.|

## Services

A Component containing shortcuts to important Services to prevent defining all Services repetitively.

|Shortcut|Service|
|--------|-------|
|P|Players|
|RS|ReplicatedStorage|
|RNS|RunService|
|RF|ReplicatedFirst|
|SV|ServerStorage|
|L|Lighting|
|UIS|UserInputService|
|CAS|ContextActionService|
|COS|CollectionService|
|TS|TweenService|
|IS|InsertService|
|MS|MarketplaceService|
|HTTP|HttpService|
|PS|PathfindingService|
|PHY|PhysicsService|
|D|Debris|
|MES|MessagingService|

# High Level

## Hitbox

A Component using Spatial Queries to spawn accurate Hitboxes. It switches from Outer to Inner Hitboxes vice versa, depending on the current Physics FPS.

### Spawn(Args) -> ()

Spawns a Hitbox.

<ins>Type Definitions</ins>

```lua
type HitboxArguments = {
	Origin : Model?,
	Reference : BasePart | {CFrame : CFrame, Size : Vector3},
	ForceMode : ("Inner" | "Outer")?,
	OnHumanoidHit : (Humanoid : Humanoid) -> ()?, --If you want custom Humanoid handling, you may define a humanoid hit function. This overwrites the standard damage function.
	
	Debug : {
		ShowHitbox : boolean?,
		PrintProcessingTime : boolean?,
		PrintEstimatedProcessTime : number? --Multiplies the Processing time by the number defined here and prints it.
	}?,
	
	Stats : {
		Linger : {
			Duration : number,
			Interval : number
		}?,
		Damage : number,
		SelfHit : boolean? --Whether or not you can hit yourself with the Hitbox.
	}
}
```

|Argument|Type|Optional|Description|
|--------|----|--------|-----------|
|Args|HitboxArguments|No|The Arguments to use for creating the Hitbox.|

## ExtendedInstance

Another Extension of the Instance Library.
