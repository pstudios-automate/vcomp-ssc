#!/bin/bash

echo "🔧 Setting up project attribution..."

# Replace placeholders with your actual information
YOUR_NAME="Your Name"
YOUR_EMAIL="your.email@domain.com" 
YOUR_GITHUB="yourusername"

# Update all files with your information
sed -i "s/\[Your Name\]/$YOUR_NAME/g" LICENSE
sed -i "s/your.email@domain.com/$YOUR_EMAIL/g" AUTHORS
sed -i "s/your.email@domain.com/$YOUR_EMAIL/g" README.md
sed -i "s/@yourusername/@$YOUR_GITHUB/g" README.md
sed -i "s/yourusername/$YOUR_GITHUB/g" README.md
sed -i "s/Your Name/$YOUR_NAME/g" METADATA.txt
sed -i "s/your.email@domain.com/$YOUR_EMAIL/g" METADATA.txt
sed -i "s/yourusername/$YOUR_GITHUB/g" METADATA.txt

# Update source file headers
for file in src/*.c src/*.h tests/*.c; do
    if [ -f "$file" ]; then
        sed -i "s/Your Name/$YOUR_NAME/g" "$file" 2>/dev/null
    fi
done

echo "✅ Attribution set up for: $YOUR_NAME"
echo "📧 Email: $YOUR_EMAIL"
echo "🐙 GitHub: $YOUR_GITHUB"
