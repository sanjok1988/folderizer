#!/bin/bash

# Script to organize images by year created (EXIF date)
# Usage: ./organize-images.sh /path/to/folder
# Images are MOVED (not copied) into year folders

set -e

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if folder path provided
if [ $# -eq 0 ]; then
    echo -e "${RED}Error: Please provide a folder path${NC}"
    echo "Usage: $0 /path/to/folder"
    exit 1
fi

FOLDER="$1"

# Check if folder exists
if [ ! -d "$FOLDER" ]; then
    echo -e "${RED}Error: Folder does not exist: $FOLDER${NC}"
    exit 1
fi

echo -e "${BLUE}🔍 Searching for images in: $FOLDER${NC}"

# Image extensions (lowercase and uppercase)
IMAGE_EXTENSIONS=("jpg" "jpeg" "png" "gif" "bmp" "tiff" "tif" "webp" "heic" "heif" "raw" "cr2" "nef")

# Counter
total_images=0
moved_images=0
failed_images=0

# Find all image files
while IFS= read -r -d '' image_file; do
    total_images=$((total_images + 1))
    
    # Get file extension
    extension="${image_file##*.}"
    
    # Extract year from file
    # Try to get EXIF date first (requires exiftool)
    year=""
    
    if command -v exiftool &> /dev/null; then
        # Try to get date from EXIF data
        year=$(exiftool -n -d "%Y" -DateTimeOriginal "$image_file" 2>/dev/null | grep -oE '[0-9]{4}' | head -1)
    fi
    
    # If no EXIF date, try file modification date
    if [ -z "$year" ]; then
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS
            year=$(stat -f "%Sm" -t "%Y" "$image_file" 2>/dev/null | grep -oE '[0-9]{4}' | head -1)
        else
            # Linux
            year=$(stat -c "%y" "$image_file" 2>/dev/null | grep -oE '[0-9]{4}' | head -1)
        fi
    fi
    
    # Fallback: use current year if nothing works
    if [ -z "$year" ]; then
        year=$(date +%Y)
        echo -e "${YELLOW}⚠️  No date found for: $(basename "$image_file"), using current year: $year${NC}"
    fi
    
    # Create year folder if it doesn't exist
    year_folder="$FOLDER/$year"
    if [ ! -d "$year_folder" ]; then
        mkdir -p "$year_folder"
        echo -e "${GREEN}✓ Created folder: $year${NC}"
    fi
    
    # Move image to year folder
    if mv "$image_file" "$year_folder/"; then
        moved_images=$((moved_images + 1))
        echo -e "${GREEN}✓ Moved: $(basename "$image_file") → $year/${NC}"
    else
        failed_images=$((failed_images + 1))
        echo -e "${RED}✗ Failed to move: $(basename "$image_file")${NC}"
    fi
    
# Find all image files (case-insensitive)
done < <(find "$FOLDER" -maxdepth 1 -type f \( \
    -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \
    -o -iname "*.gif" -o -iname "*.bmp" -o -iname "*.tiff" \
    -o -iname "*.tif" -o -iname "*.webp" -o -iname "*.heic" \
    -o -iname "*.heif" -o -iname "*.raw" -o -iname "*.cr2" \
    -o -iname "*.nef" \
\) -print0)

# Summary
echo ""
echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo -e "${BLUE}📊 Summary:${NC}"
echo -e "${BLUE}  Total images found: ${total_images}${NC}"
echo -e "${GREEN}  Successfully moved: ${moved_images}${NC}"
if [ $failed_images -gt 0 ]; then
    echo -e "${RED}  Failed: ${failed_images}${NC}"
fi
echo -e "${BLUE}═══════════════════════════════════════${NC}"

# List created folders
echo ""
echo -e "${BLUE}📁 Created year folders:${NC}"
find "$FOLDER" -maxdepth 1 -type d -not -name ".*" | sort | tail -n +2 | while read dir; do
    count=$(find "$dir" -maxdepth 1 -type f | wc -l)
    echo -e "${GREEN}  $(basename "$dir"): $count images${NC}"
done

echo ""
echo -e "${GREEN}✅ Done!${NC}"
