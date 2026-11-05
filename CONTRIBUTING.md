# Script and Project Documentation Standard

For each script or incident, provide:
1. Problem statement, symptoms, and relevant context
2. SQL Server version, edition, infrastructure, and prerequisites
3. Required permissions and whether execution is read-only
4. Script with comments and parameters
5. Execution steps, safeguards, and rollback plan where relevant
6. Example sanitized output and interpretation
7. Root-cause reasoning, actions taken, and result (for incidents)
8. Validation evidence and known limitations

## Safety
Never commit secrets, personal information, credentials, tokens, sensitive server names, or proprietary production data. Replace identifiers with clearly labeled examples. Avoid publishing executable changes as safe without review and nonproduction testing.

## Status labels
- **Planned:** Concept or proposed script
- **Draft:** Created but not validated
- **Validated:** Tested, with environment and method documented

Use descriptive file names and keep explanations accessible to hiring managers and DBAs.
