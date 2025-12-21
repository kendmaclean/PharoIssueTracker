"
IssueTrackerGanttPresenterTest comment: 'This test suite covers:
    - Initialization - presenter starts with no selection
    - hasCurrentIssue - boolean check for selection state
    - currentIssue - accessor for selected issue
    - onIssueSelected - selecting issues updates state
    - clearCurrentIssue - clearing selection
    - getFilteredIssues - returns filtered issue list
    - issueListChanged - refreshes from manager
    - filterChanged - handles filter updates
    - moveIssueUp/Down - reordering issues
    - updateMoveButtonsState - button enable/disable logic
    - updateGanttChart - chart rebuilding

"
Class {
	#name : 'IssueTrackerGanttPresenterTest',
	#superclass : 'TestCase',
	#instVars : [
		'presenter',
		'testIssue1',
		'testIssue2',
		'testIssue3'
	],
	#category : 'IssueTracker-Tests-Tests',
	#package : 'IssueTracker-Tests',
	#tag : 'Tests'
}

{ #category : 'running' }
IssueTrackerGanttPresenterTest >> setUp [
        super setUp.
        TestIssueRepository resetAll.
        IssueManager reset.

        "Point IssueManager to test repository"
        IssueManager default repository: TestIssueRepository uniqueInstance.

        "Create test issues with dates for Gantt chart"
        testIssue1 := Issue new
                title: 'First Issue';
                status: #open;
                priority: #high;
                startDate: Date today;
                duration: 5;
                yourself.

        testIssue2 := Issue new
                title: 'Second Issue';
                status: #inProgress;
                priority: #medium;
                startDate: Date today;
                duration: 3;
                yourself.

        testIssue3 := Issue new
                title: 'Closed Issue';
                status: #closed;
                priority: #low;
                startDate: (Date today subtractDays: 5);
                duration: 2;
                yourself.

        "Add via test repository"
        TestIssueRepository uniqueInstance addIssue: testIssue1.
        TestIssueRepository uniqueInstance addIssue: testIssue2.
        TestIssueRepository uniqueInstance addIssue: testIssue3.

        presenter := IssueTrackerGanttPresenter new.
]

{ #category : 'running' }
IssueTrackerGanttPresenterTest >> tearDown [
        presenter := nil.
        testIssue1 := nil.
        testIssue2 := nil.
        testIssue3 := nil.
        IssueManager reset.
        TestIssueRepository resetAll.
        super tearDown.
]

{ #category : 'tests - gantt chart' }
IssueTrackerGanttPresenterTest >> testBuildGanttChartDoesNotRaiseError [
        "Test that building the Gantt chart does not raise an error"
        self shouldnt: [ presenter buildGanttChart ] raise: Error.
]

{ #category : 'tests - gantt chart' }
IssueTrackerGanttPresenterTest >> testBuildGanttOnCanvas [
        "Test that buildGanttOn: works with a canvas"
        | canvas result |

        canvas := RSCanvas new.

        self shouldnt: [ result := presenter buildGanttOn: canvas ] raise: Error.
        self assert: result notNil.
]

{ #category : 'tests - selection' }
IssueTrackerGanttPresenterTest >> testClearCurrentIssue [
        "Test clearing the current issue"
        presenter onIssueSelected: testIssue1.
        self assert: presenter hasCurrentIssue.

        presenter clearCurrentIssue.
        self deny: presenter hasCurrentIssue.
        self assert: presenter currentIssue isNil.
]

{ #category : 'tests - selection' }
IssueTrackerGanttPresenterTest >> testCurrentIssueAccessor [
        "Test currentIssue getter"
        self assert: presenter currentIssue isNil.
        presenter onIssueSelected: testIssue1.
        self assert: presenter currentIssue equals: testIssue1.
]

{ #category : 'tests - filtering' }
IssueTrackerGanttPresenterTest >> testFilterChanged [
        "Test that filterChanged does not raise error"
        self shouldnt: [ presenter filterChanged ] raise: Error.
]

{ #category : 'tests - gantt chart' }
IssueTrackerGanttPresenterTest >> testGanttBuilderCreatedOnBuild [ 
      "Test that ganttBuilder is created when building chart"
      | builder canvas |

      canvas := RSCanvas new.
      presenter buildGanttOn: canvas.
      builder := presenter instVarNamed: 'ganttBuilder'.

      self assert: builder notNil.
      self assert: (builder isKindOf: IssueGanttChartBuilder).
 

]

{ #category : 'tests - filtering' }
IssueTrackerGanttPresenterTest >> testGetFilteredIssuesExcludesClosed [
        "Test that getFilteredIssues excludes closed issues when filter is set"
        | filtered toolbar |
        "Access toolbar via instVar and toggle hide closed"
        toolbar := presenter instVarNamed: 'toolbar'.
        toolbar instVarNamed: 'hideClosedIssues' put: true.

        filtered := presenter getFilteredIssues.
        self assert: (filtered noneSatisfy: [ :i | i status = #closed ]).
]

{ #category : 'tests - filtering' }
IssueTrackerGanttPresenterTest >> testGetFilteredIssuesExcludesResolved [
        "Test that getFilteredIssues excludes resolved issues when filter is set"
        | filtered toolbar resolvedIssue |

        "Add a resolved issue"
        resolvedIssue := Issue new
                title: 'Resolved Issue';
                status: #resolved;
                startDate: Date today;
                duration: 1;
                yourself.
        TestIssueRepository uniqueInstance addIssue: resolvedIssue.
        presenter issueListChanged.

        "Enable hide closed filter"
        toolbar := presenter instVarNamed: 'toolbar'.
        toolbar instVarNamed: 'hideClosedIssues' put: true.

        filtered := presenter getFilteredIssues.

        "Should exclude both closed and resolved"
        self assert: (filtered noneSatisfy: [ :i | i status = #resolved ]).
        self assert: (filtered noneSatisfy: [ :i | i status = #closed ]).
]

{ #category : 'tests - filtering' }
IssueTrackerGanttPresenterTest >> testGetFilteredIssuesReturnsAll [
        "Test that getFilteredIssues returns all issues with default filter"
        | filtered |
        filtered := presenter getFilteredIssues.
        self assert: filtered size equals: 3.
]

{ #category : 'tests - selection' }
IssueTrackerGanttPresenterTest >> testHasCurrentIssueWhenNil [
        "Test hasCurrentIssue returns false when no issue selected"
        self deny: presenter hasCurrentIssue.
]

{ #category : 'tests - selection' }
IssueTrackerGanttPresenterTest >> testHasCurrentIssueWhenSet [
        "Test hasCurrentIssue returns true when issue is selected"
        presenter onIssueSelected: testIssue1.
        self assert: presenter hasCurrentIssue.
]

{ #category : 'tests - initialization' }
IssueTrackerGanttPresenterTest >> testInitialization [
        "Test that presenter initializes correctly"
        self assert: presenter currentIssue isNil.
        self deny: presenter hasCurrentIssue.
]

{ #category : 'tests - issue list' }
IssueTrackerGanttPresenterTest >> testIssueListChanged [
        "Test that issueListChanged reloads issues from manager"
        | newIssue |
        newIssue := Issue new
                title: 'New Issue';
                status: #open;
                startDate: Date today;
                duration: 2;
                yourself.

        TestIssueRepository uniqueInstance addIssue: newIssue.
        presenter issueListChanged.

        self assert: presenter getFilteredIssues size equals: 4.
]

{ #category : 'tests - issue list' }
IssueTrackerGanttPresenterTest >> testIssueListChangedAfterRemovingIssue [
        "Test that issueListChanged properly updates after removing an issue"
        | countBefore countAfter |

        countBefore := presenter getFilteredIssues size.

        TestIssueRepository uniqueInstance removeIssue: testIssue1.
        presenter issueListChanged.

        countAfter := presenter getFilteredIssues size.

        self assert: countAfter equals: countBefore - 1.
]

{ #category : 'tests - integration' }
IssueTrackerGanttPresenterTest >> testIssueListChangedUpdatesButtonState [
        "Test that issueListChanged updates move button states"
        | moveUpButton moveDownButton |

        presenter onIssueSelected: testIssue1.
        presenter issueListChanged.

        moveUpButton := presenter instVarNamed: 'moveUpButton'.
        moveDownButton := presenter instVarNamed: 'moveDownButton'.

        "First issue: can move down, not up"
        self deny: moveUpButton isEnabled.
        self assert: moveDownButton isEnabled.
]

{ #category : 'tests - move issues' }
IssueTrackerGanttPresenterTest >> testMoveIssueDownLastIssue [
        "Test that moving last issue down does nothing"
        | originalLast |

        originalLast := TestIssueRepository uniqueInstance allIssues last.
        presenter onIssueSelected: testIssue3.

        presenter moveIssueDown.

        "Last issue should still be last"
        self assert: TestIssueRepository uniqueInstance allIssues last equals: originalLast.
]

{ #category : 'tests - move issues' }
IssueTrackerGanttPresenterTest >> testMoveIssueDownNoSelection [
        "Test that moveIssueDown does nothing when no issue is selected"
        | originalOrder |

        originalOrder := TestIssueRepository uniqueInstance allIssues copy.
        presenter clearCurrentIssue.

        self shouldnt: [ presenter moveIssueDown ] raise: Error.

        "Order should be unchanged"
        self assert: TestIssueRepository uniqueInstance allIssues first equals: originalOrder first.
]

{ #category : 'tests - move issues' }
IssueTrackerGanttPresenterTest >> testMoveIssueDownSuccess [
        "Test that moving issue down works correctly"
        | allIssues |

        presenter onIssueSelected: testIssue1.
        presenter moveIssueDown.

        allIssues := TestIssueRepository uniqueInstance allIssues.

        "testIssue1 should now be at position 2"
        self assert: (allIssues at: 2) equals: testIssue1.
        "testIssue2 should now be at position 1"
        self assert: (allIssues at: 1) equals: testIssue2.
]

{ #category : 'tests - move issues' }
IssueTrackerGanttPresenterTest >> testMoveIssuePreservesSelection [
        "Test that moving an issue keeps it selected"

        presenter onIssueSelected: testIssue2.
        presenter moveIssueUp.

        self assert: presenter currentIssue equals: testIssue2.
]

{ #category : 'tests - move issues' }
IssueTrackerGanttPresenterTest >> testMoveIssueUpFirstIssue [
        "Test that moving first issue up does nothing"
        | originalFirst |

        originalFirst := TestIssueRepository uniqueInstance allIssues first.
        presenter onIssueSelected: testIssue1.

        presenter moveIssueUp.

        "First issue should still be first"
        self assert: TestIssueRepository uniqueInstance allIssues first equals: originalFirst.
]

{ #category : 'tests - move issues' }
IssueTrackerGanttPresenterTest >> testMoveIssueUpNoSelection [
        "Test that moveIssueUp does nothing when no issue is selected"
        | originalOrder |

        originalOrder := TestIssueRepository uniqueInstance allIssues copy.
        presenter clearCurrentIssue.

        self shouldnt: [ presenter moveIssueUp ] raise: Error.

        "Order should be unchanged"
        self assert: TestIssueRepository uniqueInstance allIssues first equals: originalOrder first.
]

{ #category : 'tests - move issues' }
IssueTrackerGanttPresenterTest >> testMoveIssueUpSuccess [
        "Test that moving issue up works correctly"
        | allIssues |

        presenter onIssueSelected: testIssue2.
        presenter moveIssueUp.

        allIssues := TestIssueRepository uniqueInstance allIssues.

        "testIssue2 should now be at position 1"
        self assert: (allIssues at: 1) equals: testIssue2.
        "testIssue1 should now be at position 2"
        self assert: (allIssues at: 2) equals: testIssue1.
]

{ #category : 'tests - selection' }
IssueTrackerGanttPresenterTest >> testMultipleIssueSelections [
        "Test switching between issues"
        presenter onIssueSelected: testIssue1.
        self assert: presenter currentIssue title equals: 'First Issue'.

        presenter onIssueSelected: testIssue2.
        self assert: presenter currentIssue title equals: 'Second Issue'.

        presenter onIssueSelected: testIssue3.
        self assert: presenter currentIssue title equals: 'Closed Issue'.
]

{ #category : 'tests - selection' }
IssueTrackerGanttPresenterTest >> testOnIssueSelected [
        "Test that selecting an issue updates currentIssue"
        presenter onIssueSelected: testIssue2.
        self assert: presenter currentIssue equals: testIssue2.

        presenter onIssueSelected: testIssue1.
        self assert: presenter currentIssue equals: testIssue1.
]

{ #category : 'tests - selection' }
IssueTrackerGanttPresenterTest >> testOnIssueSelectedWithNil [
        "Test that selecting nil clears selection"
        presenter onIssueSelected: testIssue1.
        self assert: presenter hasCurrentIssue.

        presenter onIssueSelected: nil.
        self assert: presenter currentIssue isNil.
]

{ #category : 'tests - initialization' }
IssueTrackerGanttPresenterTest >> testPresenterHasDetailsForm [
        "Test that presenter has a details form"
        | form |

        form := presenter instVarNamed: 'detailsForm'.

        self assert: form notNil.
        self assert: (form isKindOf: IssueDetailsPresenter).
]

{ #category : 'tests - initialization' }
IssueTrackerGanttPresenterTest >> testPresenterHasGanttCanvas [
        "Test that presenter has a Gantt canvas"
        | canvas |

        canvas := presenter instVarNamed: 'ganttCanvas'.

        self assert: canvas notNil.
        self assert: (canvas isKindOf: SpRoassalPresenter).
]

{ #category : 'tests - initialization' }
IssueTrackerGanttPresenterTest >> testPresenterHasIssueManager [
        "Test that presenter has access to IssueManager"
        | manager |

        manager := presenter instVarNamed: 'issueManager'.

        self assert: manager notNil.
        self assert: (manager isKindOf: IssueManager).
]

{ #category : 'tests - initialization' }
IssueTrackerGanttPresenterTest >> testPresenterHasToolbar [
        "Test that presenter has a toolbar"
        | toolbar |

        toolbar := presenter instVarNamed: 'toolbar'.

        self assert: toolbar notNil.
        self assert: (toolbar isKindOf: IssueToolbarPresenter).
]

{ #category : 'tests - initialization' }
IssueTrackerGanttPresenterTest >> testPresenterInitializesWithIssues [
        "Test that presenter loads issues on initialization"
        | issues |

        issues := presenter instVarNamed: 'issues'.

        self assert: issues notNil.
        self assert: issues size equals: 3.
]

{ #category : 'tests - move buttons' }
IssueTrackerGanttPresenterTest >> testSelectNilDisablesMoveButtons [
        "Test that selecting nil disables move buttons"
        | moveUpButton moveDownButton |

        "First select an issue"
        presenter onIssueSelected: testIssue2.

        "Then select nil"
        presenter onIssueSelected: nil.

        moveUpButton := presenter instVarNamed: 'moveUpButton'.
        moveDownButton := presenter instVarNamed: 'moveDownButton'.

        self deny: moveUpButton isEnabled.
        self deny: moveDownButton isEnabled.
]

{ #category : 'tests - integration' }
IssueTrackerGanttPresenterTest >> testSelectingIssueUpdatesDetailsForm [
        "Test that selecting an issue updates the details form"
        | form |

        presenter onIssueSelected: testIssue1.
        form := presenter instVarNamed: 'detailsForm'.

        self assert: form titleText equals: 'First Issue'.
]

{ #category : 'tests - gantt chart' }
IssueTrackerGanttPresenterTest >> testUpdateGanttChartDoesNotRaiseError [
        "Test that updating the Gantt chart does not raise an error"
        self shouldnt: [ presenter updateGanttChart ] raise: Error.
]

{ #category : 'tests - move buttons' }
IssueTrackerGanttPresenterTest >> testUpdateMoveButtonsStateFirstIssue [
        "Test that first issue can move down but not up"
        | moveUpButton moveDownButton |

        presenter onIssueSelected: testIssue1.
        presenter updateMoveButtonsState.

        moveUpButton := presenter instVarNamed: 'moveUpButton'.
        moveDownButton := presenter instVarNamed: 'moveDownButton'.

        self deny: moveUpButton isEnabled.
        self assert: moveDownButton isEnabled.
]

{ #category : 'tests - move buttons' }
IssueTrackerGanttPresenterTest >> testUpdateMoveButtonsStateLastIssue [
        "Test that last issue can move up but not down"
        | moveUpButton moveDownButton |

        presenter onIssueSelected: testIssue3.
        presenter updateMoveButtonsState.

        moveUpButton := presenter instVarNamed: 'moveUpButton'.
        moveDownButton := presenter instVarNamed: 'moveDownButton'.

        self assert: moveUpButton isEnabled.
        self deny: moveDownButton isEnabled.
]

{ #category : 'tests - move buttons' }
IssueTrackerGanttPresenterTest >> testUpdateMoveButtonsStateMiddleIssue [
        "Test that middle issue can move both up and down"
        | moveUpButton moveDownButton |

        presenter onIssueSelected: testIssue2.
        presenter updateMoveButtonsState.

        moveUpButton := presenter instVarNamed: 'moveUpButton'.
        moveDownButton := presenter instVarNamed: 'moveDownButton'.

        self assert: moveUpButton isEnabled.
        self assert: moveDownButton isEnabled.
]

{ #category : 'tests - move buttons' }
IssueTrackerGanttPresenterTest >> testUpdateMoveButtonsStateNoSelection [
        "Test that move buttons are disabled when no issue is selected"
        | moveUpButton moveDownButton |

        presenter clearCurrentIssue.
        presenter updateMoveButtonsState.

        moveUpButton := presenter instVarNamed: 'moveUpButton'.
        moveDownButton := presenter instVarNamed: 'moveDownButton'.

        self deny: moveUpButton isEnabled.
        self deny: moveDownButton isEnabled.
]

{ #category : 'tests - view switch' }
IssueTrackerGanttPresenterTest >> testViewSwitchButtonExists [
        "Test that view switch button exists"
        | button |

        button := presenter instVarNamed: 'viewSwitchButton'.

        self assert: button notNil.
        self assert: button label equals: 'Table View'.
]
