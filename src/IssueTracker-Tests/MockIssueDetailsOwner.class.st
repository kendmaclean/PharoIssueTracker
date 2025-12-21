Class {
	#name : 'MockIssueDetailsOwner',
	#superclass : 'Object',
	#instVars : [
		'currentIssue',
		'fieldChangedCount',
		'issueListChangedCount',
		'deleteRequestCount'
	],
	#category : 'IssueTracker-Tests-Tests',
	#package : 'IssueTracker-Tests',
	#tag : 'Tests'
}

{ #category : 'accessing' }
MockIssueDetailsOwner >> application [
      "Return a default Spec application for testing"
      ^ SpApplication new
  
]

{ #category : 'actions' }
MockIssueDetailsOwner >> clearCurrentIssue [
      currentIssue := nil
  
]

{ #category : 'accessing' }
MockIssueDetailsOwner >> currentIssue [
      ^ currentIssue
  
]

{ #category : 'accessing' }
MockIssueDetailsOwner >> currentIssue: anIssue [
      currentIssue := anIssue
  
]

{ #category : 'actions' }
MockIssueDetailsOwner >> deleteCurrentIssue [
      deleteRequestCount := deleteRequestCount + 1.
      currentIssue := nil
  
]

{ #category : 'accessing' }
MockIssueDetailsOwner >> deleteRequestCount [
      ^ deleteRequestCount
  
]

{ #category : 'callbacks' }
MockIssueDetailsOwner >> fieldChanged [
      fieldChangedCount := fieldChangedCount + 1
  
]

{ #category : 'accessing' }
MockIssueDetailsOwner >> fieldChangedCount [
      ^ fieldChangedCount
  
]

{ #category : 'testing' }
MockIssueDetailsOwner >> hasCurrentIssue [
      ^ currentIssue notNil
  
]

{ #category : 'initialization' }
MockIssueDetailsOwner >> initialize [
      super initialize.
      currentIssue := nil.
      fieldChangedCount := 0.
      issueListChangedCount := 0.
      deleteRequestCount := 0.
  
]

{ #category : 'callbacks' }
MockIssueDetailsOwner >> issueListChanged [
      issueListChangedCount := issueListChangedCount + 1
  
]

{ #category : 'accessing' }
MockIssueDetailsOwner >> issueListChangedCount [
      ^ issueListChangedCount
  
]
