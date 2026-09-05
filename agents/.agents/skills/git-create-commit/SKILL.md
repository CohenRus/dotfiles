---
name: Git Create Commit
description: Create a short, focused commit message and commit staged changes
---

# Git Create Commit

## Overview

Create a short, focused commit message and commit staged changes.

## Steps

1. **Review changes**
    - Check the diff: `git --no-pager diff --cached` (if changes are staged) or `git --no-pager diff` (if unstaged)  
      **Always use `git --no-pager`** to prevent the pager from taking over, which can cause the prompt to hang on long diffs
    - Understand what changed and why
2. **Ask for issue key (optional)**
    - Check the branch name for an issue key (Linear, Jira, GitHub issue, etc.)
    - If an issue key (e.g., POW-123, PROJ-456, #123) is not already available in the chat or commit context, optionally ask the user if they want to include one
    - This is optional - commits can be made without an issue key
3. **Stage changes (if not already staged)**
    - `git add -A`
4. **Create short commit message**
    - Base the message on the actual changes in the diff
    - If the change can be accurately expressed in just the subject line, omit the body entirely
    - Use the body only when it provides *useful* additional information
    - Do not repeat information from the subject line in the message body
    - Return only the commit message in your response — no meta-commentary about the task, and no raw diff output
    - Example (subject only): `git commit -m "fix(auth): handle expired token refresh"`
    - Example with issue key: `git commit -m "PROJ-123: fix(auth): handle expired token refresh"`
    - Example with body:
      ```
      git commit -m "fix(auth): handle expired token refresh" -m ""
      ```
      ```
      Refresh the stored token when a 401 is returned instead of silently failing.
      ```

## Template

- `git commit -m "<type>(<scope>): <short summary>"`
- With issue key: `git commit -m "<issue-key>: <type>(<scope>): <short summary>"`

## Commit Message Style

### Subject line

- **Length:** Limit to 50 characters when possible
- **Imperative mood:** Use "fix", "add", "update" (not "fixed", "added", "updated")
- **Capitalize:** First letter of the subject line should be capitalized
- **No punctuation:** Do not end the subject line with a period
- **Describe why:** Not just what — "fix stuff" is meaningless

### Body (when needed)

- **Separator:** Separate the subject from the body with a blank line
- **Wrap:** Wrap the body at 72 characters
- **Conciseness:** Keep the body short and concise; omit it entirely if the change is clear from the subject alone
- **No repetition:** Do not restate what the subject already says
