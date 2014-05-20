vxPatientSearchTool
================

The source of vxPatientSearch tool released to OSEHRA by DSS Inc.

Steps to Compile:
---------------------

Install XWB_D2006 into local instance by opening XWB_D2006.dpk
and selecting "Install" for the opened project.

[DCC Error] XWB_R2006.dpk(56): F1026 File not found: 'Xwbut1.dcu'


Open the DSSPatientRecordSearch.dpr file in Delphi IDE.

Edit DSSPatientRecordSearch.dproj to replace all instances of

  D:\work\d2006\PatientRecordSearch\

with a valid local path.

Download a copy of the following files and place each into the source tree:
* https://code.google.com/p/virtual-treeview/source/browse/trunk/Common/Compilers.inc?r=235.  
* https://code.google.com/p/virtual-treeview/source/browse/trunk/Source/VTAccessibilityFactory.pas?r=290
* https://code.google.com/p/virtual-treeview/source/browse/trunk/Source/VTConfig.inc?r=290
