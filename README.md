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

This version uses **viewsets**: `BreedViewSet` and `DogViewSet` in
[dogapi/views.py](dogapi/views.py) are `ModelViewSet`s registered on a `DefaultRouter` in
[dogapi/urls.py](dogapi/urls.py), which is included under `api/` in
[dogserver/urls.py](dogserver/urls.py).

## Example requests

```bash
curl -X POST http://127.0.0.1:8000/api/breeds/ -H "Content-Type: application/json" \
  -d '{"name":"Labrador Retriever","size":"Large","friendliness":5,"trainability":5,"sheddingamount":4,"exerciseneeds":4}'

curl -X POST http://127.0.0.1:8000/api/dogs/ -H "Content-Type: application/json" \
  -d '{"name":"Buddy","age":3,"breed":1,"gender":"Male","color":"Yellow","favoritefood":"Chicken","favoritetoy":"Tennis ball"}'
```

## Testing

- `postman/DogAPI.postman_collection.json` — import into Postman; it contains all 10 requests
  (uses a `base_url` collection variable set to `http://127.0.0.1:8000`).
- `screenshots/` — one screenshot per request type (10 total), captured against the running server:

| # | Request                     | Screenshot                          |
|---|-----------------------------|-------------------------------------|
| 1 | POST `/api/breeds/`         | `01_breeds_POST.png`                |
| 2 | GET `/api/breeds/` (list)   | `02_breeds_GET_list.png`            |
| 3 | GET `/api/breeds/1/`        | `03_breeds_GET_detail.png`          |
| 4 | PUT `/api/breeds/1/`        | `04_breeds_PUT.png`                 |
| 5 | DELETE `/api/breeds/1/`     | `05_breeds_DELETE.png`              |
| 6 | POST `/api/dogs/`           | `06_dogs_POST.png`                  |
| 7 | GET `/api/dogs/` (list)     | `07_dogs_GET_list.png`              |
| 8 | GET `/api/dogs/1/`          | `08_dogs_GET_detail.png`            |
| 9 | PUT `/api/dogs/1/`          | `09_dogs_PUT.png`                   |
| 10| DELETE `/api/dogs/1/`       | `10_dogs_DELETE.png`                |

`scripts/capture_screenshots.py` regenerates the screenshots with Playwright
(`pip install playwright && playwright install chromium`, then
`python scripts/capture_screenshots.py screenshots` while the server is running).
