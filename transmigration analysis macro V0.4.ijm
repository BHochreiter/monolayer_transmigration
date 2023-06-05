//automated cell layer migration macro
//version 0.4 by Bernhard Hochreiter
//##################################################################

//change the following values to modify the analysis parameters

batchanalysis=false;	// measure opened single image or folder ('true' or 'false')
targetfolder="C:\\Users\\User\\Desktop\\ImageJ_Results\\"	//target folger for batch mode results (put 'false' to get selection box)

manual_add_ROI=false;	//manually add ROIs to analysis ('true' or 'false', not available in batch analysis)
attend_results=false;	//attend results or clear results before measurement ('true' or 'false')
keep_orig_open=true;	//keep the original image open after analysis ('true' or 'false')

Obj_size="100";			//minimal object size for cell detection
circularity="0.7";		//minimal circularity for cell detection (0-1)

dilations="4";			//number of dilations during cell detection
erosions="2";			//number of erosions during cell detection

FoBP_thresh="0.85";		//Fraction of bright pixels cutoff for cell categorization (0-1)

//#################################################################
//#################################################################

//Version History
//08.02.2022 - v0.1 - test and generation of first routines
//16.02.2022 - v0.2 - combined cell detection and analysis
//22.02.2022 - v0.3 - included batch mode
//04.03.2022 - v0.4 - improved FoBP analysis and documentation

//#################################################################
//#################################################################
//start
run("Set Measurements...", "area mean min centroid median redirect=None decimal=3");

if(batchanalysis==true){
	manual_add_ROI=false;
	keep_orig_open=false;

	if(attend_results==0){
		run("Clear Results");
	}

	setBatchMode(true);
	source=getDirectory("Choose an Input Directory");
	if(targetfolder==false){
		targetfolder=getDirectory("Choose a Results-Directory");		
	}
	
	fileList=getFileList(source);
	for (i = 0; i < fileList.length; i++) {
		open(source+fileList[i]);
		title_out=getTitle();
		title_out2=replace(title_out, ".tif", "_analyzed.tif");
		analysis();
	saveAs("Tiff", targetfolder+title_out2);
	close();
	}
	selectWindow("Results");
	saveAs("Results", targetfolder+"Results.txt");
	setBatchMode(false);
}
else{
	if(attend_results==0){
		run("Clear Results");
	}
	analysis();
}

//#################################################################
//#################################################################

function analysis() { 
setBatchMode(true);
//##########################################
//clear rois
if(roiManager("count")>0){
	roiManager("Deselect");
	roiManager("Delete");
}

//#########################################
//preamble
title=getTitle();
title1=replace(title, ".tif", "");
rename("image");

//########################################
//background correct
run("Duplicate...", "title=bg");
run("Gaussian Blur...", "sigma=40");
getStatistics(area, mean, min, max, std, histogram);
run("32-bit");
run("Divide...", "value="+max);
imageCalculator("Divide create", "image","bg");
selectWindow("Result of image");
rename("image_corr");
close("bg");

//#######################################
//detect cells
run("Duplicate...", "title=thr1");
run("Enhance Contrast...", "saturated=2");
setAutoThreshold("MaxEntropy dark");
run("Convert to Mask");
for (i = 0; i < dilations; i++) {
	run("Dilate");
	run("Fill Holes");
}
for (i = 0; i < erosions; i++) {
	run("Erode");
}
run("Watershed");
run("Analyze Particles...", "size="+Obj_size+"-Infinity circularity="+circularity+"-1.00 add");
close("thr1");

selectWindow("image_corr");

//#############################################
//manual detection
if(manual_add_ROI==true){
	roiManager("Show All");
	setTool("freehand");
	waitForUser("You can now manually add and remove Cells in the ROI manager. \n -> Circle cell and press (t) to add to ROI manager.\n -> Remove ROIs manually from ROI manager by selecting and deleting. \n \nPress OK when you are finished");
	roiManager("Show None");
	run("Select None");
}

//##############################################
//FoBP map creation
run("Duplicate...", "title=thr2");

run("Select None");
run("Select All");
median=getValue("Median");
setThreshold(median, 65535);
run("Convert to Mask");

//##############################################
//FoBP measurement

selectWindow("image_corr");
for (i = 0; i < roiManager("count"); i++) {
	selectWindow("image_corr");
	roiManager("Select", i);
	run("Measure");
	selectWindow("thr2");
	roiManager("Select", i);
	getStatistics(area, mean, min, max, std, histogram);
	FoBP=mean/255;
	setResult("FoBP", nResults-1, FoBP);
	setResult("title", nResults-1, title);
	selectWindow("image_corr");
	roiManager("Select", i);
	if(FoBP>FoBP_thresh){setForegroundColor(255, 0, 0);}
	if(FoBP<FoBP_thresh){setForegroundColor(0, 255, 0);}
	run("Draw");
}

//################################################
//Cello markings
selectWindow("image_corr");
run("RGB Color");
for (i = 0; i < roiManager("count"); i++) {
	selectWindow("thr2");
	roiManager("Select", i);
	getStatistics(area, mean, min, max, std, histogram);
	FoBP=mean/255;
	selectWindow("image_corr");
	roiManager("Select", i);
	if(FoBP>FoBP_thresh){setForegroundColor(255, 0, 0);}
	if(FoBP<FoBP_thresh){setForegroundColor(0, 255, 0);}
	run("Draw");
}

close("thr2");
selectWindow("image");
rename(title);
selectWindow("image_corr");
rename(title+"_analyzed");
run("Select None");
if(keep_orig_open==false){
	close(title);
}
setBatchMode(false);
}



