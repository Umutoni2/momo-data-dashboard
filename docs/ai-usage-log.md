# AI Usage Log — MoMo SMS Data Processing System (Week 2)

**Team:** MoMo DB Team  
**Assignment:** Week 2 — Database Design & Implementation  
**Policy Version:** 1.0

---

## Policy Summary

Per the assignment's AI Usage Policy, AI tools are **permitted** only for:
- Grammar and syntax checking in documentation
- Code syntax verification (not logic generation)
- Research on MySQL best practices (with proper citation)

AI tools are **prohibited** from:
- Generating ERD designs or SQL schemas
- Creating business logic or database relationships
- Writing reflection content or technical explanations

---

## AI Interaction Log

| # | Date | Tool | Input / Prompt | Output Used | Section | Compliant? |
|---|------|------|---------------|-------------|---------|------------|
| 1 | 2026-03-18 | Grammarly | Proofread the ERD design rationale paragraph | Grammar corrections to 2 sentences | ERD Documentation | ✅ Yes |
| 2 | 2026-03-18 | Grammarly | Check README.md for spelling and punctuation | Fixed 3 typos | README.md | ✅ Yes |
| 3 | 2026-03-19 | MySQL Docs | Researched ON DELETE CASCADE vs ON DELETE SET NULL behaviour | Used to decide System_Logs FK behaviour | database_setup.sql | ✅ Yes |
| 4 | 2026-03-19 | Grammarly | Proofread JSON schema `_description` fields | Minor phrasing changes | json_schemas.json | ✅ Yes |

---

## Attribution

**AI-assisted sections** are marked with inline comments:

**database_setup.sql** — Lines with syntax corrections from MySQL Docs research:
```sql
-- [SYNTAX-VERIFIED via MySQL 8.0 Docs] ON DELETE SET NULL behaviour for nullable FKs
CONSTRAINT fk_log_user FOREIGN KEY (User_ID) REFERENCES Users(User_ID) ON DELETE SET NULL
```

**README.md** — Design rationale paragraph was grammar-checked by Grammarly. All content and ideas are original team work.

---

## Prohibited AI Use — Compliance Statement

We confirm that **no AI tool** was used to:
- Generate the ERD entity structure or cardinality decisions
- Write the SQL CREATE TABLE statements or design the schema
- Create the JSON nesting structure or API response formats
- Produce any business logic (CHECK constraints, security rules)
- Write technical explanations or reflection content

All database design decisions were made by team members based on analysis of the MoMo XML data structure and the business requirements provided in the assignment brief.

---

## Verification

This log will be presented during live sessions for individual competency verification.  
Team-specific design choices (Rwandan phone number format, RWF currency, specific transaction categories) confirm the work is original and not generated from generic AI templates.

---

*Last updated: 2026-03-20*
