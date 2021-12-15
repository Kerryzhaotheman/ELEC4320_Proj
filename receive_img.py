import matplotlib.image as mpimg
import matplotlib.pyplot as plt
import serial
import cv2
import numpy

# img = mpimg.imread('lena_blackAndWhiteWithNoise.jpeg')
# img = img.reshape(-1)
ser = serial.Serial('COM4', baudrate=9600)
img = ser.read(10000)

img_sq = []
front = 0
back = 100
for rows in range(0, 100):
    img_sq.append(list(img[front:back]))
    front += 100
    back += 100
print(len(img_sq))
print(img_sq)

cv2.namedWindow('lena_blackAndWhiteWithNoise', cv2.WINDOW_NORMAL)
cv2.resizeWindow('lena_blackAndWhiteWithNoise', 400, 400)
cv2.imshow("lena_blackAndWhiteWithNoise", numpy.array(img_sq).astype(numpy.uint8))
cv2.waitKey(0)
