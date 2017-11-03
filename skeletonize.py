import sys
from skimage.morphology import skeletonize, skeletonize_3d
import scipy.io as sio
import cv2

I = sio.loadmat('I.mat')
I = I['I']
I = skeletonize_3d(I)
sio.savemat('I.mat',{'I':I})