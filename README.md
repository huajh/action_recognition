# Action recognition
 
@author: Junhao Hua

Action Recognition & Categories via Spatial-Temporal Features

This project is mainly based on Prior Dollar's work: 

Dollár, Piotr, et al. "Behavior recognition via sparse spatio-temporal features." Visual Surveillance and Performance Evaluation of Tracking and Surveillance, 2005. 2nd Joint IEEE International Workshop on. IEEE, 2005.

## toolbox

 http://vision.ucsd.edu/~pdollar/toolbox/doc/index.html

Runing MyDemo.m

## Feature Extraction

1. set is_Feature_extract = 1, remove comment

	conv_movies2clips
	featuresLGdetect
	featuresLGpca
	featuresLGdesc
	
	get and save DATASETSprLG.mat

## Classificaton

2. If you just want to test a video sample using KNN or SVM, try

(1) set is_SingleAction_train = 1

(2) then, is_SingleAction_Recog = 1

a) knn
b) or svm
	
3. If you want to test all video samples

 (1)   using knn, set is_Action_knn_Classif = 1

 (2)or using svm, set is_Action_svm_Classif = 1
 
4. if you want to use voting methods

 (1) if just test a video sample, 
	set isCreateCodeBook = 1 
	set is_vote_Action_Recog = 1

(2) if test all sample,
	set is_vote_recog_test = 1


## DATASET format

Some DATASETS can be downloaded from [Baidu Cloud](https://pan.baidu.com/s/1c2vSYw4) [(数据集百度云下载)](https://pan.baidu.com/s/1c2vSYw4).

Weizmann human action dataset 

(download from : http://www.wisdom.weizmann.ac.il/~vision/SpaceTimeActions.html )


set00/

	ira_walk.avi
	
	moshe_jump.avi
	
	moshe_run.avi
	
	...
	after running feature extraction, following data generated
	
	clip_ira_walk.mat
	
	cuboids_ira_walk.mat
	
	features_ira_walk.mat
	
	...
set01/

set02/

...

set08/

file directory setting
-----
	TestDir.m
	OutputDir.m
	datadir.m

