# Milestone Drafts

This directory is the working planning surface for `shell-config` milestones.

Use these files as:

- the in-repo source of truth for the active milestone draft
- a checkbox-driven execution list during implementation
- a copy/paste source when opening GitHub milestones and issues later

Recommended workflow:

1. Keep strategy and milestone ordering in [`docs/ROADMAP.md`](/home/timl/projects/tboss/shell-config/docs/ROADMAP.md).
2. Keep one markdown file here for each milestone.
3. Use markdown checkboxes in the milestone file while work is in flight.
4. Work on a milestone branch such as `feat/m0005-interactive-operator-workflows`.
5. Commit freely at verified checkpoints.
6. When the milestone is stable, open the matching GitHub milestone and issues from the markdown draft.
7. Squash-merge the milestone branch once exit criteria are met.

Branch naming convention:

- milestone implementation branch: `feat/<sortable-milestone-id>-<short-name>`
- doc-focused milestone branch: `docs/<sortable-milestone-id>-<short-name>`
- temp reframe branch: `<final-branch>--wip-YYYYMMDD-HHMM`

Examples:

- `feat/m0004-documentation-and-planning-normalization`
- `feat/m0005-interactive-operator-workflows`
- `docs/m0004-documentation-and-planning-normalization`

Sortable milestone ID mapping:

- `M4` -> `m0004`
- `M5` -> `m0005`
- `M6` -> `m0006`

Each milestone file should contain:

- objective
- exit criteria
- non-goals
- issue drafts
- verification notes
- branch and merge guidance
