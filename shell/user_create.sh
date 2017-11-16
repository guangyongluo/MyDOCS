password="WangLuo7"

groupadd -g 1000 dasadm1
groupadd -g 1001 db2fadm1
groupadd -g 1002 db2iadm1
useradd -m -u 1000 -g dasadm1 dasusr1
useradd -m -u 1001 -g db2fadm1 db2fenc1
useradd -m -u 1002 -g db2iadm1 db2inst1
useradd -m -u 810 -g db2iadm1 essc
useradd -m -u 811 -g db2iadm1 ssb
echo $password | passwd --stdin essc
echo $password | passwd --stdin ssb