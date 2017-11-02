stk.v.10.0
WrittenBy    STK_v10.0.2

BEGIN Facility

Name        CalPoly

	BEGIN CentroidPosition

		CentralBody            Earth
		DisplayCoords          Geodetic
		EcfLatitude            3.53050053000000e+001
		EcfLongitude           -1.20662494200000e+002
		EcfAltitude            0.00000000000000e+000
		HeightAboveGround      2.00000000000000e+001
		ComputeTrnMaskAsNeeded Off
		DisplayAltRef          Ellipsoid
		UseTerrainInfo         Off
		NumAzRaysInMask        360
		TerrainNormalMode      UseCbShape

	END CentroidPosition

BEGIN Extensions
    
    BEGIN Graphics

            BEGIN Attributes

                MarkerColor             #ff00ff
                LabelColor              #ff00ff
                LineStyle               0
                MarkerStyle             9
                FontStyle               0

            END Attributes

            BEGIN Graphics

                Show                    On
                Inherit                 On
                IsDynamic               Off
                ShowLabel               On
                ShowAzElMask            Off
                ShowAzElFill            Off
                AzElFillStyle           7
                AzElFillAltTranslucency 0.500000
                UseAzElColor            Off
                AzElColor               #ffffff
                MinDisplayAlt           190.000
                MaxDisplayAlt           10000000.000
                NumAzElMaskSteps        1
                ShowAzElAtRangeMask       Off
                ShowAzElAtRangeFill       Off
                AzElFillRangeTranslucency 0.500000
                AzElAtRangeFillStyle      7
                UseAzElAtRangeColor          Off
                AzElAtRangeColor          #ffffff
                MinDisplayRange           0.000
                MaxDisplayRange           10000000.000
                NumAzElAtRangeMaskSteps   1

            BEGIN RangeContourData
                    Show                  Off
                    ShowRangeFill         Off
                    RangeFillTranslucency 0.500000
                    LabelUnits            4
                    NumDecimalDigits      3

            END RangeContourData

            END Graphics

            Begin DisplayTimes
                DisplayType	AlwaysOn
            End DisplayTimes
    END Graphics
    
    BEGIN LaserCAT
    END LaserCAT
    
    BEGIN ExternData
    END ExternData
    
    BEGIN RFI
    END RFI
    
    BEGIN ADFFileData
    END ADFFileData
    
    BEGIN AccessConstraints
		LineOfSight   IncludeIntervals 
		ElevationAngle		Min  1.0000000000e+001   IncludeIntervals 
		Range		Max  3.3850000000e+006   IncludeIntervals 
    END AccessConstraints
    
    BEGIN ObjectCoverage
    END ObjectCoverage
    
    BEGIN Desc
    END Desc
    
    BEGIN Atmosphere
<!-- STKv4.0 Format="XML" -->
<STKOBJECT>
<OBJECT Class = "AtmosphereExtension" Name = "STK_Atmosphere_Extension">
    <OBJECT Class = "link" Name = "AtmosAbsorptionModel">
        <OBJECT Class = "AtmosphericAbsorptionModel" Name = "Simple_Satcom">
            <OBJECT Class = "string" Name = "Category"> &quot;&quot; </OBJECT>
            <OBJECT Class = "bool" Name = "Clonable"> True </OBJECT>
            <OBJECT Class = "string" Name = "Description"> &quot;Simple Satcom gaseous absorption model&quot; </OBJECT>
            <OBJECT Class = "bool" Name = "ReadOnly"> False </OBJECT>
            <OBJECT Class = "double" Name = "SurfaceTemperature"> 293.15 K </OBJECT>
            <OBJECT Class = "string" Name = "Type"> &quot;Simple Satcom&quot; </OBJECT>
            <OBJECT Class = "string" Name = "UserComment"> &quot;Simple Satcom gaseous absorption model&quot; </OBJECT>
            <OBJECT Class = "string" Name = "Version"> &quot;1.0.0 a&quot; </OBJECT>
            <OBJECT Class = "double" Name = "WaterVaporConcentration"> 7.5 g*m^-3 </OBJECT>
        </OBJECT>
    </OBJECT>
    <OBJECT Class = "string" Name = "Category"> &quot;&quot; </OBJECT>
    <OBJECT Class = "bool" Name = "Clonable"> True </OBJECT>
    <OBJECT Class = "string" Name = "Description"> &quot;STK Atmosphere Extension&quot; </OBJECT>
    <OBJECT Class = "bool" Name = "EnableLocalRainData"> False </OBJECT>
    <OBJECT Class = "bool" Name = "InheritAtmosAbsorptionModel"> True </OBJECT>
    <OBJECT Class = "double" Name = "LocalRainIsoHeight"> 2000 m </OBJECT>
    <OBJECT Class = "double" Name = "LocalRainRate"> 1 mm*hr^-1 </OBJECT>
    <OBJECT Class = "double" Name = "LocalSurfaceTemp"> 293.15 K </OBJECT>
    <OBJECT Class = "bool" Name = "ReadOnly"> False </OBJECT>
    <OBJECT Class = "string" Name = "Type"> &quot;STK Atmosphere Extension&quot; </OBJECT>
    <OBJECT Class = "string" Name = "UserComment"> &quot;STK Atmosphere Extension&quot; </OBJECT>
    <OBJECT Class = "string" Name = "Version"> &quot;1.0.0 a&quot; </OBJECT>
</OBJECT>
</STKOBJECT>
    END Atmosphere
    
    BEGIN RCS
	Inherited          True
	LinearClutterCoef        1.000000e+000
	BEGIN RCSBAND
		LinearConstantValue      1.000000e+000
		Swerling      0
		BandData      2.997920e+006 3.000000e+011
	END RCSBAND
    END RCS
    
    BEGIN Identification
    END Identification
    
    BEGIN Crdn
    END Crdn
    
    BEGIN VO
    END VO

END Extensions

BEGIN SubObjects

END SubObjects

END Facility

