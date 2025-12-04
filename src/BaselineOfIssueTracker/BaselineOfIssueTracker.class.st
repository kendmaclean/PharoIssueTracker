Class {
	#name : 'BaselineOfIssueTracker',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfIssueTracker',
	#package : 'BaselineOfIssueTracker'
}

{ #category : 'baselines' }
BaselineOfIssueTracker >> baseline: spec [

	<baseline>
	spec for: #common do: [ "Packages" spec package: 'IssueTracker' ]
	
"see https://github.com/pharo-open-documentation/pharo-wiki/blob/master/General/Baselines.md"
]

{ #category : 'baselines' }
BaselineOfIssueTracker >> projectClass [
	^ MetacelloCypressBaselineProject
]
