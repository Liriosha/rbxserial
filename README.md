# <\\> Rbxserial

A fast, and compact serializer for Roblox instances, supporting a variety of built-in types and custom instance hierarchies. Ideal for saving models, sending data over remotes, or archiving object trees for later reconstruction.

## ✨ Features

- 🔁 Serialize and deserialize Roblox instances, including properties and relationships.
- 📦 Built-in support for current Roblox types
- 🧩 Handles deeply nested trees and reference resolution (e.g., `Parent`, `ObjectValue`, etc.).
- 🔓 Outputs safe, compressed base64-encoded data.
- 🧪 Includes a standalone deserializer (`destandalone.lua`) for your scripts!

## 🔧 Usage
There are two files that you can be concerned about other than the source code
`bundled.lua` and `destandalone.lua`
These are the entire package and the deserializer standalone respectively.
### 📁 Bundle
> [!NOTE]
> Serialization currently requires httpservice at the moment as the serializer makes use of https://github.com/MaximumADHD/Roblox-Client-Tracker/blob/roblox/API-Dump.json this may change in the future for not only convenience but optimization!
```lua
local rbxserial = require(pathToRbxSerial)
local serialized = rbxserial.serialize(workspace.object)
-- serialized data will be in a base64 format
-- to upload to hastebin you can use the following
rbxserial.upload(serialized)
```
### 📁 Destandalone
```lua
local load = require(pathToDeserializer)
-- Noob dummy for example
local obj = load('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')[1]
-- Your instance is loaded, do whatever with it!
```
## 🧱 Format Overview
### 🪄 Magic header
`rbxSerial\0\0\0\0`
* Length: 13 bytes
* Purpose: Identifies this as a valid serialized file (leading bits may be used for version resolution later).
### `I` Instance Chunk
```
I
[uint32] Number of unique class entries
  Repeat for each class:
    [uint32] Count of instances using this class
    [uint16] Length of class name
    [string] Class name
```
* This chunk determines how many total instances will be deserialized and in what order they are allocated.
### `P` Property Chunk
```
P
[uint32] Number of instances
  Repeat for each instance:
    [uint32] Instance ID
    [uint32] Property count (excluding ClassName and internal data)
      Repeat for each property:
        [uint16] Length of property name
        [string] Property name
        [byte] Type ID
        [bytes] Serialized value
```
* Purpose : Stores serialized properties for each instance in the same order as defined in the `I` chunk.
* Type ID: An index into serializeTable.
* Special Type ID:
    - 17 - Indicates an Instance reference. Followed by a [uint32] reference ID.
    - 0 - Represents nil.
### `E` End Chunk
* Purpose : Marks the end of the binary stream
# 📄 License
MIT License. Free to use, modify, and distribute.
# 👤 Author
Made by Liriosha
Inspired by the RBXM file format.