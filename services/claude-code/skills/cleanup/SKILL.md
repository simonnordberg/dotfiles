---
name: cleanup
description: Clean up the design of a large change, or a whole codebase.
license: CC0-1.0
---

# Cleanup

Look over the current change (or the whole codebase if there is no current
change) and look for:

- Any transformations or indexes that are redundant with data structures or
  relationships already known earlier in the whole-program data flow.
- Any backwards-compatibility shims, unnecessary defensive code, or unnecessary
  deduplication.
- For any deduplication added in this change, ask yourself: could these objects
  have arrived here inherently deduplicated?

Print out your findings, if any. Then, fix any findings you found.

After fixing your findings, look over the code again: now that we have done that
cleanup, are there any other cleanups available? Print out your new findings.
Then fix them.

Continue to do that in a loop (look over the code again, find any new cleanups
that are visible now that you've fixed the last ones, print them out, and fix
them if you find any) until you find no more cleanups to do upon reinspection.
