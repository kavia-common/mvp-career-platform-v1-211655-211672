# Career Platform Database

This directory contains scripts and artifacts for running a local PostgreSQL instance for the MVP Career Platform.

- `startup.sh` — starts PostgreSQL on port 5000, creates the `myapp` database and the `appuser` user with required privileges, and writes a connection string to `db_connection.txt`. It also writes a `db_visualizer/postgres.env` with convenience environment variables.
- `backup_db.sh` — universal backup script (PostgreSQL/MySQL/SQLite/MongoDB aware). For this project we primarily use PostgreSQL.
- `restore_db.sh` — universal restore script. For PostgreSQL, it restores from `database_backup.sql` when available.
- `database_backup.sql` — sample PostgreSQL dump containing the `myapp` database creation and basic grants.

PostgreSQL defaults used by startup.sh:
- DB_NAME: `myapp`
- DB_USER: `appuser`
- DB_PASSWORD: `dbuser123`
- DB_PORT: `5000`

Connect using:
```
psql postgresql://appuser:dbuser123@localhost:5000/myapp
```
or
```
psql -h localhost -U appuser -d myapp -p 5000
```

## Optional: Database Visualizer

A small Node/Express app exists under `db_visualizer/` to quickly browse databases during development. It is **optional** and not part of the database container startup.

If you want to use it:
1. Ensure the database is running: `./startup.sh`
2. In `db_visualizer/`, install and run:
   ```
   npm install
   npm start
   ```
   Or use the helper:
   ```
   bash ./db_visualizer/run_db_visualizer.sh
   ```

The visualizer listens on http://localhost:3000 and reads from `db_visualizer/postgres.env` if sourced.

## Notes

- The database startup does not start any Node server. This avoids failures like `MODULE_NOT_FOUND: Cannot find module './lib/express'` when Node dependencies are not installed.
- All application access to the database should be through the backend APIs. Do not expose the database directly in production environments.

## Hardening and startup behavior

To ensure this DB container never attempts to run the optional Node/Express visualizer during build or startup:

- `startup.sh` sets environment variables:
  - `DB_CONTAINER_MODE=1` to mark container context
  - `NPM_CONFIG_IGNORE_SCRIPTS=true` and `YARN_IGNORE_SCRIPTS=true` to prevent any npm/yarn lifecycle scripts (postinstall/prepare) from running during DB startup
- A `.dockerignore` excludes `db_visualizer/` from the DB image build context, preventing accidental auto-run by generic Node-based entrypoints.
- The helper script `db_visualizer/run_db_visualizer.sh` refuses to run when `DB_CONTAINER_MODE=1` unless you explicitly opt-in by setting:
  ```
  export ALLOW_DB_VISUALIZER_IN_CONTAINER=1
  ```
  This keeps the visualizer strictly optional and out of the normal DB startup path.
