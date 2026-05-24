from rest_framework import generics, permissions
from rest_framework_simplejwt.views import TokenObtainPairView

from .models import User
from .serializers import LoginSerializer, UserSerializer


class LoginView(TokenObtainPairView):
    """POST /api/auth/login/ -> { access, refresh, user }"""

    serializer_class = LoginSerializer


class MeView(generics.RetrieveAPIView):
    """GET /api/auth/me/ -> { id, name, email, role }"""

    serializer_class = UserSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_object(self) -> User:
        return self.request.user
