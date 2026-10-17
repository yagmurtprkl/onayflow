# OnayFlow repository notes

## Current architecture

- Rails 8.0.5.1 and Ruby 3.4.7.
- Rails ERB frontend with session authentication and CSRF protection.
- SQLite in development/test; PostgreSQL through `DATABASE_URL` in production.
- Approval transitions and the 48-hour deadline live in
  `app/models/approval_document.rb`.
- Solid Cache, Solid Queue, and Solid Cable are intentionally disabled.

## Working rules

- Preserve the employee and assigned-manager authorization boundaries.
- Keep passwords hashed through `has_secure_password`.
- Keep SQLite gems limited to development/test and `pg` limited to production.
- Never add production demo credentials or production users to `db/seeds.rb`.
- Never commit `config/master.key`, `.env*`, SQLite databases, logs, or assets.
- Use `Time.current` and `travel_to` for deadline behavior.
- Run `ruby bin/rails test` after application changes.
- Keep the full Brakeman scan enabled; report lifecycle warnings separately.

## Deployment

- Render build: `bash bin/render-build.sh`
- Render start: `bundle exec puma -C config/puma.rb`
- Render health check: `/up`
- Production demo accounts are provisioned during a build only when temporary
  secret environment variables explicitly opt in, as documented in `README.md`.
