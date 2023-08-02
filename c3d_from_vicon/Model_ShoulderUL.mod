{*Shoulder and Upper Limb Kinematic Model*}
{*Dimitra Blana, May 2015*}

{*Model Model_ShoulderUL.MOD*}
{*Use only with BodyBuilder V. 3.53 or later*}

{*Based on Model_UpperLimb.mod, supplied by Vicon Oxford Metrics Ltd*}


{*--------------------------------------------------------------------------------------------------------*}


{*START OF MACRO SECTION*}

Macro AxesVis(segment,axislength)
{* This macro creates segment axes for display purposes*}
segment#o={0,0,0}*segment 
segment#1={axislength,0,0}*segment
segment#2={0,axislength,0}*segment
segment#3={0,0,axislength}*segment
output (segment#o,segment#1,segment#2,segment#3)
endmacro

{*-------------------------------------------------------------*}

macro REPLACE4(p1,p2,p3,p4)
{*Replaces any point missing from set of four fixed in a segment*}

{*SECTION FOR INITIALISATION OF VIRTUAL POINTS*}
{*REPLACE4*}
s123 = [p2,p1-p2,p2-p3]
p4V1 = Average(p4/s123)*s123
s124 = [p2,p1-p2,p2-p4]
p3V1 = Average(p3/s124)*s124
s134 = [p3,p1-p3,p3-p4]
p2V1 = Average(p2/s134)*s134
s234 = [p3,p2-p3,p3-p4]
p1V1 = Average(p1/s234)*s234

{*SECTION FOR SPECIFICATION OF VIRTUAL POINTS*}
p1 = p1 ? p1V1
p2 = p2 ? p2V1
p3 = p3 ? p3V1
p3 = p3 ? p3V1
p4 = p4 ? p4V1

output(p1,p2,p3,p4)

endmacro

{*-------------------------------------------------------------*}

macro calibratePoint(point,segment)
{*this macro calculates the coordinates of a point (input argument) locally to a segment (input argument) and then stores them in the parameter file of the subject*}

$%#point= point/segment		{*local coordinates calculation. See the operator '/' on the user manual: this operator just operates the coordinate transformation from global to local*}

$%#point#X=$%#point(1)		{*split the local coordinates in three; in order to have BB and WS behaving the same way*}
$%#point#Y=$%#point(2)
$%#point#Z=$%#point(3)

param($%#point#X)		{*Store the local coordinates into the parameter file. See the 'param' command on the user manual*}
param($%#point#Y)		{*it is worth noting that this macro does not write the local virtual point on the c3d file; it just uses it for further needs, such as writing the coordinates on the mp file*}
param($%#point#Z)

param($%#point)			{*For compatibility between BB and PiM*}

endmacro
{*---------------------------------------------------------------------------------------------------*}

macro reconstructPoint(P1,label)
{*This macro reads the local coordinates of the point from the .mp file and then recreates the calibrated virtual point in the global space*}
									{*recreation of the calibrated point P1 (input argument), locally to the label (input argument) segment*}
P1 = $%#P1*label										{*coordinate transformation from local to global*}
OUTPUT(P1)										{*this is the point we want to write on the C3D file*}

endmacro

{*---------------------------------------------------------------------------------------------------*}

macro RotYZY(child,parent,joint)

{*
This macro will calculate three vectors representing the three lines of the 3x3 rotation matrix based
on the XYZ fixed axis BodyBuilder default output (child,parent,XYZ).  It will then use these lines to
recalculate the three angles alpha, beta and gamma which represent the rotations obtained for the Y-Z-Y axis
ordered decomposition of the rotation matrix.  The macro is called using:
RotYZY(childsegment,parentsegment,jointname) (e.g.RotYZY(RightUpperLeg,Pelvis,HIP))
The labels jointnameYZY etc. (e.g. HIPYZY) must be added to the marker file used.
*}

joint#angles=<child,parent,xyz>
joint#alpha=joint#angles(1)
joint#beta=joint#angles(2)
joint#gamma=joint#angles(3)

joint#Rxyz1={cos(joint#beta)*cos(joint#gamma),sin(joint#alpha)*sin(joint#beta)*(cos(joint#gamma))-(cos(joint#alpha)*sin(joint#gamma)),(cos(joint#alpha)*sin(joint#beta)*cos(joint#gamma))+(sin(joint#alpha)*sin(joint#gamma))}
joint#Rxyz2={cos(joint#beta)*sin(joint#gamma),(sin(joint#alpha)*sin(joint#beta)*sin(joint#gamma))+(cos(joint#alpha)*cos(joint#gamma)),(cos(joint#alpha)*sin(joint#beta)*sin(joint#gamma))-(sin(joint#alpha)*cos(joint#gamma))}
joint#Rxyz3={-sin(joint#beta),sin(joint#alpha)*cos(joint#beta),cos(joint#alpha)*cos(joint#beta)}

z = acos(joint#Rxyz2(2))

IF (z>=-180 AND z<0)   {*Only values between 0° and 180°*}
    z = -z
ENDIF

sy = joint#Rxyz3(2)/sin(z)
cy = -joint#Rxyz1(2)/sin(z)
y = atan2(sy,cy)

sysec = joint#Rxyz2(3)/sin(z)
cysec = joint#Rxyz2(1)/sin(z)
ysec = atan2(sysec,cysec)

IF (z==0)     {*IF the first rotation is equal to zero, set the third to zero and suppose the movement has only one comp*}
     y = acos(joint#Rxyz1(1))
     ya = 0
ENDIF

joint#YZY = <y,z,ysec>
output(joint#YZY)

endmacro

{*---------------------------------------------------------------------------------------------------*}

macro RotXZY(child, parent, joint)

joint#angles=<child,parent,xyz>
joint#alpha=joint#angles(1)
joint#beta=joint#angles(2)
joint#gamma=joint#angles(3)

joint#Rxyz1={cos(joint#beta)*cos(joint#gamma),sin(joint#alpha)*sin(joint#beta)*(cos(joint#gamma))-(cos(joint#alpha)*sin(joint#gamma)),(cos(joint#alpha)*sin(joint#beta)*cos(joint#gamma))+(sin(joint#alpha)*sin(joint#gamma))}
joint#Rxyz2={cos(joint#beta)*sin(joint#gamma),(sin(joint#alpha)*sin(joint#beta)*sin(joint#gamma))+(cos(joint#alpha)*cos(joint#gamma)),(cos(joint#alpha)*sin(joint#beta)*sin(joint#gamma))-(sin(joint#alpha)*cos(joint#gamma))}
joint#Rxyz3={-sin(joint#beta),sin(joint#alpha)*cos(joint#beta),cos(joint#alpha)*cos(joint#beta)}

z1 = asin(-(joint#Rxyz1(2)))

sx = joint#Rxyz3(2)/cos(z1)
cx = joint#Rxyz2(2)/cos(z1)
X1 = atan2(sx,cx)

sy = joint#Rxyz1(3)/cos(z1)
cy = joint#Rxyz1(1)/cos(z1)
y1 = atan2(sy,cy)

IF (z1>=0)
     z2 = 180 - z1
ELSE
     z2 = -180 - z1	
ENDIF

sx2 = joint#Rxyz3(2)/cos(z2)
cx2 = joint#Rxyz2(2)/cos(z2)
x2 = atan2(sx2,cx2)

sy2 = joint#Rxyz1(3)/cos(z2)
cy2 = joint#Rxyz1(1)/cos(z2)
y2 = atan2(sy2,cy2)

IF ((-90<=z1) AND (z1<=90))
	x = x1
	y = y1
	z = z1
ELSE
	x = x2
	y = y2
	z = z2
ENDIF

joint#XZY = <x,z,y>
output(joint#XZY)

endmacro

{*---------------------------------------------------------------------------------------------------*}

macro RotXYZ(child, parent, joint)

joint#angles=<child,parent,xyz>
joint#alpha=joint#angles(1)
joint#beta=joint#angles(2)
joint#gamma=joint#angles(3)

joint#Rxyz1={cos(joint#beta)*cos(joint#gamma),sin(joint#alpha)*sin(joint#beta)*(cos(joint#gamma))-(cos(joint#alpha)*sin(joint#gamma)),(cos(joint#alpha)*sin(joint#beta)*cos(joint#gamma))+(sin(joint#alpha)*sin(joint#gamma))}
joint#Rxyz2={cos(joint#beta)*sin(joint#gamma),(sin(joint#alpha)*sin(joint#beta)*sin(joint#gamma))+(cos(joint#alpha)*cos(joint#gamma)),(cos(joint#alpha)*sin(joint#beta)*sin(joint#gamma))-(sin(joint#alpha)*cos(joint#gamma))}
joint#Rxyz3={-sin(joint#beta),sin(joint#alpha)*cos(joint#beta),cos(joint#alpha)*cos(joint#beta)}

y1 = asin(joint#Rxyz1(3))

sz = -joint#Rxyz1(2)/cos(y1)
cz = joint#Rxyz1(1)/cos(y1)
z1 = atan2(sz,cz)

sx = -joint#Rxyz2(3)/cos(y1)
cx = joint#Rxyz3(3)/cos(y1)
x1 = atan2(sx,cx)

IF (y1>=0)
     y2 = 180 - y1
ELSE
     y2 = -180 - y1	
ENDIF

sz2 = -joint#Rxyz1(2)/cos(y2)
cz2 = joint#Rxyz1(1)/cos(y2)
z2 = atan2(sz2,cz2)

sx2 = -joint#Rxyz2(3)/cos(y2)
cx2 = joint#Rxyz3(3)/cos(y2)
x2 = atan2(sx2,cx2)

IF ((-90<=y1) AND (y1<=90))
	x = x1
	y = y1
	z = z1
ELSE
	x = x2
	y = y2
	z = z2
ENDIF

joint#XYZ = <x,y,z>
output(joint#XYZ)

endmacro

{*---------------------------------------------------------------------------------------------------*}

macro RotYZX(child, parent, joint)

joint#angles=<child,parent,xyz>
joint#alpha=joint#angles(1)
joint#beta=joint#angles(2)
joint#gamma=joint#angles(3)

joint#Rxyz1={cos(joint#beta)*cos(joint#gamma),sin(joint#alpha)*sin(joint#beta)*(cos(joint#gamma))-(cos(joint#alpha)*sin(joint#gamma)),(cos(joint#alpha)*sin(joint#beta)*cos(joint#gamma))+(sin(joint#alpha)*sin(joint#gamma))}
joint#Rxyz2={cos(joint#beta)*sin(joint#gamma),(sin(joint#alpha)*sin(joint#beta)*sin(joint#gamma))+(cos(joint#alpha)*cos(joint#gamma)),(cos(joint#alpha)*sin(joint#beta)*sin(joint#gamma))-(sin(joint#alpha)*cos(joint#gamma))}
joint#Rxyz3={-sin(joint#beta),sin(joint#alpha)*cos(joint#beta),cos(joint#alpha)*cos(joint#beta)}

z1 = asin(joint#Rxyz2(1))

sx = -joint#Rxyz2(3)/cos(z1)
cx = joint#Rxyz2(2)/cos(z1)
X1 = atan2(sx,cx)

sy = -joint#Rxyz3(1)/cos(z1)
cy = joint#Rxyz1(1)/cos(z1)
y1 = atan2(sy,cy)

IF (z1>=0)
     z2 = 180 - z1
ELSE
     z2 = -180 - z1	
ENDIF

sx2 = -joint#Rxyz2(3)/cos(z2)
cx2 = joint#Rxyz2(2)/cos(z2)
x2 = atan2(sx2,cx2)

sy2 = -joint#Rxyz3(1)/cos(z2)
cy2 = joint#Rxyz1(1)/cos(z2)
y2 = atan2(sy2,cy2)

IF ((-90<=z1) AND (z1<=90))
	x = x1
	y = y1
	z = z1
ELSE
	x = x2
	y = y2
	z = z2
ENDIF

joint#YZX = <y,z,x>
output(joint#YZX)

endmacro

{*---------------------------------------------------------------------------------------------------*}
{*---------------------------------------------------------------------------------------------------*}
{*------------------------------------ END OF MACRO SECTION -----------------------------------------*}
{*---------------------------------------------------------------------------------------------------*}
{*---------------------------------------------------------------------------------------------------*}

optionalPoints(PROX, DISL, MarkerT, MarkerB, MarkerS, AC4, HUM3, RS)

replace4(HUMSupPost,HUM2,HUM3,HUM4)
replace4(C7,T8,IJ,PX)
replace4(AClong,AC2,AC3,AC4)
replace4(EL,EM,RS,US)

{* Static part of the model *}

IF $STATIC == 1 THEN
		{* Create a technical reference frame for the humerus associated with the markers HUMSupPost,HUM2,HUM3,HUM4 *}
		UPTECH = [HUMSupPost,HUM2-HUMSupPost,HUM4-HUMSupPost,xyz]		
	If $MarkerFlag == 1 Then 
		{* Calibrate EM and EL with respect to the humerus marker cluster *}
		EMhum = EM
		ELhum = EL
		calibratePoint(EMhum,UPTECH) 
		calibratePoint(ELhum,UPTECH) 
	EndIf 

		{* Create a technical reference frame for the forearm associated with the markers EM,EL,RS,US *}
		FORTECH = [EM,EL-EM,US-EM,xyz]		
	If $MarkerFlag == 9 Then 
		{* Calibrate RS and US with respect to the forearm marker cluster - only needed if RS or US are not visible for an entire dynamic trial *}
		calibratePoint(RS,FORTECH) 
		calibratePoint(US,FORTECH) 
	EndIf 
	
		{* Create a technical reference frame for the acromion associated with the markers AClong,AC2,AC3,AC4 *}
	ACTECH = [AClong,AC2-AClong,AC3-AClong,xyz]
		{* Calibrate AC,AA,TS,AI and PC with respect to the acromion marker cluster *}
		{* One static trial per bony landmark *}
	If $MarkerFlag == 2 Then
		POLE = PROX - DISL	
		AC = PROX + POLE/DIST(PROX,DISL)*150
		calibratePoint(AC,ACTECH)
	EndIf
	If $MarkerFlag == 6 Then
		POLE = PROX - DISL	
		AA = PROX + POLE/DIST(PROX,DISL)*150
		calibratePoint(AA,ACTECH)
	EndIf
	If $MarkerFlag == 4 Then
		POLE = PROX - DISL	
		TS = PROX + POLE/DIST(PROX,DISL)*150
		calibratePoint(TS,ACTECH)
	EndIf
	If $MarkerFlag == 5 Then
		POLE = PROX - DISL	
		AI = PROX + POLE/DIST(PROX,DISL)*150
		calibratePoint(AI,ACTECH)
	EndIf
	If $MarkerFlag == 3 Then
		POLE = PROX - DISL	
		PC = PROX + POLE/DIST(PROX,DISL)*150
		calibratePoint(PC,ACTECH)
	EndIf

		{* Calibrate SC with respect to the thorax marker cluster *}
	If $MarkerFlag == 1 Then
		{* Create a technical reference frame for the thorax associated with the markers C7,T8,IJ,PX *}
		THTECH = [IJ,PX-IJ,PX-C7,yxz]		
		POLE = PROX - DISL	
		SC = PROX + POLE/DIST(PROX,DISL)*150
		calibratePoint(SC,THTECH)
	EndIf

		{* Calculate position of GH centre based on AC, AA, TS, AI and PC *}
		{* from regression equations according to Meskers et al (1998) *}

	If $MarkerFlag == 7 Then	
		{* Reconstruct calibrated points *}	
		reconstructPoint(AC,ACTECH)
		reconstructPoint(AA,ACTECH)
		reconstructPoint(TS,ACTECH)
		reconstructPoint(AI,ACTECH)
		reconstructPoint(PC,ACTECH)
		
			{* Create scapula coordinate frame *}
			{* local x-axis : TS to AA *}        										
			{* local z-axis : perpendicular to x and the line connecting AA and AI *}  	
			{* local y-axis : perpendicular to z and x *}		                       	
		Rsca = [AA,AA-TS,AI-AA,xzy]																	
		AxesVis(Rsca,100)

			{* Express bony landmarks in the scapular local coordinates *}
		%PC = PC/Rsca
		%AC = AC/Rsca
		%AA = AA/Rsca
		%TS = TS/Rsca
		%AI = AI/Rsca

		LAAPC=DIST(%AA,%PC)
		LAIPC=DIST(%AI,%PC)

		THx={26.896,   0.614,  0.295}
		THy={-16.307,   0.825,   0.293}
		THz={-1.740,   -0.899,   -0.229}

		SCx={1,%TS(1),LAIPC}
		SCz={1,LAAPC,%TS(1)}
		SCy={1,%AC(2),%PC(3)}

		GHtempx = THx(1)*SCx(1)+THx(2)*SCx(2)+THx(3)*SCx(3)
		GHtempy = THy(1)*SCy(1)+THy(2)*SCy(2)+THy(3)*SCy(3)
		GHtempz = THz(1)*SCz(1)+THz(2)*SCz(2)+THz(3)*SCz(3)

			{* GH in the scapular coordinate frame *}
		%GHtemp={GHtempx,GHtempy,GHtempz}

			{* GH in the global coordinate frame *}
		GHtemp = %GHtemp*Rsca			
			{* Calibrate GH with respect to the upperArm *}
		GH = GHtemp
		output(GH)
		calibratePoint(GH,UPTECH)		
	ENDIF

ENDIF

IF $STATIC == 0 THEN
		{* Recreate the technical reference frames used to calibrate the points in the static *}
	UPTECH = [HUMSupPost,HUM2-HUMSupPost,HUM4-HUMSupPost,xyz]		
	ACTECH = [AClong,AC2-AClong,AC3-AClong,xyz]
	THTECH = [IJ,PX-IJ,PX-C7,yxz]		
	FORTECH = [EM,EL-EM,US-EM,xyz]		
	
		{* Reconstruct the calibrated points *}
	reconstructPoint(EMhum,UPTECH) 
	reconstructPoint(ELhum,UPTECH) 
	
	    {* Only needed if RS is not visible for an entire dynamic trial *}
	reconstructPoint(RS,FORTECH) 

	reconstructPoint(GH,UPTECH)
	
	reconstructPoint(AA,ACTECH)
	reconstructPoint(TS,ACTECH)
	reconstructPoint(AI,ACTECH)
	reconstructPoint(AC,ACTECH)
		
	reconstructPoint(SC,THTECH)
	
	{*-------------------------------------------*}
	{* Segment definitions *}
	{*-------------------------------------------*}

		{* Global *}
		Gorigin = {0,0,0}
		Global = [Gorigin,{-1,0,0},{0,1,0},xyz]
		AxesVis(Global,100)
		
		{* Thorax segment definition *}
		{* local y-axis : midpoint between IJ and C7 to midpoint between T8 and PX *}										
		{* local x-axis : perpendicular to y and the line connecting T8 and PX   *} 	
		{* local z-axis : perpendicular to x and y *}		                       	
	Thorax = [IJ,(IJ+C7)/2-(T8+PX)/2,PX-T8,yxz]
	AxesVis(Thorax,100)
	
		{* Clavicle segment definition *}
		{* local x-axis : SC to AC *}                    
		{* local z-axis : perpendicular to local x-axis and thoracic y-axis *}            
		{* local y-axis : perpendicular to local z and x *}                 
	Clavicle = [SC,AC-SC,(T8+PX)/2-(IJ+C7)/2,xzy]
	AxesVis(Clavicle,100)

		{* Scapula segment definition *}
		{* local x-axis : TS to AA *}        										
		{* local z-axis : perpendicular to x and the line connecting AA and AI *}  	
		{* local y-axis : perpendicular to z and x *}		                       	
	Scapula = [AA,AA-TS,AI-AA,xzy]																	
	AxesVis(Scapula,100)
		
		{* Humerus segment definition *}
		{* local y axis: mid EL-EM to GH *}
		{* local z axis: perpendicular to y and EM-EL *}
		{* local x axis: perpendicular to y and z *}
	Hmid=(EMhum+ELhum)/2
	Humerus = [GH,GH-Hmid,ELhum-EMhum,yzx]
	AxesVis(Humerus,100)		

		{* Forearm *}
		{* local y-axis : midpoint between US and RS to midpoint between EM and EL *}   	
		{* local z-axis : perpendicular to y and US-RS	*}		
		{* local x axis: perpendicular to y and z *}		
	Smid=(RS+US)/2
	Hmid=(EM+EL)/2
	Forearm = [Hmid,Hmid-Smid,RS-US,yzx]
	AxesVis(Forearm,100)		
	
	{*-------------------------------------------*}
	{* Joint angles calculation *}
	{*-------------------------------------------*}
		{* Thorax *}
		{* Euler angles sequence: XY'Z" *}
	RotXYZ(Thorax,Global,THAngles) 
		
		{* Clavicle *}
		{* Euler angles sequence: YZ'X" *}
	RotYZX(Clavicle,Thorax,SCAngles) 
		
		{* Scapula *}
		{* Euler angles sequence: YZ'X" *}
	RotYZX(Scapula,Thorax,ACthorAngles)
	RotYZX(Scapula,Clavicle,ACAngles)
		
		{* Humerus *}
		{* Euler angles sequence: YZ'Y". Plane of elevation, elevation, internal-external rotation *}
	RotYZY(Humerus,Thorax,GHthorAngles)
	RotYZY(Humerus,Scapula,GHAngles)
	
		{* Forearm *}
		{* Euler angles sequence: XZ'Y". Flexion-extension, ab-adduction, internal-external rotation *}
	RotXZY(Forearm,Humerus,ELAngles)

	
	If $MarkerFlag == 8 THEN
	{* The AMTI pole is used *}
	{* Code taken from TORCH_Pole_Plate1.mod written by Andrew Lewis for ORLAU, April 2004 *}
	
		{* Define PoleTest constants *}
		{* ============================== *}

		{* Pole Values: Dimensions etc *}
		{* Three markers on the pole are named Top (T), Side (S) and Bottom (B) *}
		TopToMarkerT = 90
		BottomToMarkerB = 444.24
		MarkerBToWand = 265
		MarkerBToAMTIOrigin = 369.65
		PoleMass = 0.92
	
		{* Pole orientation calculations *}
		{* ============================== *}

		{* Calculation and normalisation of the pole's orientation vector  *}
		PoleOrientation = MarkerT - MarkerB
		DistanceBT = DIST(MarkerB,MarkerT)
		UnitPoleOrient = PoleOrientation/DistanceBT

		{* Calculation and normalisation of the pole wand orientation vector (the wand is the side piece of the pole) *}
		{* The WandAttachment point is the point on the pole where the wand attaches *}
		WandAttachment = PERP(MarkerS, MarkerB, MarkerT)
		OUTPUT(WandAttachment)
		WandOrientation = MarkerS - WandAttachment
		DistanceWAS = DIST(WandAttachment,MarkerS)
		UnitWandOrient = WandOrientation/DistanceWAS

		{* Calculation of the position of the pole tips *}
		PoleTipT = MarkerT + TopToMarkerT*UnitPoleOrient
		PoleTipB = MarkerB - BottomToMarkerB*UnitPoleOrient
		OUTPUT(PoleTipT,PoleTipB)

		{* Create an AMTI orientation segment with the x,y,z segment axes matching the x,y,z AMTI axes *}
		SegAA = [MarkerB - MarkerBToAMTIOrigin*UnitPoleOrient,MarkerS - WandAttachment, MarkerB - MarkerT,-2]
		AxesVis(SegAA,100)		

		{* Force in the AMTI orientation segment *}
		%ForceAA = ForcePlate4(1)

		{* Force in the Vicon coordinate frame *}
		ForceAA = %ForceAA*SegAA			

		{* Force in the global coordinate frame *}
		ForceAG = ForceAA / Global
		
		OUTPUT(ForceAG)
		OUTPUT(ForceAA)
	
	ENDIF

ENDIF