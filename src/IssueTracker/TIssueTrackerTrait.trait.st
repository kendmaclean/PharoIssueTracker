Trait {
	#name : 'TIssueTrackerTrait',
	#category : 'IssueTracker',
	#package : 'IssueTracker'
}

{ #category : 'initialization' }
TIssueTrackerTrait >> colorForStatus: aStatus [
	"Copied from IssueTrackerPresenter to keep logic self-contained"

	aStatus = #open ifTrue: [ ^ Color cyan ].
	aStatus = #inProgress ifTrue: [ ^ Color orange ].
	aStatus = #resolved ifTrue: [ ^ Color green ].
	aStatus = #closed ifTrue: [ ^ Color gray ].
	aStatus = #milestone ifTrue: [ ^ Color yellow ].
	^ Color black
]
