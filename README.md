# Offline-to-Online-Conversion-for-Handwritten-Offline-Images-MATLAB
Stroke Recovery of Offline Images is an import topic in the domain of document analysis and recognition. 

The folder 'Data' is contains a handwritten example image that is being converted to a online coordinate sequence for better recognition.

convert.m is the main code for the stroke recovery process.

find_angles.m compute the angles for connected strokes at the junction-points.

This algorithm works find without upper and lower modifiers. On addition of modifiers the sequence of tracking gets a bit confusing due to the left-right tracking logic. A zonal segmentation logic as mentioned in https://arxiv.org/abs/1708.00227 can help solve this problem.

More Details about the implemented concepts are furnished in the the paper :
http://ieeexplore.ieee.org/abstract/document/602037/

A demonstration of the tracking procedure can be found here: https://drive.google.com/open?id=0B-SyYE_cCFMbY0E4WEgtcGZndGs
