#![cfg(windows)]

use std::fs;
use std::process::Command;

#[test]
fn warm_used_with_only_a_shader_cache_reports_no_recorded_pipelines() {
    let cache = tempfile::tempdir().unwrap();
    fs::create_dir(cache.path().join("shaders")).unwrap();

    let output = Command::new(env!("CARGO_BIN_EXE_victory"))
        .args(["warm", "--used"])
        .current_dir(cache.path())
        .env_remove("VICTORY_CONFIG")
        .env("VICTORY_CACHE_DIR", cache.path())
        .env("VICTORY_DATA_DIR", cache.path().join("data"))
        .output()
        .unwrap();
    assert!(output.status.success(), "{output:?}");
    let stdout = String::from_utf8_lossy(&output.stdout);
    assert!(stdout.contains("0 pipelines known"), "{stdout}");
    assert!(stdout.contains("VICTORY_PIPELINE_BOOK=1"), "{stdout}");
    assert!(!cache.path().join("pipelines").try_exists().unwrap());
}
