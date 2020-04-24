. /home/izadorozhna/monsrc

mask='check_rt_case'

echo "Starting. Using mask '$mask'"



echo "Delete servers"
for i in `openstack server list | grep $mask | awk '{print $2}'`; do openstack server delete $i; echo deleted $i; done


echo "Delete ports"
for i in `openstack port list | grep $mask | awk '{print $2}'`; do openstack port delete $i; done

echo "Delete Router ports (experimental)"
neutron router-list|grep $mask|awk '{print $2}'|while read line; do echo $line; neutron router-port-list $line|grep subnet_id|awk '{print $11}'|sed 's/^\"//;s/\",//'|while read interface; do neutron router-interface-delete $line $interface; done; done

echo "Delete subnets"
for i in `openstack subnet list | grep $mask | grep -v "tempest_sn" | awk '{print $2}'`; do openstack subnet delete $i; done

echo "Delete nets"
for i in `openstack network list | grep $mask | grep -v "tempest_nw" | awk '{print $2}'`; do openstack network delete $i; done

echo "Delete routers"
for i in `openstack router list | grep $mask | awk '{print $2}'`; do openstack router delete $i; done



echo "Done"

