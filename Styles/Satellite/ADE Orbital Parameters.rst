stk.v.10.0
WrittenBy    STK_v10.0.2

BEGIN ReportStyle

BEGIN ClassId
	Class		Satellite
END ClassId

BEGIN Header
	StyleType		0
	Date		Yes
	Name		Yes
	IsHidden		No
	DescShort		No
	DescLong		No
	YLog10		No
	Y2Log10		No
	YUseWholeNumbers		No
	Y2UseWholeNumbers		No
	VerticalGridLines		No
	HorizontalGridLines		No
	AnnotationType		Spaced
	NumAnnotations		3
	NumAngularAnnotations		5
	ShowYAnnotations		Yes
	AnnotationRotation		1
	BackgroundColor		#ffffff
	ForegroundColor		#000000
	ViewableDuration		3600.000000
	RealTimeMode		No
	DayLinesStatus		1
	LegendStatus		1
	LegendLocation		1

BEGIN PostProcessor
	Destination	0
	Use	0
	Destination	1
	Use	0
	Destination	2
	Use	0
	Destination	3
	Use	0
END PostProcessor
	NumSections		1
END Header

BEGIN Section
	Name		Section 1
	ClassName		Satellite
	NameInTitle		No
	ExpandMethod		0
	PropMask		2
	ShowIntervals		No
	NumIntervals		0
	NumLines		1

BEGIN Line
	Name		Line 1
	NumElements		10

BEGIN Element
	Name		Time
	IsIndepVar		Yes
	IndepVarName		Time
	Title		Time
	NameInTitle		No
	Service		ModOrbElem
	Type		J2000
	Element		Time
	Format		%.6f
	SumAllowedMask		0
	SummaryOnly		No
	DataType		0
	UnitType		2
	LineStyle		0
	LineWidth		0
	LineColor		#000000
	PointStyle		0
	PointSize		0
	FillPattern		0
	FillColor		#000000
	PropMask		0
BEGIN Event
	UseEvent		No
	EventValue		0.000000
	Direction		Both
	CreateFile		No
END Event
	UseScenUnits		No
BEGIN Units
		DateFormat		JulianDate
END Units
END Element

BEGIN Element
	Name		Classical Elements-J2000-Apogee Altitude
	IsIndepVar		No
	IndepVarName		Time
	Title		Apogee Altitude
	NameInTitle		Yes
	Service		ModOrbElem
	Type		J2000
	Element		Apogee Altitude
	SumAllowedMask		1543
	SummaryOnly		No
	DataType		0
	UnitType		0
	LineStyle		0
	LineWidth		0
	LineColor		#000000
	PointStyle		0
	PointSize		0
	FillPattern		0
	FillColor		#000000
	PropMask		0
	UseScenUnits		Yes
END Element

BEGIN Element
	Name		Classical Elements-J2000-Perigee Altitude
	IsIndepVar		No
	IndepVarName		Time
	Title		Perigee Altitude
	NameInTitle		Yes
	Service		ModOrbElem
	Type		J2000
	Element		Perigee Altitude
	SumAllowedMask		1543
	SummaryOnly		No
	DataType		0
	UnitType		0
	LineStyle		0
	LineWidth		0
	LineColor		#000000
	PointStyle		0
	PointSize		0
	FillPattern		0
	FillColor		#000000
	PropMask		0
	UseScenUnits		Yes
END Element

BEGIN Element
	Name		Classical Elements-J2000-Arg of Perigee
	IsIndepVar		No
	IndepVarName		Time
	Title		Arg of Perigee
	NameInTitle		Yes
	Service		ModOrbElem
	Type		J2000
	Element		Arg of Perigee
	SumAllowedMask		1543
	SummaryOnly		No
	DataType		0
	UnitType		3
	LineStyle		0
	LineWidth		0
	LineColor		#000000
	PointStyle		0
	PointSize		0
	FillPattern		0
	FillColor		#000000
	PropMask		0
	UseScenUnits		No
BEGIN Units
		AngleUnit		Degrees
END Units
END Element

BEGIN Element
	Name		Classical Elements-J2000-Eccentricity
	IsIndepVar		No
	IndepVarName		Time
	Title		Eccentricity
	NameInTitle		Yes
	Service		ModOrbElem
	Type		J2000
	Element		Eccentricity
	SumAllowedMask		1543
	SummaryOnly		No
	DataType		0
	UnitType		6
	LineStyle		0
	LineWidth		0
	LineColor		#000000
	PointStyle		0
	PointSize		0
	FillPattern		0
	FillColor		#000000
	PropMask		0
	UseScenUnits		Yes
END Element

BEGIN Element
	Name		Classical Elements-J2000-Inclination
	IsIndepVar		No
	IndepVarName		Time
	Title		Inclination
	NameInTitle		Yes
	Service		ModOrbElem
	Type		J2000
	Element		Inclination
	SumAllowedMask		1543
	SummaryOnly		No
	DataType		0
	UnitType		3
	LineStyle		0
	LineWidth		0
	LineColor		#000000
	PointStyle		0
	PointSize		0
	FillPattern		0
	FillColor		#000000
	PropMask		0
	UseScenUnits		No
BEGIN Units
		AngleUnit		Degrees
END Units
END Element

BEGIN Element
	Name		Classical Elements-J2000-Period
	IsIndepVar		No
	IndepVarName		Time
	Title		Period
	NameInTitle		Yes
	Service		ModOrbElem
	Type		J2000
	Element		Period
	SumAllowedMask		1543
	SummaryOnly		No
	DataType		0
	UnitType		1
	LineStyle		0
	LineWidth		0
	LineColor		#000000
	PointStyle		0
	PointSize		0
	FillPattern		0
	FillColor		#000000
	PropMask		0
	UseScenUnits		Yes
END Element

BEGIN Element
	Name		Classical Elements-J2000-RAAN
	IsIndepVar		No
	IndepVarName		Time
	Title		RAAN
	NameInTitle		Yes
	Service		ModOrbElem
	Type		J2000
	Element		RAAN
	SumAllowedMask		1543
	SummaryOnly		No
	DataType		0
	UnitType		20
	LineStyle		0
	LineWidth		0
	LineColor		#000000
	PointStyle		0
	PointSize		0
	FillPattern		0
	FillColor		#000000
	PropMask		0
	UseScenUnits		No
BEGIN Units
		LongitudeUnit		Degrees
END Units
END Element

BEGIN Element
	Name		Classical Elements-J2000-Perigee Radius
	IsIndepVar		No
	IndepVarName		Time
	Title		Perigee Radius
	NameInTitle		Yes
	Service		ModOrbElem
	Type		J2000
	Element		Perigee Radius
	SumAllowedMask		1543
	SummaryOnly		No
	DataType		0
	UnitType		0
	LineStyle		0
	LineWidth		0
	LineColor		#000000
	PointStyle		0
	PointSize		0
	FillPattern		0
	FillColor		#000000
	PropMask		0
	UseScenUnits		Yes
END Element

BEGIN Element
	Name		Classical Elements-J2000-True Anomaly
	IsIndepVar		No
	IndepVarName		Time
	Title		True Anomaly
	NameInTitle		Yes
	Service		ModOrbElem
	Type		J2000
	Element		True Anomaly
	SumAllowedMask		1543
	SummaryOnly		No
	DataType		0
	UnitType		3
	LineStyle		0
	LineWidth		0
	LineColor		#000000
	PointStyle		0
	PointSize		0
	FillPattern		0
	FillColor		#000000
	PropMask		0
	UseScenUnits		No
BEGIN Units
		AngleUnit		Degrees
END Units
END Element
END Line
END Section

BEGIN LineAnnotations
END LineAnnotations
END ReportStyle

