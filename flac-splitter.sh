#!/bin/bash

# Copyright (c) 2026 BroodPitt
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# SABnzbd passes the download directory as the first parameter ($1)
DOWNLOAD_DIR="$1"

if [ -z "$DOWNLOAD_DIR" ]; then
    echo "Error: No download directory provided by SABnzbd."
    exit 1
fi

# Navigate to the download directory
cd "$DOWNLOAD_DIR" || exit 1

# Search for a .cue or .cue.txt file (case-insensitive, max depth of 1)
CUE_FILE=$(find . -maxdepth 1 -type f \( -iname "*.cue" -o -iname "*.cue.txt" \) | head -n 1)

# Remove the leading "./" that the 'find' command adds by default
CUE_FILE=${CUE_FILE#./}

# If no cue file is found, exit gracefully. It's likely already a standard album release.
if [ -z "$CUE_FILE" ]; then
    echo "No .cue or .cue.txt file found. This is probably already a standard album release."
    exit 0
fi

# If the file ends with .txt (like .cue.txt, often used to bypass usenet filters), 
# we rename it to .cue first to ensure compatibility with shnsplit.
if [[ "$CUE_FILE" == *.txt || "$CUE_FILE" == *.TXT ]]; then
    NEW_CUE_NAME="${CUE_FILE%.*}" # Strips the last extension (.txt)
    mv "$CUE_FILE" "$NEW_CUE_NAME"
    CUE_FILE="$NEW_CUE_NAME"
    echo ".cue.txt detected! File renamed to: $CUE_FILE"
fi

# Count the total number of FLAC files in the directory
FLAC_COUNT=$(ls *.flac 2>/dev/null | wc -l)

# We only split if there is exactly 1 large FLAC file present
if [ "$FLAC_COUNT" -eq 1 ]; then
    LARGE_FLAC=$(ls *.flac 2>/dev/null | head -n 1)
    
    echo "Large FLAC file found: $LARGE_FLAC"
    echo "Splitting using CUE file: $CUE_FILE"

    # Split the large FLAC file based on the CUE file.
    # -f : Specifies the CUE file
    # -o flac : Output format is flac
    # -t "%n - %t" : Output filename format becomes "Tracknumber - Title.flac"
    shnsplit -f "$CUE_FILE" -o flac -t "%n - %t" "$LARGE_FLAC"
    
    SPLIT_RESULT=$?

    if [ $SPLIT_RESULT -eq 0 ]; then
        echo "Splitting successful! Adding metadata (tags)..."
        
        # Move the original large FLAC out of the way temporarily so it doesn't get tagged
        mv "$LARGE_FLAC" "${LARGE_FLAC}.bak"
        
        # Apply tags to the newly created individual .flac files using the CUE file
        cuetags.sh "$CUE_FILE" *.flac
        
        echo "Removing original large FLAC and CUE files to clean up the directory..."
        rm "${LARGE_FLAC}.bak"
        rm "$CUE_FILE"
        
        echo "Done! Lidarr can now import these tracks without issues."
        exit 0
    else
        echo "Error: Something went wrong while splitting the files using shnsplit."
        exit 1
    fi
else
    echo "Found $FLAC_COUNT FLAC files. Splitting is not needed or not possible."
    exit 0
fi