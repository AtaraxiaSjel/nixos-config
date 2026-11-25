#!/usr/bin/env python3
import os
import re
import struct
import shutil
import sys
import json
import time
import urllib.request
import urllib.error
from datetime import datetime
from pathlib import Path

def get_steam_dir():
    paths = [
        Path.home() / ".local/share/Steam",
        Path.home() / ".steam/steam",
        Path.home() / ".steam/root",
    ]
    for p in paths:
        if p.exists():
            return p
    return None

def find_libraries(steam_dir):
    libraries = [steam_dir]
    lib_vdf = steam_dir / "steamapps" / "libraryfolders.vdf"
    if lib_vdf.exists():
        try:
            with open(lib_vdf, "r", encoding="utf-8", errors="ignore") as f:
                content = f.read()
            matches = re.findall(r'"path"\s+"([^"]+)"', content)
            for m in matches:
                p = Path(m)
                if p.exists() and p not in libraries:
                    libraries.append(p)
        except Exception:
            pass
    return libraries

def get_installed_steam_games(libraries):
    installed = {}
    for lib in libraries:
        steamapps = lib / "steamapps" if (lib / "steamapps").exists() else lib
        for acf in steamapps.glob("appmanifest_*.acf"):
            try:
                appid_match = re.search(r'appmanifest_(\d+)\.acf', acf.name)
                if appid_match:
                    appid = appid_match.group(1)
                    name = "Unknown Steam Game"
                    with open(acf, "r", encoding="utf-8", errors="ignore") as f:
                        for line in f:
                            m = re.search(r'"name"\s+"([^"]+)"', line, re.IGNORECASE)
                            if m:
                                name = m.group(1)
                                break
                    installed[appid] = {
                        "name": name,
                        "type": "Steam Game"
                    }
            except Exception:
                pass
    return installed

def get_non_steam_shortcuts(steam_dir):
    shortcuts = {}
    userdata_dir = steam_dir / "userdata"
    if not userdata_dir.exists():
        return shortcuts
    
    for shortcuts_vdf in userdata_dir.glob("*/config/shortcuts.vdf"):
        try:
            with open(shortcuts_vdf, "rb") as f:
                data = f.read()
            
            idx = 0
            while True:
                idx = data.find(b"appid\x00", idx)
                if idx == -1:
                    break
                if idx > 0 and data[idx-1] == 2:
                    val_start = idx + 6
                    if val_start + 4 <= len(data):
                        val_bytes = data[val_start:val_start+4]
                        short_id = struct.unpack('<I', val_bytes)[0]
                        unsigned_id = str(short_id & 0xffffffff)
                        
                        block_start = max(0, idx - 300)
                        block_end = min(len(data), idx + 300)
                        block = data[block_start:block_end]
                        
                        name = "Unknown Non-Steam Game"
                        name_match = re.search(b"\\x01[Aa]pp[Nn]ame\\x00([^\\x00]+)\\x00", block)
                        if name_match:
                            name = name_match.group(1).decode('utf-8', errors='ignore')
                        
                        shortcuts[unsigned_id] = {
                            "name": name,
                            "type": "Non-Steam Game"
                        }
                idx += 6
        except Exception:
            pass
    return shortcuts

def fetch_single_steam_app_name(appid):
    """Fetches details for a single AppID from the public Store API."""
    url = f"https://store.steampowered.com/api/appdetails?appids={appid}&filters=basic"
    try:
        req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
        with urllib.request.urlopen(req, timeout=3.0) as response:
            data = json.loads(response.read().decode('utf-8'))
            if str(appid) in data and data[str(appid)].get("success"):
                return data[str(appid)]["data"].get("name")
    except urllib.error.HTTPError as e:
        if e.code == 429:
            return "RATE_LIMIT"
    except Exception:
        pass
    return None

def guess_name_from_reg(prefix_path):
    """Scans local Wine registry files to guess the name of deleted Non-Steam games."""
    # 1. Try to find the Executable name in user.reg
    user_reg = prefix_path / "pfx" / "user.reg"
    if user_reg.exists():
        try:
            with open(user_reg, "r", encoding="utf-8", errors="ignore") as f:
                for line in f:
                    m = re.search(r'\[Software\\Wine\\AppDefaults\\([^\]\\]+)', line, re.IGNORECASE)
                    if m:
                        exe = m.group(1)
                        if not any(x in exe.lower() for x in ["explorer", "wine", "steam", "rundll32"]):
                            return f"Non-Steam (Exe: {exe})"
        except Exception:
            pass

    # 2. Try to find an installed software name in system.reg
    system_reg = prefix_path / "pfx" / "system.reg"
    if system_reg.exists():
        try:
            with open(system_reg, "r", encoding="utf-8", errors="ignore") as f:
                for line in f:
                    m = re.search(r'^"DisplayName"\s*=\s*"([^"]+)"', line)
                    if m:
                        dn = m.group(1)
                        if not any(x in dn.lower() for x in ["mono", "gecko", "steam", "wine", "microsoft"]):
                            return f"Non-Steam ({dn})"
        except Exception:
            pass
            
    return "Unknown Game/Prefix"

def get_prefix_stats(path):
    """Recursively calculates both total prefix size and latest file modification time."""
    total_size = 0
    latest_mtime = 0
    
    # Use the root directory modified time as an initial baseline fallback
    try:
        latest_mtime = os.lstat(path).st_mtime
    except Exception:
        pass

    try:
        for root, dirs, files in os.walk(path, followlinks=False):
            for f in files:
                fp = os.path.join(root, f)
                try:
                    stat = os.lstat(fp)
                    total_size += stat.st_size
                    if stat.st_mtime > latest_mtime:
                        latest_mtime = stat.st_mtime
                except Exception:
                    pass
    except Exception:
        pass
    return total_size, latest_mtime

def format_size(bytes_size):
    for unit in ['B', 'KB', 'MB', 'GB', 'TB']:
        if bytes_size < 1024:
            return f"{bytes_size:.2f} {unit}"
        bytes_size /= 1024
    return f"{bytes_size:.2f} PB"

def format_date(timestamp):
    if timestamp <= 0:
        return "N/A"
    try:
        return datetime.fromtimestamp(timestamp).strftime('%Y-%m-%d')
    except Exception:
        return "N/A"

def main():
    steam_dir = get_steam_dir()
    if not steam_dir:
        print("Error: Could not locate Steam directory.")
        sys.exit(1)
        
    print(f"Steam directory found: {steam_dir}")
    libraries = find_libraries(steam_dir)
    print("Discovered Steam Libraries:")
    for lib in libraries:
        print(f" - {lib}")
        
    print("\nScanning active games...")
    steam_games = get_installed_steam_games(libraries)
    non_steam_games = get_non_steam_shortcuts(steam_dir)
    
    active_apps = {**steam_games, **non_steam_games}
    print(f"Found {len(steam_games)} active Steam games and {len(non_steam_games)} active Non-Steam shortcuts.")
    
    # Locate all compatdata folders across all libraries
    compatdata_folders = {}
    for lib in libraries:
        compat_dir = lib / "steamapps" / "compatdata"
        if not compat_dir.exists() and lib.name == "steamapps":
            compat_dir = lib / "compatdata"
            
        if compat_dir.exists():
            for d in compat_dir.iterdir():
                if d.is_dir() and d.name.isdigit():
                    compatdata_folders[d.name] = d

    # Filter out active apps from our scanning process first
    potential_orphans = [
        (appid, path) for appid, path in compatdata_folders.items() if appid not in active_apps
    ]

    if not potential_orphans:
        print("\nNo orphaned compatdata directories found across your libraries.")
        sys.exit(0)

    print(f"\nResolving names and scanning files for {len(potential_orphans)} orphaned folders...")
    orphans = []
    total_orphan_size = 0
    use_web_api = True

    for appid, path in potential_orphans:
        size_bytes, latest_mtime = get_prefix_stats(path)
        total_orphan_size += size_bytes
        
        game_name = None
        if use_web_api:
            res = fetch_single_steam_app_name(appid)
            if res == "RATE_LIMIT":
                print(" -> Steam API rate limit reached. Switching to local fallbacks.")
                use_web_api = False
            elif res:
                game_name = res
                print(f" -> Resolved {appid} via Steam: {game_name}")
                time.sleep(0.15) # Polite pause to avoid hitting rate limits
        
        if not game_name:
            game_name = guess_name_from_reg(path)
            print(f" -> Resolved {appid} locally: {game_name}")
            
        orphans.append({
            "appid": appid,
            "name": game_name,
            "path": path,
            "size_bytes": size_bytes,
            "size_str": format_size(size_bytes),
            "last_active": format_date(latest_mtime)
        })

    # Strict formatting specifiers to handle the new columns safely
    fmt = "{:<5} | {:<12} | {:<30} | {:<10} | {:<11} | {}"
    border = "-" * 130
    
    print(f"\nFound {len(orphans)} orphaned directories (Total size: {format_size(total_orphan_size)}):")
    print(border)
    print(fmt.format("Idx", "AppID", "Name/Title", "Size", "Last Active", "Path"))
    print(border)
    
    for idx, o in enumerate(orphans, 1):
        display_name = o['name']
        if len(display_name) > 30:
            display_name = display_name[:27] + "..."
            
        print(fmt.format(f"#{idx}", o['appid'], display_name, o['size_str'], o['last_active'], o['path']))
    print(border)

    print("\nOptions:")
    print("  [d] Delete all of the listed orphaned directories")
    print("  [s] Select specific numbers to delete (e.g., 1 3 5)")
    print("  [q] Quit without deleting anything (default)")
    
    choice = input("Choose an option: ").strip().lower()
    
    to_delete = []
    if choice == 'd':
        to_delete = orphans
    elif choice == 's':
        selections = input("Enter numbers separated by spaces: ").strip().split()
        for s in selections:
            if s.isdigit():
                val = int(s)
                if 1 <= val <= len(orphans):
                    to_delete.append(orphans[val - 1])
                else:
                    print(f"Skipping invalid index: {s}")
    else:
        print("Exiting. No changes were made.")
        sys.exit(0)
        
    if not to_delete:
        print("No folders selected. Exiting.")
        sys.exit(0)
        
    print(f"\nYou selected {len(to_delete)} folder(s) for deletion.")
    confirm = input("Type 'DELETE' to confirm permanent removal: ").strip()
    
    freed_bytes = 0
    deleted_count = 0
    
    if confirm == 'DELETE':
        for item in to_delete:
            p = item['path']
            print(f"Removing: {p} ({item['size_str']})")
            try:
                shutil.rmtree(p)
                freed_bytes += item['size_bytes']
                deleted_count += 1
            except Exception as e:
                print(f"Error removing {p}: {e}")
                
        # Final Space Report
        print("\n" + "=" * 50)
        print("                 DELETION REPORT")
        print("=" * 50)
        print(f"Successfully deleted: {deleted_count} directory(ies)")
        print(f"Total storage freed:  {format_size(freed_bytes)}")
        print("=" * 50)
    else:
        print("Confirmation failed. No folders were deleted.")

if __name__ == "__main__":
    main()
