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
IssueGanttPresenter >> buildGanttChart [
    canvas script: [ :rsCanvas | self buildGanttOn: rsCanvas ]
]

{ #category : 'initialization' }
IssueGanttPresenter >> buildGanttOn: rsCanvas [
    | issues shapes baselineDate maxDate daySpan leftMargin |
    
    issues := IssueRepository uniqueInstance allIssues 
        select: [ :issue | issue dueDate notNil ].
    
    issues ifEmpty: [ 
        ^ self showEmptyMessageOn: rsCanvas ].
    
    "Use today as baseline, or earliest creation date"
    baselineDate := Date today.
    maxDate := (issues collect: [ :i | i dueDate asDate ]) max.
    daySpan := (maxDate julianDayNumber - baselineDate julianDayNumber) max: 1.
    
    leftMargin := 100.  "Space for labels on the left"
    
    shapes := OrderedCollection new.
    
    "Create bars for each issue"
    issues withIndexDo: [ :issue :index |
        | bar width label composite daysUntilDue startX |
        
        "Calculate days from baseline to due date"
        daysUntilDue := issue dueDate asDate julianDayNumber - baselineDate julianDayNumber.
        
        "Width represents days until due"
        width := (daysUntilDue max: 1) * 20.
        
        "Start position - all bars start at leftMargin"
        startX := leftMargin.
        
        "Create bar - position it at the left edge (not centered)"
        bar := RSBox new
            width: width;
            height: 25;
            color: (self colorForStatus: issue status);
            model: issue;
            yourself.
        
        "Position bar relative to its top-left corner"
        bar translateBy: (width / 2) @ 0.  "Roassal positions from center, so offset"
        
        "Create label"
        label := RSLabel new
            text: issue title;
            fontSize: 10;
            yourself.
        
        "Position label to the right of bar"
        label translateBy: width + 10 @ 0.
        
        "Create composite with issue as model"
        composite := RSComposite new
            shapes: { bar. label };
            model: issue;
            yourself.
        
        "Position composite - all at same X (leftMargin)"
        composite translateBy: startX @ (index * 35).
        shapes add: composite.
        
        "Add tooltip to bar only"
        bar @ (RSPopup text: [ :i | 
            i title, String cr, 
            'Status: ', i status asString, String cr,
            'Priority: ', i priority asString, String cr,
            'Created: ', i createdAt asDate asString, String cr,
            'Due: ', i dueDate asDate asString ]) ].
    
    rsCanvas addAll: shapes.
    
    "Add date axis"
    self addDateAxis: rsCanvas from: baselineDate to: maxDate count: issues size leftMargin: leftMargin.
    
    "Don't auto-scale, keep actual positions"
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
