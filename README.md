# One by Zero

One is an example project created to show how to use the Zero framework.

## Features

- [x] Authentication
- [x] Authorization
- [x] Database
- [x] User management
- [x] Community management

## Installation

### Requirements

- [Dart](https://dart.dev/) v3.0.0+
- [PostgreSQL](https://www.postgresql.org/) v9.5+
- [Zero](https://zero.vercel.app)

### Setup

1. Clone the repository

```bash
git clone https://github.com/bryanbill/one.git
```

2. Install dependencies

```bash
cd one
dart pub get
```

3. Copy `.env.example` to `.env` and fill in the required values

```bash
cp .env.example .env
```

4. Import the database schema in `data/one.sql`

```bash
psql -U postgres -d one -f data/one.sql
```

5. Run the server

```bash
zero run
```

## License

[MIT](https://choosealicense.com/licenses/mit/)
