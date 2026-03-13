// Prevents additional console window on Windows in release
#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

use serde::{Deserialize, Serialize};
use similar::{ChangeTag, TextDiff};
use std::fs;
use tauri::Manager;

#[derive(Debug, Serialize, Deserialize)]
struct PlanData {
    id: String,
    original: String,
    edited: Option<String>,
}

#[derive(Debug, Serialize, Deserialize)]
struct DiffLine {
    line_type: String, // "add", "remove", "context"
    content: String,
    line_num_old: Option<usize>,
    line_num_new: Option<usize>,
}

#[derive(Debug, Serialize, Deserialize)]
struct DiffResult {
    lines: Vec<DiffLine>,
    has_changes: bool,
}

#[derive(Debug, Serialize, Deserialize)]
struct Comment {
    line: usize,
    text: String,
}

#[derive(Debug, Serialize, Deserialize)]
struct PlanFeedback {
    comments: Vec<Comment>,
    edited_plan: String,
    diff: DiffResult,
}

#[tauri::command]
fn load_plan(plan_path: String) -> Result<PlanData, String> {
    let content = fs::read_to_string(&plan_path)
        .map_err(|e| format!("Failed to read plan: {}", e))?;
    
    // Extract plan ID from filename
    let id = std::path::Path::new(&plan_path)
        .file_stem()
        .and_then(|s| s.to_str())
        .unwrap_or("unknown")
        .to_string();
    
    Ok(PlanData {
        id,
        original: content,
        edited: None,
    })
}

#[tauri::command]
fn compute_diff(original: String, edited: String) -> Result<DiffResult, String> {
    let diff = TextDiff::from_lines(&original, &edited);
    let mut lines = Vec::new();
    let mut old_line = 1;
    let mut new_line = 1;
    
    for change in diff.iter_all_changes() {
        let (line_type, line_num_old, line_num_new) = match change.tag() {
            ChangeTag::Delete => {
                let result = ("remove", Some(old_line), None);
                old_line += 1;
                result
            }
            ChangeTag::Insert => {
                let result = ("add", None, Some(new_line));
                new_line += 1;
                result
            }
            ChangeTag::Equal => {
                let result = ("context", Some(old_line), Some(new_line));
                old_line += 1;
                new_line += 1;
                result
            }
        };
        
        lines.push(DiffLine {
            line_type: line_type.to_string(),
            content: change.to_string(),
            line_num_old,
            line_num_new,
        });
    }
    
    Ok(DiffResult {
        lines,
        has_changes: diff.ratio() < 1.0,
    })
}

#[tauri::command]
fn save_feedback(
    plan_path: String,
    comments: Vec<Comment>,
    edited_plan: String,
) -> Result<(), String> {
    let original = fs::read_to_string(&plan_path)
        .map_err(|e| format!("Failed to read original: {}", e))?;
    
    let diff = compute_diff(original, edited_plan.clone())?;
    
    let feedback = PlanFeedback {
        comments,
        edited_plan,
        diff,
    };
    
    // Save feedback as JSON next to the plan file
    let feedback_path = format!("{}.feedback.json", plan_path);
    let json = serde_json::to_string_pretty(&feedback)
        .map_err(|e| format!("Failed to serialize: {}", e))?;
    
    fs::write(&feedback_path, json)
        .map_err(|e| format!("Failed to write feedback: {}", e))?;
    
    Ok(())
}

fn main() {
    tauri::Builder::default()
        .plugin(tauri_plugin_shell::init())
        .setup(|app| {
            // Get plan path from CLI args
            let args: Vec<String> = std::env::args().collect();
            if args.len() > 1 {
                let plan_path = &args[1];
                app.manage(plan_path.clone());
            }
            Ok(())
        })
        .invoke_handler(tauri::generate_handler![
            load_plan,
            compute_diff,
            save_feedback
        ])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_compute_diff_no_changes() {
        let original = "Step 1\nStep 2\nStep 3".to_string();
        let edited = "Step 1\nStep 2\nStep 3".to_string();
        
        let result = compute_diff(original, edited).unwrap();
        
        assert!(!result.has_changes);
    }

    #[test]
    fn test_compute_diff_with_changes() {
        let original = "Step 1\nStep 2".to_string();
        let edited = "Step 1\nStep 1.5\nStep 2".to_string();
        
        let result = compute_diff(original, edited).unwrap();
        
        assert!(result.has_changes);
        assert!(result.lines.len() > 0);
    }

    #[test]
    fn test_compute_diff_removal() {
        let original = "Step 1\nStep 2\nStep 3".to_string();
        let edited = "Step 1\nStep 3".to_string();
        
        let result = compute_diff(original, edited).unwrap();
        
        assert!(result.has_changes);
        // Should have at least one "remove" type line
        let has_removal = result.lines.iter().any(|l| l.line_type == "remove");
        assert!(has_removal);
    }

    #[test]
    fn test_load_plan_nonexistent_file() {
        let result = load_plan("/nonexistent/path/plan.md".to_string());
        assert!(result.is_err());
    }
}
