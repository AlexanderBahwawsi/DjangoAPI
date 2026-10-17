# DjangoAPI — Dog and Breed REST API

A Django + Django REST Framework project exposing CRUD endpoints for `Dog` and `Breed` records.

## Setup

```bash
python -m venv venv
venv\Scripts\activate        # Windows (use `source venv/bin/activate` on macOS/Linux)
pip install -r requirements.txt
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
