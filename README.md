# SABnzbd FLAC Splitter (for Lidarr)
A post-processing script for SABnzbd that automatically splits large single-file FLAC album downloads into individual tracks using a `.cue` or `.cue.txt` file, making them perfectly readable for Lidarr.

## Requirements
The system running SABnzbd needs the following packages installed:
`shntool`, `cuetools`, `flac`

**Ubuntu/Debian:**
```bash
sudo apt-get update
sudo apt-get install shntool cuetools flac
