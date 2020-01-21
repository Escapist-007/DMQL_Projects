CREATE DATABASE TinyHub;
USE TinyHub;

CREATE TABLE DEPARTMENT(
     Department_number INT NOT NULL,
     Dname VARCHAR(45) NULL,
     PRIMARY KEY (Department_number)
);

CREATE TABLE STUDENT (
    Username VARCHAR(45) NOT NULL,
    Password VARCHAR(45) NOT NULL,
    Display_name VARCHAR(45) NOT NULL,
    Dept_ID INT NOT NULL,

    PRIMARY KEY (Username),
    UNIQUE KEY Display_name_UNIQUE (Display_name),

    CONSTRAINT fk_std_dept FOREIGN KEY (Dept_ID) REFERENCES DEPARTMENT (Department_number)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

CREATE TABLE PROFESSOR (
    Username VARCHAR(45) NOT NULL,
    Password VARCHAR(45) NOT NULL,
    Display_name VARCHAR(45) NOT NULL,
    Designation VARCHAR(45),
    Dept_ID INT NOT NULL,

    PRIMARY KEY (Username),
    UNIQUE KEY Display_name_UNIQUE (Display_name),

    CONSTRAINT fk_prof_dept FOREIGN KEY (Dept_ID) REFERENCES DEPARTMENT (Department_number)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

CREATE TABLE STAFF (
    Username VARCHAR(45) NOT NULL,
    Password VARCHAR(45) NOT NULL,
    Display_name VARCHAR(45) NOT NULL,
    Designation VARCHAR(45),
    Dept_ID INT NOT NULL,

    PRIMARY KEY (Username),
    UNIQUE KEY Display_name_UNIQUE (Display_name),

    CONSTRAINT fk_staff_dept FOREIGN KEY (Dept_ID) REFERENCES DEPARTMENT (Department_number)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

CREATE TABLE MAJORS_IN (
    Susername VARCHAR(45) NOT NULL,
    Dept_ID INT NOT NULL,
    Since INT NOT NULL,

    PRIMARY KEY (Susername,Dept_ID),

    CONSTRAINT major_dept FOREIGN KEY (Dept_ID) REFERENCES DEPARTMENT (Department_number)
    ON DELETE CASCADE
    ON UPDATE CASCADE,

    CONSTRAINT major_username FOREIGN KEY (Susername) REFERENCES STUDENT (Username)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);


CREATE TABLE COURSE (
    Course_no INT NOT NULL,
    Cname VARCHAR(45),
    Credit_hours INT,
    Dept_ID INT NOT NULL,

    PRIMARY KEY (Course_no),

    CONSTRAINT course_dept FOREIGN KEY (Dept_ID) REFERENCES DEPARTMENT (Department_number)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

CREATE TABLE COURSE_PREREQUISITE (
    Main_course_no INT,
    Prerequisite_course_no INT,

    PRIMARY KEY (Main_course_no, Prerequisite_course_no),

    CONSTRAINT main_course FOREIGN KEY (Main_course_no) REFERENCES COURSE (Course_no)
    ON DELETE CASCADE
    ON UPDATE CASCADE,

    CONSTRAINT pre_course FOREIGN KEY (Prerequisite_course_no) REFERENCES COURSE (Course_no)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

CREATE TABLE QUARTER (
    QID INT NOT NULL,
    Year INT,
    Semester VARCHAR(45),

    PRIMARY KEY (QID),
    UNIQUE KEY year_sem_unique (Year, Semester)
);

CREATE TABLE COURSE_OFFERING (
    Course_no INT NOT NULL,
    QID INT NOT NULL,
    Time VARCHAR(45),
    Room INT,
    Capacity INT,
    Instructor VARCHAR(45) NOT NULL,
    Created_by VARCHAR(45) NOT NULL,

    PRIMARY KEY (Course_no,QID),

    CONSTRAINT offering_course FOREIGN KEY (Course_no) REFERENCES COURSE(Course_no)
    ON DELETE CASCADE
    ON UPDATE CASCADE,

    CONSTRAINT offering_quarter FOREIGN KEY (QID) REFERENCES QUARTER(QID)
    ON DELETE CASCADE
    ON UPDATE CASCADE,

    CONSTRAINT offering_instructor FOREIGN KEY (Instructor) REFERENCES PROFESSOR(Username)
    ON DELETE CASCADE
    ON UPDATE CASCADE,

    CONSTRAINT offering_staff FOREIGN KEY (Created_by) REFERENCES STAFF(Username)
    ON DELETE CASCADE
    ON UPDATE CASCADE

);

CREATE TABLE STUDENT_ENROLLEMNT (
    SID VARCHAR(45) NOT NULL,
    Course_no INT NOT NULL,
    QID INT NOT NULL,
    Grade VARCHAR(45) NOT NULL,

    PRIMARY KEY (SID, Course_no, QID),

    CONSTRAINT enroll_std FOREIGN KEY (SID) REFERENCES  STUDENT(Username)
    ON DELETE CASCADE
    ON UPDATE CASCADE,

    CONSTRAINT enroll_course FOREIGN KEY (Course_no, QID) REFERENCES  COURSE_OFFERING (Course_no, QID)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);


CREATE TABLE EXAM (
    ExamID INT AUTO_INCREMENT,
    Course_no INT NOT NULL,
    QID INT NOT NULL,
    Ename VARCHAR(45) NOT NULL,
    Description VARCHAR(45) NOT NULL,
    Date DATETIME,

    PRIMARY KEY (ExamID),

    UNIQUE KEY exam_UNIQUE (Course_no, QID, Ename),

    CONSTRAINT exam_course FOREIGN KEY (Course_no, QID) references COURSE_OFFERING (Course_no, QID)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);


CREATE TABLE EXAM_GRADE (
    ExamID INT AUTO_INCREMENT,
    Sname VARCHAR(45) NOT NULL,
    Grade VARCHAR(45) NOT NULL,

    PRIMARY KEY (ExamID, Sname),

    CONSTRAINT exam_grade FOREIGN KEY (ExamID) references EXAM(ExamID)
    ON DELETE CASCADE
    ON UPDATE CASCADE,

    CONSTRAINT exam_std FOREIGN KEY (Sname) references STUDENT(Username)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);


CREATE TABLE PROBLEM (
    PID INT AUTO_INCREMENT,
    ExamID INT,
    Pname VARCHAR(45) NOT NULL,
    Description VARCHAR(45) NOT NULL,

    PRIMARY KEY (PID),

    UNIQUE KEY problem_UNIQUE  (ExamID, Pname),

    CONSTRAINT exam_problem FOREIGN KEY (ExamID) references EXAM(ExamID)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);


CREATE TABLE PROBLEM_SCORE (
    PID INT,
    Sname VARCHAR(45),
    Score INT,

    PRIMARY KEY (PID, Sname),

    CONSTRAINT exam_problem_score FOREIGN KEY (PID) references PROBLEM (PID)
    ON DELETE CASCADE
    ON UPDATE CASCADE,

    CONSTRAINT exam_problem_student FOREIGN KEY (Sname) references STUDENT (Username)
    ON DELETE CASCADE
    ON UPDATE CASCADE

);



CREATE TABLE TA_ASSIGNMENT (
    Course_no INT,
    QID INT,
    Sname VARCHAR (45),
    Working_hours INT,

    PRIMARY KEY (Course_no, QID, Sname),

    CONSTRAINT course_ta FOREIGN KEY (Course_no, QID) references COURSE_OFFERING (Course_no, QID)
    ON DELETE CASCADE
    ON UPDATE CASCADE,

    CONSTRAINT ta_student FOREIGN KEY (Sname) references STUDENT (Username)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);



CREATE TABLE FEEDBACK_POST (
    PostID INT AUTO_INCREMENT,
    Sname VARCHAR (45),
    Course_no INT,
    QID INT,
    Time DATETIME,
    Description VARCHAR (45),

    PRIMARY KEY (PostID),

    CONSTRAINT std_enroll FOREIGN KEY (Sname, Course_no, QID) references STUDENT_ENROLLEMNT (SID, Course_no, QID)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

CREATE TABLE TA_FEEDBACK (
    PID INT,
    TAname VARCHAR (45),

    PRIMARY KEY (PID, TAname),

    CONSTRAINT feedback_ta FOREIGN KEY (PID) references FEEDBACK_POST(PostID)
    ON DELETE CASCADE
    ON UPDATE CASCADE,

    CONSTRAINT fd_ta FOREIGN KEY (TAname) references TA_ASSIGNMENT(Sname)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);


CREATE TABLE PROFESSOR_FEEDBACK (
    PID INT,
    Pname VARCHAR (45),

    PRIMARY KEY (PID, Pname),

    CONSTRAINT feedback_prof FOREIGN KEY (PID) references FEEDBACK_POST(PostID)
    ON DELETE CASCADE
    ON UPDATE CASCADE,

    CONSTRAINT fd_prof FOREIGN KEY (Pname) references Professor (Username)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);
