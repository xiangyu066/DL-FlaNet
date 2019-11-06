# -*- coding: utf-8 -*-
"""
Created on Thu Oct 24 15:38:58 2019

@author: XYZ2
"""

#%%
import os
import glob
import numpy as np
from keras.preprocessing.image import  img_to_array, load_img


dict_labels = {"nonFlagellated":0, "Flagellated":1}
size = (128,128)
nFrames = 6154

for folders in glob.glob("testImages/*"):
#for folders in glob.glob("trainingImages/*"):
    print(folders)
    images=[]
    labels_hot=[]
    labels=[]
    nFrame=1
    for filename in os.listdir(folders):
        if nFrame <= nFrames:
            label = os.path.basename(folders)
            className = np.asarray(label)
            img=load_img(os.path.join(folders,filename),color_mode = "grayscale")
            if img is not None:
                if label is not None:
                    labels.append(className)
                    labels_hot.append(dict_labels[label])
                x=img_to_array(img)
                images.append(x)
            nFrame+=1
    images=np.array(images)    
    labels_hot=np.array(labels_hot)
    print("images.shape={}, labels_hot.shape=={}".format(images.shape, labels_hot.shape))    
    imagesavepath='testImages_npy/'
    #imagesavepath='trainingImages_npy/'
    if not os.path.exists(imagesavepath):
        os.makedirs(imagesavepath)
    np.save(imagesavepath+'{}_images.npy'.format(label),images)    
    np.save(imagesavepath+'{}_label.npy'.format(label),labels)    
    np.save(imagesavepath+'{}_labels_hot.npy'.format(label),labels_hot)
    print('{} files has been saved.'.format(label))
