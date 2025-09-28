import json
import os
import sqlite3
import sys
import tempfile
import time
import hashlib
from pathlib import Path
from typing import List, Tuple, Optional, Dict
from urllib.parse import urlparse


def find_zen_profile() -> Optional[Path]:
    """Find the Zen Browser profile directory."""
    # Common locations for Zen Browser profile
    possible_paths = [
        Path.home() / ".zen",
        Path.home() / ".config" / "zen",
        Path.home() / ".local" / "share" / "zen",
        Path.home() / ".var" / "app" / "app.zen_browser.zen",
    ]

    for base_path in possible_paths:
        if base_path.exists():
            # Look for profiles directory
            profiles_dir = base_path / ".zen"
            if profiles_dir.exists():
                # Find the default profile (usually ends with .default or .default-release)
                for profile in profiles_dir.iterdir():
                    if profile.is_dir() and ("default" in profile.name.lower()):
                        return profile

                # If no default profile, return the first profile found
                for profile in profiles_dir.iterdir():
                    if profile.is_dir():
                        return profile

    return None


def get_favicon_cache_dir() -> Path:
    """Get the directory for cached favicon files."""
    cache_dir = Path.home() / ".cache" / "zen-bookmarks" / "favicons"
    cache_dir.mkdir(parents=True, exist_ok=True)
    return cache_dir


def save_favicon_to_file(blob_data: bytes, url: str) -> Optional[str]:
    """Save favicon blob data to a file and return the file path."""
    if not blob_data:
        return None

    # Create a hash of the URL to use as filename
    url_hash = hashlib.md5(url.encode()).hexdigest()

    # Detect file extension from blob data
    extension = _get_file_extension(blob_data)
    filename = f"{url_hash}.{extension}"

    favicon_cache_dir = get_favicon_cache_dir()
    filepath = favicon_cache_dir / filename

    # Save the favicon if it doesn't exist or is older than a day
    if not filepath.exists() or (time.time() - filepath.stat().st_mtime) > 86400:
        try:
            with open(filepath, "wb") as f:
                f.write(blob_data)
        except IOError:
            return None

    return str(filepath)


def get_favicon_file_path(profile_path: Path, url: str) -> Optional[str]:
    """Get favicon file path from the browser's favicon database."""
    # First check if we already have a cached favicon file
    url_hash = hashlib.md5(url.encode()).hexdigest()
    favicon_cache_dir = get_favicon_cache_dir()

    # Look for existing cached favicon with any extension
    for ext in ["png", "ico", "jpg", "jpeg", "gif", "webp"]:
        cached_file = favicon_cache_dir / f"{url_hash}.{ext}"
        if (
            cached_file.exists() and (time.time() - cached_file.stat().st_mtime) < 86400
        ):  # 1 day cache
            return str(cached_file)

    # Extract favicon from database
    blob_data = _extract_favicon_blob(profile_path, url)
    if blob_data:
        return save_favicon_to_file(blob_data, url)

    return None


def _extract_favicon_blob(profile_path: Path, url: str) -> Optional[bytes]:
    """Extract favicon blob data from the browser's database."""
    favicons_db = profile_path / "favicons.sqlite"

    # Try favicons.sqlite first (newer Firefox versions)
    if favicons_db.exists():
        blob_data = _extract_from_favicons_db(favicons_db, url)
        if blob_data:
            return blob_data

    # Fall back to places.sqlite (older versions)
    places_db = profile_path / "places.sqlite"
    if places_db.exists():
        return _extract_from_places_db(places_db, url)

    return None


def _extract_from_favicons_db(favicons_db: Path, url: str) -> Optional[bytes]:
    """Extract favicon from favicons.sqlite database."""
    try:
        parsed = urlparse(url)
        domain = f"{parsed.scheme}://{parsed.netloc}"
    except Exception as e:
        print(f"URL parsing error for {url}: {e}", file=sys.stderr)
        return None

    with tempfile.NamedTemporaryFile(suffix=".sqlite", delete=False) as tmp_db:
        tmp_db.write(favicons_db.read_bytes())
        tmp_db_path = tmp_db.name

    favicon_data = None
    try:
        conn = sqlite3.connect(tmp_db_path)
        cursor = conn.cursor()

        # Query to get favicon blob data
        queries = [
            # Modern favicons.sqlite schema
            """
            SELECT moz_icons.data
            FROM moz_icons
            JOIN moz_pages_w_icons ON moz_icons.id = moz_pages_w_icons.icon_id
            WHERE moz_pages_w_icons.page_url LIKE ?
            AND moz_icons.data IS NOT NULL
            ORDER BY moz_icons.width DESC
            LIMIT 1
            """,
            # Alternative schema
            """
            SELECT data
            FROM moz_icons
            WHERE icon_url LIKE ?
            AND data IS NOT NULL
            ORDER BY width DESC
            LIMIT 1
            """,
        ]

        for query in queries:
            try:
                cursor.execute(query, (f"{domain}%",))
                result = cursor.fetchone()
                if result and result[0]:
                    favicon_data = result[0]
                    break
            except sqlite3.Error:
                continue

        conn.close()
    except sqlite3.Error:
        pass
    finally:
        os.unlink(tmp_db_path)

    return favicon_data


def _extract_from_places_db(places_db: Path, url: str) -> Optional[bytes]:
    """Extract favicon from places.sqlite database (older Firefox versions)."""
    try:
        parsed = urlparse(url)
        domain = f"{parsed.scheme}://{parsed.netloc}"
    except Exception as e:
        print(f"URL parsing error for {url}: {e}", file=sys.stderr)
        return None

    with tempfile.NamedTemporaryFile(suffix=".sqlite", delete=False) as tmp_db:
        tmp_db.write(places_db.read_bytes())
        tmp_db_path = tmp_db.name

    favicon_data = None
    try:
        conn = sqlite3.connect(tmp_db_path)
        cursor = conn.cursor()

        # Query for older places.sqlite schema
        query = """
        SELECT moz_favicons.data
        FROM moz_favicons
        JOIN moz_places ON moz_places.favicon_id = moz_favicons.id
        WHERE moz_places.url LIKE ?
        AND moz_favicons.data IS NOT NULL
        LIMIT 1
        """

        cursor.execute(query, (f"{domain}%",))
        result = cursor.fetchone()
        if result and result[0]:
            favicon_data = result[0]

        conn.close()
    except sqlite3.Error:
        pass
    finally:
        os.unlink(tmp_db_path)

    return favicon_data


def _get_file_extension(blob_data: bytes) -> str:
    """Detect file extension from binary data."""
    if not blob_data or len(blob_data) < 8:
        return "png"  # default

    # Check magic bytes for common image formats
    if blob_data.startswith(b"\x89PNG\r\n\x1a\n"):
        return "png"
    elif blob_data.startswith(b"\xff\xd8\xff"):
        return "jpg"
    elif blob_data.startswith(b"GIF87a") or blob_data.startswith(b"GIF89a"):
        return "gif"
    elif blob_data.startswith(b"RIFF") and b"WEBP" in blob_data[:12]:
        return "webp"
    elif blob_data.startswith(b"\x00\x00\x01\x00") or blob_data.startswith(
        b"\x00\x00\x02\x00"
    ):
        return "ico"
    else:
        return "png"  # default fallback


def build_folder_hierarchy(conn) -> Dict[int, str]:
    """Build a dictionary mapping bookmark IDs to their folder paths."""
    cursor = conn.cursor()

    # Get all folders
    query = """
    SELECT id, parent, title, type
    FROM moz_bookmarks
    WHERE type = 2 OR id = 1
    ORDER BY parent, position
    """

    cursor.execute(query)
    folders = cursor.fetchall()

    # Build hierarchy map
    folder_map = {}  # id -> title
    parent_map = {}  # id -> parent_id

    for folder_id, parent_id, title, bookmark_type in folders:
        if bookmark_type == 2:  # folder type
            folder_map[folder_id] = title or "Untitled Folder"
            parent_map[folder_id] = parent_id

    # Build full paths
    def get_folder_path(folder_id: int) -> str:
        path_parts = []
        current_id = folder_id

        # Traverse up the hierarchy
        while current_id in folder_map and current_id != 1:  # 1 is usually root
            folder_name = folder_map[current_id]
            # Skip system folders
            if folder_name not in ["", "menu", "toolbar", "unfiled", "mobile"]:
                path_parts.append(folder_name)
            current_id = parent_map.get(current_id)

            # Prevent infinite loops
            if len(path_parts) > 10:
                break

        path_parts.reverse()
        return " > ".join(path_parts) if path_parts else ""

    # Map all folder IDs to their full paths
    folder_paths = {}
    for folder_id in folder_map:
        folder_paths[folder_id] = get_folder_path(folder_id)

    return folder_paths


def extract_bookmarks(profile_path: Path) -> List[Tuple[str, str, str]]:
    """Extract bookmarks from the Zen Browser database with folder paths."""
    bookmarks = []
    places_db = profile_path / "places.sqlite"

    if not places_db.exists():
        print(f"Error: places.sqlite not found in {profile_path}", file=sys.stderr)
        return bookmarks

    # Create a temporary copy of the database to avoid lock issues
    with tempfile.NamedTemporaryFile(suffix=".sqlite", delete=False) as tmp_db:
        tmp_db.write(places_db.read_bytes())
        tmp_db_path = tmp_db.name

    try:
        conn = sqlite3.connect(tmp_db_path)

        # Build folder hierarchy
        folder_paths = build_folder_hierarchy(conn)

        cursor = conn.cursor()

        # Query to get bookmarks with their titles, URLs, and parent folder
        query = """
        SELECT moz_bookmarks.title, moz_places.url, moz_bookmarks.parent
        FROM moz_bookmarks
        JOIN moz_places ON moz_bookmarks.fk = moz_places.id
        WHERE moz_bookmarks.type = 1
        AND moz_bookmarks.title IS NOT NULL
        AND moz_places.url NOT LIKE 'place:%'
        ORDER BY moz_bookmarks.dateAdded DESC
        """

        cursor.execute(query)
        results = cursor.fetchall()

        for title, url, parent_id in results:
            folder_path = folder_paths.get(parent_id, "")
            bookmarks.append((title, url, folder_path))

        conn.close()
    except sqlite3.Error as e:
        print(f"Database error: {e}", file=sys.stderr)
    finally:
        # Clean up temporary file
        os.unlink(tmp_db_path)

    return bookmarks


def get_cache_path() -> Path:
    """Get the path to the cache file."""
    cache_dir = Path.home() / ".cache" / "zen-bookmarks"
    cache_dir.mkdir(parents=True, exist_ok=True)
    return cache_dir / "bookmarks.json"


def is_cache_valid(cache_path: Path, max_age_seconds: int = 300) -> bool:
    """Check if cache exists and is still valid (default: 5 minutes)."""
    if not cache_path.exists():
        return False

    # Check cache age
    cache_age = time.time() - cache_path.stat().st_mtime
    return cache_age < max_age_seconds


def load_cache(cache_path: Path) -> Optional[List[Dict]]:
    """Load bookmarks from cache."""
    try:
        with open(cache_path, "r", encoding="utf-8") as f:
            data = json.load(f)
            return data.get("bookmarks", [])
    except (json.JSONDecodeError, IOError):
        return None


def save_cache(cache_path: Path, bookmarks: List[Dict]) -> None:
    """Save bookmarks to cache."""
    try:
        cache_data = {"timestamp": time.time(), "bookmarks": bookmarks}
        with open(cache_path, "w", encoding="utf-8") as f:
            json.dump(cache_data, f, ensure_ascii=False, indent=2)
    except IOError as e:
        print(f"Warning: Could not save cache: {e}", file=sys.stderr)


def main():
    # Parse command line arguments
    force_refresh = "--refresh" in sys.argv or "-r" in sys.argv

    cache_path = get_cache_path()

    # Try to use cache if valid and not forcing refresh
    if not force_refresh and is_cache_valid(cache_path):
        cached_bookmarks = load_cache(cache_path)
        if cached_bookmarks:
            for bookmark in cached_bookmarks:
                folder_display = (
                    f" [{bookmark['folder']}]" if bookmark["folder"] else ""
                )
                title_with_folder = f"{bookmark['title']}{folder_display}"

                # Use cached favicon file path
                if (
                    bookmark.get("favicon_path")
                    and Path(bookmark["favicon_path"]).exists()
                ):
                    print(
                        f"{title_with_folder}\x00icon\x1f{bookmark['favicon_path']}\x1finfo\x1f{bookmark['url']}"
                    )
                else:
                    # No icon if favicon file doesn't exist
                    print(f"{title_with_folder}\x00info\x1f{bookmark['url']}")
            return

    # Find Zen Browser profile
    profile_path = find_zen_profile()

    if not profile_path:
        print("Error: Could not find Zen Browser profile directory", file=sys.stderr)
        sys.exit(1)

    # Extract bookmarks
    bookmarks = extract_bookmarks(profile_path)

    if not bookmarks:
        print("Error: No bookmarks found", file=sys.stderr)
        sys.exit(1)

    # Prepare bookmarks with favicons for output and caching
    bookmark_data = []
    for title, url, folder_path in bookmarks:
        # Extract favicon and save to file
        favicon_path = get_favicon_file_path(profile_path, url)

        bookmark_entry = {"title": title, "url": url, "folder": folder_path}

        if favicon_path:
            bookmark_entry["favicon_path"] = favicon_path

        bookmark_data.append(bookmark_entry)

        # Display folder path next to bookmark title
        folder_display = f" [{folder_path}]" if folder_path else ""
        title_with_folder = f"{title}{folder_display}"

        # Output in rofi script mode format with favicon file path
        if favicon_path:
            print(f"{title_with_folder}\x00icon\x1f{favicon_path}\x1finfo\x1f{url}")
        else:
            # No icon if no favicon available
            print(f"{title_with_folder}\x00info\x1f{url}")

    # Save to cache
    save_cache(cache_path, bookmark_data)


if __name__ == "__main__":
    main()
