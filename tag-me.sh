#!/bin/bash

# Script to tag and push all local Spring Pet Clinic images from springcommunity to rodiroger

# Ensure we're logged in to Docker Hub
echo "Please log in to DockerHub:"
docker login

# Handle potential login failure
if [ $? -ne 0 ]; then
    echo "DockerHub login failed. Exiting."
    exit 1
fi

# Find all locally available springcommunity/spring-petclinic* images
echo "Finding all local springcommunity/spring-petclinic* images..."
IMAGES=$(docker images "springcommunity/spring-petclinic*" --format "{{.Repository}}:{{.Tag}}" | grep -v "<none>")

if [ -z "$IMAGES" ]; then
    echo "No local springcommunity/spring-petclinic* images found. Exiting."
    exit 1
fi

echo "Found the following local images:"
echo "$IMAGES"
echo ""

# Process each image
for SOURCE_IMAGE in $IMAGES; do
    # Extract the repository and tag
    REPO_WITH_TAG=$SOURCE_IMAGE
    REPO=${REPO_WITH_TAG%:*}
    TAG=${REPO_WITH_TAG#*:}
    
    # Handle case where there's no explicit tag (uses 'latest')
    if [ "$REPO" = "$TAG" ]; then
        TAG="latest"
    fi
    
    # Extract the image name without the namespace
    IMAGE_NAME=${REPO#springcommunity/}
    
    # Create the target image name
    TARGET_REPO="rodiroger$IMAGE_NAME"
    TARGET_IMAGE="$TARGET_REPO:$TAG"
    
    echo "Processing $SOURCE_IMAGE -> $TARGET_IMAGE"
    
    # Tag the image with the new namespace
    echo "  Tagging as $TARGET_IMAGE..."
    docker tag $SOURCE_IMAGE $TARGET_IMAGE
    
    if [ $? -ne 0 ]; then
        echo "  Failed to tag $SOURCE_IMAGE. Skipping."
        continue
    fi
    
    # Push the newly tagged image
    echo "  Pushing $TARGET_IMAGE to DockerHub..."
    docker push $TARGET_IMAGE
    
    if [ $? -ne 0 ]; then
        echo "  Failed to push $TARGET_IMAGE."
    else
        echo "  Successfully pushed $TARGET_IMAGE to DockerHub."
    fi
    
    echo ""
done

echo "All operations completed."