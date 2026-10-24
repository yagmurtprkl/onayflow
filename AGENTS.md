# OnayFlow coding agent instructions

Read AGENT.md for the existing architecture, authorization and deployment rules.

## Stage 2: agent-assisted purchase requests

- Work in C:\Projects\onayflow. Preserve existing employee/assigned-manager boundaries.
- Agent::LlmClient calls Groq only over HTTPS. GROQ_API_KEY is a secret environment variable.
- Never log or commit API keys, chat content, passwords or production user data.
- Agent recommendations cannot authorize documents or override the 48-hour deadline.
- Use ApprovalDocument#submit!, #approve! and #reject! for transitions.
- Lock AgentRequest before processing; one conversation creates at most one document.
- Provider failures and malformed output must hand off visibly, never simulate LLM success.
- Manager human handoff is scoped to the assigned manager; return control through a recorded note.
- Keep tests serial: SQLite transactional fixtures cannot share the pinned connection across threads.
- Run ruby bin/rails test, ruby bin/rubocop --cache false, ruby bin/importmap audit,
  and the complete Brakeman scan; report lifecycle warnings separately.
- Keep CHALLENGE_LOG.md honest: mocked tests are not evidence of a live provider demo.

## Render

- Build: bash bin/render-build.sh; start: bundle exec puma -C config/puma.rb; health: /up.
- Build script prepares the production database and assets.
- Configure GROQ_API_KEY as a Render secret; GROQ_MODEL is optional.
- Do not claim deployment or real LLM verification until actually observed.
