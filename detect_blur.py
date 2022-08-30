# import the necessary packages
from pyimagesearch.blur_detector import detect_blur_fft
import numpy as np
import argparse
import imutils
import cv2
# construct the argument parser and parse the arguments
ap = argparse.ArgumentParser()
ap.add_argument("-i", "--image", type=str, required=True,
	help="path input image that we'll detect blur in")
ap.add_argument("-t", "--thresh", type=int, default=20,
	help="threshold for our blur detector to fire")
ap.add_argument("-v", "--vis", type=int, default=-1,
	help="whether or not we are visualizing intermediary steps")
ap.add_argument("-d", "--test", type=int, default=-1,
	help="whether or not we should progressively blur the image")
args = vars(ap.parse_args())