# Image Organization Script - User Guide

## Table of Contents

1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Installation](#installation)
4. [Quick Start](#quick-start)
5. [How to Use](#how-to-use)
6. [Understanding Output](#understanding-output)
7. [Common Use Cases](#common-use-cases)
8. [Advanced Usage](#advanced-usage)
9. [Troubleshooting](#troubleshooting)
10. [FAQ](#faq)

---

## Overview

The **Image Organization Script** automatically organizes your image files into folders based on the year they were created.

### Key Benefits

✅ **Moves files** (not copies) - saves disk space  
✅ **Only processes images** - ignores other files  
✅ **Smart date detection** - uses EXIF data first, then file date  
✅ **Automatic folder creation** - creates year folders as needed  
✅ **Progress tracking** - colored output shows what's happening  
✅ **Error handling** - handles failures gracefully  

### What It Does

```
Before:
├── IMG_0001.jpg
├── IMG_0002.jpg
├── document.pdf
└── IMG_0003.jpg

After:
├── 2020/
│   ├── IMG_0001.jpg
│   └── IMG_0002.jpg
├── 2023/
│   └── IMG_0003.jpg
└── document.pdf  (unchanged)
```

---

## Prerequisites

### System Requirements

- **macOS**, **Linux**, or **Windows** (with WSL)
- **Bash** shell (pre-installed on macOS and Linux)
- Basic terminal/command line knowledge

### Optional but Recommended

For better date detection from photo metadata:

```bash
# macOS
brew install exiftool

# Ubuntu/Debian
sudo apt-get install exiftool

# Fedora/RHEL
sudo dnf install exiftool
```

Without `exiftool`, the script uses file modification dates instead.

---

## Installation

### Step 1: Get the Script

Clone or download from GitHub:

```bash
# Clone the repository
git clone https://github.com/your-username/repo.git

# Or download directly
cd path/to/script
```

### Step 2: Make It Executable

```bash
chmod +x organize-images.sh
```

### Step 3: Verify Installation

```bash
# Check if script is executable
ls -l organize-images.sh

# Output should show: -rwxr-xr-x
```

---

## Quick Start

### 5-Second Setup

```bash
# 1. Install exiftool (one time)
brew install exiftool

# 2. Run the script
./organize-images.sh ~/Pictures

# Done! ✅
```

---

## How to Use

### Basic Usage

```bash
./organize-images.sh /path/to/images
```

### Examples

#### Organize Pictures Folder

```bash
./organize-images.sh ~/Pictures
```

#### Organize Downloads

```bash
./organize-images.sh ~/Downloads
```

#### Organize Desktop

```bash
./organize-images.sh ~/Desktop
```

#### Organize Custom Folder

```bash
./organize-images.sh /Volumes/ExternalDrive/Photos
```

#### With Spaces in Path

```bash
# Use backslash to escape spaces
./organize-images.sh ~/Pictures/My\ Photos

# Or use quotes
./organize-images.sh "~/Pictures/My Photos"
```

#### Drag and Drop (Easiest)

1. Open Terminal
2. Type: `./organize-images.sh `
3. Drag folder into Terminal window
4. Press Enter

---

## Understanding Output

### During Execution

```
🔍 Searching for images in: /Users/john/Pictures

✓ Created folder: 2020
✓ Moved: IMG_0001.jpg → 2020/
✓ Moved: IMG_0002.png → 2020/
✓ Created folder: 2021
✓ Moved: IMG_0003.jpg → 2021/
✓ Created folder: 2023
✓ Moved: IMG_0004.heic → 2023/
⚠️  No date found for: IMG_0005.jpg, using current year: 2026
✓ Moved: IMG_0005.jpg → 2026/
```

### Summary Report

```
═══════════════════════════════════════
📊 Summary:
  Total images found: 5
  Successfully moved: 5
═══════════════════════════════════════

📁 Created year folders:
  2020: 2 images
  2021: 1 images
  2023: 1 images
  2026: 1 images

✅ Done!
```

### What Each Symbol Means

| Symbol | Meaning |
|--------|---------|
| 🔍 | Searching for images |
| ✓ | Successfully completed |
| ✗ | Failed to move |
| ⚠️ | Warning (no date found) |
| ❌ | Error |
| ✅ | Process finished |

---

## Common Use Cases

### Case 1: Organize Phone Photos

```bash
# After transferring photos from phone to computer
./organize-images.sh ~/Downloads/iPhone\ Photos
```

**Result:** Photos organized by year they were taken (from EXIF)

### Case 2: Organize Camera SD Card

```bash
# After copying files from SD card
./organize-images.sh /Volumes/SD_CARD
```

**Result:** Photos organized by year shot

### Case 3: Clean Up Downloads Folder

```bash
# Organize all screenshot and saved images
./organize-images.sh ~/Downloads
```

**Result:** Only images moved, other files stay in place

### Case 4: Organize External Hard Drive

```bash
# Organize large photo collection
./organize-images.sh /Volumes/PhotosBackup
```

**Result:** Entire photo library organized by year

### Case 5: Backup Folder Organization

```bash
# Before archiving backups
./organize-images.sh ~/Desktop/Photos\ to\ Archive
```

**Result:** Organized, ready to archive to external storage

---

## Advanced Usage

### Organize by Year-Month

Create a modified version for monthly organization:

1. **Save as new script:**

```bash
cp organize-images.sh organize-images-monthly.sh
nano organize-images-monthly.sh
```

2. **Find this line:**

```bash
year_folder="$FOLDER/$year"
```

3. **Replace with:**

```bash
month=$(exiftool -n -d "%m" -DateTimeOriginal "$image_file" 2>/dev/null | head -1)
if [ -z "$month" ]; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
        month=$(stat -f "%Sm" -t "%m" "$image_file" 2>/dev/null)
    else
        month=$(stat -c "%y" "$image_file" 2>/dev/null | cut -d' ' -f1 | cut -d'-' -f2)
    fi
fi
year_folder="$FOLDER/$year-$month"
```

4. **Make executable:**

```bash
chmod +x organize-images-monthly.sh
```

5. **Use it:**

```bash
./organize-images-monthly.sh ~/Pictures
```

**Result:**

```
├── 2020-01/
├── 2020-02/
├── 2020-12/
├── 2021-01/
└── 2021-03/
```

### Organize by Year-Month-Day

For daily organization, add day extraction to the monthly version above:

```bash
day=$(exiftool -n -d "%d" -DateTimeOriginal "$image_file" 2>/dev/null | head -1)
if [ -z "$day" ]; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
        day=$(stat -f "%Sm" -t "%d" "$image_file" 2>/dev/null)
    else
        day=$(stat -c "%y" "$image_file" 2>/dev/null | cut -d' ' -f1 | cut -d'-' -f3)
    fi
fi
year_folder="$FOLDER/$year/$month/$day"
```

**Result:**

```
├── 2020/
│   ├── 01/
│   │   ├── 15/
│   │   └── 20/
│   └── 12/
│       └── 25/
└── 2021/
    └── 03/
        └── 10/
```

### Test Before Running

Verify what will be organized without moving anything:

```bash
# List all images that would be processed
find ~/Pictures -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.heic" \)

# Count them
find ~/Pictures -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.heic" \) | wc -l
```

---

## Troubleshooting

### ❌ "Permission denied"

**Problem:** Script won't run

**Solution:**

```bash
# Make it executable
chmod +x organize-images.sh

# Or run with bash explicitly
bash organize-images.sh ~/Pictures
```

### ❌ "No images found"

**Problem:** Script runs but finds no images

**Possible causes:**

```bash
# 1. Check folder path exists
ls ~/Pictures

# 2. Check what files are in it
ls -la ~/Pictures

# 3. Check file extensions
find ~/Pictures -type f | head -20

# 4. Script looks in top level only
# Files in subfolders won't be organized
```

**Solution:** Make sure images are in top level of folder, not in subfolders

### ❌ "exiftool not found"

**Problem:** Script says exiftool is missing

**Solution:**

```bash
# Install it (macOS)
brew install exiftool

# Or Linux
sudo apt-get install exiftool

# Script will still work without it, but uses file dates instead
```

### ❌ "Folder does not exist"

**Problem:** Error message about folder path

**Solution:**

```bash
# Double-check the path
ls -d ~/Pictures

# Use full path
./organize-images.sh /Users/yourname/Pictures

# Or use quotes for spaces
./organize-images.sh "~/Pictures/My Photos"
```

### ❌ "Failed to move some images"

**Problem:** Some images didn't move

**Possible causes:**

- File permissions restricted
- Disk full
- File system read-only

**Solution:**

```bash
# Check permissions
ls -l ~/Pictures/IMG_0001.jpg

# Check disk space
df -h

# Run again and check error messages
./organize-images.sh ~/Pictures
```

### ⚠️ "No date found, using current year"

**Problem:** Some images have no date metadata

**This is normal for:**
- Downloaded images
- Screenshots
- Files without EXIF data

**Solution:** All such images go to current year folder. You can manually move them later if needed.

---

## FAQ

### Q: Will my original images be deleted?

**A:** No! Images are **moved**, not deleted. They're just reorganized into year folders. Original files remain intact.

### Q: Can I undo the organization?

**A:** Yes, you can manually move files back out of year folders. The script doesn't delete anything permanently.

For full recovery:

```bash
# Move all images back to parent folder
find ~/Pictures -type f \( -iname "*.jpg" -o -iname "*.png" \) -exec mv {} ~/Pictures \;

# Then delete empty year folders
find ~/Pictures -maxdepth 1 -type d -empty -delete
```

### Q: Does it organize images in subfolders?

**A:** No, the script only looks at the top level. Images already in subfolders are ignored.

To organize everything recursively, you can run it on each subfolder:

```bash
find ~/Pictures -maxdepth 1 -type d | while read dir; do
    ./organize-images.sh "$dir"
done
```

### Q: What image formats are supported?

**A:** 13+ formats including:

- JPG / JPEG
- PNG
- GIF
- BMP
- TIFF / TIF
- WEBP
- HEIC / HEIF (Apple formats)
- RAW
- CR2 (Canon)
- NEF (Nikon)

### Q: How does it determine the year?

**A:** Priority order:

1. **EXIF DateTimeOriginal** (photo metadata - most accurate)
2. **File modification date** (when file was created/modified)
3. **Current year** (fallback, with warning)

### Q: Is it safe to run multiple times?

**A:** Yes! Running it again will:
- Skip images already in year folders
- Move any new images found
- Not affect already organized images

### Q: What about duplicate filenames?

**A:** If two images have the same name in same year folder, the script will warn and skip to avoid overwriting.

Solution: Rename the duplicate first:

```bash
mv ~/Pictures/2020/IMG_0001.jpg ~/Pictures/2020/IMG_0001_copy.jpg
./organize-images.sh ~/Pictures
```

### Q: Can I run it on an external drive?

**A:** Yes!

```bash
./organize-images.sh /Volumes/ExternalDrive/Photos
```

**Note:** Moving files between drives might be slower.

### Q: Does it work on Windows?

**A:** 

- **Windows 10+:** Use Windows Subsystem for Linux (WSL)
- **Windows Bash:** Use Git Bash or similar
- **Native Windows:** Use PowerShell script instead

### Q: How long will it take?

**A:** Depends on:
- Number of images (50 images = few seconds, 5000 images = few minutes)
- Hard drive speed (SSD faster than HDD)
- EXIF data availability

Larger operations may take 5-15 minutes.

### Q: Can I organize by photographer/camera?

**A:** The current script organizes by year only. For more complex organization (by camera, photographer, etc.), you'd need a modified version.

Contact the script author for custom versions.

### Q: What if EXIF dates are wrong?

**A:** EXIF dates come from camera/phone metadata. If they're incorrect:

1. Edit photo metadata with `exiftool`:

```bash
exiftool -DateTimeOriginal="2020:01:15 10:30:00" IMG_0001.jpg
```

2. Re-run the script

Or manually move the image to correct year folder.

---

## Tips & Best Practices

### ✅ DO

- ✅ Test with a small folder first
- ✅ Check disk space before organizing large libraries
- ✅ Backup important photos before running
- ✅ Run periodically to keep photos organized
- ✅ Use `exiftool` for accurate date detection

### ❌ DON'T

- ❌ Run on system folders
- ❌ Use on read-only drives
- ❌ Interrupt the script while running
- ❌ Organize the same folder multiple times rapidly
- ❌ Move the script while it's running

---

## Support & Resources

### Getting Help

1. Check the [Troubleshooting](#troubleshooting) section above
2. Review [FAQ](#faq) for common questions
3. Check script GitHub repository for issues
4. Review script comments for technical details

### Related Tools

- **exiftool**: `brew install exiftool`
- **jq**: For JSON processing
- **find**: Built-in search utility

---

## Quick Reference

### Most Common Commands

```bash
# Organize pictures
./organize-images.sh ~/Pictures

# Organize downloads
./organize-images.sh ~/Downloads

# Organize external drive
./organize-images.sh /Volumes/MyDrive/Photos

# Make executable first time
chmod +x organize-images.sh

# Install exiftool
brew install exiftool
```

---

**Version:** 1.0  
**Last Updated:** February 2026  
**Compatibility:** macOS, Linux, Windows (WSL)

For more information, visit the GitHub repository or check the script source code.
