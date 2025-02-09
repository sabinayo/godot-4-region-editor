# Region Editor
A plugin for Godot 4.0 and above that lets you create and edit regions from an image.  
You can export regions as separate images or use them in a scene where you can easily switch between regions using an enumeration.  
Collision support is also available.

## Installation

1. Download the plugin from [Github](https://github.com/sabinayo/godot-4-region-editor/).  
2. Copy the "addons/region-editor" folder into your Godot project directory.  
3. Enable the plugin under **Project > Project Settings > Plugins**.  

## How to Use

### Notes
Hover your mouse over any button, property, or feature to see what it does. Detailed explanations are not provided here to avoid redundancy.

### Import Images
To create and edit regions, you need to import images. You can:  
- Drag and drop images from the Godot FileSystem dock, OR  
- Use the "Add texture(s)..." button or the '+' button to add new images.  

Once images are added, click on them to start editing.  
> Note: Regions created from an image will stay visible even if you select another image.  

### Image Setup

After importing images, you can toggle the **Textures Dock** for more space.  
- Edit the properties of new or existing regions.  
- Hover over a property to see its description.  
When you're ready, click "Add region" to create a region. Alternatively, toggle the **Texture Setup Dock** for even more space.  
If the **Texture Setup Dock** is closed, a toolbar will appear.

### Adding Regions
Use the **Texture Region Editor** to create regions from your images.

### Editing Regions
Regions have various properties.  
- To edit a region, click its image, and the **Properties Panel** will appear on the right.  
- You can edit multiple regions at the same time, but some properties may be unavailable.  
> Note: Collision editing is experimental.

### Exporting a Single Region
To export one region as an image:  
- Click the "Export" button in the **Region Properties Dock**, OR  
- Click the file icon button on the left of the region.  
A popup will show all the export options.

### Exporting Multiple Regions
1. Select the regions you want to export.  
2. Click the pencil button near the "Select/Deselect All" button.  
> Note: The pencil button appears only when at least 2 regions are selected.  

#### Exporting Multiple Regions as Images
- Select the regions to export.  
- Click the export button in the **Region Properties Dock**.  
- In the "Export Type" section, select **Images**.  

#### Exporting Multiple Regions as an Enumeration
- Select the regions to export.  
- Click the export button in the **Region Properties Dock**.  
- In the "Export Type" section, select **Enumerations**.  
