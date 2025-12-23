# /speckit.specify

**Purpose:** Create a comprehensive feature specification from natural language.

## Usage

```bash
/speckit.specify [feature-description]
```

## What It Does

1. Creates a new feature directory: `specs/NNN-feature-name/`
2. Generates `spec.md` with:
   - Functional requirements
   - Success criteria
   - User scenarios
   - Technical design
   - Constitutional compliance
3. Creates a requirements checklist
4. Validates the spec against quality standards

## Examples

```bash
/speckit.specify We are building a modern AI-driven fitness iOS app with authentication, onboarding, and dashboard.
```

## Output

- `specs/001-feature-name/spec.md` - Complete specification
- `specs/001-feature-name/checklists/requirements.md` - Validation checklist

## Next Steps

After running this command:
1. Review and refine the spec
2. Run `/speckit.plan` to create an implementation plan


