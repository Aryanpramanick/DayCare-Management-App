from rest_framework import serializers
from .models import Parent, Child, Activity, DayCareWorker, Attendance, DayPlan

class ParentSerializer(serializers.ModelSerializer):
    class Meta:
        model = Parent
        fields = ('id','firstname', 'lastname','user')

class DayCareserializer(serializers.ModelSerializer):
    class Meta:
        model = DayCareWorker
        fields = ('id','firstname', 'lastname','user')
        
class ChildSerializer(serializers.ModelSerializer):
    class Meta:
        model = Child
        fields = ('id', 'firstname','lastname', 'dob', 'share_permissions', 'parent', 'dayCareWorker')
        
class ActivitySerializer(serializers.ModelSerializer):
    class Meta:
        model = Activity
        fields = ('id', 'title', 'time', 'file', 'description', 'dayCareWorker', 'taggedChildrenID',"likedParentID")

class AttendanceSerializer(serializers.ModelSerializer):
    class Meta:
        model = Attendance
        fields = ('id', 'worker', 'child', 'time', 'present')
        
class DayPlanSerializer(serializers.ModelSerializer):
    date = serializers.DateField(format="%Y-%m-%d")
    startTime = serializers.TimeField(format="%H:%M:%S")
    endTime = serializers.TimeField(format="%H:%M:%S")
    
    class Meta:
        model = DayPlan
        fields = ('id', 'date', 'dayCareWorker','note', 'title','startTime','endTime',"tabColor")
        
    def validate(self, data):
        if data['startTime'] >= data['endTime']:
            raise serializers.ValidationError("End time must be greater than start time.")
        return data
