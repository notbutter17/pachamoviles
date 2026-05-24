from rest_framework import serializers

from .models import Room


class RoomSerializer(serializers.ModelSerializer):
    precioBase = serializers.DecimalField(
        source="precio_base", max_digits=10, decimal_places=2
    )
    sizeM2 = serializers.IntegerField(source="size_m2", allow_null=True)

    class Meta:
        model = Room
        fields = (
            "id",
            "numero",
            "nombre",
            "tipo",
            "capacidad",
            "precioBase",
            "sizeM2",
            "camas",
            "estado",
            "descripcion",
            "imagen",
        )
