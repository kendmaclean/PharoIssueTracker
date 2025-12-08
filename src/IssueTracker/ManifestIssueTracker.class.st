"
Please describe the package using the class comment of the included manifest class. The manifest class also includes other additional metadata for the package. These meta data are used by other tools such as the SmalllintManifestChecker and the critics Browser
"
Class {
	#name : 'ManifestIssueTracker',
	#superclass : 'PackageManifest',
	#category : 'IssueTracker-Manifest',
	#package : 'IssueTracker',
	#tag : 'Manifest'
}

{ #category : 'code-critics' }
ManifestIssueTracker class >> ruleCascadedNextPutAllsRuleV1FalsePositive [

	<ignoreForCoverage>
	^ #(#(#(#RGMethodDefinition #(#IssueTrackerPresenter #moveIssueUp #false)) #'2025-12-08T14:17:05.050692-05:00') )
]

{ #category : 'code-critics' }
ManifestIssueTracker class >> ruleGuardingClauseRuleV1FalsePositive [

	<ignoreForCoverage>
	^ #(#(#(#RGMethodDefinition #(#IssueTrackerPresenter #moveIssueDown #false)) #'2025-12-08T14:16:19.520577-05:00') #(#(#RGMethodDefinition #(#IssueTrackerPresenter #moveIssueUp #false)) #'2025-12-08T14:17:08.952791-05:00') )
]

{ #category : 'code-critics' }
ManifestIssueTracker class >> ruleLongMethodsRuleV1FalsePositive [

	<ignoreForCoverage>
	^ #(#(#(#RGMethodDefinition #(#IssueTrackerPresenter #updateIssueList #false)) #'2025-12-08T16:14:44.863885-05:00') )
]

{ #category : 'code-critics' }
ManifestIssueTracker class >> ruleReGuardClauseRuleV1FalsePositive [

	<ignoreForCoverage>
	^ #(#(#(#RGMethodDefinition #(#IssueTrackerPresenter #moveIssueDown #false)) #'2025-12-08T14:16:14.444313-05:00') #(#(#RGMethodDefinition #(#IssueTrackerPresenter #moveIssueUp #false)) #'2025-12-08T14:16:58.738102-05:00') )
]
