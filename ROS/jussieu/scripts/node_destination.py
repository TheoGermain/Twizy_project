#!/usr/bin/env python

import rospy
import sys
from std_msgs.msg import Int32

liste_tour = range(12,17) + range(22,27) + range(32,35) + range(42,47) + range(53,57) + range(65,67)

def node_destination() :
    dest = 0;
    rospy.init_node('node_destination', anonymous=True)
    pub = rospy.Publisher('current_destination', Int32, queue_size=10)
    rate = rospy.Rate(1)
    while not rospy.is_shutdown():

        print(liste_tour)
        dest = input("Enter a destination: ")
        if(dest not in liste_tour) :
            print("\nWRONG DESTINATION\n")

        rospy.loginfo(dest)
        pub.publish(dest)
        rate.sleep()
    rospy.spin()

if __name__ == '__main__':
    node_destination()
