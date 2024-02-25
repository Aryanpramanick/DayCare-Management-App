from django.test import TestCase
from chat.models import Message
from django.contrib.auth.models import User

class TestMessageClass(TestCase):
    def setUp(self):
        User.objects.create(username="johndoe")
        User.objects.create(username="janedoe")
        Message.objects.create(sender=User.objects.get(username="johndoe"),
                                receiver=User.objects.get(username="janedoe"),
                                content="Test Message")

    def test_message_str(self):
        message = Message.objects.get(content="Test Message")
        self.assertEqual(str(message), "Test Message")
