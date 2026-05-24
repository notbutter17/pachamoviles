from django.db import models


class Room(models.Model):
    """
    Hotel room. Field naming mirrors the existing web backend
    (numero, nombre, tipo, capacidad, precio_base, size_m2, camas, estado).
    """

    class Tipo(models.TextChoices):
        SIMPLE = "simple", "Simple"
        DOBLE = "doble", "Doble"
        MATRIMONIAL = "matrimonial", "Matrimonial"
        TRIPLE = "triple", "Triple"
        CUADRUPLE = "cuadruple", "Cuádruple"

    class Estado(models.TextChoices):
        DISPONIBLE = "disponible", "Disponible"
        OCUPADA = "ocupada", "Ocupada"
        MANTENIMIENTO = "mantenimiento", "Mantenimiento"

    numero = models.CharField(max_length=10, unique=True)
    nombre = models.CharField(max_length=100)
    tipo = models.CharField(max_length=20, choices=Tipo.choices)
    capacidad = models.PositiveIntegerField(default=1)
    precio_base = models.DecimalField(max_digits=10, decimal_places=2)
    size_m2 = models.PositiveIntegerField(null=True, blank=True)
    camas = models.CharField(max_length=100, blank=True)
    estado = models.CharField(
        max_length=20, choices=Estado.choices, default=Estado.DISPONIBLE
    )
    descripcion = models.TextField(blank=True)
    imagen = models.URLField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = "habitaciones"
        ordering = ["numero"]
        verbose_name = "habitación"
        verbose_name_plural = "habitaciones"

    def __str__(self) -> str:
        return f"{self.numero} · {self.nombre}"
