Class {
	#name : 'MockIssueListOwner',
	#superclass : 'Object',
	#instVars : [
		'selectedIssue'
	],
	#category : 'IssueTracker-Tests-Tests',
	#package : 'IssueTracker-Tests',
	#tag : 'Tests'
}

{ #category : 'as yet unclassified' }
MockIssueListOwner >> issueListChanged [
      "Do nothing".
]

{ #category : 'as yet unclassified' }
MockIssueListOwner >> onIssueSelected: anIssue [
      selectedIssue := anIssue.
]

{ #category : 'as yet unclassified' }
MockIssueListOwner >> selectedIssue [
      ^ selectedIssue.
]
