
target='/home/kim/.local/share/Steam/steamapps/common/Skyrim Special Edition'
# skyrim_se_var='/home/kim/.local/share/Steam/steamapps/compatdata/2266942524/pfx/drive_c/users/steamuser/Documents/My Games/Skyrim Special Edition'
# skse_loader_var='/home/kim/.local/share/Steam/steamapps/compatdata/489830/pfx/drive_c/users/steamuser/Documents/My Games/Skyrim Special Edition'

# My mods should show here.
# steamapps/compatdata/2266942524/pfx/drive_c/users/steamuser/AppData/Local/Skyrim Special Edition/Plugins.txt
# steamapps/compatdata/489830/pfx/drive_c/users/steamuser/AppData/Local/Skyrim Special Edition/Plugins.txt
# saves='$var/Saves/'

ref="$PWD/result"
cd "$(dirname "$target")" && ln -f -T "$ref" "Skyrim Special Edition"

# mkdir "$target"
# keep symlinks, but any files will take on default permissions (be writable)
# cp -r --preserve=links --no-preserve=mode ./result/* "$target"
