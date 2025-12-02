Class {
	#name : 'IssueRepository',
	#superclass : 'Object',
	#instVars : [
		'issues'
	],
	#classVars : [
		'UniqueInstance'
	],
	#category : 'IssueTracker',
	#package : 'IssueTracker'
}

{ #category : 'instance creation' }
IssueRepository class >> reset [
    UniqueInstance := nil
]

{ #category : 'instance creation' }
IssueRepository class >> uniqueInstance [
    ^ UniqueInstance ifNil: [ UniqueInstance := self new ]
]

{ #category : 'initialization' }
IssueRepository >> addIssue: anIssue [
    issues add: anIssue
]

{ #category : 'initialization' }
IssueRepository >> allIssues [
    ^ issues copy
]

{ #category : 'initialization' }
IssueRepository >> initialize [
    super initialize.
    issues := OrderedCollection new
]

{ #category : 'initialization' }
IssueRepository >> issues [
    ^ issues
]

{ #category : 'initialization' }
IssueRepository >> removeIssue: anIssue [
    issues remove: anIssue
]
