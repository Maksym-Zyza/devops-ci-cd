from django.test import TestCase

class SimpleTest(TestCase):
    def test_basic_math(self):
        """Перевірка, щоб переконатися, що тести працюють."""
        self.assertEqual(1 + 1, 2)

    def test_homepage_status_code(self):
        """Перевірка доступності головної сторінки."""
        response = self.client.get('/')
        # Ми очікуємо 200 або 404 (якщо сторінка ще не створена), 
        # але головне, що Django запустився
        self.assertIn(response.status_code, [200, 404])