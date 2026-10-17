from rest_framework.routers import DefaultRouter

from .views import BreedViewSet, DogViewSet

router = DefaultRouter()
router.register(r"dogs", DogViewSet, basename="dog")
router.register(r"breeds", BreedViewSet, basename="breed")

urlpatterns = router.urls
