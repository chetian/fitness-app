# /speckit.tasks

**Purpose:** Break down an implementation plan into actionable tasks.

## Usage

```bash
/speckit.tasks [optional-context]
```

## What It Does

1. Creates `specs/NNN-feature-name/tasks.md` with:
   - Organized task list by user stories
   - Task IDs (e.g., US1.T1)
   - Parallelization markers (⚡)
   - Story labels (US1, US2, etc.)
   - File paths for each task
   - Dependencies
   - MVP scope indicators
2. Follows strict format:
   ```
   - [ ] **[US1.T1]** ⚡ Task description (US1)
     - Files: `path/to/file.swift`
   ```

## Examples

```bash
/speckit.tasks break this down into tasks

/speckit.tasks Focus on MVP features first
```

## Output

- `specs/001-feature-name/tasks.md` - Complete task breakdown

## Task Format

Each task includes:
- **Checkbox** for tracking completion
- **ID** (e.g., US1.T1) for reference
- **⚡ Symbol** if parallelizable
- **Description** of what to do
- **Story label** (US1, US2, etc.)
- **File paths** affected
- **Dependencies** if any

## Next Steps

After running this command:
1. Review the task list
2. Start implementing tasks
3. Check off tasks as you complete them

