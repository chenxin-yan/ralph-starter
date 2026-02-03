# Project Name

> One-line description of the project.

## Overview

[2-3 paragraphs explaining what you're building, the problem it solves, and who it's for]

## Features

- Feature 1
- Feature 2
- Feature 3

## Technical Stack

- **Language**: [e.g., TypeScript 5.x]
- **Framework**: [e.g., Next.js 14 with App Router]
- **Database**: [e.g., PostgreSQL with Prisma ORM]
- **Authentication**: [e.g., NextAuth.js with JWT]
- **Testing**: [e.g., Vitest for unit tests, Playwright for E2E]
- **Other**: [Any other key technologies]

## Architecture

[Describe the architecture of the project]

## API Design

| Method | Endpoint | Description | Auth Required |
| ------ | -------- | ----------- | ------------- |
| GET    | /api/... | ...         | Yes/No        |
| POST   | /api/... | ...         | Yes/No        |

### Request/Response Examples

[Include example payloads if helpful]

## Data Models

### ModelName

| Field     | Type     | Description        | Constraints      |
| --------- | -------- | ------------------ | ---------------- |
| id        | UUID     | Primary key        | Required, Unique |
| createdAt | DateTime | Creation timestamp | Required         |
| ...       | ...      | ...                | ...              |

[Repeat for each model]

### Relationships

- [Describe relationships: User has many Posts, Post belongs to User, etc.]

## Constraints & Requirements

### Performance

- [e.g., API response time < 200ms for 95th percentile]

### Security

- [e.g., All endpoints require authentication except /api/auth/*]
- [e.g., Passwords hashed with bcrypt, minimum 12 rounds]

### Compatibility

- [e.g., Node.js 18+, modern browsers only]

### Code Quality

- [e.g., 80% test coverage minimum]
- [e.g., All code must pass TypeScript strict mode]

## Out of Scope

- [Feature X - planned for v2]
- [Integration Y - not needed for MVP]
- [Edge case Z - will handle later]

## References

- [Link to design mockups]
- [Link to external API docs]
- [Link to similar projects]
