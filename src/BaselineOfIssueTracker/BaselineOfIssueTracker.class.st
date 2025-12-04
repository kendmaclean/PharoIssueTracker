Class {
	#name : 'BaselineOfIssueTracker',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfIssueTracker',
	#package : 'BaselineOfIssueTracker'
}

{ #category : 'baselines' }
BaselineOfIssueTracker >> baseline: spec [

	<baseline>
	spec
		for: #common
		do: [
			"Packages"
			spec
				package: 'IssueTracker']
]

{ #category : 'baselines' }
BaselineOfIssueTracker >> projectClass [
	^ MetacelloCypressBaselineProject
]
