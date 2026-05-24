from django.contrib import admin

from .models import Room


@admin.register(Room)
class RoomAdmin(admin.ModelAdmin):
    list_display = ("numero", "nombre", "tipo", "estado", "capacidad", "precio_base")
    list_filter = ("estado", "tipo")
    search_fields = ("numero", "nombre")
