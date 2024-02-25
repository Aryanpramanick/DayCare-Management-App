from django.db import models
from django.contrib.postgres.fields import ArrayField
from django.contrib.auth.models import User
import datetime

# Create your models here.
class Parent(models.Model):
    id = models.AutoField(primary_key=True)
    firstname = models.CharField(max_length=100)
    lastname = models.CharField(max_length=100)
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    
    def __str__(self):
        return self.firstname + " " + self.lastname

    def ParentFromId(id):
        return Parent.objects.get(id=id)
    
class DayCareWorker(models.Model):
    id = models.AutoField(primary_key=True)
    firstname = models.CharField(max_length=100)
    lastname = models.CharField(max_length=100)
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    
    def __str__(self):
        return self.firstname + " " + self.lastname

    def DayCareWorkerFromId(id):
        return DayCareWorker.objects.get(id=id)
    
# Stand alone class child
class Child(models.Model):
    id = models.AutoField(primary_key=True)
    firstname = models.CharField(max_length=100)
    lastname = models.CharField(max_length=100)
    dob = models.DateField(max_length=100)
    share_permissions = models.BooleanField(default=False)
    parent = models.ForeignKey(Parent, related_name='parent', verbose_name="Parent of Child",on_delete=models.PROTECT,null=True,blank=True)
    dayCareWorker = models.ForeignKey(DayCareWorker, related_name='daycareworker', verbose_name="DayCareWorker of Child",on_delete=models.PROTECT, null=True,blank=True)
    
    def __str__(self):
        return self.firstname + " " + self.lastname

# Activity class associated with a dayCareWorker
class Activity(models.Model):
    id = models.AutoField(primary_key=True)
    #TODO: change field name to "title"
    title = models.CharField(max_length=100)
    time = models.DateTimeField(default=datetime.datetime.now)
    file = models.FileField(upload_to='files/', null=True, blank=True)
    description = models.CharField(max_length=110,null=True,blank=True)
    dayCareWorker = models.ForeignKey(DayCareWorker, related_name='assignedWorker', verbose_name="DayCareWorker of Activity",on_delete=models.PROTECT, null=True,blank=True)
    # taggedChildren = models.ManyToManyField(Child)
    taggedChildrenID = ArrayField(models.IntegerField(), blank=True, null=True)
    likedParentID = ArrayField(models.IntegerField(), blank=True, null=True)
    
    def __str__(self):
        return self.title
        
class Attendance(models.Model):
    id = models.AutoField(primary_key=True)
    worker = models.ForeignKey(DayCareWorker, related_name='worker', verbose_name="Worker of Attendance",on_delete=models.PROTECT)
    child = models.ForeignKey(Child, related_name='child', verbose_name="Child of Attendance",on_delete=models.PROTECT)
    time = models.DateTimeField(default=datetime.datetime.now)
    present = models.BooleanField(default=False)
    
    def __str__(self):
        return self.child.firstname + " " + self.child.lastname + " " + str(self.time)
   
# DayPlan class associated with a dayCareWorker
class DayPlan(models.Model):
    id = models.AutoField(primary_key=True)
    date = models.DateField(max_length=100)
    title = models.CharField(max_length=100)
    note = models.CharField(max_length=110,null=True,blank=True)
    dayCareWorker = models.ForeignKey(DayCareWorker, related_name='assignedDayPlanWorker', verbose_name="DayCareWorker of DayPlan",on_delete=models.PROTECT, null=True,blank=True)
    startTime = models.TimeField(default=datetime.time(8, 0, 0),null=False,blank=False)
    endTime = models.TimeField(default=datetime.time(17, 0, 0),null=False,blank=False)
    tabColor = models.IntegerField(default=0)
    
    def __str__(self):
        return str(self.date) + " with " + str(self.dayCareWorker)

