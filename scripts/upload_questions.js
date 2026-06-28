const fs = require('fs');
const path = require('path');

// 200 IT/CSE Quiz questions for Bangladesh IT Job Preparation (DBMS, OS, Networking, DSA, OOP, etc.)
const questions = [
  // --- DBMS (40 questions) ---
  {
    id: 'dbms_q1',
    text: 'Which normal form is based on the concept of multi-valued dependency?',
    options: ['1NF', '2NF', '3NF', '4NF'],
    correctIndex: 3,
    category: 'DBMS',
    difficulty: 'medium',
    explanation: '4NF (Fourth Normal Form) removes multi-valued dependencies.'
  },
  {
    id: 'dbms_q2',
    text: 'Which SQL command is used to add a new column to an existing table?',
    options: ['MODIFY TABLE', 'ALTER TABLE', 'UPDATE TABLE', 'ADD COLUMN'],
    correctIndex: 1,
    category: 'DBMS',
    difficulty: 'easy',
    explanation: 'ALTER TABLE table_name ADD column_name datatype is the SQL standard.'
  },
  {
    id: 'dbms_q3',
    text: 'In database systems, what does ACID stand for?',
    options: [
      'Atomicity, Consistency, Isolation, Durability',
      'Accuracy, Consistency, Integrity, Dependency',
      'Atomicity, Concurrency, Isolation, Durability',
      'Access, Control, Integration, Distribution'
    ],
    correctIndex: 0,
    category: 'DBMS',
    difficulty: 'easy',
    explanation: 'ACID properties guarantee safe transaction processing.'
  },
  {
    id: 'dbms_q4',
    text: 'A relation is in BCNF if and only if every determinant is a:',
    options: ['Primary Key', 'Candidate Key', 'Super Key', 'Foreign Key'],
    correctIndex: 2,
    category: 'DBMS',
    difficulty: 'medium',
    explanation: 'Boyce-Codd Normal Form requires every determinant to be a super key.'
  },
  {
    id: 'dbms_q5',
    text: 'Which join returns all rows from the left table, and the matched rows from the right table?',
    options: ['INNER JOIN', 'FULL JOIN', 'LEFT JOIN', 'RIGHT JOIN'],
    correctIndex: 2,
    category: 'DBMS',
    difficulty: 'easy',
    explanation: 'LEFT JOIN (or LEFT OUTER JOIN) returns all records from the left table and matched from the right.'
  },
  {
    id: 'dbms_q6',
    text: 'Which SQL clause is used to filter records after grouping them?',
    options: ['WHERE', 'HAVING', 'GROUP BY', 'ORDER BY'],
    correctIndex: 1,
    category: 'DBMS',
    difficulty: 'easy',
    explanation: 'HAVING is used to filter records after they have been summarized by GROUP BY.'
  },
  {
    id: 'dbms_q7',
    text: 'What represents the relationship between the number of entities in two entity sets?',
    options: ['Relation', 'Cardinality', 'Schema', 'Attribute'],
    correctIndex: 1,
    category: 'DBMS',
    difficulty: 'easy',
    explanation: 'Cardinality defines the numerical relationship between entity sets (e.g., 1-to-1, 1-to-many).'
  },
  {
    id: 'dbms_q8',
    text: 'Which transaction state occurs when the database guarantees that the transaction changes are permanent?',
    options: ['Active', 'Partially Committed', 'Committed', 'Failed'],
    correctIndex: 2,
    category: 'DBMS',
    difficulty: 'easy',
    explanation: 'A committed transaction state means changes are successfully saved and made permanent.'
  },
  {
    id: 'dbms_q9',
    text: 'Which schedule guarantees serializability by locking data items?',
    options: ['Two-Phase Locking (2PL)', 'Timestamp Ordering', 'Validation Protocol', 'Strict Schedule'],
    correctIndex: 0,
    category: 'DBMS',
    difficulty: 'medium',
    explanation: '2PL ensures serializability by using growing (locking) and shrinking (unlocking) phases.'
  },
  {
    id: 'dbms_q10',
    text: 'What prevents two users from updating the same record at the same time?',
    options: ['Deadlock', 'Concurrency Control', 'Indexing', 'Normalization'],
    correctIndex: 1,
    category: 'DBMS',
    difficulty: 'easy',
    explanation: 'Concurrency control mechanisms (like locking) manage simultaneous execution of transactions.'
  },
  {
    id: 'dbms_q11',
    text: 'Which type of index is created automatically when a primary key is defined?',
    options: ['Clustered Index', 'Non-clustered Index', 'B-Tree Index', 'Bitmap Index'],
    correctIndex: 0,
    category: 'DBMS',
    difficulty: 'medium',
    explanation: 'Most relational databases automatically create a clustered index on the primary key.'
  },
  {
    id: 'dbms_q12',
    text: 'What is a minimal super key called?',
    options: ['Primary Key', 'Foreign Key', 'Candidate Key', 'Composite Key'],
    correctIndex: 2,
    category: 'DBMS',
    difficulty: 'easy',
    explanation: 'A candidate key is a super key with no redundant attributes (minimal super key).'
  },
  {
    id: 'dbms_q13',
    text: 'Which anomaly occurs when deleting one set of data causes unintended loss of other unrelated data?',
    options: ['Insertion Anomaly', 'Deletion Anomaly', 'Update Anomaly', 'Redundancy Anomaly'],
    correctIndex: 1,
    category: 'DBMS',
    difficulty: 'easy',
    explanation: 'Deletion anomalies cause unrelated data to be lost when deleting a record.'
  },
  {
    id: 'dbms_q14',
    text: 'Which normal form is violated if a non-prime attribute depends on a part of a composite candidate key?',
    options: ['1NF', '2NF', '3NF', 'BCNF'],
    correctIndex: 1,
    category: 'DBMS',
    difficulty: 'medium',
    explanation: '2NF prohibits partial dependency, where non-prime attributes depend on subset of candidate key.'
  },
  {
    id: 'dbms_q15',
    text: 'What is a transitive dependency in relational databases?',
    options: [
      'A depends on B and B depends on C, leading to A depending on C',
      'Non-prime depends on primary key',
      'Primary key depends on foreign key',
      'Dependency between columns of different tables'
    ],
    correctIndex: 0,
    category: 'DBMS',
    difficulty: 'medium',
    explanation: 'Transitive dependency occurs when A -> B and B -> C, then A -> C (violates 3NF).'
  },
  {
    id: 'dbms_q16',
    text: 'Which lock allows multiple transactions to read a data item concurrently but none to modify it?',
    options: ['Exclusive Lock', 'Shared Lock', 'Intention Lock', 'Deadlock'],
    correctIndex: 1,
    category: 'DBMS',
    difficulty: 'easy',
    explanation: 'Shared locks (S-locks) allow concurrent read access but block exclusive write locks.'
  },
  {
    id: 'dbms_q17',
    text: 'In ER diagrams, a double ellipse represents what kind of attribute?',
    options: ['Multivalued attribute', 'Derived attribute', 'Composite attribute', 'Key attribute'],
    correctIndex: 0,
    category: 'DBMS',
    difficulty: 'medium',
    explanation: 'Double ellipses (or double outlines) depict multivalued attributes.'
  },
  {
    id: 'dbms_q18',
    text: 'What is the SQL command to delete all records from a table without deleting the table structure itself?',
    options: ['DROP TABLE', 'TRUNCATE TABLE', 'REMOVE TABLE', 'DELETE ALL'],
    correctIndex: 1,
    category: 'DBMS',
    difficulty: 'easy',
    explanation: 'TRUNCATE deletes all rows and releases storage without removing the table schema.'
  },
  {
    id: 'dbms_q19',
    text: 'Which command is classified under DDL (Data Definition Language)?',
    options: ['INSERT', 'UPDATE', 'CREATE', 'SELECT'],
    correctIndex: 2,
    category: 'DBMS',
    difficulty: 'easy',
    explanation: 'CREATE, ALTER, DROP, and TRUNCATE are DDL statements.'
  },
  {
    id: 'dbms_q20',
    text: 'What ensures database consistency by reversing changes if a transaction fails?',
    options: ['ROLLBACK', 'COMMIT', 'SAVEPOINT', 'GRANT'],
    correctIndex: 0,
    category: 'DBMS',
    difficulty: 'easy',
    explanation: 'ROLLBACK restores the database to its state prior to the start of the transaction.'
  },
  {
    id: 'dbms_q21',
    text: 'Which DBMS component is responsible for retrieving and executing SQL commands?',
    options: ['Database Manager', 'Query Optimizer', 'Storage Engine', 'Query Processor'],
    correctIndex: 3,
    category: 'DBMS',
    difficulty: 'medium',
    explanation: 'The Query Processor parses, optimizes, compiles, and executes queries.'
  },
  {
    id: 'dbms_q22',
    text: 'What is the standard port for Oracle Database listener?',
    options: ['1433', '1521', '3306', '5432'],
    correctIndex: 1,
    category: 'DBMS',
    difficulty: 'medium',
    explanation: '1521 is standard for Oracle, 3306 for MySQL, 5432 for Postgres, and 1433 for MSSQL.'
  },
  {
    id: 'dbms_q23',
    text: 'Which constraint enforces that all values in a column are distinct?',
    options: ['FOREIGN KEY', 'NOT NULL', 'UNIQUE', 'CHECK'],
    correctIndex: 2,
    category: 'DBMS',
    difficulty: 'easy',
    explanation: 'UNIQUE constraint guarantees that all data values in the field are unique.'
  },
  {
    id: 'dbms_q24',
    text: 'A table is in 3NF if it is in 2NF and has no:',
    options: ['Partial dependency', 'Transitive dependency', 'Multi-valued dependency', 'Join dependency'],
    correctIndex: 1,
    category: 'DBMS',
    difficulty: 'easy',
    explanation: '3NF eliminates transitive dependencies (where a non-prime attribute depends on another non-prime).'
  },
  {
    id: 'dbms_q25',
    text: 'Which normal form requires relations to have atomic values and no repeating groups?',
    options: ['1NF', '2NF', '3NF', 'BCNF'],
    correctIndex: 0,
    category: 'DBMS',
    difficulty: 'easy',
    explanation: '1NF requires data in all attributes to be atomic (indivisible) with no repeating groups.'
  },
  {
    id: 'dbms_q26',
    text: 'Which operator is used to combine the results of two SELECT statements, removing duplicates?',
    options: ['UNION', 'UNION ALL', 'INTERSECT', 'EXCEPT'],
    correctIndex: 0,
    category: 'DBMS',
    difficulty: 'easy',
    explanation: 'UNION merges results and excludes duplicates; UNION ALL includes duplicates.'
  },
  {
    id: 'dbms_q27',
    text: 'What is the default isolation level in MySQL InnoDB storage engine?',
    options: ['READ UNCOMMITTED', 'READ COMMITTED', 'REPEATABLE READ', 'SERIALIZABLE'],
    correctIndex: 2,
    category: 'DBMS',
    difficulty: 'hard',
    explanation: 'InnoDB default transaction isolation level is REPEATABLE READ.'
  },
  {
    id: 'dbms_q28',
    text: 'Which integrity rule states that no primary key attribute can be null?',
    options: ['Referential Integrity', 'Entity Integrity', 'Domain Integrity', 'Key Integrity'],
    correctIndex: 1,
    category: 'DBMS',
    difficulty: 'easy',
    explanation: 'Entity integrity rule states that primary keys must have unique and non-null values.'
  },
  {
    id: 'dbms_q29',
    text: 'What enforces that a foreign key value must match an existing primary key value in the referenced table?',
    options: ['Entity Integrity', 'Referential Integrity', 'Domain Integrity', 'Check Constraint'],
    correctIndex: 1,
    category: 'DBMS',
    difficulty: 'easy',
    explanation: 'Referential integrity maintains consistent relationships between foreign and primary key records.'
  },
  {
    id: 'dbms_q30',
    text: 'What is the purpose of database indexing?',
    options: ['Speed up data retrieval', 'Enhance security', 'Reduce database size', 'Enforce normalization'],
    correctIndex: 0,
    category: 'DBMS',
    difficulty: 'easy',
    explanation: 'Indexes provide faster access paths to database rows, improving query speeds.'
  },
  {
    id: 'dbms_q31',
    text: 'In NoSQL systems, MongoDB is classified as which type of database?',
    options: ['Key-value store', 'Document-oriented', 'Wide-column store', 'Graph database'],
    correctIndex: 1,
    category: 'DBMS',
    difficulty: 'easy',
    explanation: 'MongoDB stores records as BSON documents, making it document-oriented.'
  },
  {
    id: 'dbms_q32',
    text: 'Which database backup contains all changes made since the last FULL backup?',
    options: ['Differential Backup', 'Incremental Backup', 'Mirror Backup', 'Transactional Backup'],
    correctIndex: 0,
    category: 'DBMS',
    difficulty: 'medium',
    explanation: 'Differential backup stores all data changed since the last full backup.'
  },
  {
    id: 'dbms_q33',
    text: 'What index structure is most widely used by relational databases?',
    options: ['Hash Index', 'B+ Tree Index', 'Inverted Index', 'R-Tree Index'],
    correctIndex: 1,
    category: 'DBMS',
    difficulty: 'medium',
    explanation: 'B+ Tree indexes keep data sorted and allow search, sequential access, inserts, and deletes in logarithmic time.'
  },
  {
    id: 'dbms_q34',
    text: 'What does a database trigger do?',
    options: [
      'Executes automatically in response to certain events on a table',
      'Starts the database listener',
      'Performs table indexing',
      'Validates normalization levels'
    ],
    correctIndex: 0,
    category: 'DBMS',
    difficulty: 'easy',
    explanation: 'A trigger is precompiled SQL code executed automatically when DML modifications occur.'
  },
  {
    id: 'dbms_q35',
    text: 'Which concurrency anomaly occurs when a transaction reads updated data that has not been committed yet?',
    options: ['Dirty Read', 'Non-repeatable Read', 'Phantom Read', 'Lost Update'],
    correctIndex: 0,
    category: 'DBMS',
    difficulty: 'medium',
    explanation: 'Dirty reads happen when reading changes made by another uncommitted transaction (later rolled back).'
  },
  {
    id: 'dbms_q36',
    text: 'What SQL function returns the number of items in a group?',
    options: ['SUM()', 'COUNT()', 'AVG()', 'TOTAL()'],
    correctIndex: 1,
    category: 'DBMS',
    difficulty: 'easy',
    explanation: 'COUNT() returns the count of matching rows in queries.'
  },
  {
    id: 'dbms_q37',
    text: 'What SQL operator matches pattern values using wildcards?',
    options: ['IN', 'BETWEEN', 'LIKE', 'EXISTS'],
    correctIndex: 2,
    category: 'DBMS',
    difficulty: 'easy',
    explanation: 'LIKE operator matches wildcard patterns (using % and _).'
  },
  {
    id: 'dbms_q38',
    text: 'What represents the logical layout or structure of the entire database?',
    options: ['Database Instance', 'Database Schema', 'Database Catalog', 'Subschema'],
    correctIndex: 1,
    category: 'DBMS',
    difficulty: 'easy',
    explanation: 'Schema represents the complete structural description of database elements.'
  },
  {
    id: 'dbms_q39',
    text: 'In SQL, which constraint validates that input data matches a boolean condition?',
    options: ['DEFAULT', 'UNIQUE', 'CHECK', 'INDEX'],
    correctIndex: 2,
    category: 'DBMS',
    difficulty: 'easy',
    explanation: 'CHECK constraints evaluate inputs against conditions (e.g., CHECK (age >= 18)).'
  },
  {
    id: 'dbms_q40',
    text: 'Which DML command adds new records into database tables?',
    options: ['ADD', 'CREATE', 'INSERT', 'UPDATE'],
    correctIndex: 2,
    category: 'DBMS',
    difficulty: 'easy',
    explanation: 'INSERT INTO is used to insert new records.'
  },

  // --- OPERATING SYSTEMS (40 questions) ---
  {
    id: 'os_q1',
    text: 'Which scheduling algorithm is non-preemptive and selects the process with the shortest execution time?',
    options: ['Round Robin', 'Priority Scheduling', 'Shortest Job First (SJF)', 'Shortest Remaining Time First (SRTF)'],
    correctIndex: 2,
    category: 'Operating System',
    difficulty: 'medium',
    explanation: 'SJF is non-preemptive. SRTF is the preemptive version of SJF.'
  },
  {
    id: 'os_q2',
    text: 'What is a situation where two or more processes are blocked indefinitely, waiting for resources held by each other?',
    options: ['Starvation', 'Deadlock', 'Race Condition', 'Context Switch'],
    correctIndex: 1,
    category: 'Operating System',
    difficulty: 'easy',
    explanation: 'Deadlock describes a state where circular dependencies prevent progress.'
  },
  {
    id: 'os_q3',
    text: 'Which page replacement algorithm replaces the page that has not been used for the longest period of time?',
    options: ['FIFO', 'Optimal', 'Least Recently Used (LRU)', 'MRU'],
    correctIndex: 2,
    category: 'Operating System',
    difficulty: 'easy',
    explanation: 'LRU tracks reference times and evicts the page unreferenced for the longest duration.'
  },
  {
    id: 'os_q4',
    text: 'What is the term for swapping process fragments from secondary storage (disk) to main memory (RAM) dynamically?',
    options: ['Paging', 'Subnetting', 'Virtual Memory', 'Thrashing'],
    correctIndex: 2,
    category: 'Operating System',
    difficulty: 'medium',
    explanation: 'Virtual memory separates user logical memory from physical RAM, using swap space.'
  },
  {
    id: 'os_q5',
    text: 'Which OS concept uses semaphores to coordinate access to shared critical sections?',
    options: ['Context Switching', 'Process Synchronization', 'Deadlock Avoidance', 'CPU Scheduling'],
    correctIndex: 1,
    category: 'Operating System',
    difficulty: 'medium',
    explanation: 'Process synchronization uses mutexes and semaphores to avoid race conditions.'
  },
  {
    id: 'os_q6',
    text: 'What is the core component of an Operating System that manages system resources and CPU communication?',
    options: ['Shell', 'Kernel', 'Command Prompt', 'BIOS'],
    correctIndex: 1,
    category: 'Operating System',
    difficulty: 'easy',
    explanation: 'The kernel is the central core of an OS, acting as the interface between software and hardware.'
  },
  {
    id: 'os_q7',
    text: 'What is a lightweight process that shares the code, data, and resources of its parent process?',
    options: ['Daemon', 'Thread', 'Child Process', 'Zombie Process'],
    correctIndex: 1,
    category: 'Operating System',
    difficulty: 'easy',
    explanation: 'A thread is a basic unit of CPU utilization that shares memory context with parent processes.'
  },
  {
    id: 'os_q8',
    text: 'Which of the following is NOT a necessary condition for deadlock to occur?',
    options: ['Mutual Exclusion', 'No Preemption', 'Hold and Wait', 'Preemption'],
    correctIndex: 3,
    category: 'Operating System',
    difficulty: 'medium',
    explanation: 'Deadlock requirements are: Mutual Exclusion, Hold & Wait, No Preemption, and Circular Wait.'
  },
  {
    id: 'os_q9',
    text: 'What causes a CPU to save the state of the current process and load the state of another ready process?',
    options: ['Page Fault', 'Context Switch', 'System Call', 'Thrashing'],
    correctIndex: 1,
    category: 'Operating System',
    difficulty: 'easy',
    explanation: 'Context switching swaps running process execution states to support multi-tasking.'
  },
  {
    id: 'os_q10',
    text: 'Which type of memory fragmentation occurs when total memory space is enough, but it is not contiguous?',
    options: ['Internal Fragmentation', 'External Fragmentation', 'Segment Fragmentation', 'Virtual Fragmentation'],
    correctIndex: 1,
    category: 'Operating System',
    difficulty: 'medium',
    explanation: 'External fragmentation occurs when empty slots are broken up into small separate chunks.'
  },
  {
    id: 'os_q11',
    text: 'What happens when a process attempts to access a page that is mapped to logical address space but not currently in RAM?',
    options: ['System Error', 'Interrupt Exception', 'Page Fault', 'Segment Fault'],
    correctIndex: 2,
    category: 'Operating System',
    difficulty: 'easy',
    explanation: 'A page fault is an exception raised when a requested memory page is missing from physical memory.'
  },
  {
    id: 'os_q12',
    text: 'What is the state of a process that is completed but still has an entry in the process table?',
    options: ['Orphan Process', 'Zombie Process', 'Daemon Process', 'Blocked Process'],
    correctIndex: 1,
    category: 'Operating System',
    difficulty: 'medium',
    explanation: 'A zombie process is finished executing but its exit code is unread by the parent.'
  },
  {
    id: 'os_q13',
    text: 'Which algorithm is used in Operating Systems to avoid deadlocks by dynamically evaluating resource allocations?',
    options: ['Round Robin', 'Banker Algorithm', 'Kruskal Algorithm', 'Dijkstra Algorithm'],
    correctIndex: 1,
    category: 'Operating System',
    difficulty: 'hard',
    explanation: 'Bankers algorithm tests resource claims safety to avoid entering unsafe deadlock states.'
  },
  {
    id: 'os_q14',
    text: 'What mechanism translates logical memory addresses into physical RAM addresses?',
    options: ['ALU', 'BIOS', 'MMU (Memory Management Unit)', 'Direct Memory Access'],
    correctIndex: 2,
    category: 'Operating System',
    difficulty: 'medium',
    explanation: 'MMU is the hardware unit that maps logical virtual memory addresses to physical RAM.'
  },
  {
    id: 'os_q15',
    text: 'What is the term for a high page fault rate that leads to the OS spending more time swapping pages than executing processes?',
    options: ['Caching', 'Starvation', 'Thrashing', 'Context Switching'],
    correctIndex: 2,
    category: 'Operating System',
    difficulty: 'medium',
    explanation: 'Thrashing occurs when active pages are constantly swapped in and out of virtual storage.'
  },
  {
    id: 'os_q16',
    text: 'Which CPU scheduling algorithm gives a fixed execution time slice (quantum) to each ready process?',
    options: ['First Come First Served', 'Shortest Job First', 'Round Robin', 'Priority Scheduling'],
    correctIndex: 2,
    category: 'Operating System',
    difficulty: 'easy',
    explanation: 'Round Robin allocates a cyclic time quantum slice to ready processes.'
  },
  {
    id: 'os_q17',
    text: 'Which signal is used to terminate a process in Linux immediately and cannot be caught or ignored?',
    options: ['SIGINT', 'SIGTERM', 'SIGKILL', 'SIGQUIT'],
    correctIndex: 2,
    category: 'Operating System',
    difficulty: 'medium',
    explanation: 'SIGKILL (signal 9) forces immediate termination and cannot be handled or caught.'
  },
  {
    id: 'os_q18',
    text: 'What OS concept allows users to run commands via text input interfaces?',
    options: ['GUI', 'Kernel', 'CLI / Shell', 'Registry'],
    correctIndex: 2,
    category: 'Operating System',
    difficulty: 'easy',
    explanation: 'A shell is a command-line interface (CLI) that acts as the user command interpreter.'
  },
  {
    id: 'os_q19',
    text: 'What is the first sector of a bootable disk containing instructions to load the operating system?',
    options: ['FAT', 'BIOS', 'MBR (Master Boot Record)', 'Superblock'],
    correctIndex: 2,
    category: 'Operating System',
    difficulty: 'medium',
    explanation: 'MBR contains primary partition details and the initial boot loader code.'
  },
  {
    id: 'os_q20',
    text: 'What type of scheduling policy is used in real-time systems to guarantee responses to critical inputs?',
    options: ['Preemptive scheduling', 'Deterministic scheduling', 'Cooperative scheduling', 'FIFO scheduling'],
    correctIndex: 1,
    category: 'Operating System',
    difficulty: 'hard',
    explanation: 'Real-time operating systems require deterministic CPU scheduling to hit strict deadlines.'
  },
  {
    id: 'os_q21',
    text: 'Which system call in Unix-like systems creates a copy of the current process?',
    options: ['exec()', 'fork()', 'wait()', 'spawn()'],
    correctIndex: 1,
    category: 'Operating System',
    difficulty: 'medium',
    explanation: 'fork() clones the calling process, creating a new child process.'
  },
  {
    id: 'os_q22',
    text: 'Which partition format is standard for Windows Operating Systems today?',
    options: ['FAT32', 'ext4', 'NTFS', 'APFS'],
    correctIndex: 2,
    category: 'Operating System',
    difficulty: 'easy',
    explanation: 'NTFS (New Technology File System) is the default windows filesystem.'
  },
  {
    id: 'os_q23',
    text: 'What is a process that has been created but is not yet loaded into RAM called?',
    options: ['Running State', 'Ready State', 'New State', 'Terminated State'],
    correctIndex: 2,
    category: 'Operating System',
    difficulty: 'easy',
    explanation: 'The new process state represents a process being created but not loaded into main memory.'
  },
  {
    id: 'os_q24',
    text: 'Which scheduling algorithm runs the risk of starving low-priority processes indefinitely?',
    options: ['FIFO', 'Round Robin', 'Priority Scheduling', 'SJF'],
    correctIndex: 2,
    category: 'Operating System',
    difficulty: 'easy',
    explanation: 'Priority scheduling may lead to starvation if high-priority processes block CPU access.'
  },
  {
    id: 'os_q25',
    text: 'How can starvation in priority scheduling be resolved?',
    options: ['Context Switch', 'Aging', 'Paging', 'Thrashing'],
    correctIndex: 1,
    category: 'Operating System',
    difficulty: 'medium',
    explanation: 'Aging gradually increments process priority levels as they wait ready in the queue.'
  },
  {
    id: 'os_q26',
    text: 'What is the term for the storage space used when virtual memory exceeds physical RAM?',
    options: ['Cache partition', 'Swap space', 'Buffer pool', 'Disk allocation'],
    correctIndex: 1,
    category: 'Operating System',
    difficulty: 'easy',
    explanation: 'Swap space on hard disks holds inactive pages swapped out of RAM.'
  },
  {
    id: 'os_q27',
    text: 'In virtual memory systems, what defines the fixed-size blocks of logical memory?',
    options: ['Segments', 'Pages', 'Frames', 'Sectors'],
    correctIndex: 1,
    category: 'Operating System',
    difficulty: 'medium',
    explanation: 'Logical memory is split into Pages, while physical memory is split into Frames.'
  },
  {
    id: 'os_q28',
    text: 'What defines the fixed-size blocks of physical memory?',
    options: ['Pages', 'Frames', 'Segments', 'Blocks'],
    correctIndex: 1,
    category: 'Operating System',
    difficulty: 'medium',
    explanation: 'Frames are the structural memory slots in RAM that contain pages.'
  },
  {
    id: 'os_q29',
    text: 'Which registry holds the hardware and system details in Windows?',
    options: ['Windows Kernel', 'Windows Registry', 'System Registry', 'Boot Loader'],
    correctIndex: 1,
    category: 'Operating System',
    difficulty: 'easy',
    explanation: 'The Windows Registry stores configuration settings for hardware, OS, and applications.'
  },
  {
    id: 'os_q30',
    text: 'Which condition defines a system where a single program runs exclusively until it terminates?',
    options: ['Multitasking', 'Uniprogramming', 'Multithreading', 'Time-sharing'],
    correctIndex: 1,
    category: 'Operating System',
    difficulty: 'easy',
    explanation: 'Uniprogramming systems run only a single program at a time.'
  },
  {
    id: 'os_q31',
    text: 'What program translates high-level system calls into assembly commands for the kernel?',
    options: ['BIOS', 'Compiler', 'Device Driver', 'API wrapper'],
    correctIndex: 2,
    category: 'Operating System',
    difficulty: 'medium',
    explanation: 'Device drivers are specialized programs that translate generic OS calls to hardware tasks.'
  },
  {
    id: 'os_q32',
    text: 'What is the purpose of dirty bit in paging systems?',
    options: [
      'Indicate if a page has been modified since it was loaded into RAM',
      'Track page usage frequencies',
      'Validate if a page contains errors',
      'Determine page replacement priority'
    ],
    correctIndex: 0,
    category: 'Operating System',
    difficulty: 'hard',
    explanation: 'The dirty bit indicates that page content was modified in RAM and must be written to disk when evicted.'
  },
  {
    id: 'os_q33',
    text: 'Which component coordinates hardware device resources before OS loading?',
    options: ['Kernel', 'BIOS', 'MBR', 'Windows Boot Manager'],
    correctIndex: 1,
    category: 'Operating System',
    difficulty: 'easy',
    explanation: 'BIOS (Basic Input/Output System) executes hardware configuration tests prior to bootstrap.'
  },
  {
    id: 'os_q34',
    text: 'What condition represents a child process whose parent has terminated?',
    options: ['Zombie process', 'Orphan process', 'Daemon process', 'Sleeping process'],
    correctIndex: 1,
    category: 'Operating System',
    difficulty: 'medium',
    explanation: 'Orphan processes have no parent, and are typically adopted by the init/systemd daemon.'
  },
  {
    id: 'os_q35',
    text: 'What scheduling queue holds processes waiting for I/O operations?',
    options: ['Job Queue', 'Ready Queue', 'Device Queue', 'Terminated Queue'],
    correctIndex: 2,
    category: 'Operating System',
    difficulty: 'medium',
    explanation: 'The Device Queue holds processes currently waiting for dedicated I/O devices.'
  },
  {
    id: 'os_q36',
    text: 'What refers to a program in execution?',
    options: ['Instruction', 'Code block', 'Process', 'System call'],
    correctIndex: 2,
    category: 'Operating System',
    difficulty: 'easy',
    explanation: 'A process is an active instance of a computer program being executed.'
  },
  {
    id: 'os_q37',
    text: 'Which memory allocation scheme assigns the smallest block that is big enough?',
    options: ['First Fit', 'Best Fit', 'Worst Fit', 'Next Fit'],
    correctIndex: 1,
    category: 'Operating System',
    difficulty: 'medium',
    explanation: 'Best Fit searches all available holes to allocate the smallest space that satisfies requests.'
  },
  {
    id: 'os_q38',
    text: 'Which memory allocation scheme assigns the largest block that is big enough?',
    options: ['First Fit', 'Best Fit', 'Worst Fit', 'Next Fit'],
    correctIndex: 2,
    category: 'Operating System',
    difficulty: 'medium',
    explanation: 'Worst Fit assigns the largest hole, leaving the largest remaining free fragment.'
  },
  {
    id: 'os_q39',
    text: 'What occurs when page replacement algorithms violate expected behavior by increasing page faults when frames increase?',
    options: ['Belady Anomaly', 'Thrashing', 'External Fragmentation', 'Critical Section Fault'],
    correctIndex: 0,
    category: 'Operating System',
    difficulty: 'hard',
    explanation: 'Belady anomaly affects FIFO page replacement, causing higher faults as physical frames increase.'
  },
  {
    id: 'os_q40',
    text: 'What is a region of code that must not be accessed by more than one process at a time?',
    options: ['Shared resource', 'Critical Section', 'Mutual Exclusion', 'Blocked Queue'],
    correctIndex: 1,
    category: 'Operating System',
    difficulty: 'easy',
    explanation: 'The Critical Section is a segment of code where shared resources are modified.'
  },

  // --- NETWORKING (40 questions) ---
  {
    id: 'net_q1',
    text: 'What is the size of an IPv6 address?',
    options: ['32 bits', '64 bits', '128 bits', '256 bits'],
    correctIndex: 2,
    category: 'Networking',
    difficulty: 'easy',
    explanation: 'IPv6 uses 128-bit addresses (8 groups of 4 hexadecimal characters).'
  },
  {
    id: 'net_q2',
    text: 'Which OSI layer is responsible for logical routing and path determination?',
    options: ['Data Link Layer', 'Network Layer', 'Transport Layer', 'Physical Layer'],
    correctIndex: 1,
    category: 'Networking',
    difficulty: 'easy',
    explanation: 'The Network Layer handles logical IP addressing, routing, and package forwarding.'
  },
  {
    id: 'net_q3',
    text: 'What is the default subnet mask for a Class C IP address?',
    options: ['255.0.0.0', '255.255.0.0', '255.255.255.0', '255.255.255.255'],
    correctIndex: 2,
    category: 'Networking',
    difficulty: 'easy',
    explanation: 'Class C CIDR /24 translates to 255.255.255.0.'
  },
  {
    id: 'net_q4',
    text: 'Which protocol is connectionless and does not guarantee packet delivery?',
    options: ['TCP', 'UDP', 'HTTP', 'FTP'],
    correctIndex: 1,
    category: 'Networking',
    difficulty: 'easy',
    explanation: 'UDP (User Datagram Protocol) is connectionless, offering faster transmission without guarantees.'
  },
  {
    id: 'net_q5',
    text: 'What port number is standard for HTTPS?',
    options: ['80', '443', '22', '8080'],
    correctIndex: 1,
    category: 'Networking',
    difficulty: 'easy',
    explanation: 'HTTPS runs on port 443. HTTP runs on port 80.'
  },
  {
    id: 'net_q6',
    text: 'Which protocol translates domain names into IP addresses?',
    options: ['DHCP', 'DNS', 'ARP', 'NAT'],
    correctIndex: 1,
    category: 'Networking',
    difficulty: 'easy',
    explanation: 'DNS (Domain Name System) translates names (google.com) to IP addresses.'
  },
  {
    id: 'net_q7',
    text: 'What protocol is used to dynamically assign IP addresses to devices on a network?',
    options: ['DNS', 'DHCP', 'ARP', 'SNMP'],
    correctIndex: 1,
    category: 'Networking',
    difficulty: 'easy',
    explanation: 'DHCP (Dynamic Host Configuration Protocol) automatically leases IP details to clients.'
  },
  {
    id: 'net_q8',
    text: 'Which networking device operates primarily at the Data Link Layer (Layer 2)?',
    options: ['Router', 'Switch', 'Hub', 'Repeater'],
    correctIndex: 1,
    category: 'Networking',
    difficulty: 'easy',
    explanation: 'Switches read MAC addresses to route frames inside local networks (Layer 2).'
  },
  {
    id: 'net_q9',
    text: 'What is the purpose of ARP (Address Resolution Protocol)?',
    options: [
      'Map domain names to IP addresses',
      'Map IP addresses to MAC addresses',
      'Forward packets between subnets',
      'Translate private IPs to public IPs'
    ],
    correctIndex: 1,
    category: 'Networking',
    difficulty: 'medium',
    explanation: 'ARP translates a known Layer 3 logical IP to a Layer 2 physical MAC address.'
  },
  {
    id: 'net_q10',
    text: 'Which routing protocol is categorized as an Exterior Gateway Protocol (EGP)?',
    options: ['OSPF', 'RIP', 'BGP', 'EIGRP'],
    correctIndex: 2,
    category: 'Networking',
    difficulty: 'hard',
    explanation: 'BGP (Border Gateway Protocol) routing manages internet routing between Autonomous Systems.'
  },
  {
    id: 'net_q11',
    text: 'What is the term for translating private network IP addresses to public IPs?',
    options: ['Subnetting', 'NAT (Network Address Translation)', 'Routing', 'VLAN tagging'],
    correctIndex: 1,
    category: 'Networking',
    difficulty: 'medium',
    explanation: 'NAT maps private local addresses to single public internet IPs to preserve address space.'
  },
  {
    id: 'net_q12',
    text: 'Which Layer 4 protocol uses a 3-way handshake to establish connections?',
    options: ['UDP', 'ICMP', 'TCP', 'IP'],
    correctIndex: 2,
    category: 'Networking',
    difficulty: 'medium',
    explanation: 'TCP connections use SYN, SYN-ACK, and ACK handshake sequence.'
  },
  {
    id: 'net_q13',
    text: 'In CIDR notation /26, how many host addresses are available per subnet?',
    options: ['32', '62', '64', '126'],
    correctIndex: 1,
    category: 'Networking',
    difficulty: 'hard',
    explanation: '/26 leaves 32 - 26 = 6 host bits. 2^6 - 2 = 62 usable host addresses (subtracting network and broadcast).'
  },
  {
    id: 'net_q14',
    text: 'Which Layer 4 header field is used to detect errors in transit?',
    options: ['Sequence Number', 'Window Size', 'Checksum', 'Port Number'],
    correctIndex: 2,
    category: 'Networking',
    difficulty: 'medium',
    explanation: 'The Checksum verifies the integrity of the segment payload and headers.'
  },
  {
    id: 'net_q15',
    text: 'What is the default port for SSH (Secure Shell)?',
    options: ['21', '22', '23', '25'],
    correctIndex: 1,
    category: 'Networking',
    difficulty: 'easy',
    explanation: 'SSH operates on port 22. Telnet runs on 23, FTP on 21, and SMTP on 25.'
  },
  {
    id: 'net_q16',
    text: 'Which layer of the OSI model handles data encryption and compression?',
    options: ['Application Layer', 'Presentation Layer', 'Session Layer', 'Transport Layer'],
    correctIndex: 1,
    category: 'Networking',
    difficulty: 'medium',
    explanation: 'The Presentation Layer (Layer 6) formats, encrypts, and compresses data.'
  },
  {
    id: 'net_q17',
    text: 'What is the loopback IP address for local host testing in IPv4?',
    options: ['10.0.0.1', '192.168.1.1', '127.0.0.1', '255.255.255.255'],
    correctIndex: 2,
    category: 'Networking',
    difficulty: 'easy',
    explanation: '127.0.0.1 refers to localhost loopback.'
  },
  {
    id: 'net_q18',
    text: 'Which topology connects every node directly to every other node in the network?',
    options: ['Star Topology', 'Mesh Topology', 'Ring Topology', 'Bus Topology'],
    correctIndex: 1,
    category: 'Networking',
    difficulty: 'easy',
    explanation: 'Full Mesh topology links all devices directly, offering high redundancy.'
  },
  {
    id: 'net_q19',
    text: 'What routing protocol uses hop count as its primary metric?',
    options: ['OSPF', 'BGP', 'RIP (Routing Information Protocol)', 'IS-IS'],
    correctIndex: 2,
    category: 'Networking',
    difficulty: 'medium',
    explanation: 'RIP relies on distance-vector metrics, capping routes at 15 hops.'
  },
  {
    id: 'net_q20',
    text: 'Which protocol is used by the ping utility to diagnose connectivity?',
    options: ['TCP', 'UDP', 'ICMP (Internet Control Message Protocol)', 'ARP'],
    correctIndex: 2,
    category: 'Networking',
    difficulty: 'easy',
    explanation: 'Ping sends ICMP Echo Requests and listens for Echo Replies.'
  },
  {
    id: 'net_q21',
    text: 'What is the MAC address length?',
    options: ['32 bits', '48 bits', '64 bits', '128 bits'],
    correctIndex: 1,
    category: 'Networking',
    difficulty: 'medium',
    explanation: 'A MAC address is a 48-bit (6 bytes) hardware identifier, written in hex.'
  },
  {
    id: 'net_q22',
    text: 'What is standard port for FTP control connection?',
    options: ['20', '21', '22', '80'],
    correctIndex: 1,
    category: 'Networking',
    difficulty: 'medium',
    explanation: 'FTP control uses port 21. FTP data transfer uses port 20.'
  },
  {
    id: 'net_q23',
    text: 'Which IP range is designated for Class A private networks?',
    options: [
      '10.0.0.0 to 10.255.255.255',
      '172.16.0.0 to 172.31.255.255',
      '192.168.0.0 to 192.168.255.255',
      '127.0.0.0 to 127.255.255.255'
    ],
    correctIndex: 0,
    category: 'Networking',
    difficulty: 'medium',
    explanation: '10.0.0.0/8 defines the Class A private network scope.'
  },
  {
    id: 'net_q24',
    text: 'Which network layer protocol handles error reporting and routing feedback?',
    options: ['TCP', 'ICMP', 'DNS', 'UDP'],
    correctIndex: 1,
    category: 'Networking',
    difficulty: 'medium',
    explanation: 'ICMP handles control messages and diagnostic reporting on Layer 3.'
  },
  {
    id: 'net_q25',
    text: 'What collision avoidance method is standard for wired Ethernet networks?',
    options: ['CSMA/CA', 'CSMA/CD', 'Token Passing', 'Polling'],
    correctIndex: 1,
    category: 'Networking',
    difficulty: 'hard',
    explanation: 'Wired Ethernet uses Carrier Sense Multiple Access with Collision Detection (CSMA/CD).'
  },
  {
    id: 'net_q26',
    text: 'What collision avoidance method is standard for wireless (Wi-Fi) networks?',
    options: ['CSMA/CD', 'CSMA/CA', 'Token Passing', 'TDMA'],
    correctIndex: 1,
    category: 'Networking',
    difficulty: 'hard',
    explanation: 'Wi-Fi networks use CSMA with Collision Avoidance (CSMA/CA).'
  },
  {
    id: 'net_q27',
    text: 'What represents the maximum size of a packet that can be transmitted over a network layer?',
    options: ['MSS', 'MTU (Maximum Transmission Unit)', 'Window size', 'Bandwidth'],
    correctIndex: 1,
    category: 'Networking',
    difficulty: 'medium',
    explanation: 'MTU measures the largest packet size (typically 1500 bytes on Ethernet) allowed on a link.'
  },
  {
    id: 'net_q28',
    text: 'Which header field in IPv4 packets prevents packets from circulating indefinitely?',
    options: ['Header Checksum', 'Time to Live (TTL)', 'Fragmentation Offset', 'Total Length'],
    correctIndex: 1,
    category: 'Networking',
    difficulty: 'easy',
    explanation: 'TTL decrements by 1 at each router hop. Packets are dropped if TTL reaches 0.'
  },
  {
    id: 'net_q29',
    text: 'What type of routing protocol uses link-state databases to compute shortest paths?',
    options: ['RIP', 'OSPF', 'BGP', 'EGP'],
    correctIndex: 1,
    category: 'Networking',
    difficulty: 'hard',
    explanation: 'OSPF uses Dijkstra algorithm on link-state databases to determine optimal routes.'
  },
  {
    id: 'net_q30',
    text: 'What is the default port for SMTP (Simple Mail Transfer Protocol)?',
    options: ['25', '110', '143', '465'],
    correctIndex: 0,
    category: 'Networking',
    difficulty: 'easy',
    explanation: 'SMTP standard default listening port is 25.'
  },
  {
    id: 'net_q31',
    text: 'Which command helps trace the path packets take to reach a destination host?',
    options: ['ping', 'nslookup', 'traceroute / tracert', 'netstat'],
    correctIndex: 2,
    category: 'Networking',
    difficulty: 'easy',
    explanation: 'Traceroute shows hop-by-hop routers traversed by packets.'
  },
  {
    id: 'net_q32',
    text: 'Which protocol retrieves emails from mail servers, deleting them from the server by default?',
    options: ['SMTP', 'IMAP', 'POP3', 'HTTP'],
    correctIndex: 2,
    category: 'Networking',
    difficulty: 'easy',
    explanation: 'POP3 downloads and deletes email from servers. IMAP synchronizes emails across devices.'
  },
  {
    id: 'net_q33',
    text: 'What is the purpose of a VLAN (Virtual Local Area Network)?',
    options: [
      'Link remote sites securely',
      'Segment physical switch domains logically',
      'Distribute network traffic',
      'Translate IP addresses'
    ],
    correctIndex: 1,
    category: 'Networking',
    difficulty: 'medium',
    explanation: 'VLANs split physical local area switches into isolated logical broadcast domains.'
  },
  {
    id: 'net_q34',
    text: 'What type of cable is least susceptible to electromagnetic interference (EMI)?',
    options: ['Coaxial Cable', 'Shielded Twisted Pair', 'Fiber Optic Cable', 'Unshielded Twisted Pair'],
    correctIndex: 2,
    category: 'Networking',
    difficulty: 'easy',
    explanation: 'Fiber Optic cables use light pulses, making them immune to EMI.'
  },
  {
    id: 'net_q35',
    text: 'What is the standard port for DNS?',
    options: ['53', '67', '68', '80'],
    correctIndex: 0,
    category: 'Networking',
    difficulty: 'easy',
    explanation: 'DNS uses port 53 (on both UDP and TCP).'
  },
  {
    id: 'net_q36',
    text: 'Which TCP mechanism handles flow control by dynamically adjusting client package buffers?',
    options: ['Checksum', 'Sequence Number', 'Sliding Window', '3-way Handshake'],
    correctIndex: 2,
    category: 'Networking',
    difficulty: 'hard',
    explanation: 'Sliding window sizes let receivers specify buffer limits to avoid overflow.'
  },
  {
    id: 'net_q37',
    text: 'What represents the physical MAC address format?',
    options: ['Dotted decimal', 'Hexadecimal notation', 'Binary numbers', 'Base64 strings'],
    correctIndex: 1,
    category: 'Networking',
    difficulty: 'easy',
    explanation: 'MAC addresses are written in colon-separated hex groups (e.g., 00:0a:95:9d:68:16).'
  },
  {
    id: 'net_q38',
    text: 'Which protocol is used to access files securely over an encrypted connection?',
    options: ['TFTP', 'FTP', 'SFTP', 'HTTP'],
    correctIndex: 2,
    category: 'Networking',
    difficulty: 'easy',
    explanation: 'SFTP (SSH File Transfer Protocol) runs inside SSH tunnels.'
  },
  {
    id: 'net_q39',
    text: 'Which class of IPv4 addresses is reserved for multicast?',
    options: ['Class B', 'Class C', 'Class D', 'Class E'],
    correctIndex: 2,
    category: 'Networking',
    difficulty: 'medium',
    explanation: 'Class D IP addresses (224.0.0.0 to 239.255.255.255) are reserved for multicast.'
  },
  {
    id: 'net_q40',
    text: 'Which protocol operates on Layer 7 to transmit hypertext resources?',
    options: ['TCP', 'UDP', 'HTTP', 'IP'],
    correctIndex: 2,
    category: 'Networking',
    difficulty: 'easy',
    explanation: 'HTTP is the Application layer standard for transfer of hypertext web pages.'
  },

  // --- DATA STRUCTURES & ALGORITHMS (40 questions) ---
  {
    id: 'dsa_q1',
    text: 'What is the time complexity of searching in a balanced Binary Search Tree (BST)?',
    options: ['O(1)', 'O(log n)', 'O(n)', 'O(n log n)'],
    correctIndex: 1,
    category: 'Data Structures',
    difficulty: 'easy',
    explanation: 'Balanced BST search takes logarithmic time (O(log n)).'
  },
  {
    id: 'dsa_q2',
    text: 'Which sorting algorithm has a worst-case time complexity of O(n^2) but average-case of O(n log n)?',
    options: ['Merge Sort', 'Heap Sort', 'Quick Sort', 'Radix Sort'],
    correctIndex: 2,
    category: 'Algorithms',
    difficulty: 'easy',
    explanation: 'Quick Sort degrades to O(n^2) when partition pivots are poorly chosen (e.g., already sorted arrays).'
  },
  {
    id: 'dsa_q3',
    text: 'Which data structure operates on a Last In First Out (LIFO) basis?',
    options: ['Queue', 'Linked List', 'Stack', 'Heap'],
    correctIndex: 2,
    category: 'Data Structures',
    difficulty: 'easy',
    explanation: 'Stacks push and pop items from the same end, resulting in LIFO ordering.'
  },
  {
    id: 'dsa_q4',
    text: 'What algorithm is used to find the shortest path from a single source to all other nodes in a weighted graph with non-negative weights?',
    options: ['Prim Algorithm', 'Kruskal Algorithm', 'Dijkstra Algorithm', 'Floyd-Warshall Algorithm'],
    correctIndex: 2,
    category: 'Algorithms',
    difficulty: 'medium',
    explanation: 'Dijkstra Single Source Shortest Path operates on non-negative weighted graphs.'
  },
  {
    id: 'dsa_q5',
    text: 'Which data structure is most suitable for implementing Breadth-First Search (BFS) on a graph?',
    options: ['Stack', 'Queue', 'Priority Queue', 'Tree'],
    correctIndex: 1,
    category: 'Data Structures',
    difficulty: 'easy',
    explanation: 'BFS processes nodes in FIFO order, making a Queue the standard data structure.'
  },
  {
    id: 'dsa_q6',
    text: 'What is the worst-case time complexity of Merge Sort?',
    options: ['O(n)', 'O(n log n)', 'O(n^2)', 'O(log n)'],
    correctIndex: 1,
    category: 'Algorithms',
    difficulty: 'easy',
    explanation: 'Merge Sort consistently achieves O(n log n) in best, worst, and average scenarios.'
  },
  {
    id: 'dsa_q7',
    text: 'What binary tree property defines an AVL tree?',
    options: [
      'Maximum path size',
      'The difference in height between left and right subtrees is at most 1',
      'Every node has either 0 or 2 children',
      'The tree is complete'
    ],
    correctIndex: 1,
    category: 'Data Structures',
    difficulty: 'medium',
    explanation: 'An AVL tree is a self-balancing binary search tree where subtree heights differ by at most one.'
  },
  {
    id: 'dsa_q8',
    text: 'What is the time complexity of pushing an element onto a stack?',
    options: ['O(1)', 'O(log n)', 'O(n)', 'O(n^2)'],
    correctIndex: 0,
    category: 'Data Structures',
    difficulty: 'easy',
    explanation: 'Pushing an item onto a stack is a constant time operation (O(1)).'
  },
  {
    id: 'dsa_q9',
    text: 'Which sorting algorithm divides the array, sorts the halves recursively, and then combines them?',
    options: ['Selection Sort', 'Insertion Sort', 'Merge Sort', 'Bubble Sort'],
    correctIndex: 2,
    category: 'Algorithms',
    difficulty: 'easy',
    explanation: 'Merge Sort is a classic Divide and Conquer sorting algorithm.'
  },
  {
    id: 'dsa_q10',
    text: 'What is the height of a complete binary tree with n nodes?',
    options: ['O(log n)', 'O(n)', 'O(n log n)', 'O(1)'],
    correctIndex: 0,
    category: 'Data Structures',
    difficulty: 'medium',
    explanation: 'Complete binary tree heights grow logarithmically relative to nodes count (O(log n)).'
  },
  {
    id: 'dsa_q11',
    text: 'Which traversal visits BST nodes in ascending sorted order?',
    options: ['Pre-order', 'Post-order', 'In-order', 'Level-order'],
    correctIndex: 2,
    category: 'Data Structures',
    difficulty: 'easy',
    explanation: 'In-order traversal (Left, Root, Right) processes BST nodes in sorted order.'
  },
  {
    id: 'dsa_q12',
    text: 'What is the time complexity of Binary Search?',
    options: ['O(1)', 'O(log n)', 'O(n)', 'O(n log n)'],
    correctIndex: 1,
    category: 'Algorithms',
    difficulty: 'easy',
    explanation: 'Binary Search halves search spaces recursively, leading to O(log n) time.'
  },
  {
    id: 'dsa_q13',
    text: 'What graph representation is most memory efficient for sparse graphs?',
    options: ['Adjacency Matrix', 'Adjacency List', 'Incidence Matrix', 'Path List'],
    correctIndex: 1,
    category: 'Data Structures',
    difficulty: 'medium',
    explanation: 'Adjacency list stores only connected edges, saving memory on sparse graphs.'
  },
  {
    id: 'dsa_q14',
    text: 'What graph representation takes O(1) time to check if an edge exists between two nodes?',
    options: ['Adjacency List', 'Adjacency Matrix', 'Edge List', 'Path List'],
    correctIndex: 1,
    category: 'Data Structures',
    difficulty: 'medium',
    explanation: 'Adjacency Matrix check is a simple matrix lookup: matrix[i][j].'
  },
  {
    id: 'dsa_q15',
    text: 'Which data structure operates on a First In First Out (FIFO) basis?',
    options: ['Stack', 'Queue', 'BST', 'Hash Table'],
    correctIndex: 1,
    category: 'Data Structures',
    difficulty: 'easy',
    explanation: 'Queues insert at tail and remove from head, establishing FIFO order.'
  },
  {
    id: 'dsa_q16',
    text: 'What sorting algorithm repeatedly swaps adjacent elements if they are in the wrong order?',
    options: ['Insertion Sort', 'Selection Sort', 'Bubble Sort', 'Merge Sort'],
    correctIndex: 2,
    category: 'Algorithms',
    difficulty: 'easy',
    explanation: 'Bubble sort bubbles the largest unsorted value to the end via adjacent swaps.'
  },
  {
    id: 'dsa_q17',
    text: 'What is the worst-case time complexity of Quick Sort when already sorted arrays are input?',
    options: ['O(n)', 'O(n log n)', 'O(n^2)', 'O(n!)'],
    correctIndex: 2,
    category: 'Algorithms',
    difficulty: 'medium',
    explanation: 'Using first/last element as pivot on sorted lists leads to highly unbalanced O(n^2) splits.'
  },
  {
    id: 'dsa_q18',
    text: 'Which data structure is based on hash values to fetch elements in O(1) average time?',
    options: ['Linked List', 'AVL Tree', 'Hash Table', 'Min-Heap'],
    correctIndex: 2,
    category: 'Data Structures',
    difficulty: 'easy',
    explanation: 'Hash tables map keys to index locations to retrieve items in constant time.'
  },
  {
    id: 'dsa_q19',
    text: 'What represents the worst-case time complexity to search an item in a singly linked list?',
    options: ['O(1)', 'O(log n)', 'O(n)', 'O(n^2)'],
    correctIndex: 2,
    category: 'Data Structures',
    difficulty: 'easy',
    explanation: 'Singly linked lists require linear traversal to search elements.'
  },
  {
    id: 'dsa_q20',
    text: 'What is the best sorting time complexity possible for comparison-based sorting algorithms?',
    options: ['O(n)', 'O(n log n)', 'O(log n)', 'O(n^2)'],
    correctIndex: 1,
    category: 'Algorithms',
    difficulty: 'medium',
    explanation: 'Comparison-based sorting has a mathematical lower bound of O(n log n).'
  },
  {
    id: 'dsa_q21',
    text: 'Which tree structure guarantees that the root is always the minimum element?',
    options: ['Max-Heap', 'Min-Heap', 'AVL Tree', 'Trie'],
    correctIndex: 1,
    category: 'Data Structures',
    difficulty: 'easy',
    explanation: 'Min-Heaps guarantee that parent nodes are smaller than or equal to child nodes.'
  },
  {
    id: 'dsa_q22',
    text: 'What sorting algorithm behaves similarly to inserting cards in a hand one by one?',
    options: ['Bubble Sort', 'Selection Sort', 'Insertion Sort', 'Heap Sort'],
    correctIndex: 2,
    category: 'Algorithms',
    difficulty: 'easy',
    explanation: 'Insertion sort inserts each element into its correct position in a sorted subarray.'
  },
  {
    id: 'dsa_q23',
    text: 'Which algorithm finds a minimum spanning tree for a connected weighted graph by picking edges in sorted order?',
    options: ['Dijkstra Algorithm', 'Kruskal Algorithm', 'Prim Algorithm', 'Bellman-Ford'],
    correctIndex: 1,
    category: 'Algorithms',
    difficulty: 'medium',
    explanation: 'Kruskal\'s algorithm sorts all edges and adds them greedily avoiding cycles.'
  },
  {
    id: 'dsa_q24',
    text: 'Which algorithm finds a minimum spanning tree by growing a tree from an initial vertex?',
    options: ['Kruskal Algorithm', 'Prim Algorithm', 'Dijkstra Algorithm', 'Warshall Algorithm'],
    correctIndex: 1,
    category: 'Algorithms',
    difficulty: 'medium',
    explanation: 'Prim\'s algorithm grows the spanning tree from a starting vertex by adding the cheapest adjacent node.'
  },
  {
    id: 'dsa_q25',
    text: 'What is the average time complexity of Heap Sort?',
    options: ['O(n)', 'O(n log n)', 'O(n^2)', 'O(log n)'],
    correctIndex: 1,
    category: 'Algorithms',
    difficulty: 'medium',
    explanation: 'Heap sort uses heap structures to sort elements in O(n log n) time.'
  },
  {
    id: 'dsa_q26',
    text: 'What data structure is used to implement Depth-First Search (DFS)?',
    options: ['Queue', 'Stack', 'Heap', 'Graph Matrix'],
    correctIndex: 1,
    category: 'Data Structures',
    difficulty: 'easy',
    explanation: 'DFS uses LIFO scheduling, making a Stack (or recursion) the standard implementation.'
  },
  {
    id: 'dsa_q27',
    text: 'What is the space complexity of Depth-First Search (DFS) on a tree of height h?',
    options: ['O(1)', 'O(h)', 'O(n)', 'O(w)'],
    correctIndex: 1,
    category: 'Algorithms',
    difficulty: 'hard',
    explanation: 'DFS stores call stack frames equal to the maximum path depth, which is O(h).'
  },
  {
    id: 'dsa_q28',
    text: 'What data structure is optimal for autocomplete search suggestions?',
    options: ['Hash Table', 'B-Tree', 'Trie', 'Red-Black Tree'],
    correctIndex: 2,
    category: 'Data Structures',
    difficulty: 'hard',
    explanation: 'A Trie (Prefix Tree) stores character keys along paths, optimized for prefix matching.'
  },
  {
    id: 'dsa_q29',
    text: 'What is the worst-case search complexity in a Hash Table when many collisions occur?',
    options: ['O(1)', 'O(log n)', 'O(n)', 'O(n^2)'],
    correctIndex: 2,
    category: 'Data Structures',
    difficulty: 'medium',
    explanation: 'Collisions resolved via chaining degrade to linear search (O(n)) in the worst case.'
  },
  {
    id: 'dsa_q30',
    text: 'What algorithm determines if a graph contains a cycle?',
    options: ['Binary Search', 'Dijkstra', 'DFS with Backtracking', 'Kruskal'],
    correctIndex: 2,
    category: 'Algorithms',
    difficulty: 'medium',
    explanation: 'DFS tracks visited ancestors; finding a visited node along active paths reveals cycles.'
  },
  {
    id: 'dsa_q31',
    text: 'What dynamic programming algorithm solves the single-source shortest path problem with negative edge weights?',
    options: ['Dijkstra', 'Kruskal', 'Bellman-Ford', 'Floyd-Warshall'],
    correctIndex: 2,
    category: 'Algorithms',
    difficulty: 'hard',
    explanation: 'Bellman-Ford operates on negative weighted graphs and detects negative weight cycles.'
  },
  {
    id: 'dsa_q32',
    text: 'What is the worst-case time complexity of Floyd-Warshall all-pairs shortest path algorithm?',
    options: ['O(V^2)', 'O(V^3)', 'O(E log V)', 'O(V E)'],
    correctIndex: 1,
    category: 'Algorithms',
    difficulty: 'hard',
    explanation: 'Floyd-Warshall uses three nested loops over graph vertices, taking O(V^3) time.'
  },
  {
    id: 'dsa_q33',
    text: 'What sorting algorithm has best-case time complexity of O(n) when input is already sorted?',
    options: ['Quick Sort', 'Merge Sort', 'Insertion Sort', 'Selection Sort'],
    correctIndex: 2,
    category: 'Algorithms',
    difficulty: 'medium',
    explanation: 'Insertion sort takes linear time O(n) on sorted arrays because no swaps or shifts occur.'
  },
  {
    id: 'dsa_q34',
    text: 'What defines a complete binary tree where every node is greater than or equal to its children?',
    options: ['Min-Heap', 'Max-Heap', 'Binary Search Tree', 'AVL Tree'],
    correctIndex: 1,
    category: 'Data Structures',
    difficulty: 'easy',
    explanation: 'A Max-Heap satisfies the heap property where parent keys are larger than child keys.'
  },
  {
    id: 'dsa_q35',
    text: 'What data structure is used to reverse a string?',
    options: ['Queue', 'Stack', 'Linked List', 'Binary Tree'],
    correctIndex: 1,
    category: 'Data Structures',
    difficulty: 'easy',
    explanation: 'Pushing characters to a stack and popping them reverses their order (LIFO).'
  },
  {
    id: 'dsa_q36',
    text: 'What sorting algorithm finds the minimum element and places it at the beginning, repeating for the remaining array?',
    options: ['Insertion Sort', 'Selection Sort', 'Bubble Sort', 'Quick Sort'],
    correctIndex: 1,
    category: 'Algorithms',
    difficulty: 'easy',
    explanation: 'Selection sort scans the unsorted list to select the smallest element, placing it next.'
  },
  {
    id: 'dsa_q37',
    text: 'What is the average time complexity of insertion in a Hash Table?',
    options: ['O(1)', 'O(log n)', 'O(n)', 'O(n log n)'],
    correctIndex: 0,
    category: 'Data Structures',
    difficulty: 'easy',
    explanation: 'Hash tables resolve keys directly, achieving constant O(1) average insertion time.'
  },
  {
    id: 'dsa_q38',
    text: 'What data structure uses two pointers, head and tail, with nodes pointing only forward?',
    options: ['Singly Linked List', 'Doubly Linked List', 'Circular Queue', 'Stack'],
    correctIndex: 0,
    category: 'Data Structures',
    difficulty: 'easy',
    explanation: 'Singly linked lists link nodes forward sequentially with a single next pointer.'
  },
  {
    id: 'dsa_q39',
    text: 'Which algorithm checks if parenthesized expressions are balanced?',
    options: ['Queue checking', 'Stack-based matching', 'DFS traversal', 'Binary Search'],
    correctIndex: 1,
    category: 'Algorithms',
    difficulty: 'easy',
    explanation: 'Stack-based matching pushes open brackets and pops to match closing brackets.'
  },
  {
    id: 'dsa_q40',
    text: 'What is the worst-case space complexity of Quick Sort?',
    options: ['O(1)', 'O(log n)', 'O(n)', 'O(n log n)'],
    correctIndex: 2,
    category: 'Algorithms',
    difficulty: 'hard',
    explanation: 'Worst-case recursion depth in Quick Sort can be O(n) (e.g., highly unbalanced recursion stacks).'
  },

  // --- OOP, SOFTWARE ENGINEERING, & MISC CSE (40 questions) ---
  {
    id: 'oop_q1',
    text: 'Which OOP concept refers to the ability of different classes to respond to the same message in different ways?',
    options: ['Inheritance', 'Polymorphic execution / Polymorphism', 'Encapsulation', 'Abstraction'],
    correctIndex: 1,
    category: 'OOP',
    difficulty: 'easy',
    explanation: 'Polymorphism allows objects of different subclasses to implement methods differently.'
  },
  {
    id: 'oop_q2',
    text: 'What OOP concept wraps data variables and methods together inside a single unit class?',
    options: ['Inheritance', 'Encapsulation', 'Polymorphism', 'Abstraction'],
    correctIndex: 1,
    category: 'OOP',
    difficulty: 'easy',
    explanation: 'Encapsulation bundles data and methods while restricting direct external access.'
  },
  {
    id: 'oop_q3',
    text: 'What OOP concept hides complex background details and exposes only essential interface features?',
    options: ['Abstraction', 'Encapsulation', 'Inheritance', 'Polymorphism'],
    correctIndex: 0,
    category: 'OOP',
    difficulty: 'easy',
    explanation: 'Abstraction hides internal implementation, defining clean client interfaces.'
  },
  {
    id: 'oop_q4',
    text: 'What allows a class to inherit attributes and methods from another class?',
    options: ['Encapsulation', 'Inheritance', 'Polymorphism', 'Abstraction'],
    correctIndex: 1,
    category: 'OOP',
    difficulty: 'easy',
    explanation: 'Inheritance allows a subclass to acquire properties from a parent superclass.'
  },
  {
    id: 'oop_q5',
    text: 'In C++, what special function is called automatically when an object is destroyed?',
    options: ['Constructor', 'Destructor', 'Garbage Collector', 'Finalizer'],
    correctIndex: 1,
    category: 'OOP',
    difficulty: 'easy',
    explanation: 'Destructors clean up resources when object lifetimes end.'
  },
  {
    id: 'oop_q6',
    text: 'What software engineering model is characterized by linear sequential phases?',
    options: ['Agile model', 'Waterfall model', 'Spiral model', 'Prototype model'],
    correctIndex: 1,
    category: 'Software Engineering',
    difficulty: 'easy',
    explanation: 'The Waterfall model is a classic linear sequential development cycle.'
  },
  {
    id: 'oop_q7',
    text: 'What software development methodology emphasizes iteration, feedback, and customer collaboration?',
    options: ['Waterfall', 'Agile', 'V-Model', 'Cleanroom'],
    correctIndex: 1,
    category: 'Software Engineering',
    difficulty: 'easy',
    explanation: 'Agile models focus on iterative sprints, adaptiveness, and customer reviews.'
  },
  {
    id: 'oop_q8',
    text: 'What SDLC phase translates system design specifications into functional code?',
    options: ['Requirement analysis', 'Design', 'Implementation / Coding', 'Testing'],
    correctIndex: 2,
    category: 'Software Engineering',
    difficulty: 'easy',
    explanation: 'Coding/Implementation is the phase where designs are written as code.'
  },
  {
    id: 'oop_q9',
    text: 'What type of testing validates individual functions or components of software in isolation?',
    options: ['Integration Testing', 'System Testing', 'Unit Testing', 'Acceptance Testing'],
    correctIndex: 2,
    category: 'Software Engineering',
    difficulty: 'easy',
    explanation: 'Unit tests check individual code blocks (functions, classes) in isolation.'
  },
  {
    id: 'oop_q10',
    text: 'What type of testing checks how different software components interact with each other?',
    options: ['Unit Testing', 'Integration Testing', 'Regression Testing', 'Sanity Testing'],
    correctIndex: 1,
    category: 'Software Engineering',
    difficulty: 'easy',
    explanation: 'Integration tests check communication flows between combined modules.'
  },
  {
    id: 'oop_q11',
    text: 'Which software testing method examines internal code structures and logical paths?',
    options: ['Black-box Testing', 'White-box Testing', 'Grey-box Testing', 'User Testing'],
    correctIndex: 1,
    category: 'Software Engineering',
    difficulty: 'medium',
    explanation: 'White-box testing validates internal program logic, loops, and statement coverage.'
  },
  {
    id: 'oop_q12',
    text: 'Which testing method evaluates external functionality without viewing internal code paths?',
    options: ['White-box Testing', 'Black-box Testing', 'Structural Testing', 'Mutation Testing'],
    correctIndex: 1,
    category: 'Software Engineering',
    difficulty: 'easy',
    explanation: 'Black-box testing focuses purely on inputs and expected outputs.'
  },
  {
    id: 'oop_q13',
    text: 'Which design pattern guarantees that a class has only one instance, providing global access?',
    options: ['Factory Pattern', 'Singleton Pattern', 'Observer Pattern', 'Adapter Pattern'],
    correctIndex: 1,
    category: 'Software Engineering',
    difficulty: 'medium',
    explanation: 'Singleton pattern restricts class instantiation to a single unique instance.'
  },
  {
    id: 'oop_q14',
    text: 'What design pattern defines a one-to-many dependency so when one object changes, dependents are notified?',
    options: ['Singleton', 'Factory', 'Observer', 'Strategy'],
    correctIndex: 2,
    category: 'Software Engineering',
    difficulty: 'medium',
    explanation: 'Observer pattern updates dependent objects automatically when subjects change.'
  },
  {
    id: 'oop_q15',
    text: 'What describes a software defect found by users after release?',
    options: ['Bug', 'Error', 'Failure', 'Fault'],
    correctIndex: 2,
    category: 'Software Engineering',
    difficulty: 'medium',
    explanation: 'A failure is the visible manifestation of a software bug during user operations.'
  },
  {
    id: 'oop_q16',
    text: 'What represents the degree of interconnection between software modules?',
    options: ['Cohesion', 'Coupling', 'Inheritance', 'Abstraction'],
    correctIndex: 1,
    category: 'Software Engineering',
    difficulty: 'medium',
    explanation: 'Coupling measures dependencies between modules. Low coupling is highly desired.'
  },
  {
    id: 'oop_q17',
    text: 'What represents the strength of relationships within a single software module?',
    options: ['Coupling', 'Cohesion', 'Encapsulation', 'Polymorphism'],
    correctIndex: 1,
    category: 'Software Engineering',
    difficulty: 'medium',
    explanation: 'Cohesion measures module task focus. High cohesion is highly desired.'
  },
  {
    id: 'oop_q18',
    text: 'In Java, which keyword prevents methods from being overridden by subclasses?',
    options: ['static', 'final', 'const', 'volatile'],
    correctIndex: 1,
    category: 'OOP',
    difficulty: 'medium',
    explanation: 'A final method cannot be overridden. A final class cannot be inherited.'
  },
  {
    id: 'oop_q19',
    text: 'Which constructor contains no arguments and is called by default?',
    options: ['Parameterized Constructor', 'Default Constructor', 'Copy Constructor', 'Virtual Constructor'],
    correctIndex: 1,
    category: 'OOP',
    difficulty: 'easy',
    explanation: 'Default constructors have no parameters and initialize objects with default values.'
  },
  {
    id: 'oop_q20',
    text: 'What is the keyword used in Java to inherit from an interface?',
    options: ['extends', 'implements', 'inherits', 'uses'],
    correctIndex: 1,
    category: 'OOP',
    difficulty: 'easy',
    explanation: 'Classes use "implements" for interfaces, and "extends" for classes.'
  },
  {
    id: 'oop_q21',
    text: 'Which OOP relationship is represented by class composition?',
    options: ['IS-A relationship', 'HAS-A relationship', 'USES-A relationship', 'BELONGS-TO relationship'],
    correctIndex: 1,
    category: 'OOP',
    difficulty: 'medium',
    explanation: 'Composition represents a "HAS-A" relationship (e.g., Car has an Engine).'
  },
  {
    id: 'oop_q22',
    text: 'Which OOP relationship is represented by class inheritance?',
    options: ['HAS-A relationship', 'IS-A relationship', 'USES-A relationship', 'PART-OF relationship'],
    correctIndex: 1,
    category: 'OOP',
    difficulty: 'medium',
    explanation: 'Inheritance represents an "IS-A" relationship (e.g., Dog is an Animal).'
  },
  {
    id: 'oop_q23',
    text: 'What is method overloading?',
    options: [
      'Methods in same class with same name but different parameters',
      'Methods in child class overriding parent methods',
      'Methods with too much execution code',
      'Calling recursive methods'
    ],
    correctIndex: 0,
    category: 'OOP',
    difficulty: 'easy',
    explanation: 'Method overloading allows methods to share names if parameter signatures differ.'
  },
  {
    id: 'oop_q24',
    text: 'What is method overriding?',
    options: [
      'Child class redefining a parent method with same signature',
      'Defining same method in same class with different arguments',
      'Calling parent methods inside static loops',
      'Encapsulating private fields'
    ],
    correctIndex: 0,
    category: 'OOP',
    difficulty: 'easy',
    explanation: 'Method overriding redefines inherited superclass methods inside subclasses.'
  },
  {
    id: 'oop_q25',
    text: 'Which type of polymorphism is checked during compile-time?',
    options: ['Method overriding', 'Method overloading', 'Virtual functions', 'Interface implementation'],
    correctIndex: 1,
    category: 'OOP',
    difficulty: 'medium',
    explanation: 'Method overloading is resolved during compilation (Static Binding).'
  },
  {
    id: 'oop_q26',
    text: 'Which type of polymorphism is checked during run-time?',
    options: ['Method overloading', 'Method overriding', 'Static method calls', 'Final fields access'],
    correctIndex: 1,
    category: 'OOP',
    difficulty: 'medium',
    explanation: 'Method overriding is resolved at runtime (Dynamic Binding).'
  },
  {
    id: 'oop_q27',
    text: 'What software process model focuses heavily on risk assessment at each spiral loop?',
    options: ['Agile model', 'Waterfall model', 'Spiral model', 'V-model'],
    correctIndex: 2,
    category: 'Software Engineering',
    difficulty: 'medium',
    explanation: 'The Spiral model blends prototyping with linear testing, emphasizing risk analysis.'
  },
  {
    id: 'oop_q28',
    text: 'In digital logic, which logic gate outputs 1 if and only if all inputs are 1?',
    options: ['OR gate', 'AND gate', 'NAND gate', 'XOR gate'],
    correctIndex: 1,
    category: 'Digital Logic',
    difficulty: 'easy',
    explanation: 'AND gates yield high outputs only when all inputs are high.'
  },
  {
    id: 'oop_q29',
    text: 'In digital logic, which logic gate outputs 0 if all inputs are 1?',
    options: ['AND gate', 'OR gate', 'NAND gate', 'XOR gate'],
    correctIndex: 2,
    category: 'Digital Logic',
    difficulty: 'easy',
    explanation: 'NAND (Not-AND) gate is the inverse of the AND gate.'
  },
  {
    id: 'oop_q30',
    text: 'Which gate outputs 1 only when inputs are different (odd parity)?',
    options: ['AND gate', 'OR gate', 'XOR gate', 'XNOR gate'],
    correctIndex: 2,
    category: 'Digital Logic',
    difficulty: 'easy',
    explanation: 'XOR (Exclusive-OR) outputs 1 when inputs differ (e.g. 0 and 1).'
  },
  {
    id: 'oop_q31',
    text: 'What is a boolean reduction method using structural table grids?',
    options: ['Truth Table', 'Karnaugh Map (K-map)', 'De Morgan theorem', 'Venn Diagram'],
    correctIndex: 1,
    category: 'Digital Logic',
    difficulty: 'medium',
    explanation: 'Karnaugh maps optimize boolean equations visually in tabular cells.'
  },
  {
    id: 'oop_q32',
    text: 'What circuit is used to store 1 bit of memory data in digital logic?',
    options: ['Multiplexer', 'Decoder', 'Flip-flop', 'Demultiplexer'],
    correctIndex: 2,
    category: 'Digital Logic',
    difficulty: 'easy',
    explanation: 'Flip-flops are bi-stable multivibrator circuits that store a single state bit.'
  },
  {
    id: 'oop_q33',
    text: 'What is a combinational circuit that selects one input from many and forwards it to a single output?',
    options: ['Decoder', 'Demultiplexer', 'Multiplexer (MUX)', 'Encoder'],
    correctIndex: 2,
    category: 'Digital Logic',
    difficulty: 'medium',
    explanation: 'A Multiplexer (MUX) routes one of several input lines to a single output based on select lines.'
  },
  {
    id: 'oop_q34',
    text: 'What is the binary representation of decimal 25?',
    options: ['11001', '10101', '11100', '10011'],
    correctIndex: 0,
    category: 'Digital Logic',
    difficulty: 'easy',
    explanation: '25 in binary is 16 + 8 + 1 = 11001.'
  },
  {
    id: 'oop_q35',
    text: 'In software development, what does DRY stand for?',
    options: [
      'Do Repeat Yourself',
      'Don\'t Repeat Yourself',
      'Design Robust Yields',
      'Documentation Requires Years'
    ],
    correctIndex: 1,
    category: 'Software Engineering',
    difficulty: 'easy',
    explanation: 'DRY (Don\'t Repeat Yourself) advocates for avoiding code duplication.'
  },
  {
    id: 'oop_q36',
    text: 'Which compiler phase checks if character sequences form valid programming syntax patterns?',
    options: ['Lexical Analysis', 'Syntax Analysis', 'Semantic Analysis', 'Code Generation'],
    correctIndex: 1,
    category: 'Software Engineering',
    difficulty: 'hard',
    explanation: 'Syntax Analysis (parsing) checks expressions against language grammar rules.'
  },
  {
    id: 'oop_q37',
    text: 'Which compiler phase groups character streams into tokens (lexemes)?',
    options: ['Lexical Analysis', 'Syntax Analysis', 'Intermediate Code Generation', 'Optimization'],
    correctIndex: 0,
    category: 'Software Engineering',
    difficulty: 'hard',
    explanation: 'Lexical Analysis (scanning) converts raw source text into a stream of syntax tokens.'
  },
  {
    id: 'oop_q38',
    text: 'In software engineering, what is the term for restructuring existing code without changing external behaviors?',
    options: ['Debugging', 'Refactoring', 'Re-compiling', 'Porting'],
    correctIndex: 1,
    category: 'Software Engineering',
    difficulty: 'easy',
    explanation: 'Refactoring improves code readability, performance, or structure safely.'
  },
  {
    id: 'oop_q39',
    text: 'Which UML diagram represents system classes, attributes, methods, and relationships?',
    options: ['Use Case Diagram', 'Sequence Diagram', 'Class Diagram', 'Activity Diagram'],
    correctIndex: 2,
    category: 'Software Engineering',
    difficulty: 'easy',
    explanation: 'Class diagrams depict static structure and object blueprints.'
  },
  {
    id: 'oop_q40',
    text: 'Which design pattern acts as a wrapper that translates one interface into another expected format?',
    options: ['Decorator Pattern', 'Adapter Pattern', 'Singleton Pattern', 'Facade Pattern'],
    correctIndex: 1,
    category: 'Software Engineering',
    difficulty: 'medium',
    explanation: 'Adapter pattern links classes with incompatible interfaces by adapting calls.'
  }
];

// Helper to resolve user config access token from firebase-tools.json
function getAccessToken() {
  try {
    const configPath = path.join(
      process.env.USERPROFILE || process.env.HOME || '',
      '.config',
      'configstore',
      'firebase-tools.json'
    );
    if (!fs.existsSync(configPath)) {
      throw new Error(`Firebase config not found at: ${configPath}`);
    }

    const data = JSON.parse(fs.readFileSync(configPath, 'utf8'));
    if (!data.tokens || !data.tokens.access_token) {
      throw new Error('Access token missing in firebase-tools.json. Please run firebase login first.');
    }
    return data.tokens.access_token;
  } catch (err) {
    console.error('Error fetching access token:', err.message);
    process.exit(1);
  }
}

// REST batch commit calls to Firestore REST API
async function uploadToFirestore() {
  const projectId = 'quizapps12';
  const accessToken = getAccessToken();
  const commitUrl = `https://firestore.googleapis.com/v1/projects/${projectId}/databases/(default)/documents:commit`;

  // Segment questions into batches of 50 to fit commit limits
  const batchSize = 50;
  const batchesCount = Math.ceil(questions.length / batchSize);

  console.log(`Starting upload of ${questions.length} questions to Firestore project '${projectId}'...`);

  for (let i = 0; i < batchesCount; i++) {
    const start = i * batchSize;
    const end = Math.min(start + batchSize, questions.length);
    const subset = questions.slice(start, end);

    // Build the writes commit payload
    const writes = subset.map((q) => {
      return {
        update: {
          name: `projects/${projectId}/databases/(default)/documents/questions/${q.id}`,
          fields: {
            id: { stringValue: q.id },
            text: { stringValue: q.text },
            options: {
              arrayValue: {
                values: q.options.map((opt) => ({ stringValue: opt }))
              }
            },
            correctIndex: { integerValue: String(q.correctIndex) },
            category: { stringValue: q.category },
            difficulty: { stringValue: q.difficulty },
            explanation: { stringValue: q.explanation }
          }
        }
      };
    });

    const payload = JSON.stringify({ writes });

    try {
      const response = await fetch(commitUrl, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${accessToken}`,
          'Content-Type': 'application/json'
        },
        body: payload
      });

      const data = await response.json();
      if (!response.ok) {
        throw new Error(data.error ? data.error.message : 'Unknown REST commit error');
      }

      console.log(`[Batch ${i + 1}/${batchesCount}] Uploaded questions ${start + 1} to ${end} successfully.`);
    } catch (err) {
      console.error(`[Batch ${i + 1}/${batchesCount}] Failed to upload:`, err.message);
      process.exit(1);
    }
  }

  console.log('All 200 questions successfully uploaded to Firestore!');
}

uploadToFirestore();
