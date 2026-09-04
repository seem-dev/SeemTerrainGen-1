# Creating a MaterialList (config)
It is really simple to create a MaterialList, as you mostly copy and then adjust whatever you want. It is unnecessary writing everything on your own everytime.

Take a look at "Template", in there is everything explained, every type, key and value.

It is also best practice to try things out, just like I did. Look into different MaterialLists and adjust each value and always read what the key does (as done above in the Template).

**Be aware:** that the Template uses Instances! If you don't have such instances, simply create them and name them like they are in the template.
The Template uses the Roblox Forest Pack (search in Toolbox).

The Template generates this Map:

<img width="1198" height="806" alt="image" src="https://github.com/user-attachments/assets/8df2bd3a-25da-4b89-9995-29496ca7a357" />

## Adding more tables (e.g. Biomes)

### Tables with Thresholds
Look at the type of the MaterialList. The MaterialList (first table) directly stores Biomes.
1 Table = 1 Biome (where its properties(e.g. other tables) are stored in).

<img width="1361" height="546" alt="image" src="https://github.com/user-attachments/assets/4fc2727c-e582-4f7d-8d6c-e34c62e99977" />

You see the threshold? The threshold indicates how much the biome is distributed in the map. Meaning if we have 1 biome, we want it to have full **distribution** (as we have no other one).

To add another biome, we simply create a second table like the first one (e.g. copy and pasting, then making adjustments).

But we still need to **change the threshold**, because we cant have 2 biomes with the threshold of 1. 
We can now change the threshold of the **first** biome/table, because SeemTerrainGen-1 is built for an array and not for a dictionary, meaning we can change the first biomes' threshold to any number lower than the biomes' threshold that comes after **and** bigger than the biomes' threshold that is before the biome we are editing.

Example:
(Here are 3 biomes created to demonstrate how to set the threshold. Read the comments.)
<img width="753" height="678" alt="image" src="https://github.com/user-attachments/assets/45504ed3-ef84-4a3f-8924-b6af34a4968e" />

BUT: this isn't all. SeemTerrainGen-1 can do a lot more! Each biome has its own Property. This means, that we can set a few more options (remember: we made 3 biomes):

<img width="295" height="109" alt="image" src="https://github.com/user-attachments/assets/37323766-e8fd-424f-98c2-81ccd80df7ca" />

As you can see, we need to set those values for each biome. Our second biome (Biome2) is in the second position in the MaterialList, meaning so is its property in the dynamic parameters (as seen above).
E.g. Our second Biome (Biome2) has the following properties:

<img width="295" height="109" alt="image" src="https://github.com/user-attachments/assets/f53a294b-cfbb-4d12-921e-dffa423ba11c" />

***

Great! You now understood thresholds! Trust me, it's easy if you looked at a few MaterialLists.

Got Questions? Please join the discord and ask a question. Everyone is welcome!

Now that you understood thresholds, we can do this **pattern for everything where tables with thresholds are used.**

E.g. In a material-layer in a Layer(Range):

<img width="321" height="573" alt="image" src="https://github.com/user-attachments/assets/69bb780d-9e5b-4dac-beb4-31677a31fd76" />

### Layers
Take a look at the MaterialList type again. Do you see the "Layers" key?

<img width="1437" height="353" alt="image" src="https://github.com/user-attachments/assets/85425967-45d0-4adf-924e-d3f01e9ebed7" />

This Table stores every MaterialLayer:

Do you see the "[string]" key? This is the range (scroll down for examples) which sets the range of this layer (global y axis in Roblox Studio).
<img width="320" height="124" alt="image" src="https://github.com/user-attachments/assets/401723e2-0a92-4200-acd5-39c987bc4e30" />

Take a look at this example. We have created 2 Layers (remember: SeemTerrainGen-1 is data-driven, meaning you can do as many key/values as you want) where the second layer starts with the end-value of the first Layer (105):

<img width="244" height="91" alt="image" src="https://github.com/user-attachments/assets/437af079-8173-4301-b76c-3970d1a7f916" />

The content (value of the key) of this Layer is called a SingleLayer and stores this:

<img width="1445" height="400" alt="image" src="https://github.com/user-attachments/assets/41b95cd9-6ab8-467c-a20e-3cd04ce7d647" />

Adjust each property and play around. You will quickly be able to tell what each property does.

## Gaining access to Positions
SeemTerrainGen-1 stores everything you need and can. Another useful value is the _Positions. 

This key stores every single position that SeemTerrainGen-1 created and currently stores positions and material (an array out of tables which store position and material).

Now you can simply expand this table to gain access to advanced gps-coordinates and world-data-control. What do I mean? Keys in _Positions are inserted in the lowest level of the generation, meaning all data has been checked.

E.g. The biome is identified, the layer, the instance, etc.
This means that you could put all those data in the _Positions table which gives you access to more than just a coordinate ;)

You could make a UI that shows the Biome the player is in, the tree (instance) the player is pick-axing and even identify where the tree is located and its nearbies. You can do everything.

I didn't do it, because I simply didn't use it. If you have a question, let me (or others) help you in the discord! I am happy to answer questions!
