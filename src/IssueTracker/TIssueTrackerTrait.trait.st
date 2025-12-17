Trait {
	#name : 'TIssueTrackerTrait',
	#category : 'IssueTracker',
	#package : 'IssueTracker'
}

{ #category : 'initialization' }
TIssueTrackerTrait >> colorForStatus: status [
	"Return color for issue status"

	status = #open ifTrue: [ ^ Color cyan ].
	status = #inProgress ifTrue: [ ^ Color orange ].
	status = #resolved ifTrue: [ ^ Color green ].
	status = #closed ifTrue: [ ^ Color gray ].
	status = #blocked ifTrue: [ ^ Color red ].
	status = #milestone ifTrue: [ ^ Color yellow ].
	^ Color lightGray
]
