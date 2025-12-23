# /speckit.constitution

**Purpose:** Initialize or update the project constitution with core principles.

## Usage

```bash
/speckit.constitution [optional-description]
```

## What It Does

1. Creates or updates `.specify/memory/constitution.md`
2. Establishes 5 core principles for the project
3. Sets versioning (semantic: MAJOR.MINOR.PATCH)
4. Defines acceptance criteria for each principle

## Examples

```bash
# Initialize with defaults
/speckit.constitution

# Initialize with context
/speckit.constitution Fill the constitution with the bare minimum requirements for an iOS app.
```

## Output

- `.specify/memory/constitution.md` - The project constitution
- Updates all templates to reference the constitution

## Next Steps

After running this command:
1. Review the constitution
2. Run `/speckit.specify` to create your first feature spec


