#!/usr/bin/env python

import rospy
from geometry_msgs.msg import Twist
from std_msgs.msg import Int32
from jussieu.msg import yolo_msg


global curr_dest
speed = Twist()
liste_tour = range(12,17) + range(22,27) + range(32,35) + range(42,47) + range(53,57) + range(65,67)

def change_dest(data) :
    global curr_dest
    if data in liste_tour :
        curr_dest = data

def callback(data) :
    # Compléter avec les prises de décisions :

    # La variable data est de type yolo_msg, et contient les informations relatives
    # à la détections des pancartes.

    # La variable speed est de type Twist et doit être remplie en accord avec les décisions
    # pour atteindre la destination (variable curr_dest)



def node_decision() :
    rospy.init_node('node_decision', anonymous=True)
    rospy.Subscriber('topic_sortie_yoloV3', yolo_msg, callback)
    rospy.Subscriber('current_destination', Int32, change_dest)
    pub = rospy.Publisher('cmd_vel', Twist, queue_size=10)
    rate = rospy.Rate(10)
    while not rospy.is_shutdown():
        rospy.loginfo(speed)
        pub.publish(speed)
        rate.sleep()
    rospy.spin()

if __name__ == '__main__':
    node_decision()
