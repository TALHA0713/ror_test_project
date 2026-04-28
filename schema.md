
---

## 1. `users`

```sql
users (
  id PK,
  name,
  email UNIQUE,
  password_hash,
  is_active,
  created_at,
  updated_at
)
```

**Relationships:**

```text
users.id → projects.created_by_user_id
users.id → project_members.user_id
users.id → tickets.created_by_user_id
users.id → tickets.assigned_to_user_id
users.id → comments.user_id
users.id → attachments.uploaded_by_user_id
users.id → ticket_history.changed_by_user_id
```

---

## 2. `roles`

```sql
roles (
  id PK,
  name UNIQUE,          -- admin, developer, qa, viewer
  description,
  created_at,
  updated_at
)
```

**Relationships:**

```text
roles.id → project_member_roles.role_id
```

---

## 3. `projects`

```sql
projects (
  id PK,
  name,
  description,
  created_by_user_id FK → users.id,
  created_at,
  updated_at
)
```

**Relationships:**

```text
projects.id → project_members.project_id
projects.id → tickets.project_id
```

---

## 4. `project_members`

```sql
project_members (
  id PK,
  project_id FK → projects.id,
  user_id FK → users.id,
  joined_at,
  is_active,

  UNIQUE(project_id, user_id)
)
```

**Purpose:**

```text
Connects users with projects.
One user can be member of many projects.
One project can have many users.
```

**Relationships:**

```text
project_members.project_id → projects.id
project_members.user_id → users.id
project_members.id → project_member_roles.project_member_id
```

---

## 5. `project_member_roles`

```sql
project_member_roles (
  id PK,
  project_member_id FK → project_members.id,
  role_id FK → roles.id,
  created_at,

  UNIQUE(project_member_id, role_id)
)
```

**Purpose:**

```text
Allows one user to have multiple roles inside one project.
Example: user can be developer + QA in the same project.
```

**Relationships:**

```text
project_member_roles.project_member_id → project_members.id
project_member_roles.role_id → roles.id
```

---

## 6. `tickets`

```sql
tickets (
  id PK,
  project_id FK → projects.id,
  ticket_no,
  title,
  description,
  type,                  -- bug, feature, task
  status,                -- open, in_progress, resolved, closed
  priority,              -- low, medium, high, urgent
  created_by_user_id FK → users.id,
  assigned_to_user_id FK → users.id NULL,
  due_date NULL,
  created_at,
  updated_at,
  closed_at NULL,

  UNIQUE(project_id, ticket_no)
)
```

**Relationships:**

```text
tickets.project_id → projects.id
tickets.created_by_user_id → users.id
tickets.assigned_to_user_id → users.id

tickets.id → comments.ticket_id
tickets.id → attachments.ticket_id
tickets.id → ticket_history.ticket_id
```

---

## 7. `comments`

```sql
comments (
  id PK,
  ticket_id FK → tickets.id,
  user_id FK → users.id,
  comment,
  created_at,
  updated_at
)
```

**Relationships:**

```text
comments.ticket_id → tickets.id
comments.user_id → users.id
comments.id → attachments.comment_id
```

---

## 8. `attachments`

```sql
attachments (
  id PK,
  ticket_id FK → tickets.id NULL,
  comment_id FK → comments.id NULL,
  uploaded_by_user_id FK → users.id,
  file_name,
  file_path,
  mime_type,
  file_size,
  created_at,

  CHECK (
    (ticket_id IS NOT NULL AND comment_id IS NULL)
    OR
    (ticket_id IS NULL AND comment_id IS NOT NULL)
  )
)
```

**Purpose:**

```text
Attachment can belong either to a ticket or to a comment.
Not both.
```

**Relationships:**

```text
attachments.ticket_id → tickets.id
attachments.comment_id → comments.id
attachments.uploaded_by_user_id → users.id
```

---

## 9. `ticket_history`

```sql
ticket_history (
  id PK,
  ticket_id FK → tickets.id,
  changed_by_user_id FK → users.id,
  field_name,
  old_value,
  new_value,
  changed_at
)
```

**Purpose:**

```text
Tracks changes like:
status changed
priority changed
assignee changed
title updated
ticket closed
```

**Relationships:**

```text
ticket_history.ticket_id → tickets.id
ticket_history.changed_by_user_id → users.id
```

---

# Final Relationship Summary

```text
users 1 → many projects
users 1 → many project_members
users 1 → many tickets created
users 1 → many tickets assigned
users 1 → many comments
users 1 → many attachments
users 1 → many ticket_history records

projects 1 → many project_members
projects 1 → many tickets

project_members 1 → many project_member_roles

roles 1 → many project_member_roles

tickets 1 → many comments
tickets 1 → many attachments
tickets 1 → many ticket_history records

comments 1 → many attachments
```

The key design is this:

```text
users → project_members → project_member_roles → roles
```

That is what allows a user to have **multiple roles per project**, like **Developer + QA**.````
this schema tell me 