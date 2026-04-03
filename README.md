# SABnzbd FLAC Splitter (for Lidarr)

A post-processing script for SABnzbd that automatically splits large single-file FLAC album downloads (often found in "scene" releases) into individual tracks using a `.cue` or `.cue.txt` file. This makes the albums perfectly readable and importable for Lidarr.

## Features
* Automatically detects `.cue` and `.cue.txt` files (case-insensitive).
* Splits single large FLAC files into individual tracks (`01 - Track Name.flac`).
* Injects the correct metadata/tags into the new files using the cue data.
* Cleans up the original large FLAC and CUE file afterward.
* Skips processing if the album is already split (standard releases).

## Requirements
The system running SABnzbd needs the following packages installed: `shntool`, `cuetools`, and `flac`.

### For standard Linux (Ubuntu/Debian):
Open your terminal and run:
```bash
sudo apt-get update
sudo apt-get install shntool cuetools flac
```

### For Docker users (e.g., `linuxserver/sabnzbd`):
By default, Docker containers do not have these tools installed. If you install them manually, they will disappear when the container updates. To make them permanent:
1. Go to your mapped SABnzbd config folder and look for the `custom-cont-init.d` directory (create it if it doesn't exist).
2. Create a new file inside it, for example `install-tools.sh`, and add the following lines:
   ```bash
   #!/bin/bash
   apt-get update && apt-get install -y shntool cuetools flac
   ```
3. Restart your SABnzbd container. It will now automatically install the tools on every boot!

## How to use

### Step 1: Add the script to SABnzbd
1. Download the `flac-splitter.sh` script from this repository.
2. Place the script inside your SABnzbd **Scripts Folder**. 
   *(You can check or set this folder in SABnzbd under **Settings > Folders > Scripts Folder**).*
3. Make the script executable. Open your terminal and run:
   ```bash
   chmod +x /path/to/your/sabnzbd/scripts/flac-splitter.sh
   ```

### Step 2: Configure SABnzbd Categories
1. Open the SABnzbd web interface.
2. Go to **Settings** (the gear icon) and click on the **Categories** tab.
3. Find your category for Music (the one Lidarr uses, e.g., `music` or `lidarr`).
4. In the **Script** dropdown column for that category, select `flac-splitter.sh`.
5. Click **Save Changes**.

**You're done!** 
Now, whenever Lidarr sends a release to SABnzbd that contains a single FLAC + CUE file, SABnzbd will split it into individual tagged tracks *before* telling Lidarr the download is finished. Lidarr will then import the tracks smoothly.

## License
MIT License - Copyright (c) 2026 [BroodPitt](https://github.com/BroodPitt)
