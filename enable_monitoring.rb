class Chef
	class Knife
		class EnableEc2Monitoring < Knife
			deps do
				require 'chef/api_client'
				require 'chef'
				require 'chef/node'
				require 'chef/knife'
				require 'aws-sdk'
				require 'chef/search/query'
				require 'chef/knife/search'
			end
			banner "knife enable ec2 monitoring (options)"
			
			option :chef_nodename,
				:short => "-N chef_node_name",
				:long => "--chef-node-name chef_node_name",
				:description => "Node name whose monitoring is to be enabled",
				:default => "",
				:proc => Proc.new { |chef_node_name| Chef::Config[:knife][:chef_nodename] = chef_node_name }	

			option :instance_id,
				:short => "-I instance_id",
				:long => "--instance-id instance ID",
				:description => "Instance ID of the node",
				:default => "",
				:proc => Proc.new { |instance_id| Chef::Config[:knife][:instance_id] = instance_id }	

			option :aws_access_key_id,
				:short => "-K aws_key_id",
				:long => "--aws-access-key-id AWS_key_id",
				:description => "AWS access key id",
				:default => "#{Chef::Config[:knife][:aws_access_key_id]}",
				:proc => Proc.new { |aws| Chef::Config[:knife][:aws_access_key_id] = aws }	
			
			option :region,
				:short => "-R Instance's region",
				:long => "--instance-region",
				:description => "AWS region of instance e.g. us-east-1. Default is us-east-1",
				:default => "us-east-1",
				:proc => Proc.new { |region| Chef::Config[:knife][:instance_region] = region }
			
			option :aws_secret_access_key,
				:short => "-S secret-key",
				:long => "--aws-secret-access-key AWS_secret_key",
				:description => "AWS secret access key",
				:default => "#{Chef::Config[:knife][:aws_secret_access_key]}",
				:proc => Proc.new { |access| Chef::Config[:knife][:aws_secret_access_key] = access }	
			
			def validate
				node_name = Chef::Config[:knife][:chef_nodename]
        instance_id = Chef::Config[:knife][:instance_id]
        region = Chef::Config[:knife][:instance_region]
				if node_name.nil?
					if instance_id.nil?
						ui.error("Both Chef Node name and instance id are nil!! Expecting at least one of them")
						return [false]
					else
					  ui.warn("Node name nil not instance_id")
						return [true,region,instance_id]
					end
				else
					if instance_id.nil?
						ui.warn("Node name not nil and instance_id nil")	
						puts "Output:: #{get_region_instance_id(node_name)}"
						if get_region_instance_id(node_name).length == 0
							ui.error("Node name doesn't exist!!")
							return [false]
						end
					else
						ui.warn("Node name and instance ID is there")	
						if get_region_instance_id(node_name).length == 0 
							ui.error("#{node_name} doesn't exist")
							ui.warn("Instance ID will get the preferance")
							return [true,region,instance_id]
						else
							return get_region_instance_id(node_name)	
						end
					end
				end
			end
			
			def get_region_instance_id(chef_node_name)
				q = Chef::Search::Query.new
				srch = q.search(:node, "name:#{chef_node_name}")
				begin
					region = srch[0][0]['ec2']['placement_availability_zone']
					instance_id  = srch[0][0]['ec2']['instance_id']
					region[ region.length - 1] = ''
					return [true,region, instance_id]
				rescue
					return []
				end
			end

			def enable_detailed_montoring(region,instance_id)
				begin
				AWS.config(:access_key_id => Chef::Config[:knife][:aws_access_key_id],:secret_access_key => Chef::Config[:knife][:aws_secret_access_key])
				AWS.memoize do 
					ec2 = AWS::EC2.new(:region => region)
					aws_obj = ec2.instances[instance_id]
					if aws_obj.monitoring.eql?:disabled 
					    aws_obj.enable_monitoring 
					end
					return true
				end
				rescue Exception => e
					ui.error (e)
					ui.error("Either instance:: #{instance_id} doesn't exist or instance doesn't exist in region #{region}")
					return false
				end
			end

			def run
				node_name = Chef::Config[:knife][:chef_nodename]
				instance_id = Chef::Config[:knife][:instance_id]
				region = Chef::Config[:knife][:instance_region]
				valid_return =  validate
				valid = valid_return[0]
				region_of_instance = valid_return[1]
				instance_id_to_monitor = valid_return[2]
				puts valid
				if valid
					puts "Running enabling ec2 monitoring for instance_id :: #{instance_id_to_monitor} in region #{region_of_instance}"
					puts "Node:: #{node_name}, region:: #{region_of_instance}, instance_id :: #{instance_id_to_monitor}"
				  status = enable_detailed_montoring(region_of_instance,instance_id_to_monitor)	
					status ? ui.info("Detailed monitoring for instance_id :: #{instance_id_to_monitor} in region #{region_of_instance} completed") : ui.error("Detailed monitoring for instance_id :: #{instance_id_to_monitor} in region #{region_of_instance} failed !!")
				else
					puts "Invalid"
					show_usage
				end
			end
		end
	end
end

