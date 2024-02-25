from django.db import models
from django.contrib.auth.models import User
# Create your models here.

class Message(models.Model):
    id = models.AutoField(primary_key=True)
    sender = models.ForeignKey(User, related_name='sender', on_delete=models.PROTECT)
    receiver = models.ForeignKey(User, related_name='receiver', on_delete=models.PROTECT)
    content = models.TextField()
    #isRead = models.BooleanField(default=False)
    timestamp = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.content
    
# class Chat(models.Model):
#     id = models.AutoField(primary_key=True)
#     participants = models.ManyToManyField(User)
#     messages = models.ForeignKey(Message, on_delete=models.CASCADE)
    
#     def __str__(self):
#         return str(self.id)
    