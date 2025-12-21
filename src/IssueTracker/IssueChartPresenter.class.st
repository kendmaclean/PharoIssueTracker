Class {
	#name : 'IssueChartPresenter',
	#superclass : 'SpPresenter',
	#traits : 'TIssueTrackerTrait',
	#classTraits : 'TIssueTrackerTrait classTrait',
	#instVars : [
		'canvas'
	],
	#category : 'IssueTracker',
	#package : 'IssueTracker'
}

{ #category : 'instance creation' }
IssueChartPresenter class >> open [
	<script>
	^ self new open
]

{ #category : 'build' }
IssueChartPresenter >> buildChart [
	canvas script: [ :rsCanvas | self buildChartOn: rsCanvas ]
]

{ #category : 'build' }
IssueChartPresenter >> buildChartOn: rsCanvas [
      self buildChartOn: rsCanvas with: IssueManager default allIssues
]

{ #category : 'build' }
IssueChartPresenter >> buildChartOn: rsCanvas with: issues [
      | statusCounts bars maxCount |

      issues ifEmpty: [ ^ self showEmptyMessageOn: rsCanvas ].

      statusCounts := Dictionary new.
      #(open inProgress resolved closed) do: [ :status |
          statusCounts at: status put: (issues count: [ :i | i status = status ]) ].

      maxCount := statusCounts values max max: 1.

      bars := statusCounts associations collect: [ :assoc |
          | bar label composite |
          bar := RSBox new
              width: 100;
              height: (assoc value / maxCount * 250 max: 10);
              color: (self colorForStatus: assoc key);
              model: assoc;
              yourself.

          label := RSLabel new
              text: assoc key asString, String cr, assoc value asString;
              fontSize: 12;
              bold;
              yourself.

          composite := RSComposite new
              shapes: { bar. label };
              yourself ].

      rsCanvas addAll: bars.
      RSHorizontalLineLayout new gapSize: 20; on: bars.
      rsCanvas @ RSCanvasController
]

{ #category : 'initialization' }
IssueChartPresenter >> defaultLayout [
	^ SpBoxLayout newTopToBottom
		add: canvas;
		yourself
]

{ #category : 'initialization' }
IssueChartPresenter >> initializePresenters [
	canvas := self instantiate: SpRoassalPresenter.
	self buildChart
]

{ #category : 'initialization' }
IssueChartPresenter >> initializeWindow: aWindowPresenter [
	aWindowPresenter
		title: 'Issue Status Chart';
		initialExtent: 600 @ 500
]

{ #category : 'initialization' }
IssueChartPresenter >> showEmptyMessageOn: rsCanvas [
	| label |
	label := RSLabel new
		text: 'No issues to display';
		fontSize: 14;
		yourself.
	rsCanvas add: label.
	^ rsCanvas
]
