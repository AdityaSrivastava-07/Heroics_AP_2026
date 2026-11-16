# Phase 1 & 2: Database Normalization Report

## 1. Functional Dependencies (FDs) and Normal Forms

Below is the normalization analysis for every table in the `linkedin` schema. A table is in **BCNF (Boyce-Codd Normal Form)** if, for every non-trivial functional dependency $X \rightarrow Y$, $X$ is a superkey. 

### `cities`
* **FDs:** `city_id` $\rightarrow$ `city_name`, `state`
* **Candidate Key(s):** `city_id`
* **Normal Form:** **BCNF**. The only determinant is `city_id`, which is the primary key.

### `skills`
* **FDs:** 
  * `skill_id` $\rightarrow$ `skill_name`
  * `skill_name` $\rightarrow$ `skill_id`
* **Candidate Key(s):** `skill_id`, `skill_name`
* **Normal Form:** **BCNF**. Both determinants are candidate keys.

### `companies`
* **FDs:** 
  * `company_id` $\rightarrow$ `company_name`, `industry`, `company_size`, `hq_city_id`, `founded_year`, `website`
  * `company_name` $\rightarrow$ `company_id`, `industry`, `company_size`, `hq_city_id`, `founded_year`, `website`
* **Candidate Key(s):** `company_id`, `company_name`
* **Normal Form:** **BCNF**. Both determinants are candidate keys.

### `members`
* **FDs:** 
  * `member_id` $\rightarrow$ `first_name`, `last_name`, `headline`, `email`, `city_id`, `industry`, `is_premium`, `open_to_work`, `created_at`
  * `email` $\rightarrow$ `member_id`, `first_name`, `last_name`, `headline`, `city_id`, `industry`, `is_premium`, `open_to_work`, `created_at`
* **Candidate Key(s):** `member_id`, `email`
* **Normal Form:** **BCNF**. Both determinants are candidate keys.

### `positions`
* **FDs:** `position_id` $\rightarrow$ `member_id`, `company_id`, `title`, `employment_type`, `start_date`, `end_date`
* **Candidate Key(s):** `position_id`
* **Normal Form:** **BCNF**. The only determinant is the primary key.

### `member_skills`
* **FDs:** `{member_id, skill_id}` $\rightarrow$ `endorsements`
* **Candidate Key(s):** `{member_id, skill_id}`
* **Normal Form:** **BCNF**. The composite primary key is the only determinant.

### `connections`
* **FDs:** `{member_a, member_b}` $\rightarrow$ `connected_at`
* **Candidate Key(s):** `{member_a, member_b}`
* **Normal Form:** **BCNF**. The composite primary key is the only determinant. (Note: A CHECK constraint enforces `member_a < member_b` to ensure physical uniqueness of the relationship).

### `invitations`
* **FDs:** `invitation_id` $\rightarrow$ `sender_id`, `recipient_id`, `note`, `sent_at`, `status`, `responded_at`
* **Candidate Key(s):** `invitation_id`
* **Normal Form:** **BCNF**. The only determinant is the primary key.

### `jobs`
* **FDs:** `job_id` $\rightarrow$ `company_id`, `title`, `city_id`, `workplace_type`, `employment_type`, `min_experience`, `min_salary_lpa`, `max_salary_lpa`, `posted_at`, `closes_at`, `status`
* **Candidate Key(s):** `job_id`
* **Normal Form:** **BCNF**. The only determinant is the primary key.

### `job_skills`
* **FDs:** No non-trivial FDs. (All columns form the primary key).
* **Candidate Key(s):** `{job_id, skill_id}`
* **Normal Form:** **BCNF**.

### `applications`
* **FDs:** 
  * `application_id` $\rightarrow$ `job_id`, `member_id`, `applied_at`, `easy_apply`, `status`, `status_updated_at`
  * `{job_id, member_id}` $\rightarrow$ `application_id`, `applied_at`, `easy_apply`, `status`, `status_updated_at`
* **Candidate Key(s):** `application_id`, `{job_id, member_id}`
* **Normal Form:** **BCNF**. Both determinants are candidate keys.

### `profile_views`
* **FDs:** `view_id` $\rightarrow$ `viewer_id`, `viewed_id`, `viewed_at`
* **Candidate Key(s):** `view_id`
* **Normal Form:** **BCNF**. The only determinant is the primary key.

---

## 2. Redundant and Derived Columns Analysis

During schema design, we identified potential redundancies related to the `members` table:

1. **`members.headline`:** A member's headline often duplicates the `title` of their currently active job in the `positions` table (where `end_date IS NULL`).
2. **`members.industry`:** A member's industry often duplicates the `industry` of the company they currently work for (via `positions.company_id` $\rightarrow$ `companies.industry`).

**Justification for Keeping Them:**
While these fields represent a technical redundancy and a potential violation of strict normalization if we assume they *must* match, keeping them in the `members` table is highly justified by the business logic of a professional networking platform:
* **User Override:** LinkedIn allows users to write custom headlines (e.g., "Aspiring Software Engineer") that do not strictly match their current formal job title.
* **Transitional States:** A member may be unemployed (no active position) but still belong to a specific industry or have a professional headline. 
* **Performance:** Displaying a member's basic profile card (like in query `R01`) requires immediate access to their headline and industry without needing to join the `positions` and `companies` tables every time.

Therefore, storing `headline` and `industry` at the `members` level is a deliberate design choice that accommodates user customization and read-heavy workload optimization rather than a true normalization failure.
