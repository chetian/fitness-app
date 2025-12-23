# .specify Directory

This directory contains the governance framework and templates for FitnessApp development.

## Structure

```
.specify/
├── memory/
│   └── constitution.md          # Project constitution and core principles
└── templates/
    ├── plan-template.md         # Template for implementation plans
    ├── spec-template.md         # Template for feature specifications
    ├── tasks-template.md        # Template for task breakdowns
    └── commands/                # Command definitions (reserved for future use)
```

## Constitution

The **constitution** (`memory/constitution.md`) defines the bare minimum non-negotiable requirements for iOS app development:

1. **Platform Compliance** - iOS HIG and App Store guidelines
2. **Memory and Performance** - Efficient resource usage and responsiveness
3. **Data Persistence and Privacy** - Safe data handling and privacy compliance
4. **Error Handling and Stability** - Graceful error handling without crashes
5. **Build and Deployment Readiness** - Maintainable releasable state

Current version: **1.0.0** (Ratified: 2025-12-21)

## Templates

Templates ensure consistency and constitutional compliance across all development artifacts:

- **plan-template.md** - For implementation plans with constitution checkpoints
- **spec-template.md** - For feature specifications aligned with principles
- **tasks-template.md** - For task breakdowns organized by constitutional categories

## Usage

1. Always reference the constitution when creating specifications or plans
2. Use templates as starting points for new documents
3. Validate all work against constitutional principles
4. Update constitution version when principles change

## Governance

The constitution follows semantic versioning:
- **MAJOR:** Backward-incompatible changes to principles
- **MINOR:** New principles or material expansions
- **PATCH:** Clarifications and non-semantic improvements

See `memory/constitution.md` for full governance procedures.

