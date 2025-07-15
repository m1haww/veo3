# Runway API Setup Guide

## Overview
This app integrates with Runway's AI video generation API to create videos from images. The integration supports both Gen4 Turbo and Gen3a Turbo models.

## Setup Instructions

### 1. Get Your API Key
1. Sign up or log in to Runway at https://app.runwayml.com
2. Navigate to Settings → API
3. Create a new API key and copy it

### 2. Configure the App
Open `veo3/Config/APIConfig.swift` and replace the placeholder with your API key:

```swift
static let runwayAPIKey = "YOUR_ACTUAL_API_KEY_HERE"
```

Alternatively, you can set an environment variable:
```bash
export RUNWAY_API_KEY="your_api_key_here"
```

### 3. API Features

#### Image to Video Generation
- Upload an image as the starting frame
- Add optional text prompts to guide generation
- Choose between Gen4 Turbo (faster) or Gen3a Turbo (high quality)
- Select aspect ratios supported by each model
- Monitor generation progress in real-time

#### Task Management
- Automatic task status monitoring
- Progress tracking with visual feedback
- Error handling and retry capabilities
- View all active, completed, and failed tasks

### 4. Usage

1. **Select an Image**: Tap the image picker to choose a photo from your library
2. **Add a Prompt** (Optional): Describe what should happen in the video
3. **Choose Model**: Select between Gen4 Turbo or Gen3a Turbo
4. **Select Aspect Ratio**: Pick from available ratios for your chosen model
5. **Generate**: Tap the generate button to start creating your video

### 5. Supported Aspect Ratios

**Gen4 Turbo:**
- 1280:720 (Landscape)
- 720:1280 (Portrait)
- 1104:832 (Wide)
- 832:1104 (Tall)
- 960:960 (Square)
- 1584:672 (Ultra Wide)

**Gen3a Turbo:**
- 1280:768 (Landscape)
- 768:1280 (Portrait)

### 6. Rate Limits & Pricing
- Check Runway's documentation for current rate limits
- Video generation consumes credits based on duration and model
- Monitor your usage in the Runway dashboard

### 7. Troubleshooting

**Common Issues:**
- "401 Unauthorized": Check your API key is correct
- "429 Too Many Requests": You've hit the rate limit
- "Task Failed": The image might violate content policy

**Debug Mode:**
Enable debug logging by setting a breakpoint in `RunwayAPIService.swift` to inspect API responses.

### 8. API Documentation
Full API documentation: https://docs.runwayml.com/api