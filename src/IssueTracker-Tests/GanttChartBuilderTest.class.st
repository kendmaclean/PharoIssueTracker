"
| Category       | Tests | Coverage                                |
  |----------------|-------|-----------------------------------------|
  | Initialization | 4     | Default leftMargin, setters             |
  | Callbacks      | 5     | Click/right-click callbacks, invocation |
  | Build          | 6     | Building with/without issues, filtering |
  | Shapes         | 11    | Bar, milestone, composite creation      |
  | Labels         | 5     | Regular, milestone, delayed labels      |
  | Tooltips       | 7     | Title, status, priority, dependencies   |
  | Colors         | 7     | All status colors (from trait)          |
  | Grid/Axis      | 3     | Grid lines, date axis                   |
  | Dependencies   | 4     | Arrow creation, dependency handling     |
  | Empty Message  | 2     | Empty state display                     |
  | Integration    | 4     | Full builds with various scenarios      |

"
Class {
	#name : 'GanttChartBuilderTest',
	#superclass : 'TestCase',
	#instVars : [
		'builder',
		'canvas',
		'testIssue1',
		'testIssue2',
		'testIssue3',
		'milestoneIssue'
	],
	#category : 'IssueTracker-Tests-Tests',
	#package : 'IssueTracker-Tests',
	#tag : 'Tests'
}

{ #category : 'running' }
GanttChartBuilderTest >> setUp [
      super setUp.
      canvas := RSCanvas new.
      builder := GanttChartBuilder new.
      builder canvas: canvas.

      "Create test issues with dates"
      testIssue1 := Issue new
          title: 'First Issue';
          status: #open;
          priority: #high;
          startDate: Date today;
          duration: 5;
          yourself.

      testIssue2 := Issue new
          title: 'Second Issue';
          status: #inProgress;
          priority: #medium;
          startDate: (Date today addDays: 3);
          duration: 3;
          yourself.

      testIssue3 := Issue new
          title: 'Third Issue';
          status: #closed;
          priority: #low;
          startDate: (Date today subtractDays: 5);
          duration: 2;
          yourself.

      milestoneIssue := Issue new
          title: 'Milestone';
          status: #milestone;
          priority: #high;
          startDate: (Date today addDays: 10);
          duration: 0;
          yourself.
]

{ #category : 'running' }
GanttChartBuilderTest >> tearDown [
      builder := nil.
      canvas := nil.
      testIssue1 := nil.
      testIssue2 := nil.
      testIssue3 := nil.
      milestoneIssue := nil.
      super tearDown.
]

{ #category : 'tests - grid' }
GanttChartBuilderTest >> testAddDateAxisAddsLabelsToCanvas [
      "Test that addDateAxisFrom:to:issueCount: adds labels"
      | shapesBefore |
      shapesBefore := canvas shapes size.
      builder addDateAxisFrom: Date today to: (Date today addDays: 14) issueCount: 3.
      self assert: canvas shapes size > shapesBefore.
]

{ #category : 'tests - dependencies' }
GanttChartBuilderTest >> testAddDependencyArrowsNoDependencies [
      "Test that addDependencyArrowsFor:shapeMap: adds no arrows without dependencies"
      | shapeMap shape1 shapesBefore |
      shape1 := RSBox new model: testIssue1.
      canvas add: shape1.
      shapeMap := Dictionary new.
      shapeMap at: testIssue1 put: shape1.
      shapesBefore := canvas shapes size.
      builder addDependencyArrowsFor: { testIssue1 } shapeMap: shapeMap.
      self assert: canvas shapes size equals: shapesBefore.
]

{ #category : 'tests - dependencies' }
GanttChartBuilderTest >> testAddDependencyArrowsWithDependencies [
      "Test that addDependencyArrowsFor:shapeMap: adds arrows for dependencies"
      | shapeMap shape1 shape2 shapesBefore |
      testIssue1 addDependency: testIssue3.
      shape1 := RSBox new model: testIssue1.
      shape2 := RSBox new model: testIssue3.
      canvas add: shape1; add: shape2.
      shapeMap := Dictionary new.
      shapeMap at: testIssue1 put: shape1.
      shapeMap at: testIssue3 put: shape2.
      shapesBefore := canvas shapes size.
      builder addDependencyArrowsFor: { testIssue1 } shapeMap: shapeMap.
      self assert: canvas shapes size equals: shapesBefore + 1.
]

{ #category : 'tests - grid' }
GanttChartBuilderTest >> testAddGridLineAddsLineToCanvas [
      "Test that addGridLineAt:height: adds a line to canvas"
      | shapesBefore |
      shapesBefore := canvas shapes size.
      builder addGridLineAt: 100 height: 200.
      self assert: canvas shapes size equals: shapesBefore + 1.
]

{ #category : 'tests - grid' }
GanttChartBuilderTest >> testAddGridLineCreatesRSLine [
      "Test that grid line is an RSLine"
      builder addGridLineAt: 100 height: 200.
      self assert: (canvas shapes last isKindOf: RSLine).
]

{ #category : 'tests - build' }
GanttChartBuilderTest >> testBuildAddsShapesToCanvas [
      "Test that build adds shapes to canvas"
      builder issues: { testIssue1 }.
      builder build.
      self assert: canvas shapes isNotEmpty.
]

{ #category : 'tests - build' }
GanttChartBuilderTest >> testBuildChartForCreatesShapesForEachIssue [
      "Test that buildChartFor: creates shapes for each issue"
      | issues shapesBeforeCount |
      issues := { testIssue1. testIssue2 }.
      shapesBeforeCount := canvas shapes size.
      builder buildChartFor: issues.
      self assert: canvas shapes size > shapesBeforeCount.
]

{ #category : 'tests - integration' }
GanttChartBuilderTest >> testBuildWithClickCallbackDoesNotError [
      "Test that build with click callback works"
      builder issues: { testIssue1 }.
      builder onIssueClick: [ :issue | issue title ].
      self shouldnt: [ builder build ] raise: Error.
]

{ #category : 'tests - build' }
GanttChartBuilderTest >> testBuildWithEmptyCollectionShowsEmptyMessage [
      "Test that build shows empty message when issues collection is empty"
      builder issues: {}.
      builder build.
      self assert: (canvas shapes anySatisfy: [ :shape |
          (shape isKindOf: RSLabel) and: [
              shape text includesSubstring: 'No issues' ] ]).
]

{ #category : 'tests - build' }
GanttChartBuilderTest >> testBuildWithEmptyIssuesShowsEmptyMessage [
      "Test that build shows empty message when no issues"
      | result |
      builder issues: {}.
      result := builder build.
      self assert: result equals: canvas.
      self assert: canvas shapes isNotEmpty.
]

{ #category : 'tests - build' }
GanttChartBuilderTest >> testBuildWithIssueWithoutExplicitDatesStillDisplays [
	"Test that issue without explicit dates still displays (uses computed defaults)"
"
	| issueWithoutExplicitDates |
	issueWithoutExplicitDates := Issue new
		                             title: 'No Explicit Dates';
		                             status: #open;
		                             yourself.
	builder issues: { issueWithoutExplicitDates }.
	builder build.
	""Issue should still be displayed since computed dates are used as fallback""
	self assert: (canvas shapes anySatisfy: [ :shape |
			 (shape isKindOf: RSLabel) and: [
				 shape text includesSubstring: 'No Explicit Dates' ] ])"
]

{ #category : 'tests - build' }
GanttChartBuilderTest >> testBuildWithIssuesReturnsCanvas [
      "Test that build returns the canvas when issues have dates"
      | result |
      builder issues: { testIssue1. testIssue2 }.
      result := builder build.
      self assert: result equals: canvas.
]

{ #category : 'tests - build' }
GanttChartBuilderTest >> testBuildWithMultipleIssues [
      "Test that build handles multiple issues"
      builder issues: { testIssue1. testIssue2. testIssue3 }.
      self shouldnt: [ builder build ] raise: Error.
]

{ #category : 'tests - integration' }
GanttChartBuilderTest >> testBuildWithRightClickCallbackDoesNotError [
      "Test that build with right-click callback works"
      builder issues: { testIssue1 }.
      builder onIssueRightClick: [ :issue :evt | issue title ].
      self shouldnt: [ builder build ] raise: Error.
]

{ #category : 'tests - initialization' }
GanttChartBuilderTest >> testCanvasSetter [
      "Test canvas: setter"
      | newCanvas |
      newCanvas := RSCanvas new.
      builder canvas: newCanvas.
      self assert: (builder instVarNamed: 'canvas') equals: newCanvas.
]

{ #category : 'tests - colors' }
GanttChartBuilderTest >> testColorForStatusBlocked [
      "Test colorForStatus returns red for blocked"
      self assert: (builder colorForStatus: #blocked) equals: Color red.
]

{ #category : 'tests - colors' }
GanttChartBuilderTest >> testColorForStatusClosed [
      "Test colorForStatus returns gray for closed"
      self assert: (builder colorForStatus: #closed) equals: Color gray.
]

{ #category : 'tests - colors' }
GanttChartBuilderTest >> testColorForStatusInProgress [
      "Test colorForStatus returns orange for inProgress"
      self assert: (builder colorForStatus: #inProgress) equals: Color orange.
]

{ #category : 'tests - colors' }
GanttChartBuilderTest >> testColorForStatusMilestone [
      "Test colorForStatus returns yellow for milestone"
      self assert: (builder colorForStatus: #milestone) equals: Color yellow.
]

{ #category : 'tests - colors' }
GanttChartBuilderTest >> testColorForStatusOpen [
      "Test colorForStatus returns cyan for open"
      self assert: (builder colorForStatus: #open) equals: Color cyan.
]

{ #category : 'tests - colors' }
GanttChartBuilderTest >> testColorForStatusResolved [
      "Test colorForStatus returns green for resolved"
      self assert: (builder colorForStatus: #resolved) equals: Color green.
]

{ #category : 'tests - colors' }
GanttChartBuilderTest >> testColorForStatusUnknown [
      "Test colorForStatus returns lightGray for unknown status"
      self assert: (builder colorForStatus: #unknownStatus) equals: Color lightGray.
]

{ #category : 'tests - dependencies' }
GanttChartBuilderTest >> testCreateArrowCreatesRSArrowedLine [
      "Test that arrow is an RSArrowedLine"
      | shape1 shape2 |
      shape1 := RSBox new.
      shape2 := RSBox new.
      canvas add: shape1; add: shape2.
      builder createArrowFrom: shape1 to: shape2.
      self assert: (canvas shapes last isKindOf: RSArrowedLine).
]

{ #category : 'tests - dependencies' }
GanttChartBuilderTest >> testCreateArrowFromToAddsArrowToCanvas [
      "Test that createArrowFrom:to: adds an arrow to canvas"
      | shape1 shape2 shapesBefore |
      shape1 := RSBox new.
      shape2 := RSBox new.
      canvas add: shape1; add: shape2.
      shapesBefore := canvas shapes size.
      builder createArrowFrom: shape1 to: shape2.
      self assert: canvas shapes size equals: shapesBefore + 1.
]

{ #category : 'tests - shapes' }
GanttChartBuilderTest >> testCreateBarShapeDelayedHasBorder [
      "Test that delayed bar shape has red border"
      | shape |
      shape := builder createBarShape: testIssue1 width: 100 hasDelayDue: true.
      self assert: shape border notNil.
      self assert: shape border color equals: Color red.
]

{ #category : 'tests - shapes' }
GanttChartBuilderTest >> testCreateBarShapeHasCorrectHeight [
      "Test that bar shape has height of 25"
      | shape |
      shape := builder createBarShape: testIssue1 width: 100 hasDelayDue: false.
      self assert: shape height equals: 25.
]

{ #category : 'tests - shapes' }
GanttChartBuilderTest >> testCreateBarShapeHasCorrectWidth [
      "Test that bar shape has correct width"
      | shape |
      shape := builder createBarShape: testIssue1 width: 100 hasDelayDue: false.
      self assert: shape width equals: 100.
]

{ #category : 'tests - shapes' }
GanttChartBuilderTest >> testCreateBarShapeHasIssueAsModel [
      "Test that bar shape has issue as model"
      | shape |
      shape := builder createBarShape: testIssue1 width: 100 hasDelayDue: false.
      self assert: shape model equals: testIssue1.
]

{ #category : 'tests - shapes' }
GanttChartBuilderTest >> testCreateBarShapeNotDelayedNoBorder [
      "Test that non-delayed bar shape has no border"
      | shape |
      shape := builder createBarShape: testIssue1 width: 100 hasDelayDue: false.
      self assert: shape border isNil.
]

{ #category : 'tests - shapes' }
GanttChartBuilderTest >> testCreateBarShapeReturnsRSBox [
      "Test that createBarShape:width:hasDelayDue: returns an RSBox"
      | shape |
      shape := builder createBarShape: testIssue1 width: 100 hasDelayDue: false.
      self assert: (shape isKindOf: RSBox).
]

{ #category : 'tests - shapes' }
GanttChartBuilderTest >> testCreateCompositeForHasTwoShapes [
      "Test that composite has two shapes (bar/diamond + label)"
      | composite |
      composite := builder createCompositeFor: testIssue1 at: 1 baseline: Date today.
      self assert: composite shapes size equals: 2.
]

{ #category : 'tests - shapes' }
GanttChartBuilderTest >> testCreateCompositeForMilestone [
      "Test that composite for milestone has polygon shape"
      | composite firstShape |
      composite := builder createCompositeFor: milestoneIssue at: 1 baseline: Date today.
      firstShape := composite shapes first.
      self assert: (firstShape isKindOf: RSPolygon).
]

{ #category : 'tests - shapes' }
GanttChartBuilderTest >> testCreateCompositeForRegularIssue [
      "Test that composite for regular issue has box shape"
      | composite firstShape |
      composite := builder createCompositeFor: testIssue1 at: 1 baseline: Date today.
      firstShape := composite shapes first.
      self assert: (firstShape isKindOf: RSBox).
]

{ #category : 'tests - shapes' }
GanttChartBuilderTest >> testCreateCompositeForReturnsRSComposite [
      "Test that createCompositeFor:at:baseline: returns an RSComposite"
      | composite |
      composite := builder createCompositeFor: testIssue1 at: 1 baseline: Date today.
      self assert: (composite isKindOf: RSComposite).
]

{ #category : 'tests - labels' }
GanttChartBuilderTest >> testCreateLabelContainsIssueTitle [
      "Test that label contains issue title"
      | label |
      label := builder createLabelFor: testIssue1 isMilestone: false hasDelayDue: false width: 100.
      self assert: (label text includesSubstring: 'First Issue').
]

{ #category : 'tests - labels' }
GanttChartBuilderTest >> testCreateLabelForDelayedIssue [
      "Test that delayed issue label contains (delayed)"
      | label |
      label := builder createLabelFor: testIssue1 isMilestone: false hasDelayDue: true width: 100.
      self assert: (label text includesSubstring: '(delayed)').
]

{ #category : 'tests - labels' }
GanttChartBuilderTest >> testCreateLabelForDelayedMilestone [
      "Test that delayed milestone label contains both diamond and delayed"
      | label |
      label := builder createLabelFor: milestoneIssue isMilestone: true hasDelayDue: true width: 100.
      self assert: (label text includesSubstring: '◆').
      self assert: (label text includesSubstring: '(delayed)').
]

{ #category : 'tests - labels' }
GanttChartBuilderTest >> testCreateLabelForMilestone [
      "Test that milestone label contains diamond symbol"
      | label |
      label := builder createLabelFor: milestoneIssue isMilestone: true hasDelayDue: false width: 100.
      self assert: (label text includesSubstring: '◆').
]

{ #category : 'tests - labels' }
GanttChartBuilderTest >> testCreateLabelReturnsRSLabel [
      "Test that createLabelFor:isMilestone:hasDelayDue:width: returns RSLabel"
      | label |
      label := builder createLabelFor: testIssue1 isMilestone: false hasDelayDue: false width: 100.
      self assert: (label isKindOf: RSLabel).
]

{ #category : 'tests - shapes' }
GanttChartBuilderTest >> testCreateMilestoneShapeDelayedHasRedBorder [
      "Test that delayed milestone has red border"
      | shape |
      shape := builder createMilestoneShape: milestoneIssue hasDelayDue: true.
      self assert: shape border color equals: Color red.
]

{ #category : 'tests - shapes' }
GanttChartBuilderTest >> testCreateMilestoneShapeHasIssueAsModel [
      "Test that milestone shape has issue as model"
      | shape |
      shape := builder createMilestoneShape: milestoneIssue hasDelayDue: false.
      self assert: shape model equals: milestoneIssue.
]

{ #category : 'tests - shapes' }
GanttChartBuilderTest >> testCreateMilestoneShapeHasYellowColor [
      "Test that milestone shape is yellow"
      | shape |
      shape := builder createMilestoneShape: milestoneIssue hasDelayDue: false.
      self assert: shape color equals: Color yellow.
]

{ #category : 'tests - shapes' }
GanttChartBuilderTest >> testCreateMilestoneShapeNotDelayedHasBlackBorder [
      "Test that non-delayed milestone has black border"
      | shape |
      shape := builder createMilestoneShape: milestoneIssue hasDelayDue: false.
      self assert: shape border color equals: Color black.
]

{ #category : 'tests - shapes' }
GanttChartBuilderTest >> testCreateMilestoneShapeReturnsRSPolygon [
      "Test that createMilestoneShape:hasDelayDue: returns an RSPolygon"
      | shape |
      shape := builder createMilestoneShape: milestoneIssue hasDelayDue: false.
      self assert: (shape isKindOf: RSPolygon).
]

{ #category : 'tests - tooltips' }
GanttChartBuilderTest >> testCreateTooltipContainsPriority [
      "Test that tooltip contains priority"
      | tooltip |
      tooltip := builder createTooltipFor: testIssue1 isMilestone: false hasDelayDue: false originalStart: nil.
      self assert: (tooltip includesSubstring: 'Priority:').
      self assert: (tooltip includesSubstring: 'high').
]

{ #category : 'tests - tooltips' }
GanttChartBuilderTest >> testCreateTooltipContainsStatus [
      "Test that tooltip contains status"
      | tooltip |
      tooltip := builder createTooltipFor: testIssue1 isMilestone: false hasDelayDue: false originalStart: nil.
      self assert: (tooltip includesSubstring: 'Status:').
      self assert: (tooltip includesSubstring: 'open').
]

{ #category : 'tests - tooltips' }
GanttChartBuilderTest >> testCreateTooltipContainsTitle [
      "Test that tooltip contains issue title"
      | tooltip |
      tooltip := builder createTooltipFor: testIssue1 isMilestone: false hasDelayDue: false originalStart: nil.
      self assert: (tooltip includesSubstring: 'First Issue').
]

{ #category : 'tests - tooltips' }
GanttChartBuilderTest >> testCreateTooltipForDelayedIssue [
      "Test that delayed issue tooltip contains warning"
      | tooltip |
      tooltip := builder createTooltipFor: testIssue1 isMilestone: false hasDelayDue: true originalStart: nil.
      self assert: (tooltip includesSubstring: 'Delayed by dependencies').
]

{ #category : 'tests - tooltips' }
GanttChartBuilderTest >> testCreateTooltipForMilestoneContainsType [
      "Test that milestone tooltip contains Type: Milestone"
      | tooltip |
      tooltip := builder createTooltipFor: milestoneIssue isMilestone: true hasDelayDue: false originalStart: nil.
      self assert: (tooltip includesSubstring: 'Type: Milestone').
]

{ #category : 'tests - tooltips' }
GanttChartBuilderTest >> testCreateTooltipWithDependencies [
      "Test that tooltip shows dependencies count"
      | tooltip |
      testIssue1 addDependency: testIssue3.
      tooltip := builder createTooltipFor: testIssue1 isMilestone: false hasDelayDue: false originalStart: nil.
      self assert: (tooltip includesSubstring: 'Dependencies:').
]

{ #category : 'tests - tooltips' }
GanttChartBuilderTest >> testCreateTooltipWithOriginalStart [
      "Test that tooltip with original start shows it"
      | tooltip originalDate |
      originalDate := Date today subtractDays: 2.
      tooltip := builder createTooltipFor: testIssue1 isMilestone: false hasDelayDue: false originalStart: originalDate.
      self assert: (tooltip includesSubstring: 'Original Start:').
]

{ #category : 'tests - integration' }
GanttChartBuilderTest >> testFullBuildWithDependencies [
      "Test full build with issues that have dependencies"
      testIssue1 addDependency: testIssue3.
      builder issues: { testIssue1. testIssue3 }.
      self shouldnt: [ builder build ] raise: Error.
]

{ #category : 'tests - integration' }
GanttChartBuilderTest >> testFullBuildWithMixedIssues [
      "Test full build with regular issues and milestones"
      builder issues: { testIssue1. testIssue2. milestoneIssue }.
      self shouldnt: [ builder build ] raise: Error.
      self assert: canvas shapes isNotEmpty.
]

{ #category : 'tests - initialization' }
GanttChartBuilderTest >> testInitializeSetsDefaultLeftMargin [
      "Test that initialize sets leftMargin to 150"
      | newBuilder |
      newBuilder := GanttChartBuilder new.
      self assert: (newBuilder instVarNamed: 'leftMargin') equals: 150.
]

{ #category : 'tests - initialization' }
GanttChartBuilderTest >> testIssuesSetter [
      "Test issues: setter"
      | issues |
      issues := { testIssue1. testIssue2 }.
      builder issues: issues.
      self assert: (builder instVarNamed: 'issues') equals: issues.
]

{ #category : 'tests - initialization' }
GanttChartBuilderTest >> testLeftMarginSetter [
      "Test leftMargin: setter"
      builder leftMargin: 200.
      self assert: (builder instVarNamed: 'leftMargin') equals: 200.
]

{ #category : 'tests - callbacks' }
GanttChartBuilderTest >> testOnIssueClickSetsCallback [
      "Test that onIssueClick: sets the callback"
      | callback |
      callback := [ :issue | issue title ].
      builder onIssueClick: callback.
      self assert: (builder instVarNamed: 'clickCallback') equals: callback.
]

{ #category : 'tests - callbacks' }
GanttChartBuilderTest >> testOnIssueClickedDoesNothingWithoutCallback [
      "Test that onIssueClicked:with: does nothing when no callback is set"
      self shouldnt: [ builder onIssueClicked: testIssue1 with: nil ] raise: Error.
]

{ #category : 'tests - callbacks' }
GanttChartBuilderTest >> testOnIssueClickedInvokesCallback [
      "Test that onIssueClicked:with: invokes the callback"
      | clickedIssue |
      clickedIssue := nil.
      builder onIssueClick: [ :issue | clickedIssue := issue ].
      builder onIssueClicked: testIssue1 with: nil.
      self assert: clickedIssue equals: testIssue1.
]

{ #category : 'tests - callbacks' }
GanttChartBuilderTest >> testOnIssueRightClickSetsCallback [
      "Test that onIssueRightClick: sets the callback"
      | callback |
      callback := [ :issue :evt | issue title ].
      builder onIssueRightClick: callback.
      self assert: (builder instVarNamed: 'rightClickCallback') equals: callback.
]

{ #category : 'tests - callbacks' }
GanttChartBuilderTest >> testOnIssueRightClickedInvokesCallback [
      "Test that onIssueRightClicked:with: invokes the callback"
      | clickedIssue clickedEvt |
      clickedIssue := nil.
      clickedEvt := nil.
      builder onIssueRightClick: [ :issue :evt |
          clickedIssue := issue.
          clickedEvt := evt ].
      builder onIssueRightClicked: testIssue1 with: #testEvent.
      self assert: clickedIssue equals: testIssue1.
      self assert: clickedEvt equals: #testEvent.
]

{ #category : 'tests - empty' }
GanttChartBuilderTest >> testShowEmptyMessageAddsLabelToCanvas [
      "Test that showEmptyMessage adds a label to canvas"
      builder showEmptyMessage.
      self assert: canvas shapes isNotEmpty.
      self assert: (canvas shapes first isKindOf: RSLabel).
]

{ #category : 'tests - empty' }
GanttChartBuilderTest >> testShowEmptyMessageLabelText [
      "Test that empty message label has correct text"
      builder showEmptyMessage.
      self assert: (canvas shapes first text includesSubstring: 'No issues').
]
