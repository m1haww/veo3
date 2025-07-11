# Video Optimization Guide for iOS Apps

## Techniques to Keep App Size Small

### 1. **Video Compression Settings**
```bash
# Ultra-compressed preview videos (for thumbnails)
ffmpeg -i input.mp4 -vf "scale=360:-2" -c:v libx264 -crf 35 -preset veryslow -an preview.mp4

# High-quality but compressed hero videos
ffmpeg -i input.mp4 -c:v libx265 -crf 28 -preset slow -tag:v hvc1 -vf "scale=1080:-2" -c:a aac -b:a 64k hero.mp4
```

### 2. **App Thinning Strategies**

#### Use On-Demand Resources (ODR)
```swift
// Configure in Xcode:
// 1. Select video files
// 2. In File Inspector, set "On Demand Resource Tags"
// 3. Load when needed:

NSBundleResourceRequest(tags: ["premium-videos"]).beginAccessingResources { error in
    if error == nil {
        // Videos are now available
    }
}
```

#### App Slicing
- Create different video qualities for different devices
- iPad Pro: 1080p videos
- iPhone SE: 720p videos
- Xcode automatically delivers appropriate assets

### 3. **Video Format Optimization**

| Format | Compression | Quality | File Size |
|--------|------------|---------|-----------|
| HEVC/H.265 | Best | Excellent | Smallest |
| H.264 | Good | Very Good | Medium |
| ProRes | Poor | Best | Largest |

### 4. **Hybrid Approach** (Recommended)

```swift
// Store only thumbnails and 3-second previews locally
// Stream full videos from CDN

struct VideoAsset {
    let thumbnail: String // Local image
    let preview: String   // Local 3-sec video
    let fullVideoURL: String // Remote URL
}
```

### 5. **Advanced Techniques**

#### Video Sprites
- Combine multiple short clips into one video file
- Use time ranges to play specific segments

#### Adaptive Bitrate Streaming
- Use HLS (HTTP Live Streaming)
- Multiple quality versions on server
- Client downloads appropriate quality

### 6. **Practical Implementation**

1. **For Style Preview Videos** (3-5 seconds each):
   - Resolution: 720x1280 (portrait) or 1280x720 (landscape)
   - Bitrate: 600-800 kbps
   - Format: HEVC/H.265
   - Expected size: ~300-500 KB per video

2. **For Hero/Banner Videos** (10-15 seconds):
   - Resolution: 1080p
   - Bitrate: 1-1.5 Mbps
   - Format: HEVC/H.265
   - Expected size: 1.5-2.5 MB per video

3. **Batch Processing Script**:
```bash
#!/bin/bash
# compress-videos.sh

for video in *.mp4; do
    # Create compressed version
    ffmpeg -i "$video" -c:v libx265 -crf 28 -preset slow -tag:v hvc1 \
           -vf "scale=720:-2" -c:a aac -b:a 64k "compressed_${video}"
    
    # Create thumbnail
    ffmpeg -i "$video" -ss 00:00:01 -vframes 1 -vf "scale=360:-2" \
           "${video%.*}_thumb.jpg"
    
    # Create 3-second preview
    ffmpeg -i "$video" -t 3 -c:v libx264 -crf 30 -vf "scale=360:-2" \
           -an "${video%.*}_preview.mp4"
done
```

## Size Comparison Example

For a 30-second full quality video:
- Original: 50 MB
- H.264 compressed: 8 MB
- HEVC compressed: 4 MB
- Preview version: 300 KB
- Thumbnail: 50 KB

## Your App Structure

```
veo3.app/
├── Assets/
│   ├── Thumbnails/      # 50-100 KB each
│   ├── Previews/        # 200-500 KB each
│   └── HeroVideos/      # 1-2 MB each (only 3-5 videos)
└── Remote CDN/
    └── FullVideos/      # Stream on demand
```

This approach keeps your app under 50 MB while providing high-quality video content!