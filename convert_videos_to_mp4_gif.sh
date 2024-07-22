#!/bin/bash

# Default directories
default_input_dir="./source_videos"
default_output_dir="./processed_videos"

# Use provided directories or fall back to defaults
input_dir=${1:-$default_input_dir}
output_dir=${2:-$default_output_dir}

# Create the output directory if it doesn't exist
mkdir -p "$output_dir"

# Loop through all MOV and AVI files in the input directory
for file in "$input_dir"/*.{mov,avi}; do
    # Check if the file exists (in case there are no matching files)
    if [[ ! -e "$file" ]]; then
        continue
    fi

    # Get the base name of the file without the extension
    base_name=$(basename "$file" .mov)
    base_name=$(basename "$base_name" .avi)

    # Define the output file names
    output_mp4="$output_dir/$base_name.mp4"
    output_gif="$output_dir/$base_name.gif"

    # Check if MP4 file already exists
    if [[ -f "$output_mp4" ]]; then
        echo "Skipping $file as $output_mp4 already exists."
    else
        # Convert to MP4 if it doesn't already exist
        ffmpeg -i "$file" -c:v libx264 -crf 23 -preset fast -c:a aac -b:a 128k -vf "scale=800:800,setsar=1:1" "$output_mp4"
        echo "Converted $file to $output_mp4"
    fi

    # Check if GIF file already exists
    if [[ -f "$output_gif" ]]; then
        echo "Skipping $file as $output_gif already exists."
    else
        # Convert to GIF if it doesn't already exist
        ffmpeg -i "$file" -vf "scale=800:800,setsar=1:1,fps=10" "$output_gif"
        echo "Converted $file to $output_gif"
    fi
done

echo "All conversions are done."