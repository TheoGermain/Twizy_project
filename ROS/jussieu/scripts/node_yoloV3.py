#!/usr/bin/env python
import cv2
import argparse
import numpy as np
import rospy
from jussieu.msg import yolo_msg
from sensor_msgs.msg import Image
from cv_bridge import CvBridge, CvBridgeError

message = yolo_msg()
scale = 0.00392

global prediction_ready

# Instantiate CvBridge
bridge = CvBridge()

# read class names from text file
classes = None
with open('src/jussieu/scripts/classes.txt', 'r') as f:
    classes = [line.strip() for line in f.readlines()]

# generate different colors for different classes
COLORS = np.random.uniform(0, 255, size=(len(classes), 3))

# read pre-trained model and config file
net = cv2.dnn.readNet('src/jussieu/scripts/yolov3_custom_final.weights', 'src/jussieu/scripts/yolov3_custom.cfg')





# function to get the output layer names
# in the architecture
def get_output_layers(net):

    layer_names = net.getLayerNames()

    output_layers = [layer_names[i[0] - 1] for i in net.getUnconnectedOutLayers()]

    return output_layers





# # function to draw bounding box on the detected object with class name
# def draw_bounding_box(img, class_id, confidence, x, y, x_plus_w, y_plus_h):
#
#     label = str(classes[class_id])
#
#     color = COLORS[class_id]
#
#     cv2.rectangle(img=img, pt1=(int(x),int(y)), pt2=(int(x_plus_w),int(y_plus_h)), color=color, thickness=2)
#
#     cv2.putText(img, label, (int(x-10),int(y-10)), cv2.FONT_HERSHEY_SIMPLEX, 0.5, color, 2)






def callback(data) :
    #print("Received an image!")
    try:
        # Convert your ROS Image message to OpenCV2
        image = bridge.imgmsg_to_cv2(data, "bgr8")
    except CvBridgeError, e:
        print(e)
    else:
        # Save your OpenCV2 image as a jpeg
        #cv2.imwrite('/home/theo/camera_image.jpeg', cv2_img)
        Width = data.width
        Height = data.height
        # create input blob
        blob = cv2.dnn.blobFromImage(image, scale, (416,416), (0,0,0), True, crop=False)
        # set input blob for the network
        net.setInput(blob)
        # run inference through the network
        # and gather predictions from output layers
        outs = net.forward(get_output_layers(net))

        # initialization
        class_ids = []
        confidences = []
        boxes = []
        conf_threshold = 0.5
        nms_threshold = 0.4

        # for each detetion from each output layer
        # get the confidence, class id, bounding box params
        # and ignore weak detections (confidence < 0.5)
        for out in outs:
            for detection in out:
                scores = detection[5:]
                class_id = np.argmax(scores)
                confidence = scores[class_id]
                if confidence > conf_threshold:
                    center_x = int(detection[0] * Width)
                    center_y = int(detection[1] * Height)
                    w = int(detection[2] * Width)
                    h = int(detection[3] * Height)
                    x = center_x - w / 2
                    y = center_y - h / 2
                    class_ids.append(class_id)
                    confidences.append(float(confidence))
                    boxes.append([x, y, w, h])

        # apply non-max suppression
        indices = cv2.dnn.NMSBoxes(boxes, confidences, conf_threshold, nms_threshold)

        # go through the detections remaining
        # after nms and draw bounding box
        del message.x[:]
        del message.y[:]
        del message.w[:]
        del message.h[:]
        del message.classes[:]
        for i in indices:
            i = i[0]
            box = boxes[i]
            message.x.append(round(box[0]))
            message.y.append(round(box[1]))
            message.w.append(round(box[2]))
            message.h.append(round(box[3]))
            message.classes.append(class_ids[i])
        global prediction_ready
        prediction_ready = True
            #draw_bounding_box(image, class_ids[i], confidences[i], round(x), round(y), round(x+w), round(y+h))

         # save output image to disk
         #cv2.imwrite("object-detection.jpg", image)

         # release resources
         #cv2.destroyAllWindows()


def node_yoloV3() :
    global prediction_ready
    prediction_ready = False
    rospy.init_node('node_yoloV3', anonymous=True)
    rospy.Subscriber('/camera/rgb/image_raw', Image, callback)
    pub = rospy.Publisher('topic_sortie_yoloV3', yolo_msg, queue_size=10)
    rate = rospy.Rate(10)
    while not rospy.is_shutdown():
        if prediction_ready :
            rospy.loginfo(message)
            pub.publish(message)
            prediction_ready = False
        rate.sleep()
    rospy.spin()

if __name__ == '__main__':
    node_yoloV3()
