from django.core.validators import MaxValueValidator, MinValueValidator
from django.db import models


class Breed(models.Model):
    SIZE_CHOICES = [
        ("Tiny", "Tiny"),
        ("Small", "Small"),
        ("Medium", "Medium"),
        ("Large", "Large"),
    ]
    RATING_VALIDATORS = [MinValueValidator(1), MaxValueValidator(5)]

    name = models.CharField(max_length=100)
    size = models.CharField(max_length=10, choices=SIZE_CHOICES)
    friendliness = models.IntegerField(validators=RATING_VALIDATORS)
    trainability = models.IntegerField(validators=RATING_VALIDATORS)
    sheddingamount = models.IntegerField(validators=RATING_VALIDATORS)
    exerciseneeds = models.IntegerField(validators=RATING_VALIDATORS)

    def __str__(self):
        return self.name


class Dog(models.Model):
    name = models.CharField(max_length=100)
    age = models.IntegerField()
    breed = models.ForeignKey(Breed, related_name="dogs", on_delete=models.CASCADE)
    gender = models.CharField(max_length=20)
    color = models.CharField(max_length=50)
    favoritefood = models.CharField(max_length=100)
    favoritetoy = models.CharField(max_length=100)

    def __str__(self):
        return self.name
