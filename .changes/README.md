# Change entries

This folder holds the unreleased changes for the next release. Each file describes one change: how big a version bump it warrants and what to say about it in the changelog. At release time [Changewrite](https://github.com/flipbook-labs/changewrite) combines every entry here into `CHANGELOG.md`, bumps the version, and deletes the entries it consumed.

## Adding an entry

Create a Luau file in this folder that returns the entry's fields. The filename only exists to make entries easy to browse, so name it after the change, such as `fix-find-timeout.luau`:

```luau
return {
	bump = "minor",
	category = "Features",
	kind = "queries",
	summary = "Add `getByRole` queries that match Instances by their class.",
}
```

- **`bump`** (required): how much to move the version, `"major"`, `"minor"`, or `"patch"`.
- **`category`** (required): the heading this entry appears under in the changelog, one of `Features`, `Changes`, `Fixes`, `Dependencies`, or `Internal`. The changelog lists the headings in that order, as set by `categories` in [`changewrite.luau`](../changewrite.luau). Dependencies and Internal start collapsed in GitHub release notes.
- **`kind`** (required): the part of the library the change landed in, shown as a chip beside the entry. Pick one of the `kind` keys in [`changewrite.luau`](../changewrite.luau): `queries`, `render`, `events`, `async`, `docs`, `build`, `tooling`, `packages`, `ci`, `release`, or `contributing`. A refactor takes the kind of whatever it touches.
- **`summary`** (required): the changelog line, one short sentence of at most 140 characters, written for someone reading the changelog without the pull request.
- **`highlight`** (optional): a short title for a change worth a headline. The entry's summary and body appear under Highlights at the top of the release notes.
- **`body`** (optional): more detail in Markdown, shown collapsed under the summary.

`changewrite check` fails on any other Markdown file in this folder. `changewrite check --fix` converts Markdown entries to Luau.

An optional `release.md` in this folder opens the next release's notes with a one- or two-sentence summary of what it brings. Changewrite consumes it with the entries.

After changing the kinds in `changewrite.luau`, run `changewrite generate` and commit the chip images it writes to `assets/`.

## How the version is chosen

The next version is the largest bump across all pending entries: a single `major` entry makes the release a major, otherwise a single `minor` makes it a minor, otherwise it's a `patch`.

## Notes

- `README.md` (this file) and the `assets/` folder are ignored, so they're safe to keep here.
- Entries are deleted once they're released. They live in this folder only while unreleased.
- Run `changewrite check` to validate every pending entry.
