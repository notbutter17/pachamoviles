from rest_framework import viewsets

from .models import Room
from .serializers import RoomSerializer


class RoomViewSet(viewsets.ReadOnlyModelViewSet):
    """
    Sprint 2 (controlled): list (HU20) and detail (HU21) only.
    GET /api/rooms/        -> list
    GET /api/rooms/{id}/   -> detail
    """

    queryset = Room.objects.all()
    serializer_class = RoomSerializer
