import os
import boto3

# global variable which is used to track all the region data
regions = []

def main(sess):
	'''
		:param sess: the aws session variable
		main is the main entrypoint into the script and is responsible for deleting the unused ebs volumes/amis
	'''

	try:
		delete_ebs_volumes(sess)
		delete_unused_amis(sess)
	except Exception as e:
		print(e)
		os.exit(1)

def delete_unused_amis(sess):
	'''
	:param sess: the aws session variable
	delete_unused_amis is responsible for removing all unused amis. This is accomplished by first getting all the amis that were created by the account.
	Afterwards, the amis for each ec2 instance are checked. If there are any amis that are created by the account and NOT associated with an ec2 instance, they are deleted.
	'''

	print('Deleting unused amis')
	# create a list which will contain a dictionary
	# The key will be the ami (this should always be a unique string), and the value will be the region (region is required when deleting)
	try:
		amis = []
		for region in regions:
			ec2 = sess.client('ec2', region_name=region)
			for image in ec2.describe_images(Owners=['self'])["Images"]:
				amis.append({image['ImageId']: region})
	except Exception as e:
		print('failed to get the ec2 instances')
		return e

	# amis_in_use is a variable which will be used to count the amis that are in use and increment them
	try:
		amis_in_use = {}
		for region in regions:
			ec2 = sess.client('ec2', region_name=region)

			# Loop through each instance, and create a running total for the amis that are being used
			response = ec2.describe_instances()
			for reservation in response["Reservations"]:
				for instance in reservation["Instances"]:

					image_id = instance["ImageId"]
					# increment the amis_in_use dictionary every time an ami is used
					# these amis may not be amis that we have created, but still need to be incremented
					if not image_id in amis_in_use:
						amis_in_use[image_id] = 1
					else:
						amis_in_use[image_id] += 1
	except Exception as e:
		print('failed to get the amis in use')
		return e

	# now that we have the amis in use, loop through the ami list that we built earlier
	# and delete any unused amis
	try:
		for ami in amis:
			for k, v in ami.items():
				if not k in amis_in_use:
					print(f'Deleting {k}')
					ec2 = sess.client('ec2', region_name=v)
					ec2.deregister_image(ImageId=k)
	except Exception as e:
		print('failed to delete ami')
		return e

def delete_ebs_volumes(sess):
	'''
	:param sess: the aws session variable
	delete_ebs_volumes deletes all volumes that are not in use by checking the attachments
	'''

	print('Deleting unused ebs volumes')

	try:
		volumes = []
		for region in regions:
			ec2 = sess.resource('ec2', region_name=region)
			volumes.append(ec2.volumes.all())
	except Exception as e:
		print('failed to get all volumes')
		return e

	try:
		volumes_to_terminate = []
		for volume_collection in volumes:
			for volume in volume_collection.all():
				if len(volume.attachments) == 0:
					volumes_to_terminate.append(volume)
	except Exception as e:
		print('failed to get volume attachments')
		return e

	# loop through the
	try:
		for volume in volumes_to_terminate:
			print(f'Deleting volume {volume.id}')
			volume.delete()
	except Exception as e:
		print('failed to delete volumes')
		return e



if __name__ == "__main__":
	AWS_ACCESS_KEY_ID = os.getenv('AWS_ACCESS_KEY_ID')
	AWS_SECRET_ACCESS_KEY= os.getenv('AWS_SECRET_ACCESS_KEY')
	AWS_REGION = os.getenv('AWS_REGION', "us-east-2")

	if AWS_ACCESS_KEY_ID is None or AWS_ACCESS_KEY_ID == "":
		print('AWS_ACCESS_KEY_ID is a required environment variable')
		os.exit(1)

	if AWS_SECRET_ACCESS_KEY is None or AWS_SECRET_ACCESS_KEY == "":
		print('AWS_SECRET_ACCESS_KEY is a required environment variable')
		os.exit(1)

	sess = boto3.Session(
		aws_access_key_id= AWS_ACCESS_KEY_ID,
		aws_secret_access_key=AWS_SECRET_ACCESS_KEY,
		region_name=AWS_REGION,
	)

	# variable to store all the regions for the tasks at hand
	ec2_instance = sess.client('ec2')
	response = ec2_instance.describe_regions()
	for reg in response['Regions']:
		regions.append(reg.get("RegionName"))

	main(sess)
