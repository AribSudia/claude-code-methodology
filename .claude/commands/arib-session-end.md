---
description: Session | Close session - update all memory files, run tests, commit, push, report next steps
---

# /arib-session-end Command

## Purpose
Properly close a session with full memory update, ensuring all work is documented and committed.

## Trigger
User types `/arib-session-end`

## Instructions

### Step 1: Update Memory Files
Update all session memory files with current session's work:

1. **session_notes.md**: 
   - Summary of work completed in this session
   - Any blockers encountered
   - Next session recommendations

2. **project_status.md**: 
   - Update overall project progress
   - Mark completed features
   - Flag in-progress items
   - Update completion percentages

3. **change_log.md**: 
   - Document significant changes made
   - Include git commit hashes
   - Note any breaking changes

4. **testing_log.md**: 
   - Record which tests were run
   - Document test results
   - Flag any failed tests and their status

### Step 2: Run Final Tests
Execute the project's test suite:
```
npm test (or equivalent for the project)
```
Ensure all tests pass before proceeding. If tests fail, address failures or document why they're acceptable.

### Step 3: Create Session-End Commit
Create a git commit documenting the session closure:
```
git add .
git commit -m "Session end: [brief summary of work done]"
```

### Step 4: Push to Remote
Push all changes to the remote repository:
```
git push origin [current-branch]
```

### Step 5: Generate Session Report
Create and present a comprehensive report containing:
- **Completed Tasks**: List of finished work items
- **Issues Encountered**: Any problems faced and how they were resolved
- **Test Status**: Pass/fail summary
- **Code Quality**: Any quality metrics or concerns
- **Next Session Recommendations**: Clear direction for next work session

### Step 6: Closing Summary
Provide a brief closing message indicating the session is properly concluded.

## Notes
- This command should be run at the end of every work session
- All tests must pass before pushing to remote
- Commit messages should be clear and descriptive
- Memory files are critical for session continuity
- Do not skip the push to remote step
