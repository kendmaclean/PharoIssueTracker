Class {
	#name : 'IssueGanttPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'canvas'
	],
	#category : 'IssueTracker',
	#package : 'IssueTracker'
}

{ #category : 'instance creation' }
IssueGanttPresenter class >> open [
    <script>
    ^ self new open
]

{ #category : 'initialization' }
IssueGanttPresenter >> addDateAxis: aCanvas from: startDate to: endDate [
    | currentDate xPos labels daysBetween |
    
    labels := OrderedCollection new.
    currentDate := startDate.
    daysBetween := endDate julianDayNumber - startDate julianDayNumber.
    
    "Add labels every week or adjust based on timespan"
    [ currentDate <= endDate ] whileTrue: [
        xPos := (currentDate julianDayNumber - startDate julianDayNumber) * 20.
        
        labels add: ((RSLabel new
            text: currentDate asString;
            fontSize: 8;
            color: Color gray;
            yourself) translateBy: xPos @ -20).
        
        "Add vertical grid line"
        labels add: (RSLine new
            startPoint: xPos @ -10;
            endPoint: xPos @ (labels size * 35 + 100);
            color: (Color gray alpha: 0.2);
            yourself).
        
        currentDate := currentDate addDays: 7 ].
    
    aCanvas addAll: labels
]

{ #category : 'initialization' }
IssueGanttPresenter >> addDateAxis: aCanvas from: startDate to: endDate count: issueCount [
    | currentDate xPos labels dateLabel gridLine |
    
    labels := OrderedCollection new.
    currentDate := startDate.
    
    "Add labels every week"
    [ currentDate <= endDate ] whileTrue: [
        xPos := (currentDate julianDayNumber - startDate julianDayNumber) * 20.
        
        "Date label"
        dateLabel := RSLabel new
            text: currentDate asString;
            fontSize: 8;
            color: Color gray;
            yourself.
        dateLabel translateBy: xPos @ -20.
        labels add: dateLabel.
        
        "Vertical grid line"
        gridLine := RSLine new
            startPoint: xPos @ -10;
            endPoint: xPos @ (issueCount * 35 + 10);
            color: (Color gray alpha: 0.2);
            yourself.
        labels add: gridLine.
        
        currentDate := currentDate addDays: 7 ].
    
    aCanvas addAll: labels
]

{ #category : 'initialization' }
IssueGanttPresenter >> addDateAxis: aCanvas from: startDate to: endDate count: issueCount leftMargin: leftMargin [
    | currentDate xPos labels dateLabel gridLine |
    
    labels := OrderedCollection new.
    currentDate := startDate.
    
    "Add labels every week"
    [ currentDate <= endDate ] whileTrue: [
        xPos := leftMargin + ((currentDate julianDayNumber - startDate julianDayNumber) * 20).
        
        "Date label"
        dateLabel := RSLabel new
            text: currentDate asString;
            fontSize: 8;
            color: Color gray;
            yourself.
        dateLabel translateBy: xPos @ -20.
        labels add: dateLabel.
        
        "Vertical grid line"
        gridLine := RSLine new
            startPoint: xPos @ -10;
            endPoint: xPos @ (issueCount * 35 + 10);
            color: (Color gray alpha: 0.2);
            yourself.
        labels add: gridLine.
        
        currentDate := currentDate addDays: 7 ].
    
    aCanvas addAll: labels
]

{ #category : 'initialization' }
IssueGanttPresenter >> addDependencyArrows: rsCanvas issues: issues shapeMap: issueShapeMap [
    "Draw arrows from dependencies to dependent issues"
    | arrows |
    arrows := OrderedCollection new.
    
    issues do: [ :issue |
        | toShape |
        toShape := issueShapeMap at: issue ifAbsent: [ nil ].
        
        issue dependencies do: [ :dependency |
            | fromShape line |
            fromShape := issueShapeMap at: dependency ifAbsent: [ nil ].
            
            (fromShape notNil and: [ toShape notNil ]) ifTrue: [
                "Create arrow from end of dependency to start of dependent issue"
                line := RSLine new
                    from: fromShape;
                    to: toShape;
                    color: (Color blue alpha: 0.5);
                    width: 2;
                    yourself.
                
                "Add arrowhead"
                line markerEnd: (RSShapeFactory arrow
                    color: (Color blue alpha: 0.5);
                    size: 8).
                
                arrows add: line ] ] ].
    
    rsCanvas addAll: arrows.
    
    "Move arrows behind bars"
    arrows do: [ :arrow | arrow pushBack ]
]

{ #category : 'initialization' }
IssueGanttPresenter >> buildGanttChart [
    canvas script: [ :rsCanvas | self buildGanttOn: rsCanvas ]
]

{ #category : 'initialization' }
IssueGanttPresenter >> buildGanttOn: rsCanvas [
    | issues shapes baselineDate maxDate daySpan leftMargin issueShapeMap |
    
    "Filter issues that have either a due date or can compute one"
    issues := IssueRepository uniqueInstance allIssues 
        select: [ :issue | 
            issue dependencyAwareEndDate notNil and: [ issue dependencyAwareStartDate notNil ] ].
    
    issues ifEmpty: [ 
        ^ self showEmptyMessageOn: rsCanvas ].
    
    "Use earliest dependency-aware start date as baseline"
    baselineDate := (issues collect: #dependencyAwareStartDate) min.
    maxDate := (issues collect: #dependencyAwareEndDate) max.
    daySpan := (maxDate julianDayNumber - baselineDate julianDayNumber) max: 1.
    
    leftMargin := 100.
    
    shapes := OrderedCollection new.
    issueShapeMap := Dictionary new.  "Map issues to their shapes for dependency drawing"
    
    "Create bars for each issue"
    issues withIndexDo: [ :issue :index |
        | bar width label composite startDays endDays startX hasDelayDue originalStart |
        
        "Calculate days from baseline using dependency-aware dates"
        startDays := issue dependencyAwareStartDate julianDayNumber - baselineDate julianDayNumber.
        endDays := issue dependencyAwareEndDate julianDayNumber - baselineDate julianDayNumber.
        
        "Check if issue is delayed due to dependencies"
        originalStart := issue computedStartDate.
        hasDelayDue := originalStart notNil and: [ 
            issue dependencyAwareStartDate > originalStart ].
        
        "Calculate position and width"
        startX := leftMargin + (startDays * 20).
        width := ((endDays - startDays) max: 1) * 20.
        
        "Create bar - with visual indicator if delayed"
        bar := RSBox new
            width: width;
            height: 25;
            color: (hasDelayDue 
                ifTrue: [ (self colorForStatus: issue status) darker ]
                ifFalse: [ self colorForStatus: issue status ]);
            model: issue;
            yourself.
        
        "Add border if delayed"
        hasDelayDue ifTrue: [
            bar border: (RSBorder new color: Color red; width: 2) ].
        
        "Position bar relative to its center"
        bar translateBy: (width / 2) @ 0.
        
        "Create label"
        label := RSLabel new
            text: (hasDelayDue 
                ifTrue: [ issue title, ' (delayed)' ]
                ifFalse: [ issue title ]);
            fontSize: 10;
            yourself.
        
        "Position label to the right of bar"
        label translateBy: width + 10 @ 0.
        
        "Create composite with issue as model"
        composite := RSComposite new
            shapes: { bar. label };
            model: issue;
            yourself.
        
        "Position composite"
        composite translateBy: startX @ (index * 35).
        shapes add: composite.
        
        "Store shape for dependency drawing"
        issueShapeMap at: issue put: bar.
        
        "Add tooltip to bar only"
        bar @ (RSPopup text: [ :i | 
            | tooltip |
            tooltip := i title, String cr,
                'Status: ', i status asString, String cr,
                'Priority: ', i priority asString, String cr.
            originalStart notNil ifTrue: [
                tooltip := tooltip, 'Original Start: ', originalStart asString, String cr ].
            tooltip := tooltip,
                'Actual Start: ', i dependencyAwareStartDate asString, String cr,
                'End: ', i dependencyAwareEndDate asString, String cr,
                'Duration: ', i computedDuration asString, ' days'.
            hasDelayDue ifTrue: [
                tooltip := tooltip, String cr, 
                    '⚠ Delayed by dependencies' ].
            tooltip ]) ].
    
    rsCanvas addAll: shapes.
    
    "Draw dependency arrows"
    self addDependencyArrows: rsCanvas issues: issues shapeMap: issueShapeMap.
    
    "Add date axis"
    self addDateAxis: rsCanvas from: baselineDate to: maxDate count: issues size leftMargin: leftMargin.
    
    rsCanvas @ RSCanvasController.
    ^ rsCanvas
]

{ #category : 'initialization' }
IssueGanttPresenter >> colorForStatus: aStatus [
    aStatus = #open ifTrue: [ ^ Color cyan ].
    aStatus = #inProgress ifTrue: [ ^ Color orange ].
    aStatus = #resolved ifTrue: [ ^ Color green ].
    aStatus = #closed ifTrue: [ ^ Color gray ].
    ^ Color black
]

{ #category : 'initialization' }
IssueGanttPresenter >> defaultLayout [
    ^ SpBoxLayout newTopToBottom
        add: canvas;
        yourself
]

{ #category : 'initialization' }
IssueGanttPresenter >> initializePresenters [
    canvas := self instantiate: SpRoassalPresenter.
    self buildGanttChart
]

{ #category : 'initialization' }
IssueGanttPresenter >> initializeWindow: aWindowPresenter [
    aWindowPresenter
        title: 'Issue Gantt Chart';
        initialExtent: 900 @ 600
]

{ #category : 'initialization' }
IssueGanttPresenter >> showEmptyMessage [
    | rsCanvas label |
    rsCanvas := RSCanvas new.
    label := RSLabel new
        text: 'No issues with due dates to display';
        fontSize: 14;
        yourself.
    rsCanvas add: label.
    
    "FIX: Use block with argument"
    canvas script: [ :c | rsCanvas ]
]

{ #category : 'initialization' }
IssueGanttPresenter >> showEmptyMessageOn: rsCanvas [
    | label |
    label := RSLabel new
        text: 'No issues with due dates to display';
        fontSize: 14;
        yourself.
    rsCanvas add: label.
    ^ rsCanvas
]
