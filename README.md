# SeemTerrainGen-1
SeemTerrainGen-1: Roblox Studio World-Nature-Generator (Voxel Terrain + Props). Open Source and MIT.

**Made by Seem for devs.**

I'd love to see you on the discord, join us!
Discord: https://discord.gg/fZPqkdyqD

I am already working on the next open source Project: UI Framework! Help me build it!

## How to Import to Studio
1. Create a Folder
2. Copy the "SeemTerrainGen-1" Module into the folder
3. Create a Folder named "MathHelp" in the same folder
4. Copy the "Formulas" Module into the "MathHelp" Folder
5. Copy the "TableLib" Module in the main-folder.
6. This is how it should look like:

<img width="232" height="96" alt="image" src="https://github.com/user-attachments/assets/70c729e5-eacb-4aff-b986-f30707a92298" />

After that, create this structure in the workspace:

<img width="183" height="43" alt="image" src="https://github.com/user-attachments/assets/905850d0-4618-4f9e-8d69-9d2ef5e0830e" />

Then create a Folder called "SeemTerrain" in the ReplicatedStorage:

<img width="204" height="24" alt="image" src="https://github.com/user-attachments/assets/bed36f52-caf2-4c48-a199-0a6290a4c0c0" />

In this folder you will create the config for SeemTerrainGen-1. You can find snippets and examples in this repository (src/examples).

## How to use
### Creating the config(MaterialList)
You firstly need to create the MaterialList. The MaterialList stores everything SeemTerrainGen-1 needs. This means you can easily share, re-use and adjust it quickly. Think of it like a preset.
This MaterialList must be placed in ReplicatedStorage/SeemTerrain. If you make changes:
1. select the MaterialList
2. Cut it (CTRL + X)
3. Paste it in the same folder. Then you need to require the module in your code for SeemTerrainGen-1 again
4. This updates the module and clears the cache from Roblox Studio

To setup a MaterialList, please take a look into src/examples.

### Using SeemTerrainGen-1
After that, you simply call GenerateTerrain with the MaterialList:
`SeemTerrainGen_1.GenerateTerrain(MaterialList)`

You can only generate Props when you generated Terrain. This is because there is a temporary table created in the memory only (globally declared) and firstly filled when GenerateTerrain was called.
GenerateProps expects this table (CurrentIterationTable) to be filled already.

You call GenerateProps in the same way:
`SeemTerrainGen_1.GenerateProps(MaterialList)`

After you have generated the Props, you will need to load the props into Studio, because again: they are stored in memory only first to boost performance.
Simply call `SeemTerrainGen_1.CreateFolders()`

Then there is going to be a folder in the SeemTerrain/Temp in workspace. This Folder stores the whole generation. 

**Note:** Whenever you want to make another generation (Terrain + Props), delete everything within SeemTerrain/Temp.

# Video Tutorials
## All-In-One Tutorial
https://youtu.be/UanoH9D9VMY
## MaterialList Tutorial - More in Depth
-- Video-Tutorial in development.
Read the README.md in src/examples for a readable tutorial.
