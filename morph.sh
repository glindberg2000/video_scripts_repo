#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status.

# Directory for input images and output files
input_dir="cap_images"
output_dir="output"

# Create output directory if it doesn't exist
mkdir -p "$output_dir"

# Count the number of input images
input_count=$(ls -1 ${input_dir}/cap_*.jpg | wc -l)
echo "Number of input images found: $input_count"

# Ask user for desired video duration and frame rate
read -p "Enter desired video duration in seconds: " desired_duration
read -p "Enter desired frame rate (e.g., 30): " frame_rate

# Calculate total number of frames needed
total_frames=$((desired_duration * frame_rate))

# Calculate number of intermediate frames between each pair of images
frames_between=$(( (total_frames - input_count) / (input_count - 1) ))

# Ensure at least one intermediate frame between images
frames_between=$((frames_between < 1 ? 1 : frames_between))

echo "Generating $frames_between intermediate frames between each pair of images."
echo "This will result in approximately $total_frames total frames."

# Function to create morphed frames between two images
morph_images() {
    start=$1
    end=$2
    for ((i=1; i<=frames_between; i++)); do
        percentage=$(bc <<< "scale=2; $i / ($frames_between + 1)")
        inverse_percentage=$(bc <<< "scale=2; 1 - $percentage")
        output_file=$(printf "${output_dir}/frame_%04d.jpg" $debug_frame_count)
        echo "Generating frame $debug_frame_count: $output_file ($percentage blend between $start and $end)"
        composite -blend ${percentage}x${inverse_percentage} "${input_dir}/cap_${end}.jpg" "${input_dir}/cap_${start}.jpg" "$output_file"
        debug_frame_count=$((debug_frame_count + 1))
        if [ $debug_frame_count -ge $total_frames ]; then
            echo "Reached total frame count. Stopping frame generation."
            return 1
        fi
    done
}

# Debug frame count initialization
debug_frame_count=0

# Generate morphed frames
for i in $(seq 0 $((input_count - 2))); do
    morph_images $i $((i+1))
    if [ $? -eq 1 ]; then
        break
    fi
done

# Copy the original images to their respective positions
for i in $(seq 0 $((input_count - 1))); do
    if [ $debug_frame_count -ge $total_frames ]; then
        echo "Reached total frame count. Stopping original frame copying."
        break
    fi
    output_file=$(printf "${output_dir}/frame_%04d.jpg" $debug_frame_count)
    echo "Copying original frame $i to $output_file"
    cp "${input_dir}/cap_${i}.jpg" "$output_file"
    debug_frame_count=$((debug_frame_count + 1))
done

echo "Frame generation complete."

# Debug: List all generated frames
echo "Listing all generated frames:"
ls -1 ${output_dir}/frame_*.jpg

# Debug: Count the number of frames
frame_count=$(ls -1 ${output_dir}/frame_*.jpg | wc -l)
echo "Number of frames generated: $frame_count"
echo "Debug frame count: $debug_frame_count"

# Create video using FFmpeg
ffmpeg -framerate $frame_rate -i "${output_dir}/frame_%04d.jpg" -c:v libx264 -pix_fmt yuv420p -crf 23 "${output_dir}/cap_rotation.mp4"

# Debug: Check the duration of the created video
duration=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "${output_dir}/cap_rotation.mp4")
echo "Duration of the created video: $duration seconds"

echo "Video creation complete. Output: ${output_dir}/cap_rotation.mp4"

# Clean up intermediate frames
read -p "Do you want to delete the intermediate frames? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    rm "${output_dir}"/frame_*.jpg
    echo "Intermediate frames deleted."
fi