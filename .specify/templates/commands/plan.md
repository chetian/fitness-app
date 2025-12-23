# /speckit.plan

**Purpose:** Generate a detailed implementation plan from a specification.

## Usage

```bash
/speckit.plan [implementation-notes]
```

## What It Does

1. Creates `specs/NNN-feature-name/plan.md` with:
   - Technology stack
   - Architecture decisions
   - Data flow diagrams
   - Implementation steps
   - Testing strategy
   - Risk assessment
2. Generates supporting documents:
   - `research/research.md` - Technical decisions
   - `data-model.md` - Data entities
   - `contracts/api-spec.yaml` - API contracts
   - `quickstart.md` - Setup guide
3. Updates `.cursor/rules/specify-rules.mdc`

## Examples

```bash
/speckit.plan I plan to setup auth with Firebase using register buttons for google, apple, email.
```

## Output

- `specs/001-feature-name/plan.md` - Implementation plan
- `specs/001-feature-name/research/research.md` - Technical research
- `specs/001-feature-name/data-model.md` - Data models
- `specs/001-feature-name/contracts/api-spec.yaml` - API spec
- `specs/001-feature-name/quickstart.md` - Setup guide
- `.cursor/rules/specify-rules.mdc` - Updated agent context

## Next Steps

After running this command:
1. Review the plan and supporting docs
2. Run `/speckit.tasks` to break down into actionable tasks

