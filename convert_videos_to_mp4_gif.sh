#!/bin/bash

# Directory containing video files
input_dir="./caseoh_vids"
output_dir="./caseoh_vids"

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
        ffmpeg -i "$file" -c:v libx264 -crf 23 -preset fast -c:a aac -b:a 128k -vf "scale=iw*min(1920/iw\,1080/ih):ih*min(1920/iw\,1080/ih), pad=1920:1080:(1920-iw*min(1920/iw\,1080/ih))/2:(1080-ih*min(1920/iw\,1080/ih))/2" "$output_mp4"
        echo "Converted $file to $output_mp4"
    fi

    # Check if GIF file already exists
    if [[ -f "$output_gif" ]]; then
        echo "Skipping $file as $output_gif already exists."
    else
        # Convert to GIF if it doesn't already exist
        ffmpeg -i "$file" -vf "scale=iw*min(600/iw\,600/ih):ih*min(600/iw\,600/ih), fps=10" "$output_gif"
        echo "Converted $file to $output_gif"
    fi
done

echo "All conversions are done."