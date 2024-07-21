
# Video Scripts Repository

This repository contains scripts to convert videos to MP4 and GIF formats, as well as to morph images.

## Scripts

1. `convert_videos_to_mp4_gif.sh`
2. `morph.sh`

## Prerequisites

Ensure you have the following software installed on your system:

- `ffmpeg`
- `imagemagick`

You can install them using the following commands:

### For Ubuntu/Debian

```bash
sudo apt update
sudo apt install ffmpeg imagemagick
```

### For macOS

```bash
brew install ffmpeg imagemagick
```

## Usage

### 1. Convert Videos to MP4 and GIF

```bash
./convert_videos_to_mp4_gif.sh input_video
```

Replace `input_video` with the path to your video file.

### 2. Morph Images

```bash
./morph.sh input_image1 input_image2
```

Replace `input_image1` and `input_image2` with the paths to your image files.

## Contributing

Feel free to open issues or submit pull requests if you find any bugs or want to add new features.

## License

This project is licensed under the MIT License.
