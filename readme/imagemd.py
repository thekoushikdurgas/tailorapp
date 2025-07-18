import os
import re
import requests
import hashlib
from urllib.parse import urlparse, unquote
from pathlib import Path
import time
from typing import List, Dict, Tuple

class MarkdownImageDownloader:
    def __init__(self, root_dir: str = ".", images_dir: str = "images"):
        """
        Initialize the image downloader
        
        Args:
            root_dir: Root directory to scan for markdown files
            images_dir: Directory to store downloaded images
        """
        self.root_dir = Path(root_dir)
        self.images_dir = Path(images_dir)
        self.images_dir.mkdir(exist_ok=True)
        
        # Regex patterns for finding images in markdown
        self.image_patterns = [
            # ![alt text](url)
            r'!\[([^\]]*)\]\(([^)]+)\)',
            # <img src="url" alt="alt text">
            r'<img[^>]+src=["\']([^"\']+)["\'][^>]*>',
            # [alt]: url
            r'^\s*\[([^\]]+)\]:\s*([^\s]+)',
        ]
        
        # Supported image extensions
        self.image_extensions = {'.png', '.jpg', '.jpeg', '.gif', '.svg', '.webp', '.bmp'}
        
        # Keep track of downloaded images to avoid duplicates
        self.downloaded_images: Dict[str, str] = {}
        
    def find_markdown_files(self) -> List[Path]:
        """Find all markdown files in the root directory and subdirectories"""
        markdown_files = []
        for pattern in ['*.md', '*.markdown']:
            markdown_files.extend(self.root_dir.rglob(pattern))
        return markdown_files
    
    def extract_image_urls(self, content: str) -> List[Tuple[str, str, str]]:
        """
        Extract image URLs from markdown content
        
        Returns:
            List of tuples: (full_match, alt_text, url)
        """
        image_urls = []
        
        for pattern in self.image_patterns:
            matches = re.finditer(pattern, content, re.MULTILINE)
            for match in matches:
                if pattern.startswith('!'):  # ![alt](url) format
                    full_match = match.group(0)
                    alt_text = match.group(1)
                    url = match.group(2)
                elif pattern.startswith('<img'):  # <img> format
                    full_match = match.group(0)
                    url = match.group(1)
                    alt_match = re.search(r'alt=["\']([^"\']*)["\']', full_match)
                    alt_text = alt_match.group(1) if alt_match else ""
                else:  # [alt]: url format
                    full_match = match.group(0)
                    alt_text = match.group(1)
                    url = match.group(2)
                
                # Check if it's an online image URL
                if self.is_online_image_url(url):
                    image_urls.append((full_match, alt_text, url))
        
        return image_urls
    
    def is_online_image_url(self, url: str) -> bool:
        """Check if URL is an online image"""
        if not url.startswith(('http://', 'https://')):
            return False
        
        parsed_url = urlparse(url)
        path = parsed_url.path.lower()
        
        # Check if it has an image extension or is from known image services
        has_image_extension = any(path.endswith(ext) for ext in self.image_extensions)
        is_image_service = any(domain in parsed_url.netloc for domain in [
            'user-gen-media-assets.s3.amazonaws.com',
            'ppl-ai-code-interpreter-files.s3.amazonaws.com',
            'imgur.com',
            'github.com',
            'githubusercontent.com'
        ])
        
        return has_image_extension or is_image_service
    
    def generate_filename(self, url: str, alt_text: str = "") -> str:
        """Generate a unique filename for the downloaded image"""
        # Get the original extension
        parsed_url = urlparse(url)
        path = unquote(parsed_url.path)
        
        # Extract extension
        extension = Path(path).suffix.lower()
        if not extension or extension not in self.image_extensions:
            extension = '.png'  # Default extension
        
        # Create a filename based on alt text and URL hash
        if alt_text:
            # Clean alt text for filename
            clean_alt = re.sub(r'[^\w\s-]', '', alt_text).strip()
            clean_alt = re.sub(r'[-\s]+', '-', clean_alt)
            base_name = clean_alt[:50]  # Limit length
        else:
            base_name = "image"
        
        # Add URL hash to ensure uniqueness
        url_hash = hashlib.md5(url.encode()).hexdigest()[:8]
        filename = f"{base_name}-{url_hash}{extension}"
        
        return filename
    
    def download_image(self, url: str, filename: str) -> bool:
        """Download image from URL to local file"""
        try:
            headers = {
                'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
            }
            
            response = requests.get(url, headers=headers, timeout=30)
            response.raise_for_status()
            
            file_path = self.images_dir / filename
            with open(file_path, 'wb') as f:
                f.write(response.content)
            
            print(f"✓ Downloaded: {filename}")
            return True
            
        except Exception as e:
            print(f"✗ Failed to download {url}: {str(e)}")
            return False
    
    def process_markdown_file(self, file_path: Path) -> int:
        """Process a single markdown file and update image references"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            original_content = content
            image_urls = self.extract_image_urls(content)
            
            if not image_urls:
                return 0
            
            print(f"\nProcessing: {file_path}")
            print(f"Found {len(image_urls)} images")
            
            updated_count = 0
            
            for full_match, alt_text, url in image_urls:
                # Check if we already downloaded this image
                if url in self.downloaded_images:
                    local_filename = self.downloaded_images[url]
                else:
                    # Generate filename and download
                    local_filename = self.generate_filename(url, alt_text)
                    
                    if self.download_image(url, local_filename):
                        self.downloaded_images[url] = local_filename
                    else:
                        continue  # Skip this image if download failed
                
                # Calculate relative path from markdown file to images directory
                relative_path = os.path.relpath(self.images_dir / local_filename, file_path.parent)
                
                # Update the markdown content
                if full_match.startswith('!['):
                    # Standard markdown format
                    new_reference = f"![{alt_text}]({relative_path})"
                elif full_match.startswith('<img'):
                    # HTML img tag - keep original but update src
                    new_reference = re.sub(r'src=["\'][^"\']+["\']', f'src="{relative_path}"', full_match)
                else:
                    # Reference style
                    new_reference = f"[{alt_text}]: {relative_path}"
                
                content = content.replace(full_match, new_reference)
                updated_count += 1
            
            # Write back the updated content if changes were made
            if content != original_content:
                with open(file_path, 'w', encoding='utf-8') as f:
                    f.write(content)
                print(f"✓ Updated {updated_count} image references in {file_path}")
            
            return updated_count
            
        except Exception as e:
            print(f"✗ Error processing {file_path}: {str(e)}")
            return 0
    
    def run(self):
        """Main method to process all markdown files"""
        print("🔍 Scanning for markdown files...")
        markdown_files = self.find_markdown_files()
        
        if not markdown_files:
            print("No markdown files found!")
            return
        
        print(f"Found {len(markdown_files)} markdown files")
        print(f"Images will be saved to: {self.images_dir.absolute()}")
        
        total_images = 0
        total_files_updated = 0
        
        for file_path in markdown_files:
            updated_count = self.process_markdown_file(file_path)
            if updated_count > 0:
                total_files_updated += 1
                total_images += updated_count
            
            # Small delay to be respectful to servers
            time.sleep(0.5)
        
        print(f"\n🎉 Complete!")
        print(f"📁 Files processed: {len(markdown_files)}")
        print(f"📄 Files updated: {total_files_updated}")
        print(f"🖼️  Images downloaded: {len(self.downloaded_images)}")
        print(f"🔗 References updated: {total_images}")
        print(f"📂 Images saved to: {self.images_dir.absolute()}")


def main():
    """Main function to run the image downloader"""
    print("🚀 Starting Markdown Image Downloader")
    print("=" * 50)
    
    # You can customize these paths
    root_directory = "."  # Current directory - change if needed
    images_directory = "images"  # Local images folder
    
    downloader = MarkdownImageDownloader(root_directory, images_directory)
    downloader.run()


if __name__ == "__main__":
    main()
