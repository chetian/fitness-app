# Specify Command

Help manage feature specifications using the SpecKit system.

## Usage

```
/specify <subcommand> [args]
```

## Subcommands

### `/specify new <feature-name>`
Create a new feature specification in the specs directory with all required files.

### `/specify status`
Show status of all features and their implementation progress.

### `/specify check <feature-id>`
Validate a feature specification for completeness and constitutional compliance.

### `/specify tasks <feature-id>`
Display or update task breakdown for a feature.

### `/specify implement <feature-id> <task-id>`
Begin guided implementation of a specific task.

## Examples

```
/specify new user-notifications
/specify status
/specify check 001
/specify tasks 001
/specify implement 001 T036
```

## System

This command works with the specs/ directory structure:
- specs/XXX-feature-name/
  - spec.md (requirements)
  - plan.md (implementation plan)
  - tasks.md (task breakdown)
  - quickstart.md (setup guide)
  - data-model.md (data structures)
  - contracts/ (API specs)
  - checklists/ (requirement checklists)
  - research/ (research notes)



