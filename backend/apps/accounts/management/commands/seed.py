"""Seed demo staff users and rooms so the mobile app has real data."""
from decimal import Decimal

from django.core.management.base import BaseCommand

from apps.accounts.models import User
from apps.rooms.models import Room


DEMO_USERS = [
    {"email": "admin@pachasuite.com", "name": "Ana Quispe", "role": User.Role.ADMIN, "password": "admin123"},
    {"email": "recepcion@pachasuite.com", "name": "Luis Mamani", "role": User.Role.RECEPCIONISTA, "password": "recepcion123"},
]

DEMO_ROOMS = [
    {"numero": "101", "nombre": "Suite Titicaca", "tipo": Room.Tipo.MATRIMONIAL, "capacidad": 2,
     "precio_base": Decimal("180.00"), "size_m2": 32, "camas": "1 King", "estado": Room.Estado.DISPONIBLE,
     "descripcion": "Vista panorámica al lago, cama king y bañera de inmersión."},
    {"numero": "102", "nombre": "Suite Inca", "tipo": Room.Tipo.DOBLE, "capacidad": 3,
     "precio_base": Decimal("140.00"), "size_m2": 28, "camas": "2 Queen", "estado": Room.Estado.OCUPADA,
     "descripcion": "Decoración andina contemporánea con balcón y coffee bar."},
    {"numero": "103", "nombre": "Suite Andina", "tipo": Room.Tipo.SIMPLE, "capacidad": 1,
     "precio_base": Decimal("90.00"), "size_m2": 20, "camas": "1 Queen", "estado": Room.Estado.DISPONIBLE,
     "descripcion": "Acogedora habitación individual con escritorio y vista al jardín."},
    {"numero": "201", "nombre": "Suite Familiar Uros", "tipo": Room.Tipo.CUADRUPLE, "capacidad": 4,
     "precio_base": Decimal("240.00"), "size_m2": 44, "camas": "2 Queen + 1 Sofá", "estado": Room.Estado.MANTENIMIENTO,
     "descripcion": "Amplia suite familiar con sala de estar y vista a la cordillera."},
    {"numero": "202", "nombre": "Suite Taquile", "tipo": Room.Tipo.TRIPLE, "capacidad": 3,
     "precio_base": Decimal("160.00"), "size_m2": 30, "camas": "1 King + 1 Twin", "estado": Room.Estado.DISPONIBLE,
     "descripcion": "Suite cálida con detalles textiles típicos de la isla Taquile."},
]


class Command(BaseCommand):
    help = "Crea usuarios y habitaciones de demostración"

    def handle(self, *args, **options):
        for data in DEMO_USERS:
            password = data.pop("password")
            user, created = User.objects.get_or_create(
                email=data["email"], defaults=data
            )
            if created:
                user.set_password(password)
                user.save()
                self.stdout.write(self.style.SUCCESS(f"Usuario creado: {user.email} / {password}"))
            else:
                self.stdout.write(f"Usuario ya existe: {user.email}")

        for data in DEMO_ROOMS:
            room, created = Room.objects.get_or_create(
                numero=data["numero"], defaults=data
            )
            status = "creada" if created else "ya existe"
            self.stdout.write(f"Habitación {room.numero} {status}")

        self.stdout.write(self.style.SUCCESS("Seed completado."))
