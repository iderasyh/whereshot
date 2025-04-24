#!/bin/bash

# Parameters
INPUT_IMAGE="assets/images/logo-transparent.png"
OUTPUT_IMAGE="assets/images/splash-icon.png"
TEMP_CIRCLE_MASK="assets/images/temp_circle_mask.png"
CANVAS_SIZE=1152
CIRCLE_DIAMETER=768

echo "Creating Android 12+ splash icon from $INPUT_IMAGE"

# Create a circular mask
convert -size ${CANVAS_SIZE}x${CANVAS_SIZE} xc:none -fill white \
  -draw "circle $((CANVAS_SIZE/2)),$((CANVAS_SIZE/2)) $((CANVAS_SIZE/2)),$((CANVAS_SIZE/2 - CIRCLE_DIAMETER/2))" \
  "$TEMP_CIRCLE_MASK"

# Get the dimensions of the input image
DIMENSIONS=$(identify -format "%wx%h" "$INPUT_IMAGE")
echo "Original image dimensions: $DIMENSIONS"

# Create the final image with proper dimensions
convert "$INPUT_IMAGE" -resize ${CIRCLE_DIAMETER}x${CIRCLE_DIAMETER} -background none -gravity center \
  -extent ${CANVAS_SIZE}x${CANVAS_SIZE} "$OUTPUT_IMAGE"

echo "Splash icon created at $OUTPUT_IMAGE"
echo "Now update your flutter_native_splash configuration to use this image:"
echo ""
echo "flutter_native_splash:"
echo "  color: \"#FFFFFF\""
echo "  image: assets/images/splash-icon.png"
echo "  android_12:"
echo "    image: assets/images/splash-icon.png"
echo "    color: \"#FFFFFF\""
echo ""
echo "Then run: dart run flutter_native_splash:create" 