#!/bin/bash

# Function to add header to a file
add_header() {
    local file="$1"
    local header="/*
 * VizOS - High-performance desktop environment
 * Copyright (c) 2025 $(git config user.name 2>/dev/null || echo 'Your Name')
 *
 * This file is part of VizOS desktop environment
 */"
    
    # Check if header already exists
    if ! head -n 5 "$file" | grep -q "Copyright"; then
        # Create temp file with header
        temp_file=$(mktemp)
        echo "$header" > "$temp_file"
        echo "" >> "$temp_file"
        cat "$file" >> "$temp_file"
        mv "$temp_file" "$file"
        echo "✓ Added header to $file"
    else
        echo "⚠️  Header already exists in $file"
    fi
}

# Add headers to all C source files
for file in src/*.c src/*.h tests/*.c; do
    if [ -f "$file" ]; then
        add_header "$file"
    fi
done

echo "✅ Headers added to source files"
