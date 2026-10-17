from rest_framework import viewsets

from .models import Breed, Dog
from .serializers import BreedSerializer, DogSerializer


class BreedViewSet(viewsets.ModelViewSet):
    """
    Provides list, create, retrieve, update, partial_update and destroy
    for Breed records at /api/breeds/ and /api/breeds/<id>/.
    """

    queryset = Breed.objects.all()
    serializer_class = BreedSerializer


class DogViewSet(viewsets.ModelViewSet):
    """
    Provides list, create, retrieve, update, partial_update and destroy
    for Dog records at /api/dogs/ and /api/dogs/<id>/.
    """

    queryset = Dog.objects.all()
    serializer_class = DogSerializer
