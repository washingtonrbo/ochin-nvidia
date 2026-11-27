# ochin-nvidia optimized launcher preset for 16GB RAM + 6GB VRAM GPUs (e.g. RTX 3050 6GB Laptop)
# Incorporates full community breakthrough architecture:
# - VICTORY_WINDOWS_BAR_MB=3072 (CPU-mapped VRAM via ReBAR, keeps shared system RAM <= 4.4GB instead of 7.5GB)
# - VICTORY_CARD_STEPS=2 (Executes memory buffer steps directly on GPU, saving 25-30ms CPU stall)
# - VICTORY_RELAY=2 (Asynchronous GPU landing, eliminating CPU wait-for-card stalls)
# - VICTORY_CARD_ROOM_FOR_BUFFERS=1 & MIN_KB=64 (All title buffers in VRAM, eliminating 30ms CPU compare)
# - VICTORY_SKIP_PIPELINES (Skips 1,000 ray-tracing resolve passes via HashSet)
# - Anti-black texture controls (VICTORY_KEEP_SHOWN=1 + VICTORY_AMBIENT=0.85)
# - Native mouse camera look (PR #9)
param(
    [Parameter(Mandatory = $true)][string]$Game,
    [string]$Cache = "$env:LOCALAPPDATA\ochin-nvidia\cache-opt",
    [string]$Data = "$env:LOCALAPPDATA\ochin-nvidia\data",
    [string]$Exe = "$PSScriptRoot\..\target\release\victory.exe",
    [ValidateSet("series-s", "series-x")][string]$Console = "series-s",
    [string]$Resolution = "540",
    [string]$DisplayMode = "960x540",
    [int]$WindowsBarMB = 3072,
    [int]$CardBuffersMb = 1024,
    [string]$Log = "$env:TEMP\ochin-nvidia-6gb.log"
)

foreach ($v in "VICTORY_CAPTURE", "VICTORY_CAPTURE_FRAMES", "VICTORY_DUMP_TARGETS", "VICTORY_LEVELS_ON_DEMAND") {
    Remove-Item "Env:$v" -ErrorAction SilentlyContinue
}

New-Item -ItemType Directory -Force $Cache, $Data | Out-Null

$env:VICTORY_CACHE_DIR = $Cache
$env:VICTORY_DATA_DIR = $Data
$env:VICTORY_DISPLAY_MODE = "$DisplayMode"
$env:VICTORY_RESOLUTION = "$DisplayMode"
$env:VICTORY_WINDOW_MAX = "$DisplayMode"
$env:VICTORY_GAMEPAD_MOUSE = "1"
if (-not $env:VICTORY_KEYS) {
    $env:VICTORY_KEYS = "25:Enter,30:Enter,35:Enter,40:Enter,45:Enter,50:Enter,55:Enter"
}

# 16 GB PC RAM optimization (keeps system RAM flat at ~4.4 GB via Resizable BAR)
$env:VICTORY_WINDOWS_BAR_MB = "$WindowsBarMB"
$env:VICTORY_SCRATCH_BAR = "1"

# GPU-side steps and asynchronous landing (eliminates 25-30ms submitting thread stalls)
$env:VICTORY_CARD_STEPS = "2"
$env:VICTORY_RELAY = "2"
$env:VICTORY_RELAY_COPY = "1"
$env:VICTORY_WIDE_BACK = "1"
$env:VICTORY_CARD_REHASH_RUNS = "1"
$env:VICTORY_JOIN_COPIES = "1"
$env:VICTORY_LAND = "1"
$env:VICTORY_LAND_THREADS = "8"
$env:VICTORY_LAND_SKIP = "1"
$env:VICTORY_LAND_BESIDE = "1"
$env:VICTORY_LAND_TAKEN = "1"
$env:VICTORY_INDIRECT_WINDOW = "1"
$env:VICTORY_INDIRECT_BATCH = "2"
$env:VICTORY_MAP_THREADS = "auto"
$env:VICTORY_TITLE_PRIORITIES = "0"
$env:VICTORY_HELPER_PRIORITY = "1"
$env:VICTORY_THREAD_TICKET = "1"
$env:VICTORY_RAW_VIEW_CLAMP = "1"
$env:VICTORY_CARD_AWAKE = "1"
$env:VICTORY_SHOW_AFTER = "1"
$env:VICTORY_THIN = "1"
$env:VICTORY_THIN_THREADS = "8"
$env:VICTORY_JOIN_PARTS = "8"
$env:VICTORY_REFRESH_FRONT = "1"
$env:VICTORY_UPLOAD_AHEAD = "1"
$env:VICTORY_TEXTURE_NO_WAIT = "1"
$env:VICTORY_WAIT_RESIDENT = "0"
$env:VICTORY_PRELUDE_POOL = "1"

# Card buffers in VRAM (forces all buffers into card memory for hardware compare)
$env:VICTORY_CARD_ROOM_FOR_BUFFERS = "1"
$env:VICTORY_CARD_BUFFERS_MIN_KB = "64"
$env:VICTORY_CARD_BUFFERS_MIN_MB = "1"
$env:VICTORY_CARD_BUFFERS_MB = "$CardBuffersMb"
$env:VICTORY_INDIRECT_REST = "0"
$env:VICTORY_HEAP_BUFFER_INTERVAL = "2"

# VRAM headroom management and high-throughput streaming for 6GB GPUs
$env:VICTORY_TEXTURE_BUDGET_MB = "2500"
$env:VICTORY_TEXTURE_ROOM_PERCENT = "90"
$env:VICTORY_CARD_ROOM_FOR_TARGETS_MB = "450"
$env:VICTORY_BAKE_ROOM_PERCENT = "80"
$env:VICTORY_BAKE_SOURCES = "1"
$env:VICTORY_BAKE_EXACT = "1"
$env:VICTORY_EVICT_COLD = "1"
$env:VICTORY_EVICT_SPAN_MS = "1000"
$env:VICTORY_EVICT_BYTES_MB = "128"

# Texture streaming throughput and quick recovery (eliminates wax doll / delayed skin textures)
$env:VICTORY_TEXTURE_STAGE_MB = "256"
$env:VICTORY_TEXTURE_STAGE_MS = "400"
$env:VICTORY_EARLY_TEXTURES_MS = "32"
$env:VICTORY_RELOOK_MS = "2000"

# Picture fixes, lighting and anti-black-texture controls
$env:VICTORY_KEEP_SHOWN = "1"
$env:VICTORY_AMBIENT = "0.85"
$env:VICTORY_AMBIENT_SPECULAR = "0.75,0.0"
$env:VICTORY_AMBIENT_AIR = "1.5"
$env:VICTORY_AMBIENT_MOST = "2"
$env:VICTORY_NAN_SCRUB = "1"
$env:VICTORY_PIPELINE_WAIT_MS = "24"
$env:VICTORY_DYNAMIC_SLOTS = "524288"

# Ray tracing completely disabled (BVH builder off, BVH ray walks abort at root, resolve passes dropped)
$env:VICTORY_BVH_BUILDER = "0"
$env:VICTORY_BVH_MISS = "1"

# Upscaler and console preset
# Use title's own temporal upscaler (OWN_UPSCALER=1) to eliminate FSR's 200ms compute pass overhead on RTX 3050
$env:VICTORY_RENDER_SCALE = "0.5"
$env:VICTORY_OWN_UPSCALER = "1"
$env:VICTORY_SUBMIT_FRAMES = "2"
$env:VICTORY_COMPOSE = "1"
$env:VICTORY_NO_WATCHDOG = "1"

# Skip ray-tracing resolve shaders
$rtList = Join-Path $PSScriptRoot "rt_off_hashes.txt"
if (Test-Path $rtList) {
    $env:VICTORY_SKIP_PIPELINES_FILE = $rtList
    $env:VICTORY_SKIP_PIPELINES = (Get-Content $rtList -Raw).Trim()
}

$Exe = (Resolve-Path $Exe).Path
$Game = (Resolve-Path $Game).Path

Write-Host "Iniciando ochin-nvidia (Series S preset, ReBAR Windows: ${WindowsBarMB}MB, Card Steps: 2, Relay: 2)..."
cmd.exe /c "`"$Exe`" run `"$Game`" --console $Console --execute > `"$Log`" 2>&1"
Write-Host "Finalizado com código $LASTEXITCODE; log: $Log"
