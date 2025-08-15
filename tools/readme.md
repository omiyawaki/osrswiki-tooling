# OSRSWiki Asset Generation Tools

This directory contains a set of tools used to extract and process assets required for the OSRSWiki Android application's native map feature.

## Overview

The new native map system relies on pre-processed assets generated from the OSRS game cache. This toolchain is designed to be as automated and future-proof as possible.

The core asset generation workflow is a 4-step process:
1.  **Setup/Update Game Cache**: Automatically download the latest complete game cache from a public archive.
2.  **Fetch Decryption Keys**: Automatically download the latest map decryption keys (XTEAs).
3.  **Dump Complete Map Images**: Render the full game world from the cache.
4.  **Slice Map Tiles**: Process the map images into `.mbtiles` assets for use in the app.

---

## Environment Setup

All Python scripts in this directory are designed to run within a specific `micromamba` environment to ensure all dependencies are met.

### Prerequisites

-   [Micromamba](https://mamba.readthedocs.io/en/latest/installation.html) must be installed.

### Creating the Environment

If you are setting up this project for the first time, use the `environment.yml` file to create an identical environment.

1.  Navigate to the `tools/` directory in your terminal.
2.  Create the environment from the provided file. This only needs to be done once.
    ```bash
    micromamba create --name osrs-tools --file environment.yml
    ```
3.  Activate the environment before running any scripts. You must do this every time you open a new terminal session.
    ```bash
    micromamba activate osrs-tools
    ```

### Exporting/Updating the Environment File

If you have manually installed or updated packages in your `osrs-tools` environment, you should regenerate the `environment.yml` file to reflect these changes before committing your work.

```bash
# Make sure the 'osrs-tools' environment is active
micromamba env export --from-history > environment.yml
```

---

## The Asset Generation Pipeline

Follow these steps in order to generate a complete and up-to-date set of map assets.

### Prerequisites

- The `osrs-tools` micromamba environment must be active.
- A Java Development Kit (JDK) version 11 or higher.

### Step 1: Setup or Update the Game Cache

The `setup_cache.py` script automatically finds and downloads the latest complete OSRS game cache from the OpenRS2 Archive. It is idempotent: it will only download the cache if it doesn't exist locally or if the local version is outdated.

**Run this script first to ensure you have the necessary game data.** The initial download is large and may take several minutes.

```bash
python3 setup_cache.py
```

### Step 2: Update XTEA Decryption Keys

The `update_xteas.py` script automatically fetches the latest XTEA keys that correspond to the latest cache from the OpenRS2 Archive.

**Run this script after setting up the cache to get the correct decryption keys.**

```bash
python3 update_xteas.py
```

### Step 3: Dump Complete Map Images

The `map-dumper/` directory contains a Java project that reads the game cache and renders the full game world. The `run_dumper.sh` script now automatically points to the cache downloaded by `setup_cache.py`.

**This step only needs to be re-run when there are significant changes to the game world.**

```bash
./run_dumper.sh
```
The output images (`img-0.png`, `img-1.png`, etc.) will be placed in `tools/map-dumper/output/`.

### Step 4: Slice Tiles into MBTiles

The `slice_tiles.py` script takes the high-resolution images from the `map-dumper` and processes them into the final `.mbtiles` assets used by the Android application.

```bash
python3 slice_tiles.py
```
This will create `map_floor_0.mbtiles`, `map_floor_1.mbtiles`, etc., and place them directly in the Android app's assets folder (`app/src/main/assets/`).

---

## Meta Asset Updater (Recommended)

For maximum convenience, use the unified meta wrapper that orchestrates all asset generation tools:

```bash
# Update all assets (maps, CSS, and JS discovery)
python3 asset-updater.py --all

# Update only map assets with force regeneration
python3 asset-updater.py --maps --force

# Update only CSS assets
python3 asset-updater.py --css

# Update only JS module discovery
python3 asset-updater.py --js-discovery

# Preview what would be updated (dry-run for maps)
python3 asset-updater.py --all --dry-run

# Verify all assets exist and are up to date
python3 asset-updater.py --all --verify

# Check freshness of map assets only
python3 asset-updater.py --maps --check-freshness
```

The meta updater:
- ✅ **Unified Interface**: Single command for all asset types
- ✅ **Automatic Environment**: Uses local micromamba with proper dependencies  
- ✅ **Smart Orchestration**: Coordinates map, CSS, and JS discovery tool execution
- ✅ **Pass-through Arguments**: Forwards options to underlying tools
- ✅ **Comprehensive Reporting**: Detailed progress and summary output
- ✅ **Error Handling**: Graceful failure handling with clear diagnostics

## Individual Tool Workflows

### Map Assets Only

For map-specific workflows, use the specialized map tool directly:

```bash
# Run the complete workflow automatically (only updates if needed)
python3 map/map-asset-generator.py

# Force regeneration even if assets are up to date  
python3 map/map-asset-generator.py --force

# Preview what would be done without executing
python3 map/map-asset-generator.py --dry-run

# Just verify that all assets exist
python3 map/map-asset-generator.py --verify

# Check if local assets are up to date with OpenRS2
python3 map/map-asset-generator.py --check-freshness
```

The automated tool:
- ✅ Checks OpenRS2 API for cache updates and only regenerates if needed
- ✅ Runs all 4 steps in sequence with proper error handling
- ✅ Validates dependencies (Java, Python packages, required scripts)
- ✅ Provides detailed progress reporting and colored output
- ✅ Verifies that all expected mbtiles files are created successfully

### CSS Assets Only

For CSS-specific workflows, use the CSS perfect sync tool:

```bash
# Achieve perfect CSS parity with reference
python3 css/css-perfect-sync.py
```

### JS Module Discovery Only

For JavaScript module discovery and tracking:

```bash
# Run discovery scan on sample pages
python3 js-discovery/update_discovery.py

# View current implementation status
python3 js-discovery/update_discovery.py --summary-only

# Generate comprehensive report
python3 js-discovery/generate_report.py

# Initialize masterlists from existing data (first time only)
python3 js-discovery/initialize_masterlists.py
```

The JS discovery system:
- ✅ Accumulative tracking of all discovered modules across scans
- ✅ Smart deduplication prevents data corruption
- ✅ Implementation mapping connects wiki modules to app code
- ✅ Priority scoring identifies high-impact unimplemented modules
- ✅ Overlap detection finds functional similarities between modules
- ✅ Comprehensive reporting shows implementation progress

