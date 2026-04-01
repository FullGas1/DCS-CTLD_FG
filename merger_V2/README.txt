How to run the merge (PowerShell)
----------------------------------
1> Shift+click the folder containing merger.cmd and select "Open PowerShell window here"
2> In PowerShell, enter: ./merger.cmd
   Confirm execution if prompted.

The merger reads listToMerge.txt, merges all source files from ../src/
and generates CTLD_futur.lua in the parent (repo root) folder.

Notes:
- Lines starting with "--" in listToMerge.txt are comments and are skipped.
- Subdirectory paths (e.g. scenes/CTLD_fobSceneDatas.lua) are resolved
  relative to ../src/.
- CTLD_futur.lua is the development output. At final release it replaces CTLD.lua.
