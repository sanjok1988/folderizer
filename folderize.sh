#!/bin/bash

# Script to organize files by kind (file type) and year created
# Usage: ./organize-files.sh /path/to/folder
# Files are MOVED (not copied) into kind/year folders

set -e

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Check if folder path provided
if [ $# -eq 0 ]; then
    echo -e "${RED}Error: Please provide a folder path${NC}"
    echo "Usage: $0 /path/to/folder"
    exit 1
fi

FOLDER="$1"

if [ ! -d "$FOLDER" ]; then
    echo -e "${RED}Error: Folder does not exist: $FOLDER${NC}"
    exit 1
fi

echo -e "${BLUE}🔍 Organizing files in: $FOLDER${NC}"
echo ""

# File extensions by kind (using string lists)
IMAGE_EXT="jpg jpeg png gif bmp tiff tif webp heic heif raw cr2 nef dng arw orf rw2 pef sr2 svg ico"
PDF_EXT="pdf"
DOC_EXT="doc docx txt rtf odt pages tex wpd wps"
SPREADSHEET_EXT="xls xlsx csv ods numbers tsv"
PRESENTATION_EXT="ppt pptx key odp"
VIDEO_EXT="mp4 avi mov mkv flv wmv webm m4v mpg mpeg 3gp f4v"
AUDIO_EXT="mp3 wav flac aac ogg wma m4a opus aiff"
ARCHIVE_EXT="zip rar 7z tar gz bz2 xz iso dmg"
CODE_EXT="js php py java cpp c h cs rb go rs swift kt sh bash sql html css json xml yaml yml"

# Function to get file kind
get_file_kind() {
    local filename="$1"
    local extension="${filename##*.}"
    extension=$(echo "$extension" | tr '[:upper:]' '[:lower:]')
    
    for ext in $IMAGE_EXT; do
        if [ "$extension" = "$ext" ]; then
            echo "Images"
            return
        fi
    done
    
    for ext in $PDF_EXT; do
        if [ "$extension" = "$ext" ]; then
            echo "PDFs"
            return
        fi
    done
    
    for ext in $DOC_EXT; do
        if [ "$extension" = "$ext" ]; then
            echo "Documents"
            return
        fi
    done
    
    for ext in $SPREADSHEET_EXT; do
        if [ "$extension" = "$ext" ]; then
            echo "Spreadsheets"
            return
        fi
    done
    
    for ext in $PRESENTATION_EXT; do
        if [ "$extension" = "$ext" ]; then
            echo "Presentations"
            return
        fi
    done
    
    for ext in $VIDEO_EXT; do
        if [ "$extension" = "$ext" ]; then
            echo "Videos"
            return
        fi
    done
    
    for ext in $AUDIO_EXT; do
        if [ "$extension" = "$ext" ]; then
            echo "Audio"
            return
        fi
    done
    
    for ext in $ARCHIVE_EXT; do
        if [ "$extension" = "$ext" ]; then
            echo "Archives"
            return
        fi
    done
    
    for ext in $CODE_EXT; do
        if [ "$extension" = "$ext" ]; then
            echo "Code"
            return
        fi
    done
    
    echo "Other"
}

# Function to get year from file
get_file_year() {
    local file="$1"
    local year=""
    
    if command -v exiftool &> /dev/null; then
        year=$(exiftool -n -d "%Y" -DateTimeOriginal "$file" 2>/dev/null | grep -oE '[0-9]{4}' | head -1)
        if [ -z "$year" ]; then
            year=$(exiftool -n -d "%Y" -CreateDate "$file" 2>/dev/null | grep -oE '[0-9]{4}' | head -1)
        fi
    fi
    
    if [ -z "$year" ]; then
        if [[ "$OSTYPE" == "darwin"* ]]; then
            year=$(stat -f "%SB" -t "%Y" "$file" 2>/dev/null | grep -oE '[0-9]{4}' | head -1)
            if [ -z "$year" ]; then
                year=$(stat -f "%Sm" -t "%Y" "$file" 2>/dev/null | grep -oE '[0-9]{4}' | head -1)
            fi
        else
            year=$(stat -c "%y" "$file" 2>/dev/null | grep -oE '[0-9]{4}' | head -1)
        fi
    fi
    
    if [ -z "$year" ]; then
        year=$(date +%Y)
    fi
    
    echo "$year"
}

# Counters
total_files=0
moved_files=0
failed_files=0
temp_kinds="/tmp/kinds_$$"
temp_years="/tmp/years_$$"
touch "$temp_kinds" "$temp_years"

echo -e "${BLUE}📁 Processing files...${NC}"
echo ""

# Process all files
find "$FOLDER" -maxdepth 1 -type f | while read -r file; do
    total_files=$((total_files + 1))
    
    filename=$(basename "$file")
    kind=$(get_file_kind "$filename")
    year=$(get_file_year "$file")
    
    # Create target folder
    target_folder="$FOLDER/$kind/$year"
    
    if [ ! -d "$target_folder" ]; then
        mkdir -p "$target_folder"
        echo -e "${GREEN}✓ Created: $kind/$year${NC}"
    fi
    
    # Move file
    if mv "$file" "$target_folder/"; then
        moved_files=$((moved_files + 1))
        echo "$kind" >> "$temp_kinds"
        echo "$year" >> "$temp_years"
        echo -e "${GREEN}✓ Moved: $filename → $kind/$year/${NC}"
    else
        failed_files=$((failed_files + 1))
        echo -e "${RED}✗ Failed to move: $filename${NC}"
    fi
done

# Summary
echo ""
echo -e "${BLUE}═════════════════════════════════════════════${NC}"
echo -e "${BLUE}📊 Summary:${NC}"
echo -e "${BLUE}  Total files found: ${total_files}${NC}"
echo -e "${GREEN}  Successfully moved: ${moved_files}${NC}"
if [ $failed_files -gt 0 ]; then
    echo -e "${RED}  Failed: ${failed_files}${NC}"
fi
echo -e "${BLUE}═════════════════════════════════════════════${NC}"

# Show breakdown by kind
if [ -s "$temp_kinds" ]; then
    echo ""
    echo -e "${CYAN}📂 Files by Kind:${NC}"
    sort "$temp_kinds" | uniq -c | while read count kind; do
        echo -e "${GREEN}  $kind: $count files${NC}"
    done
fi

# Show breakdown by year
if [ -s "$temp_years" ]; then
    echo ""
    echo -e "${CYAN}📅 Files by Year:${NC}"
    sort "$temp_years" | uniq -c | while read count year; do
        echo -e "${GREEN}  $year: $count files${NC}"
    done
fi

# List created folder structure
echo ""
echo -e "${BLUE}📁 Folder Structure Created:${NC}"
find "$FOLDER" -type d -not -name ".*" | sort | tail -n +2 | while read dir; do
    count=$(find "$dir" -maxdepth 1 -type f | wc -l)
    relative_path=$(echo "$dir" | sed "s|^$FOLDER/||")
    if [ $count -gt 0 ]; then
        echo -e "${GREEN}  $relative_path: $count files${NC}"
    fi
done

# Cleanup
rm -f "$temp_kinds" "$temp_years"

echo ""
echo -e "${GREEN}✅ Done!${NC}"
