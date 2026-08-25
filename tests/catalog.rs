//! Integration tests for EricStack's metadata catalog and public CLI contracts.

use std::collections::BTreeSet;
use std::fs;
use std::path::{Path, PathBuf};
use std::process::Command;

fn repo_root() -> PathBuf {
    PathBuf::from(env!("CARGO_MANIFEST_DIR"))
}

/// Read the canonical skill counts from `.loopx/sync-state.json` `.totals`.
/// This file is the single source of truth; Cargo.toml metadata and docs
/// must stay aligned with it.
fn sync_state_totals(root: &Path) -> (usize, usize, usize) {
    let text = fs::read_to_string(root.join(".loopx/sync-state.json"))
        .expect("sync-state.json should be readable");
    (
        json_number_field(&text, "process_skills")
            .expect("sync-state totals.process_skills should exist") as usize,
        json_number_field(&text, "ability_skills")
            .expect("sync-state totals.ability_skills should exist") as usize,
        json_number_field(&text, "router_skills")
            .expect("sync-state totals.router_skills should exist") as usize,
    )
}

/// Minimal numeric field lookup — avoids adding a JSON dependency to a
/// placeholder crate. Handles `"field": 42` with arbitrary spacing.
fn json_number_field(text: &str, field: &str) -> Option<u64> {
    let marker = format!("\"{field}\"");
    let pos = text.find(&marker)?;
    let rest = text[pos + marker.len()..].trim_start();
    let rest = rest.strip_prefix(':')?.trim_start();
    let end = rest
        .find(|c: char| !c.is_ascii_digit())
        .unwrap_or(rest.len());
    if end == 0 {
        return None;
    }
    rest[..end].parse().ok()
}

fn collect_skill_files(dir: &Path, output: &mut Vec<PathBuf>) {
    for entry in fs::read_dir(dir).expect("skill directory should be readable") {
        let entry = entry.expect("directory entry should be readable");
        let path = entry.path();
        if path.file_name().is_some_and(|name| name == ".omc") {
            continue;
        }
        if path.is_dir() {
            collect_skill_files(&path, output);
        } else if path.file_name().is_some_and(|name| name == "SKILL.md") {
            output.push(path);
        }
    }
}

fn installed_skill_names(root: &Path) -> BTreeSet<String> {
    let mut names = BTreeSet::new();
    for kind in ["process", "ability"] {
        let category = root.join(format!(".loopx/skills/erics-{kind}"));
        for entry in fs::read_dir(category).expect("skill category should be readable") {
            let path = entry.expect("skill entry should be readable").path();
            if !path.join("SKILL.md").is_file() {
                continue;
            }
            let source_name = path
                .file_name()
                .expect("skill should have a directory name")
                .to_string_lossy();
            let prefix = format!("erics-{kind}-");
            let installed = if source_name.starts_with(&prefix) {
                source_name.into_owned()
            } else {
                format!("{prefix}{source_name}")
            };
            names.insert(installed);
        }
    }
    names
}

fn referenced_skill_names(text: &str) -> BTreeSet<String> {
    let mut names = BTreeSet::new();
    for prefix in ["erics-process-", "erics-ability-"] {
        let mut remainder = text;
        while let Some(offset) = remainder.find(prefix) {
            let candidate = &remainder[offset..];
            let length = candidate
                .bytes()
                .take_while(|byte| {
                    byte.is_ascii_lowercase() || byte.is_ascii_digit() || *byte == b'-'
                })
                .count();
            if length > prefix.len() {
                names.insert(candidate[..length].to_owned());
            }
            remainder = &candidate[length..];
        }
    }
    names
}

#[test]
fn catalog_has_expected_shape_and_frontmatter() {
    let root = repo_root();
    let skills_root = root.join(".loopx/skills");
    let mut files = Vec::new();
    collect_skill_files(&skills_root, &mut files);

    let (expected_process, expected_ability, expected_router) = sync_state_totals(&root);
    assert_eq!(
        files.len(),
        expected_process + expected_ability + expected_router,
        "catalog size ({}) must match .loopx/sync-state.json .totals",
        files.len()
    );
    assert_eq!(
        files
            .iter()
            .filter(|path| path.starts_with(skills_root.join("erics-process")))
            .count(),
        expected_process,
        "process skill count must match sync-state totals"
    );
    assert_eq!(
        files
            .iter()
            .filter(|path| path.starts_with(skills_root.join("erics-ability")))
            .count(),
        expected_ability,
        "ability skill count must match sync-state totals"
    );
    assert_eq!(
        expected_router, 1,
        "exactly one router skill expected per sync-state totals"
    );
    assert!(skills_root.join("erics-loop-router/SKILL.md").is_file());

    for file in files {
        let text = fs::read_to_string(&file).expect("SKILL.md should be UTF-8");
        let directory_name = file
            .parent()
            .and_then(Path::file_name)
            .expect("skill should have a parent directory")
            .to_string_lossy();
        assert!(
            text.starts_with("---\n"),
            "{} lacks frontmatter",
            file.display()
        );
        assert!(
            text.contains(&format!("\nname: {directory_name}\n")),
            "{} name must match its directory",
            file.display()
        );
        assert!(
            text.contains("\ndescription: Use when"),
            "{} lacks a routing description",
            file.display()
        );
        assert!(
            text.contains("\ntriggers:\n"),
            "{} lacks triggers",
            file.display()
        );
        assert!(text.contains("\n# "), "{} lacks an H1", file.display());
    }
}

#[test]
fn router_only_references_installable_skills() {
    let root = repo_root();
    let router = fs::read_to_string(root.join(".loopx/skills/erics-loop-router/SKILL.md"))
        .expect("router should be readable");
    let installed = installed_skill_names(&root);
    let referenced = referenced_skill_names(&router);
    let missing: Vec<_> = referenced.difference(&installed).cloned().collect();

    assert!(!referenced.is_empty(), "router should reference skills");
    assert!(
        missing.is_empty(),
        "router references missing skills: {missing:?}"
    );
}

#[test]
fn public_clis_have_help_and_reject_unknown_arguments() {
    let root = repo_root();
    let shell_scripts = [
        "check-readme-bilingual.sh",
        "check-skill-counts.sh",
        "check-wikilinks.sh",
        "install-acceptance-pipeline.sh",
        "install-ericsstack.sh",
        "lint-skills.sh",
        "sync-skills.sh",
        "uninstall-ericsstack.sh",
    ];

    for script in shell_scripts {
        let path = format!(".loopx/bin/{script}");
        let help = Command::new("bash")
            .args([&path, "--help"])
            .current_dir(&root)
            .output()
            .expect("bash CLI help should run");
        assert!(help.status.success(), "{script} --help failed");
        assert!(!help.stdout.is_empty(), "{script} --help was empty");

        let invalid = Command::new("bash")
            .args([&path, "--definitely-invalid"])
            .current_dir(&root)
            .output()
            .expect("bash CLI invalid-argument check should run");
        assert!(
            !invalid.status.success(),
            "{script} accepted an unknown argument"
        );
    }

    for python_script in [
        ".loopx/bin/regenerate-wiki-index.py",
        ".loopx/bin/check-markdown-links.py",
    ] {
        let help = Command::new("python3")
            .args([python_script, "--help"])
            .current_dir(&root)
            .output()
            .expect("Python CLI help should run");
        assert!(help.status.success(), "{python_script} --help failed");
        assert!(!help.stdout.is_empty(), "{python_script} --help was empty");

        let invalid = Command::new("python3")
            .args([python_script, "--definitely-invalid"])
            .current_dir(&root)
            .output()
            .expect("Python CLI invalid-argument check should run");
        assert!(
            !invalid.status.success(),
            "{python_script} accepted an unknown argument"
        );
    }
}
