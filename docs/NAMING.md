# Naming discipline

Every capability has one canonical slug, and that slug is spelled identically
everywhere it appears. A name must never mean two things, and two names must
never mean one thing.

For a Skill in this library, the slug propagates to:

- the directory: `skills/<slug>/`
- the frontmatter: `name: <slug>` in `SKILL.md`
- the changelog heading: `# Changelog: <slug>`
- the namespace when published: `<plugin>:<slug>`

`checks/check-naming.sh` enforces the directory-equals-frontmatter rule and runs
in CI. If you rename the directory but forget the frontmatter, the Skill keeps
triggering on its description (so nothing breaks loudly) while a teammate who
greps for the slug cannot find the folder. That is a small fork inside a single
repo, and the check exists to catch it before it spreads.

## Slug rules

- lowercase, hyphen-separated, no spaces (`audit-secrets`, not `Audit Secrets`)
- a verb-or-noun that names the job, not the implementation (`morning-brief`,
  not `run-cron-script`)
- stable: once published, a slug is a promise. Renaming is a MAJOR change with a
  deprecation note, not a quiet edit.
