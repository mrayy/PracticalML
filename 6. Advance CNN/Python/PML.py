#Utility script for Practical Machine Learning (PML) class
#Written by: MHD Yamen Saraiji yamen@kmd.keio.ac.jp

 
import tensorflow
from tensorflow import keras
from tensorflow.keras import layers
from tensorflow.keras import models
from tensorflow.keras import optimizers
from tensorflow.keras.utils import plot_model
from tensorflow.keras import regularizers
from tensorflow.keras import utils
from PIL import Image
import pandas as pd
import os
import random
import matplotlib.pyplot as plt
import numpy as np

from sklearn.preprocessing import LabelEncoder

from ipywidgets import IntProgress
from IPython.display import display
import OSCHelper

#dataset load
def load_img_dataset_from_folder(path,target_size=None,shuffle=True,grayscale=True):
    dirs=os.listdir(path)
    labels=[]
    samples=[]
    index=0
    for i,l in enumerate(dirs):
        samples_dir=os.path.join(path,l)
        if not os.path.isdir(samples_dir):
            continue
        labels.append(l)
        samples_paths=os.listdir(samples_dir)
        for s in samples_paths:
            try:
                img=Image.open(os.path.join(samples_dir,s))
                if(grayscale):
                    img=img.convert('L')
                if target_size!=None:
                    img=img.resize(target_size)
                #print("sample loaded",s)
                sample=[np.array(img)/255.,index]
                #if sample[0].shape[2]==3: #make sure its RGB with 3 channels
                samples.append(sample)
                img.close()
            except:
                continue

        index=index+1

    if shuffle:
        random.shuffle(samples)

    for i,l in enumerate(labels):
        samples_count=len([s for s in samples if s[1]==i])
        print("{0}- [{1}] with total of {2} samples".format(i,l,samples_count))
    return np.array(samples),np.array(labels)


## Data capture from OSC


def GetOSCSamples(server,Label,features_names,DeviceID,NumberofSamples):
    GetOSCSamples.sample=[]

    def reset_sample(length):
        GetOSCSamples.sample=list(np.zeros(length))

    GetOSCSamples.features_count=len(features_names)
    reset_sample(GetOSCSamples.features_count)

    GetOSCSamples.progress_bar = IntProgress(min=0, max=NumberofSamples) # instantiate the bar
    display(GetOSCSamples.progress_bar) # display the bar
    def onOSC_data(*args):
        dtype=str(args[0]).split('/')[-1]
        vals=list(args[1:])
        index=-1
        for i,f in enumerate(features_names):
            if dtype==f:
                index=i
        if(index!=-1):
            GetOSCSamples.sample[index]=','.join([str(x) for x in vals])

        if dtype=='deviceinfo':
            GetOSCSamples.sample.append(Label)
            GetOSCSamples.samples.append(GetOSCSamples.sample)
            reset_sample(GetOSCSamples.features_count)
            GetOSCSamples.progress_bar.value = len(GetOSCSamples.samples)
            #print(progress_bar.value)
            index=-1
            if(len(GetOSCSamples.samples)==NumberofSamples):
                server.stop()
                print("done samples")

    server.addMsgHandler("/ZIGSIM/Yamen/*", onOSC_data )
    GetOSCSamples.samples=[]
    OSCHelper.start_server(server)
    server.removeMsgHandler("/ZIGSIM/Yamen/*")

    return GetOSCSamples.samples.copy()


def CollectSamplesOSC(server,features_names,labels,UUID,nPerLabel=200):
    Samples=[]
    for l in labels:
        print("Capturing samples for label: {0}".format(l))
        input("Press Enter to start...")
        subset=GetOSCSamples(server,l,features_names,UUID,nPerLabel)
        Samples.extend(subset)

    print("Total samples count: {0}".format(len(Samples)))
    return Samples

def ExportOSCData(samples,features,path):
    Cols=features.copy()
    Cols.append("Label")
    cwd = os.getcwd()
    path=(os.path.join(cwd,path))
    print(path)
    df=pd.DataFrame(samples,columns=Cols)
    with open(path,"w") as f:
        df.to_csv(f, index=False)



def load_csv_samples(path):
    data=pd.read_csv(path)#load csv data file
    print("Cols of data loaded:")
    print(data.columns.values)

    labelEnc=LabelEncoder()
    labelEnc.fit(data[['Label']].values)
    data['Label']=labelEnc.transform(data[['Label']].values)

    raw=np.array(data.values)

    processed=[]
    samples=[]
    for x in raw:
        sample=[]
        for i in range(len(x)-1):
            sample.extend(x[i].split(','))
        for i in range(len(sample)):
            sample[i]=float(sample[i])
        processed.append(sample)
        label=x[len(x)-1]
        samples.append([sample,label])

    labels=list(labelEnc.classes_)

    return samples,labels
## Preprocessing
def prepare_flatten_samples(samples):
    samples=np.array(samples)
    return samples.reshape(samples.shape[0],-1)

def prepare_conv_samples(samples):
    samples=np.array(samples)
    if len(samples.shape)==3:
        samples=np.expand_dims(samples,axis=3)
    return samples

## Normalization

class Normalizer:
    def Normalize(self,X):
        return X


class NormalizerMeanSTD(Normalizer):
    def __init__(self,mean,std):
        self._mean=mean
        self._std=std
    def Normalize(self,X):
        return (X-self._mean)/self._std

class Normalizer01(Normalizer):
    def __init__(self,min,max):
        self._min=min
        self._max=max
    def Normalize(self,X):
        return (X-self._min)/(self._max-self._min)

def normalize_mean_std(samples):
    mean=(np.mean(samples,axis=0))
    std=(np.std(samples,axis=0))
    return (samples-mean)/std,NormalizerMeanSTD(mean,std)

def normalize_0_1(samples):
    min=(np.min(samples,axis=0))
    max=(np.max(samples,axis=0))
    return (samples-min)/(max-min),Normalizer01(min,max)

def normalize_image(samples):
    min=0
    max=255
    return (samples-min)/(max-min),Normalizer01(min,max)

## Plotting
def plot_random_images(samples,labels,rows,cols,output=""):
    fig=plt.figure(figsize=(cols*2,rows*2))
    for i in range(1,rows*cols+1):
        idx=random.randrange(0,len(samples))
        sample=samples[idx]
        img=sample[0]
        fig.add_subplot(rows,cols,i)
        plt.axis('off')
        plt.title(labels[sample[1]])
        plt.imshow(img,interpolation='nearest',cmap='gray')
    if(output!=""):
        plt.savefig(output, bbox_inches='tight')
    plt.show()


def plot_acc_loss(history,output=""):
    #get training accuracy and error
    acc = history.history['acc']
    val_acc = history.history['val_acc']
    loss = history.history['loss']
    val_loss = history.history['val_loss']

    epochs = range(1, len(acc) + 1)
    # plot accuracy
    plt.plot(epochs, acc, 'b', label='Training acc')
    plt.plot(epochs, val_acc, 'r', label='Validation acc')
    plt.title('Training and validation accuracy')
    plt.legend()
    plt.figure()

    # plot error
    plt.plot(epochs, loss, 'b', label='Training loss')
    plt.plot(epochs, val_loss, 'r', label='Validation loss')
    plt.title('Training and validation loss')
    plt.legend()
    if(output!=""):
        plt.savefig(output, bbox_inches='tight')
    plt.show()

## Visualizing Model

from tensorflow.keras import backend as K


def VisualizeLayerActivation(model,layer_name,count=3,epochs=30):

    def deprocess_image(x):
        x-=x.mean()
        x/=(x.std()+1e-5)
        x*=0.1

        x+=0.5
        x=np.clip(x,0,1)

        x*=255
        x=np.clip(x,0,255).astype('uint8')
        return x

    def generate_pattern(model,layer_name,filter_index,size=224,step=1.,epochs=30):
        layer_output=model.get_layer(layer_name).output
        loss=K.mean(layer_output[:,:,:,filter_index])

        grads=K.gradients(loss,model.input)[0]

        grads/=(K.sqrt(K.mean(K.square(grads)))+1e-5)

        iterate=K.function([model.input],[loss,grads])
        input_img_data=np.random.random((1,size,size,3))*20+128
        for i in range(epochs):
            loss_val,grads_val=iterate([input_img_data])
            input_img_data += grads_val*step

        return deprocess_image(input_img_data[0])

    size=64
    margin=5

    results=np.zeros((count*size+(count-1)*margin,count*size+(count-1)*margin,3))

    for i in range(count):
        for j in range(count):
            index=(j+(i*count))
            img=generate_pattern(model,layer_name,index,size=size,step=1,epochs=epochs)

            x=i*(size+margin)
            y=j*(size+margin)
            results[x:x+size,y:y+size,:]=img

    plt.figure(figsize=(10,10))
    plt.imshow(results.astype('uint8'))


def VisualizeActivations(model,image,last_layer):
    layer_outputs=[layer.output for layer in model.layers[1:last_layer]]
    activation_model=models.Model(inputs=model.input,outputs=layer_outputs)
    activations=activation_model.predict(np.array([image]))


    layer_names=[]
    for layer_name in model.layers:
        layer_names.append(layer_name.name)

    image_per_row=16

    for name,activation in zip(layer_names,activations):
        features=activation.shape[-1]
        size=activation.shape[1]

        cols=features//image_per_row
        display_grid=np.zeros((size*cols,size*image_per_row))

        for col in range(cols):
            for row in range(image_per_row):
                channel_img=activation[0,:,:,col*image_per_row+row]

                channel_img-=channel_img.mean()
                channel_img/=channel_img.std()
                channel_img*=64
                channel_img+=128
                channel_img=np.clip(channel_img,0,255).astype('uint8')
                display_grid[col*size:(col+1)*size, row*size:(row+1)*size]=channel_img


        scale=1./size
        plt.figure(figsize=(scale*display_grid.shape[1],scale*display_grid.shape[0]))
        plt.title(name)
        plt.grid(False)
        plt.imshow(display_grid,aspect='auto')
        plt.show()

## Models
def create_classify_model(input_len,nbclasses,firstLayer,nlayers,dropout=0.2):
    model=models.Sequential()
    model.add(layers.Dense(firstLayer,activation='relu',input_shape=(input_len,)))
    if dropout>0:
        model.add(layers.Dropout(dropout))
    for l in nlayers:
        model.add(layers.Dense(l,activation='relu'))
        if dropout>0:
            model.add(layers.Dropout(dropout))
    model.add(layers.Dense(nbclasses,activation='softmax'))
    model.compile(optimizer='adam',loss='categorical_crossentropy',metrics=['accuracy'])
    model.summary()
    return model


def create_conv_classify_model(input_shape,nbclasses,firstLayer,nlayers,denseLayers,dropout=0.2):
    model=models.Sequential()
    model.add(layers.Conv2D(firstLayer,(3,3),activation='relu',input_shape=input_shape))
    model.add(layers.MaxPooling2D(pool_size=2))
    if dropout>0:
        model.add(layers.Dropout(dropout))
    for l in nlayers:
        model.add(layers.Conv2D(l,(3,3),activation='relu'))
        model.add(layers.MaxPooling2D(pool_size=2))
        if dropout>0:
            model.add(layers.Dropout(dropout))
    model.add(layers.Flatten())
    for l in denseLayers:
        model.add(layers.Dense(l,activation='relu'))
    model.add(layers.Dense(nbclasses,activation='softmax'))
    model.compile(optimizer='adam',loss='categorical_crossentropy',metrics=['accuracy'])
    model.summary()
    return model

def create_regression_model(input_len,nboutputs,firstLayer,nlayers,dropout=0.2):
    model=models.Sequential()
    model.add(layers.Dense(firstLayer,activation='sigmoid',input_shape=(input_len,)))
    if dropout>0:
        model.add(layers.Dropout(dropout))
    for l in nlayers:
        model.add(layers.Dense(l,activation='sigmoid'))
        if dropout>0:
            model.add(layers.Dropout(dropout))
    model.add(layers.Dense(nboutputs,activation='linear'))
    model.compile(optimizer='adam',loss='mse',metrics=['mae'])
    model.summary()
    return model


## Testing
def test_samples(model,samples,labels,trainlabels,normalizer,flatten=True):
    def preprocess_sample(sample,normalizer):
        #normalize values
        if flatten:
            sample=prepare_flatten_samples([sample])[0]# convert to 1D array
        else: sample=prepare_conv_samples([sample])[0]
        sample=normalizer.Normalize(sample) #scale to 0->1 range
        return sample

    total=np.zeros(len(labels))
    err=np.zeros(len(labels))
    for s in samples:

        sample=preprocess_sample(s[0],normalizer)#preprocess test sample
        res=model.predict(np.array([sample]))#predict its label

        total[s[1]]=total[s[1]]+1
        if labels[s[1]] !=trainlabels[np.argmax(res)]:
            err[s[1]]=err[s[1]]+1
            flag="Error"
        else:
            flag="Correct"
        #print("{0} - Original: {1}  Predicted: {2}".format(flag,labels_test[s[1]],labels[np.argmax(res)]))

    for i,e in enumerate(err):
        print("Accuracy for [{0}] is {1}%".format(labels[i], 100-int(100*e/float(total[i]))))
    return err,total


## Export/Import
def export_model(model,path="./model"):
  model_json = model.to_yaml()
  with open(path+".yaml", "w") as json_file:
      json_file.write(model_json)
  # serialize weights to HDF5
  model.save_weights(path+".h5")
  print("Model exported.")

def import_model(path):
    with open(path+".yaml",'r') as f:
        model=models.model_from_yaml(f.read())
    model.load_weights(path+".h5")
    return model
