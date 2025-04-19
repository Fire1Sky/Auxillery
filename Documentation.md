The Auxillery Components are split in 2 Categories: High Level, and Low Level.
Depending whether or not the Component has Dependencies, it goes either into Low Level or into High Level.

# Low Level
These Components don't have any Dependencies and are often required in other High Level Components.

## Emitter
A Component mimicing the Signals from the Roblox engine. It's very straight forward to use, and probably the most important Dependency within Auxillery.

### new() -> Emitter
The constructor for a Emitter.

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


## Instance
Extends upon the Instance Library. Part of the BaseType Components

### CreateInstance<T>(Class, Properties) -> T
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

## Table


### Await(tab, key, timeout) -> any
> This method yields.

Waits for a value within a table per key and returns it.

|Argument|Type|Optional|Description|
|--------|----|--------|-----------|
|tab|table|No|The table to go through|
|key|any|No|the key to wait for|
|timeout|number|Yes|The amount of time to wait for until stopping execution|

If no timeout parameter is provided, the thread will yield forever until the key is added to the table. After ~5 seconds of waiting, a warning will appear in the output informing you that a infinite yield is possible in the given table with the given key. 


Code Sample:
```lua
local Aux = require(game.ReplicatedStorage.Modules.Auxiliary)
local Table = {"hi"}

print(Aux.TableFunctions:Await(Table, 1)) --Output: hi
print(Aux.TableFunctions:Await(Table, "KeyXYZ")) --Delayed Output (2s): I am a value.
task.wait(2)
Table.KeyXYZ = "I am a value." 
print(Aux.TableFunctions:Await(Table, 5, 1)) --Output: nil
print(Aux.TableFunctions:Await(Table, 10)) --Delayed Output (5s): Infinite yield possible with table Table and key 10
```

## String

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


## Number


### NumberInRange() -> (boolean, number)
This method is used to check the distance between 2 numbers.

|Argument|Type|Optional|Description|
|--------|----|--------|-----------|
|ReferenceNumber|number|No|The base number.|
|TargetNumber|number|No|The number to check the distance from the REferenceNumber to the TargetNumber.|
|MaxDistance|number|No|The maximal range between ReferenceNumber and TargetNumber which decides if the boolean is true or false.|

<ins>Returns a boolean which indicates whether or not the TargetNumber is within the ReferenceNumber, and the distance.</ins>

Code Sample:
```lua
local Aux = require(game.ReplicatedStorage.Auxillery.Auxiliary)

local IsInRange, Distance = Aux:NumberInRange(50, 40, 1)

print(IsInRange) --false
print(Distance) --10
```


## Services
A Component containing shortcuts to important Services.

|Shortcut|Service|
|--------|-------|
|D|Debris|
|L|Lighting|
|RS|ReplicatedStorage|
|RNS|RunService|
|HTTP|HttpService|
|RF|ReplicatedFirst|
|||
|||
|||
|||
|||
|||
|||

# High Level

## Auxiliary
The purpose of this module is to make writing code easier. It contains functions which are useful for most scripts.

### Auxiliary:GetServices()
Instead of defining all services needed repetitively, you can use this method to get a <ins>table with services that are commonly used</ins>. You can edit it to your needs.

### Auxiliary:GenerateRandomID()
Uses HttpService to obtain a randomly generated ID

<ins>Returns a string if HttpService is enabled, else it'll return nil.</ins>


### Auxiliary.TableFunctions:DeepCopy()
Using table.clone() doesn't truly create a new independant table with the same values. Because of that, there's now a DeepCopy method. It also returns a copy of the table, but fully independant.

Takes *1* Argument:

- **val** (table): The table to copy


<ins>Returns the copied table.</ins>

### Auxiliary.TableFunctions:DeepCopyGetTableType()
Tables come in 2 types: Arrays and Dictionaries. This method indicates which one of the 2 the table is.

Takes *1* Argument:

- **Table** (table): The table to check


<ins>Returns a string indicating the type of the table</ins>

Code Sample:
```lua
local Aux = require(game.ReplicatedStorage.Auxillery.Auxiliary)

local function PrintTableType(tab)
    print(Aux.TableFunctions:GetTableType(tab))
end

PrintTableType({1, 2, 3}) --Output: Array
PrintTableType({Hi = "Hello", Bye = "Cya"}) --Output: Dictionary
```
