Class {
	#name : 'IssuePersistenceSettings',
	#superclass : 'SpPresenter',
	#instVars : [
		'locationLabel',
		'testButton',
		'backupButton'
	],
	#category : 'IssueTracker',
	#package : 'IssueTracker'
}

{ #category : 'instance creation' }
IssuePersistenceSettings class >> open [
	<script>
	^ self new open
]

{ #category : 'initialization' }
IssuePersistenceSettings >> createBackup [
	"Create a backup"
	| backupFile |
	backupFile := IssueRepository uniqueInstance createBackup.
	backupFile ifNotNil: [
		self inform: 'Backup created: ', backupFile basename
	] ifNil: [
		self inform: 'No issues to backup'
	]
]

{ #category : 'initialization' }
IssuePersistenceSettings >> defaultLayout [
	^ SpBoxLayout newTopToBottom
		spacing: 10;
		add: 'Persistence Settings' expand: false;
		add: 'Storage Location:' expand: false;
		add: locationLabel expand: false;
		add: (SpBoxLayout newLeftToRight
			add: testButton;
			add: backupButton;
			yourself) expand: false;
		yourself
]

{ #category : 'initialization' }
IssuePersistenceSettings >> initializePresenters [
	
	locationLabel := self newLabel
		label: IssueRepository uniqueInstance defaultPersistenceFileName fullName;
		yourself.
	
	testButton := self newButton
		label: 'Test Save/Load';
		action: [ self testPersistence ];
		yourself.
	
	backupButton := self newButton
		label: 'Create Backup Now';
		action: [ self createBackup ];
		yourself
]

{ #category : 'initialization' }
IssuePersistenceSettings >> testPersistence [
	"Test that save/load works properly"
	| repo savedOk loadedOk |
	repo := IssueRepository uniqueInstance.
	
	"Test saving"
	savedOk := repo saveToFile.
	
	savedOk ifTrue: [
		"Test loading"
		loadedOk := repo loadFromFile.
		loadedOk 
			ifTrue: [ self inform: 'Persistence test successful!' ]
			ifFalse: [ self inform: 'Load test failed!' ]
	] ifFalse: [
		self inform: 'Save test failed!'
	]
]
