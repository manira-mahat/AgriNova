from django.core.management.base import BaseCommand
from authentication.models import CustomUser


class Command(BaseCommand):
    help = 'Create admin user bejati@admin.com with password Bejati@123'

    def handle(self, *args, **options):
        email = 'bejati@admin.com'
        username = 'bejati_admin'
        password = 'Bejati@123'

        # Check if user already exists
        if CustomUser.objects.filter(email=email).exists():
            self.stdout.write(self.style.WARNING(f'User {email} already exists'))
            return

        # Create the user
        user = CustomUser.objects.create_user(
            username=username,
            email=email,
            password=password,
            first_name='Bejati',
            last_name='Admin',
            is_staff=True,
            is_superuser=True
        )

        self.stdout.write(self.style.SUCCESS(f'Successfully created admin user: {email}'))
        self.stdout.write(self.style.SUCCESS(f'Username: {username}'))
        self.stdout.write(self.style.SUCCESS(f'Password: {password}'))
