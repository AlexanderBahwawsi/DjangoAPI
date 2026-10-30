# DjangoAPI — Dog and Breed REST API

A Django + Django REST Framework project exposing CRUD endpoints for `Dog` and `Breed` records,
containerized with Docker and backed by PostgreSQL.

## Running with Docker (recommended)

Requires [Docker Desktop](https://www.docker.com/products/docker-desktop/) (Docker Compose v2).

```bash
docker compose up --build
```

That builds the `app` image and starts two services:

| Service | Image                       | Role                                                      |
|---------|-----------------------------|-----------------------------------------------------------|
| `app`   | built from `Dockerfile`     | Django + DRF dev server on port 8000, runs migrations on start |
| `db`    | `postgres:16-alpine`        | PostgreSQL database, data persisted in the `postgres_data` volume |

The API is then available at `http://localhost:8000/api/`. Stop with `Ctrl+C` or
`docker compose down` (add `-v` to also wipe the database volume).

### How the containerization works

- **`Dockerfile`** — encapsulates every dependency: Python 3.13, the `libpq` client library
  that `psycopg` needs, `pg_isready` for the startup wait, and the Python packages from
  `requirements.txt`. The application source is deliberately *not* `COPY`'d into the image.
- **`docker-compose.yml`** — defines the `app` and `db` services on a shared network. `app`
  reaches the database by the hostname `db`. `depends_on` with a `pg_isready` healthcheck means
  the app container is not started until Postgres accepts connections.
- **Volumes** — the project directory is bind-mounted to `/app` inside the `app` container
  (`.:/app`), so code changes on the host are picked up immediately by `runserver`'s auto-reload
  with no rebuild. A named volume `postgres_data` keeps the database between restarts.
- **`entrypoint.sh`** — waits for Postgres, runs `python manage.py migrate`, then starts the
  dev server.
- **PostgreSQL instead of SQLite** — `dogserver/settings.py` now uses
  `django.db.backends.postgresql` (see the
  [Django database docs](https://docs.djangoproject.com/en/5.2/ref/databases/#postgresql-notes))
  with connection settings read from environment variables (`POSTGRES_DB`, `POSTGRES_USER`,
  `POSTGRES_PASSWORD`, `POSTGRES_HOST`, `POSTGRES_PORT`). `psycopg[binary]` is the driver.
- **Configuration** — defaults are set in `docker-compose.yml`; copy `.env.example` to `.env`
  to override them (`.env` is git-ignored).

### Useful commands

```bash
docker compose ps                                  # see both services running
docker compose logs -f app                         # follow the Django log
docker compose exec app python manage.py createsuperuser
docker compose exec db psql -U dogapi -d dogapi    # open a psql shell on the database
```

## Running without Docker

You need a local PostgreSQL server; set the `POSTGRES_*` environment variables to point at it
(the defaults assume host `db`, so at minimum set `POSTGRES_HOST=localhost`).

```bash
python -m venv venv
venv\Scripts\activate        # Windows (use `source venv/bin/activate` on macOS/Linux)
pip install -r requirements.txt
set POSTGRES_HOST=localhost  # export POSTGRES_HOST=localhost on macOS/Linux
python manage.py migrate
python manage.py runserver
```

The API is then available at `http://127.0.0.1:8000/api/`.

## Endpoints

| Method | URL                  | Action                    |
|--------|----------------------|---------------------------|
| GET    | `/api/breeds/`       | List all breeds           |
| POST   | `/api/breeds/`       | Create a breed            |
| GET    | `/api/breeds/<id>/`  | Retrieve one breed        |
| PUT    | `/api/breeds/<id>/`  | Replace a breed           |
| DELETE | `/api/breeds/<id>/`  | Delete a breed            |
| GET    | `/api/dogs/`         | List all dogs             |
| POST   | `/api/dogs/`         | Create a dog              |
| GET    | `/api/dogs/<id>/`    | Retrieve one dog          |
| PUT    | `/api/dogs/<id>/`    | Replace a dog             |
| DELETE | `/api/dogs/<id>/`    | Delete a dog              |

## Models

**Breed** — `name`, `size` (Tiny / Small / Medium / Large), `friendliness`, `trainability`,
`sheddingamount`, `exerciseneeds` (each an integer 1–5).

**Dog** — `name`, `age`, `breed` (foreign key to Breed), `gender`, `color`, `favoritefood`, `favoritetoy`.

Validation is enforced by the model (choices and `MinValueValidator`/`MaxValueValidator`), so the
API returns `400 Bad Request` for an invalid size or a rating outside 1–5.

## Implementation

This version uses **explicit class-based views**: `BreedList`, `BreedDetail`, `DogList` and
`DogDetail` in [dogapi/controllers.py](dogapi/controllers.py) subclass DRF's `APIView` and
implement each HTTP method by hand (`get`/`post` on the list views, `get`/`put`/`delete` on the
detail views), following the
[DRF class-based views tutorial](https://www.django-rest-framework.org/tutorial/3-class-based-views/).
Each view builds a `BreedSerializer`/`DogSerializer`, returns `201 Created` on a successful POST,
`204 No Content` on DELETE, `400 Bad Request` with the serializer errors on invalid input, and
`404 Not Found` (via `Http404`) for an unknown id.

Routing is done with explicit `path()` entries in [dogapi/urls.py](dogapi/urls.py)
(`dogs/`, `dogs/<int:pk>/`, `breeds/`, `breeds/<int:pk>/`), included under `api/` in
[dogserver/urls.py](dogserver/urls.py).

The earlier commit (`797d369`) implemented the same API with **viewsets**: `BreedViewSet` and
`DogViewSet` were `ModelViewSet`s in `dogapi/views.py` registered on a `DefaultRouter`. Both
versions expose identical endpoints, JSON and status codes.

## Example requests

```bash
curl -X POST http://127.0.0.1:8000/api/breeds/ -H "Content-Type: application/json" \
  -d '{"name":"Labrador Retriever","size":"Large","friendliness":5,"trainability":5,"sheddingamount":4,"exerciseneeds":4}'

curl -X POST http://127.0.0.1:8000/api/dogs/ -H "Content-Type: application/json" \
  -d '{"name":"Buddy","age":3,"breed":1,"gender":"Male","color":"Yellow","favoritefood":"Chicken","favoritetoy":"Tennis ball"}'
```

## Testing

Each endpoint was tested with Postman, one request per method type for each model
(GET list, POST, GET detail, PUT, DELETE for both `/api/breeds/` and `/api/dogs/`),
ten requests in total. The screenshots are submitted separately with the assignment.

The containerized version was tested by running `docker compose up --build`, confirming both
services are healthy with `docker compose ps`, and re-running the same ten requests against
`http://localhost:8000/api/`. The migrated tables can be seen in Postgres with
`docker compose exec db psql -U dogapi -d dogapi -c "\dt"`.
