# Database Visualizer (Optional)

This is a minimal Node.js/Express app to quickly inspect local databases (PostgreSQL, MySQL, SQLite, MongoDB) during development. It is not required for the PostgreSQL database container to run, and it should not be started automatically as part of the database startup.

If you see a MODULE_NOT_FOUND error for express, it means dependencies have not been installed for this optional tool. The main database startup (startup.sh) does not rely on this app.

## Prerequisites
- Node.js 18+ and npm available locally (inside your environment where you intend to run the visualizer).

## Install dependencies
From this folder:
```
npm install
```

This installs:
- express
- pg
- mysql2
- sqlite3
- mongodb
- nodemon (dev)

## Configure PostgreSQL connection
The PostgreSQL database is started by `../startup.sh` on port 5000 with:
- DB: myapp
- User: appuser
- Password: dbuser123
- Host: localhost

The startup script writes a `postgres.env` file in this folder. You may source it before running the visualizer:
```
source postgres.env
```

Ensure the DB is running (start it via `../startup.sh` if needed).

## Run the visualizer
```
npm start
```
This starts the Express server on port 3000 (binds to 0.0.0.0). Visit:
- http://localhost:3000

Alternatively, you can use the helper script that installs dependencies and starts the server:
```
bash ./run_db_visualizer.sh
```

## Notes
- This tool is optional and not part of production. The CareerPlatformDatabase container will not auto-run this Node service. If you do **not** need it, you can safely ignore this directory.
- If you modify ports or credentials, update `postgres.env` accordingly.
