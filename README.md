knife-ec2-enable-detailed-monitoring
====================================

knife-enable-ec2-monitoring is a knife plugin to enable detailed monitoring for a EC2 instance.
It takes instance-id or chef node name for enabling monitoring. Default region of the instance it takes is US-East-1. In order to enable monitoring for a different region use switch -R .

Example:

1) Enable detailed monitoring of instance with chef node name:

   	knife enable ec2 monitoring -N <node name>
	
	 Region is optional over here as chef server gives the actual region of the instance.

2) Enable detailed monitoring of instance with instance id in default region i.e. us-east-1:

   	knife enable ec2 monitoring -I <instance id>
	 
	 Default region that this plugin assumes is us-east-1. So, if the instance is in us-east-1 then it will enable it's monitoring else it will fail.

3) Enable detailed monitoring of instance with instance id in any region:
   
	 knife enable ec2 monitoring -I <instance id> -R <region> 
	 e.g. region = us-east-1/eu-west-1

4) Enable detailed monitoring of instance with instance id and chef node name: 
   
	 knife enable ec2 monitoring -I <instance id> -N <node name>

	 In this particular usage node name gets the preferance and detailed monitoring is guided by chef search. Instance id becomes redundant. 
	 But if the node name doesn't exist then the instance ID gets the preferance and works as step 3.


   
	 




