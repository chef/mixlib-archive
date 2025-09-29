# AI Assistant Operational Instructions

## 1. Purpose
Definitive, enforceable instructions for AI-assisted contributors working in the `mixlib-archive` repository. Covers Jira-driven development (via atlassian-mcp-server), branching, implementation, testing, coverage enforcement, DCO compliance, PR lifecycle, labeling, CI/Expeditor interactions, protected file guardrails, and iterative prompt-based collaboration. This document MUST be followed by any autonomous or semi-autonomous AI agent operating in this repository.

---
## 2. Repository Structure (Concise Tree)
Directories only (depth ≤ 3) with inline purpose notes:

```
./                          # Root: Ruby gem source (mixlib-archive)
├─ lib/                     # Runtime library code
│  └─ mixlib/
│     └─ archive/           # Core implementation (tar + libarchive adapters, version)
├─ spec/                    # RSpec tests + fixtures
│  └─ fixtures/             # Test data (text + binary sample files)
├─ distro/                  # Windows DLL dependencies copied during development
│  └─ ruby_bin_folder/      # Bundled native libs for ffi-libarchive on Windows
├─ .expeditor/              # Expeditor automation (versioning, pipelines, release)
├─ .github/                 # GitHub meta (workflows, CODEOWNERS, issue templates)
├─ .vscode/                 # (If present) Editor settings
├─ CHANGELOG.md             # Human-readable change history (rollup managed by Expeditor)
├─ Gemfile                  # Dependencies + groups (test/dev)
├─ Rakefile                 # Tasks: spec, style, gem build
├─ VERSION                  # Current gem version (bumped by Expeditor flow)
├─ *.gemspec                # Gem specification(s) including universal mingw variant
├─ README.md                # Project overview and usage
├─ LICENSE                  # Apache 2.0 License (PROTECTED)
├─ CODE_OF_CONDUCT.md       # Points to Chef Community CoC (PROTECTED)
├─ CONTRIBUTING.md          # Contribution guidelines (delegated link)
└─ .rubocop.yml             # Style / lint config (Cookstyle/Chefstyle)
```

---
## 3. Tooling & Ecosystem
* Language: Ruby (version targets include 3.1 and 3.4 per CI matrix).
* Packaging: RubyGems (multiple gemspecs including Windows universal build).
* Test Framework: RSpec (`spec/**/*_spec.rb`).
* Style / Lint: Cookstyle (Chefstyle wrapper over RuboCop) via `rake style`.
* Coverage: Not explicitly configured (no SimpleCov). Agents MUST add SimpleCov only if explicitly requested by maintainers; otherwise treat coverage target conceptually (approximate via test breadth) and do not commit coverage tooling changes without approval.
* Build / Tasks: Rake (`rake spec`, `rake style`, default task runs both).
* Continuous Integration:
  - `.github/workflows/lint.yml`: Runs RuboCop/Cookstyle on PR + pushes to `main`.
  - `.github/workflows/unit.yml`: Windows matrix tests on PR + pushes to `master` (note: repository currently appears to use `main` branch; treat `master` trigger as legacy—do not rename workflows without instruction).
  - `.github/workflows/ci-main-pull-request-checks.yml`: Delegates to centralized Chef common GA pipeline (complexity, secret scan, SBOM, optional scans, mostly disabled build/unit in stub).
* Expeditor: Present (`.expeditor/config.yml` & pipeline scripts) managing version bumps, changelog updates, gem building, release publishing, branch deletion, and promotion pipelines.
* Protected / Non‑modifiable without explicit instruction: `LICENSE`, `CODE_OF_CONDUCT.md`, `CONTRIBUTING.md` (external pointer), `.expeditor/` automation scripts, GitHub Actions workflow definitions, `CODEOWNERS`, security scanning configuration inherited via central workflows.

---
## 4. MCP (Jira) Integration (atlassian-mcp-server)
All Jira interactions MUST use the atlassian-mcp-server MCP endpoint (not raw REST from the AI unless specifically approved). Standard invocation pattern:

1. Input: Jira ID (e.g., `ABC-123`).
2. Action: `getIssue <JIRA_ID>` via atlassian-mcp-server.
3. Parse fields: summary, description, acceptance criteria (look for headings like "Acceptance Criteria", bullet lists), story points, linked issues (blocks / relates / duplicates), labels, components.
4. Produce Structured Plan:
   - Design Overview
   - Impacted Files / New Files
   - Data / API changes (N/A typically for this gem)
   - Test Strategy (unit specs to add/update; edge cases)
   - Risk & Mitigations
   - Rollback / Reversion simplicity
5. Ask for explicit confirmation before coding.

Sample Prompt to Agent:
```
Invoke Jira fetch: getIssue ABC-123
Return structured plan with: Design, Impacted Files, Test Strategy, Edge Cases, Risks.
```

Edge Cases To Always Consider:
* Windows vs *nix path separators.
* Binary file handling / CRLF conversions.
* Large archives vs memory consumption.
* Empty directories.
* Permission preservation flags (`perms` option).

---
## 5. Workflow Overview (High-Level Canonical Flow)
1. Intake & Clarify (Jira or freeform task). Fetch Jira if ID supplied.
2. Analyze Repository (structure, existing specs, style expectations).
3. Draft Implementation Plan (no code yet). Present for confirmation.
4. Confirm Plan (user approves; may iterate).
5. Implement Incrementally (small cohesive commits including tests).
6. Run Specs & Lint (must pass locally/macOS & matrix assumptions).
7. Ensure Coverage Adequacy (heuristic ≥ 80% line coverage concept—add specs if logic branches untested).
8. Commit With DCO Sign-off.
9. Push Branch & Open PR (HTML sectioned template).
10. Apply Labels (map from Jira type + repo label set).
11. Monitor CI / Expeditor outcomes; remediate failures.
12. Summarize & Await Merge (AI never merges—human responsibility or Expeditor pipeline triggers upon merge to release branch).

Each major step ends with: (a) Step Summary, (b) Remaining Steps Checklist, (c) Prompt: `Continue to next step? (yes/no)`.

---
## 6. Detailed Step Instructions

### 6.1 Intake & Clarification
* If Jira ID provided: perform MCP fetch (Section 4). If not, request whether a Jira issue should be created before proceeding.
* Confirm scope boundaries and acceptance criteria.

### 6.2 Repository Analysis
* Confirm target Ruby versions and gemspec constraints.
* Identify relevant spec files for modification or duplication.
* Detect if new dependency needed (avoid adding unless essential).

### 6.3 Planning
Include: Design Outline, Affected Files, New Tests, Edge Cases, Risk, Rollback Simplicity (revert commit).

### 6.4 Confirmation Gate
Ask: `Proceed with implementation? (yes/no)`.

### 6.5 Branch Creation
Branch naming rules:
* If Jira: EXACT `JIRA-ID` (uppercase) (e.g., `ABC-123`).
* If no Jira: fallback slug `feature/<short-slug>`.

Commands:
```bash
git fetch origin
git checkout -b ABC-123
```

### 6.6 Implementation & Tests
* Modify minimal logic first.
* Add/update RSpec examples in closest existing spec file; if new component, create `spec/mixlib/<component>_spec.rb`.
* Validate with `bundle exec rake spec` and `bundle exec rake style`.
* Keep changes atomic—avoid mixing refactors unrelated to Jira acceptance criteria.

### 6.7 Coverage Enforcement
Because SimpleCov not configured, approximate coverage via:
* Ensure all new branches / conditionals have at least one spec assertion path.
* Report untested branches (manual reasoning) if any remain; propose additional tests and ask to proceed.
* If maintainers enable SimpleCov later, integrate actual percentage; treat 80% as minimum.

### 6.8 Commit (DCO)
Commit message format:
```
<type>(<scope>): <short imperative summary> [JIRA-ID]

<Longer body explaining rationale, risks, testing performed>

Signed-off-by: Full Name <email@example.com>
```
Refuse to create commit if sign-off missing or malformed.

### 6.9 Push & PR Creation (GitHub CLI)
```bash
git push -u origin ABC-123
gh pr create --fill --title "ABC-123: <Concise Title>" --body-file /tmp/pr_body.md
```
Then patch PR body (if needed) using `gh pr edit`.

### 6.10 PR Description Template (HTML)
If repo lacks template (current state):
```html
<h2>Summary</h2>
<p>...</p>
<h2>Jira</h2>
<p><a href="https://your-jira/browse/ABC-123">ABC-123</a></p>
<h2>Changes</h2>
<ul>
  <li>Code modifications...</li>
</ul>
<h2>Tests & Coverage</h2>
<p>Added/Updated specs; estimated coverage ≥ 80% for new logic.</p>
<h2>Risk & Mitigations</h2>
<p>Identify potential breakages + fallback.</p>
<h2>DCO</h2>
<p>All commits Signed-off-by.</p>
```

### 6.11 Labeling
Apply labels from mapping (Section 10). Use `gh pr edit --add-label "label"` per label.

### 6.12 CI Monitoring
* Observe GitHub Actions results: lint, unit, central CI stub.
* If failure: retrieve logs, adjust code/tests, recommit (DCO!).
* Re-run workflows: Use GH UI “Re-run all jobs” or amend commit.

### 6.13 Finalization
* Present summary: file count changes, spec additions, risk statement.
* Ask for approval to proceed to next user task or close loop.

---
## 7. Branching & PR Standards
* Branch Naming: `JIRA-ID` (preferred) or `feature/<slug>`.
* One logical feature/bugfix per branch.
* Draft PR if: tests incomplete, speculative design, waiting on Jira clarification.
* Ready PR criteria: all tests green, style passes, DCO verified, plan executed, risk documented.
* Required Status Checks (inferred): lint workflow, unit workflow (Windows matrix), central CI stub (if configured to run checks). Always ensure these pass before marking ready for review.
* Label rules: Add at least one classification label plus any Expeditor bump labels if version semantics require minor/major bump.
* Re-run: Push a no-op amend commit or use GitHub UI.
* Merge Strategy: Rely on squash or merge commit per repository norms (Expeditor handles versioning post-merge). AI MUST NOT perform merge.

---
## 8. Commit & DCO Policy
MANDATORY: Every commit ends with exact line:
```
Signed-off-by: Full Name <email@example.com>
```
Validation Rules:
* Name + email must be plausible (not placeholders like `user@localhost`).
* If missing: AI agent must regenerate commit message with sign-off or request user details.
* AI must never auto-fabricate unknown contributor identity—ask explicitly if not provided.

---
## 9. Testing & Coverage Strategy
Testing Principles:
* Prefer focused RSpec examples naming behavior, not implementation details.
* Add tests for new public methods or option branches (e.g., gzip variants, ignore patterns, empty extraction directory behavior).
* Ensure Windows-specific logic (CRLF handling) remains intact—avoid altering tests that assert file size invariants unless requirement changes.
* If altering archive logic, add tests for error conditions (invalid headers, unsupported compression) as feasible.

Coverage Enforcement (Heuristic ≥ 80%):
1. Enumerate new/modified conditional branches.
2. Map each branch to at least one example.
3. If gaps: propose additional spec(s); ask user to continue.
4. Only proceed to PR once all branches exercised or explicitly waived (record waiver in PR “Tests & Coverage” section).

---
## 10. Labels Reference
Global Mapping Guidelines:
* bug / fix -> defect resolution
* enhancement / feature -> functional addition
* documentation -> docs-only change
* chore / maintenance -> refactor / dep update without functional change
* test -> test-only modification
* ci -> CI workflow or pipeline update
* security -> security fix / hardening

Repository-Specific Labels:
* Expeditor version bump labels:
  - `Expeditor: Bump Version Minor`
  - `Expeditor: Bump Version Major`
  - `Expeditor: Skip Version Bump`
  - `Expeditor: Skip Changelog`
  - `Expeditor: Skip All`

If additional labels exist in GitHub (queried via API), include them similarly. (Agents should attempt real-time retrieval when runtime CLI access with `gh` is permitted.)

API Retrieval Pattern (Manual Execution Example):
```bash
gh api -H "Accept: application/vnd.github+json" \
  /repos/chef/mixlib-archive/labels | jq '.[] | {name, description}'
```

---
## 11. CI / Expeditor Integration
### GitHub Actions Workflows
1. `lint.yml` – Runs Cookstyle on PRs and pushes to `main`; concurrency cancel to avoid stale runs.
2. `unit.yml` – Windows matrix tests (Ruby 3.1 & 3.4) triggered on PR and pushes to `master` (legacy). Ensures Windows compatibility.
3. `ci-main-pull-request-checks.yml` – Stub invoking centralized `chef/common-github-actions` pipeline with secret scanning (TruffleHog), SBOM generation, optional complexity and security scanning flags.

### Expeditor
* On PR merge to release branch: version bump (unless skip labels), update version file & changelog, build gem artifact.
* Promotion triggers publish to RubyGems.
* Auto deletion of merged PR branches.
* Minor/Major release control via labels.
* Avoid manual edits to `.expeditor/config.yml` unless explicitly tasked.

### Release Flow Summary
1. Merge PR -> Expeditor bump + changelog update.
2. Build gem(s) including Windows universal variant.
3. Promotion -> Publish (rubygems & universal mingw32 variant).

---
## 12. Security & Protected Files
NEVER modify without explicit maintainer instruction:
* `LICENSE`
* `CODE_OF_CONDUCT.md`
* `CONTRIBUTING.md`
* `.expeditor/*`
* `.github/workflows/*`
* Any secrets, tokens, or credential references (do not add/alter encrypted secrets).
* `CODEOWNERS`

Prohibited Actions:
* Force-pushing to `main` / default branch.
* Merging PRs autonomously.
* Committing secrets or large (>5MB) binary blobs.
* Introducing new network calls in tests without approval.

---
## 13. Prompts Pattern (Interaction Model)
All AI steps MUST be iterative. After each major phase output:
1. Step Summary (1–3 sentences).
2. Remaining Steps Checklist (markdown list with checked/unchecked boxes).
3. Explicit question: `Continue to next step? (yes/no)` plus a recommended next prompt.

Example Interaction Block:
```
Summary: Implemented archive option parsing and added RSpec examples for gzip flag.
Remaining:
- [x] Plan
- [x] Implementation
- [ ] Add edge case tests
- [ ] Run lint & specs
- [ ] Prepare PR
Continue to next step? (yes/no)
Suggested prompt: "Add edge case tests for invalid headers".
```

If user replies `yes`, proceed. If `no`, pause and request clarifications.

---
## 14. Validation & Exit Criteria
Completion Requirements for a Task:
1. Jira acceptance criteria satisfied (if Jira-backed) and referenced in PR body.
2. All modified/new logic covered by at least one RSpec example; heuristic coverage ≥ 80% for new code paths.
3. Lint/style passes (`rake style`).
4. Specs pass locally and no failing CI workflows.
5. DCO compliance for every commit.
6. PR created with HTML template sections populated.
7. Appropriate labels applied (classification + Expeditor bump label if needed).
8. No protected files altered without authorization.
9. Risk & mitigation section documented.
10. Iterative prompts followed each phase.

Exit Signal: Provide final summary + checklist all checked. Ask: `Ready for human review? (yes/no)`.

---
## 15. Environment Preparation
Local setup commands (macOS/Linux):
```bash
git clone https://github.com/chef/mixlib-archive.git
cd mixlib-archive
bundle install --jobs 4 --retry 3
rake spec        # run tests
rake style       # lint/style
```
Windows notes: Ensure Ruby (matching CI versions) installed; DLLs from `distro/ruby_bin_folder` are auto-copied by Gemfile logic on bundle install.

Optional (Add SimpleCov ONLY if instructed):
1. Add `spec/coverage_helper.rb` requiring `simplecov` and configure minimum.
2. Require helper from `spec/spec_helper.rb`.
3. Exclude fixtures & spec directories.

---
## 16. Jira Integration Quick Reference
Prompt Template:
```
Fetch Jira: getIssue ABC-123
Return structured implementation plan (Design, Files, Tests, Edge Cases, Risks) and wait.
```
Post-Fetch Plan Confirmation Prompt:
```
Proceed implementing ABC-123 step 1 (create branch, scaffold tests)?
```

---
## 17. Idempotency & Recovery
* If branch already exists locally: `git checkout ABC-123` and resume next incomplete step.
* If PR already open: update branch, append changes; do NOT open duplicate PR.
* If partial tests added: identify missing edge cases; continue.
* If DCO missing in older commits: interactive rebase and re-sign (`git commit --amend --no-edit --signoff`).

---
## 18. Safeguards Recap
Always verify before modifying critical automation or policy files. Ask for confirmation if task appears to require altering protected resources.

---
## 19. Quick Command Reference
```bash
# Run specs + style
bundle exec rake spec
bundle exec rake style

# Create branch
git checkout -b ABC-123

# Commit (after staging changes)
git commit -m "fix(archive): handle empty directory extraction [ABC-123]" -s

# Push & create PR
git push -u origin ABC-123
gh pr create --fill --title "ABC-123: Handle empty extraction" --body-file /tmp/pr_body.md

# Add label
gh pr edit --add-label "bug"
```

---
## 20. Amendment & Evolution
Propose updates to this instruction file via a dedicated PR referencing rationale (e.g., new workflow, enabled coverage tool). AI agents must append—not overwrite—existing sections unless performing a structured revision explicitly approved.

---
## 21. Final Reminder
ALWAYS end each operational response with: `Continue to next step? (yes/no)` when engaged in a multi-step task.

---
*Document version: 1.0.0 (initial creation on 2025-09-29)*
