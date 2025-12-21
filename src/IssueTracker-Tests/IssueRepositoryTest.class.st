Class {
	#name : 'IssueRepositoryTest',
	#superclass : 'TestCase',
	#category : 'IssueTracker-Tests-Tests',
	#package : 'IssueTracker-Tests',
	#tag : 'Tests'
}

{ #category : 'running' }
IssueRepositoryTest >> setUp [                                                                                                                                                                             
        "Set up test fixtures before each test"                                                                                                                                                                        
        super setUp.                                                                                                                                                                                                   
        TestIssueRepository resetAll
]

{ #category : 'running' }
IssueRepositoryTest >> tearDown [                                                                                                                                                                          
        "Clean up after each test"                                                                                                                                                                                     
        TestIssueRepository resetAll.                                                                                                                                                                                  
        super tearDown
]

{ #category : 'tests - issue management' }
IssueRepositoryTest >> testAddIssue [                                                                                                                                                                      
        "Test adding an issue to the repository"                                                                                                                                                                       
        | repo issue |                                                                                                                                                                                                 
        repo := TestIssueRepository uniqueInstance.                                                                                                                                                                    
        issue := Issue new                                                                                                                                                                                             
                title: 'Test Issue';                                                                                                                                                                                        
                yourself.                                                                                                                                                                                                     
                                                                                                                                                                                                                  
        repo addIssue: issue.                                                                                                                                                                                          
                                                                                                                                                                                                                  
        self assert: repo issues size equals: 1.                                                                                                                                                                       
        self assert: (repo issues includes: issue)
]

{ #category : 'tests - issue management' }
IssueRepositoryTest >> testAddMultipleIssues [                                                                                                                                                             
        "Test adding multiple issues"                                                                                                                                                                                  
        | repo issue1 issue2 issue3 |                                                                                                                                                                                  
        repo := TestIssueRepository uniqueInstance.                                                                                                                                                                    
        issue1 := Issue new                                                                                                                                                                                            
                title: 'Issue 1';                                                                                                                                                                                           
                yourself.                                                                                                                                                                                                     
        issue2 := Issue new                                                                                                                                                                                            
                title: 'Issue 2';                                                                                                                                                                                           
                yourself.                                                                                                                                                                                                     
        issue3 := Issue new                                                                                                                                                                                            
                title: 'Issue 3';                                                                                                                                                                                           
                yourself.                                                                                                                                                                                                     
                                                                                                                                                                                                                  
        repo addIssue: issue1.                                                                                                                                                                                         
        repo addIssue: issue2.                                                                                                                                                                                         
        repo addIssue: issue3.                                                                                                                                                                                         
                                                                                                                                                                                                                  
        self assert: repo issues size equals: 3.                                                                                                                                                                       
        self assert: (repo issues includes: issue1).                                                                                                                                                                   
        self assert: (repo issues includes: issue2).                                                                                                                                                                   
        self assert: (repo issues includes: issue3)
]

{ #category : 'tests - issue management' }
IssueRepositoryTest >> testAddNilIssue [                                                                                                                                                                   
        "Test that adding nil issue raises an error"                                                                                                                                                                   
        | repo |                                                                                                                                                                                                       
        repo := TestIssueRepository uniqueInstance.                                                                                                                                                                    
                                                                                                                                                                                                                  
        self should: [ repo addIssue: nil ] raise: Error
]

{ #category : 'tests - issue management' }
IssueRepositoryTest >> testAllIssues [                                                                                                                                                                     
        "Test that allIssues returns a copy"                                                                                                                                                                           
        | repo issue allIssues |                                                                                                                                                                                       
        repo := TestIssueRepository uniqueInstance.                                                                                                                                                                    
        issue := Issue new                                                                                                                                                                                             
                title: 'Test Issue';                                                                                                                                                                                        
                yourself.                                                                                                                                                                                                     
                                                                                                                                                                                                                  
        repo addIssue: issue.                                                                                                                                                                                          
        allIssues := repo allIssues.                                                                                                                                                                                   
                                                                                                                                                                                                                  
        self assert: allIssues size equals: 1.                                                                                                                                                                         
        self assert: (allIssues includes: issue).                                                                                                                                                                      
                                                                                                                                                                                                                  
        "Verify it is a copy, not the original collection"                                                                                                                                                             
        allIssues add: (Issue new                                                                                                                                                                                      
                title: 'Another Issue';                                                                                                                                                                                     
                yourself).                                                                                                                                                                                                    
        self assert: repo issues size equals: 1
]

{ #category : 'tests - initialization' }
IssueRepositoryTest >> testInitializeLoadsExistingFile [                                                                                                                                                   
        "Test that initialization loads existing issues from file"                                                                                                                                                     
        | repo1 issue repo2 |                                                                                                                                                                                          
        repo1 := TestIssueRepository uniqueInstance.                                                                                                                                                                   
        issue := Issue new                                                                                                                                                                                             
                title: 'Persisted Issue';                                                                                                                                                                                   
                yourself.                                                                                                                                                                                                     
        repo1 addIssue: issue.                                                                                                                                                                                         
        repo1 saveToFile.                                                                                                                                                                                              
                                                                                                                                                                                                                  
        TestIssueRepository reset.                                                                                                                                                                                     
        repo2 := TestIssueRepository uniqueInstance.                                                                                                                                                                   
                                                                                                                                                                                                                  
        self assert: repo2 issues size equals: 1.                                                                                                                                                                      
        self assert: repo2 issues first title equals: 'Persisted Issue'
]

{ #category : 'tests - persistence' }
IssueRepositoryTest >> testLoadFromFile [                                                                                                                                                                  
        "Test loading issues from file"                                                                                                                                                                                
        | repo issue1 issue2 loaded |                                                                                                                                                                                  
        repo := TestIssueRepository uniqueInstance.                                                                                                                                                                    
        issue1 := Issue new                                                                                                                                                                                            
                title: 'Issue 1';                                                                                                                                                                                           
                yourself.                                                                                                                                                                                                     
        issue2 := Issue new                                                                                                                                                                                            
                title: 'Issue 2';                                                                                                                                                                                           
                yourself.                                                                                                                                                                                                     
                                                                                                                                                                                                                  
        repo addIssue: issue1.                                                                                                                                                                                         
        repo addIssue: issue2.                                                                                                                                                                                         
        repo saveToFile.                                                                                                                                                                                               
                                                                                                                                                                                                                  
        TestIssueRepository reset.                                                                                                                                                                                     
        repo := TestIssueRepository uniqueInstance.                                                                                                                                                                    
        loaded := repo loadFromFile.                                                                                                                                                                                   
                                                                                                                                                                                                                  
        self assert: loaded.                                                                                                                                                                                           
        self assert: repo issues size equals: 2
]

{ #category : 'tests - persistence' }
IssueRepositoryTest >> testLoadFromNonExistentFile [                                                                                                                                                       
        "Test loading when file does not exist returns false"                                                                                                                                                          
        | repo result |                                                                                                                                                                                                
        TestIssueRepository resetAll.                                                                                                                                                                                  
        repo := TestIssueRepository uniqueInstance.                                                                                                                                                                    
                                                                                                                                                                                                                  
        result := repo loadFromFile.                                                                                                                                                                                   
                                                                                                                                                                                                                  
        self deny: result
]

{ #category : 'tests - issue management' }
IssueRepositoryTest >> testRemoveIssue [                                                                                                                                                                   
        "Test removing an issue from the repository"                                                                                                                                                                   
        | repo issue |                                                                                                                                                                                                 
        repo := TestIssueRepository uniqueInstance.                                                                                                                                                                    
        issue := Issue new                                                                                                                                                                                             
                title: 'Test Issue';                                                                                                                                                                                        
                yourself.                                                                                                                                                                                                     
                                                                                                                                                                                                                  
        repo addIssue: issue.                                                                                                                                                                                          
        self assert: repo issues size equals: 1.                                                                                                                                                                       
                                                                                                                                                                                                                  
        repo removeIssue: issue.                                                                                                                                                                                       
        self assert: repo issues isEmpty
]

{ #category : 'tests - issue management' }
IssueRepositoryTest >> testRemoveIssueFromMultiple [                                                                                                                                                       
        "Test removing a specific issue from multiple issues"                                                                                                                                                          
        | repo issue1 issue2 issue3 |                                                                                                                                                                                  
        repo := TestIssueRepository uniqueInstance.                                                                                                                                                                    
        issue1 := Issue new                                                                                                                                                                                            
                title: 'Issue 1';                                                                                                                                                                                           
                yourself.                                                                                                                                                                                                     
        issue2 := Issue new                                                                                                                                                                                            
                title: 'Issue 2';                                                                                                                                                                                           
                yourself.                                                                                                                                                                                                     
        issue3 := Issue new                                                                                                                                                                                            
                title: 'Issue 3';                                                                                                                                                                                           
                yourself.                                                                                                                                                                                                     
                                                                                                                                                                                                                  
        repo addIssue: issue1.                                                                                                                                                                                         
        repo addIssue: issue2.                                                                                                                                                                                         
        repo addIssue: issue3.                                                                                                                                                                                         
                                                                                                                                                                                                                  
        repo removeIssue: issue2.                                                                                                                                                                                      
                                                                                                                                                                                                                  
        self assert: repo issues size equals: 2.                                                                                                                                                                       
        self assert: (repo issues includes: issue1).                                                                                                                                                                   
        self deny: (repo issues includes: issue2).                                                                                                                                                                     
        self assert: (repo issues includes: issue3)
]

{ #category : 'tests - singleton' }
IssueRepositoryTest >> testReset [

	 "Test that reset clears the singleton instance"
	| instance1 instance2 issue |
	instance1 := TestIssueRepository uniqueInstance.
	issue := Issue new
		         title: 'Test Issue';
		         yourself.
	"Add directly to issues collection to avoid auto-save"
	instance1 issues add: issue.

	TestIssueRepository reset.
	instance2 := TestIssueRepository uniqueInstance.

	self deny: instance1 identicalTo: instance2.
	self assert: instance2 issues isEmpty 
]

{ #category : 'tests - singleton' }
IssueRepositoryTest >> testResetAll [                                                                                                                                                                      
        "Test that resetAll clears both singleton and persistence file"                                                                                                                                                
        | instance persistenceFile |                                                                                                                                                                                   
        instance := TestIssueRepository uniqueInstance.                                                                                                                                                                
        instance addIssue: (Issue new                                                                                                                                                                                  
                title: 'Test Issue';                                                                                                                                                                                        
                yourself).                                                                                                                                                                                                    
        instance saveToFile.                                                                                                                                                                                           
                                                                                                                                                                                                                  
        persistenceFile := instance defaultPersistenceFileName.                                                                                                                                                        
        self assert: persistenceFile exists.                                                                                                                                                                           
                                                                                                                                                                                                                  
        TestIssueRepository resetAll.                                                                                                                                                                                  
        self deny: persistenceFile exists
]

{ #category : 'tests - singleton' }
IssueRepositoryTest >> testResetAndInitialize [
	"Test that resetAndInitialize returns a fresh instance"

	| instance1 instance2 |
	instance1 := TestIssueRepository uniqueInstance.
	instance1 addIssue: (Issue new
			 title: 'Test Issue';
			 yourself).

	instance2 := TestIssueRepository resetAndInitialize.

	self deny: instance1 identicalTo: instance2.
	self assert: instance2 issues isEmpty.
	self assert:
		instance2 identicalTo: TestIssueRepository uniqueInstance.
]

{ #category : 'tests - persistence' }
IssueRepositoryTest >> testSaveAndLoadPreservesData [                                                                                                                                                      
        "Test that save and load preserves issue data"                                                                                                                                                                 
        | repo issue1 issue2 loadedRepo loadedIssue1 loadedIssue2 |                                                                                                                                                    
        repo := TestIssueRepository uniqueInstance.                                                                                                                                                                    
                                                                                                                                                                                                                  
        issue1 := Issue new.                                                                                                                                                                                           
        issue1 title: 'Test Issue 1'.                                                                                                                                                                                
        issue1 description: 'Description 1'.                                                                                                                                                                         
        issue1 priority: #high.                                                                                                                                                                                        
        issue1 status: #inProgress.                                                                                                                                                                                    
                                                                                                                                                                                                                  
        issue2 := Issue new.                                                                                                                                                                                           
        issue2 title: 'Test Issue 2'.                                                                                                                                                                                
        issue2 description: 'Description 2'.                                                                                                                                                                         
        issue2 priority: #low.                                                                                                                                                                                         
        issue2 status: #open.                                                                                                                                                                                          
                                                                                                                                                                                                                  
        repo addIssue: issue1.                                                                                                                                                                                         
        repo addIssue: issue2.                                                                                                                                                                                         
        repo saveToFile.                                                                                                                                                                                               
                                                                                                                                                                                                                  
        TestIssueRepository reset.                                                                                                                                                                                     
        loadedRepo := TestIssueRepository uniqueInstance.                                                                                                                                                              
        loadedRepo loadFromFile.                                                                                                                                                                                       
                                                                                                                                                                                                                  
        self assert: loadedRepo issues size equals: 2.                                                                                                                                                                 
                                                                                                                                                                                                                  
        loadedIssue1 := loadedRepo issues first.                                                                                                                                                                       
        loadedIssue2 := loadedRepo issues second.                                                                                                                                                                      
                                                                                                                                                                                                                  
        self assert: loadedIssue1 title equals: 'Test Issue 1'.                                                                                                                                                      
        self assert: loadedIssue1 description equals: 'Description 1'.                                                                                                                                               
        self assert: loadedIssue1 priority equals: #high.                                                                                                                                                              
        self assert: loadedIssue1 status equals: #inProgress.                                                                                                                                                          
                                                                                                                                                                                                                  
        self assert: loadedIssue2 title equals: 'Test Issue 2'.                                                                                                                                                      
        self assert: loadedIssue2 description equals: 'Description 2'.                                                                                                                                               
        self assert: loadedIssue2 priority equals: #low.                                                                                                                                                               
        self assert: loadedIssue2 status equals: #open
]

{ #category : 'tests - persistence' }
IssueRepositoryTest >> testSaveToFile [                                                                                                                                                                    
        "Test saving issues to file"                                                                                                                                                                                   
        | repo issue result persistenceFile |                                                                                                                                                                          
        repo := TestIssueRepository uniqueInstance.                                                                                                                                                                    
        issue := Issue new                                                                                                                                                                                             
                title: 'Test Issue';                                                                                                                                                                                        
                yourself.                                                                                                                                                                                                     
        repo addIssue: issue.                                                                                                                                                                                          
                                                                                                                                                                                                                  
        result := repo saveToFile.                                                                                                                                                                                     
        persistenceFile := repo defaultPersistenceFileName.                                                                                                                                                            
                                                                                                                                                                                                                  
        self assert: result.                                                                                                                                                                                           
        self assert: persistenceFile exists
]

{ #category : 'tests - issue management' }
IssueRepositoryTest >> testSwapIssues [                                                                                                                                                                    
        "Test swapping two issues in the repository"                                                                                                                                                                   
        | repo issue1 issue2 issue3 |                                                                                                                                                                                  
        repo := TestIssueRepository uniqueInstance.                                                                                                                                                                    
        issue1 := Issue new                                                                                                                                                                                            
                title: 'Issue 1';                                                                                                                                                                                           
                yourself.                                                                                                                                                                                                     
        issue2 := Issue new                                                                                                                                                                                            
                title: 'Issue 2';                                                                                                                                                                                           
                yourself.                                                                                                                                                                                                     
        issue3 := Issue new                                                                                                                                                                                            
                title: 'Issue 3';                                                                                                                                                                                           
                yourself.                                                                                                                                                                                                     
                                                                                                                                                                                                                  
        repo addIssue: issue1.                                                                                                                                                                                         
        repo addIssue: issue2.                                                                                                                                                                                         
        repo addIssue: issue3.                                                                                                                                                                                         
                                                                                                                                                                                                                  
        repo swapIssueAt: 1 with: 3.                                                                                                                                                                                   
                                                                                                                                                                                                                  
        self assert: (repo issues at: 1) identicalTo: issue3.                                                                                                                                                          
        self assert: (repo issues at: 2) identicalTo: issue2.                                                                                                                                                          
        self assert: (repo issues at: 3) identicalTo: issue1
]

{ #category : 'tests - singleton' }
IssueRepositoryTest >> testUniqueInstance [                                                                                                                                                                
        "Test that uniqueInstance returns a singleton"                                                                                                                                                                 
        | instance1 instance2 |                                                                                                                                                                                        
        instance1 := TestIssueRepository uniqueInstance.                                                                                                                                                               
        instance2 := TestIssueRepository uniqueInstance.                                                                                                                                                               
                                                                                                                                                                                                                  
        self assert: instance1 identicalTo: instance2.                                                                                                                                                                 
        self assert: instance1 notNil
]
